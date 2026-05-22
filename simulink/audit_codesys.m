% Auditoría previa para PLC CODESYS — Fase 1
% Output: simulink/audit_codesys_output.txt
% No compila (evita bug Joystick block). Usa Stateflow API + GotoTag lookup.

clc;

this_dir = fileparts(mfilename('fullpath'));
proj_root = fileparts(this_dir);
cd(proj_root);

try
    run(fullfile(this_dir, 'init_plant_parameters.m'));
    params_ok = true;
catch ME_params
    params_ok = false;
    params_err = ME_params.message;
end

this_dir = fileparts(mfilename('fullpath'));
proj_root = fileparts(this_dir);
out_path = fullfile(this_dir, 'audit_codesys_output.txt');
fid = fopen(out_path, 'w');
if fid < 0
    error('No se pudo abrir %s', out_path);
end
fprintf('Output -> %s\n', out_path);

logf = @(varargin) (fprintf(fid, varargin{:}) + fprintf(varargin{:}));

logf('===== AUDIT CODESYS — %s =====\n\n', datestr(now));
if params_ok
    logf('[OK] init_plant_parameters cargado\n\n');
else
    logf('[ERR] init_plant_parameters: %s\n\n', params_err);
end

% =====================================================
% PARTE 1: planta.slx — Stateflow data de Nivel 0 y Nivel 1
% =====================================================
logf('========== PARTE 1: planta.slx — Stateflow data ==========\n');
try
    load_system('simulink/planta.slx');
    rt = sfroot;
    charts = rt.find('-isa', 'Stateflow.Chart');
    logf('Charts encontrados: %d\n', length(charts));

    for c = 1:length(charts)
        chart_path = charts(c).Path;
        logf('\n--- Chart: %s ---\n', chart_path);
        all_data = charts(c).find('-isa', 'Stateflow.Data');

        % Filtrar por Scope: Input y Output
        for scope_name = {'Input', 'Output'}
            logf('%s data:\n', scope_name{1});
            cnt = 0;
            for d = 1:length(all_data)
                if strcmp(all_data(d).Scope, scope_name{1})
                    cnt = cnt + 1;
                    nm = all_data(d).Name;
                    sz = all_data(d).Props.Array.Size;
                    if isempty(sz), sz = '-1'; end
                    dt = all_data(d).DataType;
                    logf('  [%2d] %-25s size=%s dtype=%s\n', cnt, nm, sz, dt);
                end
            end
        end
    end
catch ME
    logf('[ERR] planta.slx: %s\n', ME.message);
    for c = 1:length(ME.cause)
        logf('  cause[%d]: %s\n', c, ME.cause{c}.message);
    end
end

% =====================================================
% PARTE 2: planta_codesys.slx — Demux/Mux con GotoTags
% =====================================================
logf('\n\n========== PARTE 2: planta_codesys.slx ==========\n');
try
    load_system('simulink/planta_codesys.slx');

    % --- UDP Blocks ---
    logf('\n--- UDP Blocks ---\n');
    all_blocks = find_system('planta_codesys', 'LookUnderMasks', 'all', ...
        'FollowLinks', 'on', 'Type', 'Block');
    for k = 1:length(all_blocks)
        try, mt = get_param(all_blocks{k}, 'MaskType'); catch, mt = ''; end
        try, bt = get_param(all_blocks{k}, 'BlockType'); catch, bt = ''; end
        nm = get_param(all_blocks{k}, 'Name');
        is_udp = contains(lower([mt ' ' bt ' ' nm]), 'udp');
        if is_udp
            logf('Block: %s\n', all_blocks{k});
            logf('  MaskType: %s | BlockType: %s\n', mt, bt);
            params_try = {'LocalIPPort','RemoteIPAddress','RemoteIPPort', ...
                'SignalDataType','OutputDataDimensions','SampleTime', ...
                'Outputs','MaxLength','ByteOrder','sampletime','localPort','remotePort'};
            for p = 1:length(params_try)
                try
                    v = get_param(all_blocks{k}, params_try{p});
                    if ~isempty(v)
                        logf('  %s = %s\n', params_try{p}, num2str(v));
                    end
                catch
                end
            end
            % Listar parámetros de dialog (todos)
            try
                dialog = get_param(all_blocks{k}, 'DialogParameters');
                if ~isempty(dialog)
                    fns = fieldnames(dialog);
                    for fn = 1:length(fns)
                        try
                            v = get_param(all_blocks{k}, fns{fn});
                            if ischar(v) && ~isempty(v)
                                logf('  [dialog] %s = %s\n', fns{fn}, v);
                            end
                        catch
                        end
                    end
                end
            catch
            end
        end
    end

    % --- Demux principal (lanes RX) ---
    logf('\n--- Demux blocks (con GotoTag de destino) ---\n');
    demux_h = find_system('planta_codesys', 'SearchDepth', 2, 'BlockType', 'Demux');
    for k = 1:length(demux_h)
        logf('\nDemux: %s\n', demux_h{k});
        try, logf('  Outputs: %s\n', get_param(demux_h{k}, 'Outputs')); catch, end
        ph = get_param(demux_h{k}, 'PortHandles');
        for j = 1:length(ph.Outport)
            line_h = get_param(ph.Outport(j), 'Line');
            dst_info = '-';
            if line_h > 0
                try
                    dst = get_param(line_h, 'DstBlockHandle');
                    if ~isempty(dst) && any(dst > 0)
                        d = dst(1);
                        dst_name = get_param(d, 'Name');
                        dst_type = get_param(d, 'BlockType');
                        % Si es Goto, tomar su GotoTag
                        if strcmp(dst_type, 'Goto')
                            try
                                tag = get_param(d, 'GotoTag');
                            catch, tag = '?'; end
                            dst_info = sprintf('Goto[%s]', tag);
                        else
                            dst_info = sprintf('%s (%s)', dst_name, dst_type);
                        end
                    end
                catch
                end
            end
            logf('  out[%2d] -> %s\n', j, dst_info);
        end
    end

    % --- Mux principal (lanes TX) — rastrea hacia atrás a través de Delay/Gain ---
    logf('\n--- Mux blocks (con rastreo hacia atrás) ---\n');
    mux_h = find_system('planta_codesys', 'SearchDepth', 2, 'BlockType', 'Mux');
    for k = 1:length(mux_h)
        logf('\nMux: %s\n', mux_h{k});
        try, logf('  Inputs: %s\n', get_param(mux_h{k}, 'Inputs')); catch, end
        ph = get_param(mux_h{k}, 'PortHandles');
        for j = 1:length(ph.Inport)
            % Rastrear hacia atrás hasta encontrar From o un Goto tag en la línea
            chain = trace_back(get_param(ph.Inport(j), 'Line'), 8);
            logf('  in[%2d] <- %s\n', j, chain);
        end
    end

catch ME
    logf('[ERR] planta_codesys.slx: %s\n', ME.message);
    for c = 1:length(ME.cause)
        logf('  cause[%d]: %s\n', c, ME.cause{c}.message);
    end
end

% --- Valores de Gain blocks en planta_codesys.slx ---
logf('\n--- Gain blocks (planta_codesys raíz) ---\n');
try
    gains = find_system('planta_codesys', 'SearchDepth', 1, 'BlockType', 'Gain');
    for g = 1:length(gains)
        nm = get_param(gains{g}, 'Name');
        gv = get_param(gains{g}, 'Gain');
        logf('  %s: Gain = %s\n', nm, gv);
    end
catch ME
    logf('[err] gains: %s\n', ME.message);
end

logf('\n===== FIN AUDIT =====\n');
fclose(fid);
fprintf('\n>> Output guardado en %s\n', out_path);

% =====================================================
% Helper: rastrea hacia atrás una línea, saltando Delay/Gain/Derivative
% para encontrar el nombre real de la señal
% =====================================================
function s = trace_back(line_h, max_depth)
    s = '-';
    if line_h <= 0, return; end
    % Primero: si la línea tiene Name no vacío
    try
        nm = get_param(line_h, 'Name');
        if ~isempty(nm)
            s = sprintf('line[%s]', nm);
            return;
        end
    catch
    end
    % Sino, ir al SrcBlock
    try
        src = get_param(line_h, 'SrcBlockHandle');
    catch
        return;
    end
    if src <= 0, return; end
    src_name = get_param(src, 'Name');
    src_type = get_param(src, 'BlockType');
    if strcmp(src_type, 'From')
        try, s = sprintf('From[%s]', get_param(src, 'GotoTag')); catch, s = 'From[?]'; end
        return;
    end
    % Bloques transparentes: seguir su Inport
    transparent = {'Delay','UnitDelay','Gain','Derivative','Integrator','Saturate', ...
                   'DataTypeConversion','Sum','Product','SignalConversion'};
    if any(strcmp(src_type, transparent)) && max_depth > 0
        % Tomar el primer puerto de entrada
        try
            sph = get_param(src, 'PortHandles');
            if ~isempty(sph.Inport)
                next_line = get_param(sph.Inport(1), 'Line');
                inner = trace_back(next_line, max_depth - 1);
                s = sprintf('%s(%s) <- %s', src_name, src_type, inner);
                return;
            end
        catch
        end
    end
    s = sprintf('%s (%s)', src_name, src_type);
end
