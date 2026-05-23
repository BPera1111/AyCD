% audit_planta_mux.m
% Audita el bloque UDP Send y su Mux fuente en planta.slx.
% Salida: simulink/audit_planta_output.txt
% Ejecutar desde VSCode MATLAB extension (botón Run en la esquina superior derecha).

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
out_path = fullfile(this_dir, 'audit_planta_output.txt');
fid = fopen(out_path, 'w');
if fid < 0
    error('No se pudo abrir %s', out_path);
end
fprintf('Output -> %s\n', out_path);

logf = @(varargin) (fprintf(fid, varargin{:}) + fprintf(varargin{:}));

logf('===== AUDIT PLANTA MUX/UDP — %s =====\n\n', datestr(now));
if params_ok
    logf('[OK] init_plant_parameters cargado\n\n');
else
    logf('[ERR] init_plant_parameters: %s\n\n', params_err);
end

MODEL = 'planta';

try
    load_system(fullfile(this_dir, 'planta.slx'));
catch ME
    logf('[ERR] No se pudo cargar planta.slx: %s\n', ME.message);
    fclose(fid);
    error(ME.message);
end

% =====================================================
% PARTE 1: Buscar todos los bloques UDP Send en planta.slx
% =====================================================
logf('========== PARTE 1: UDP Send blocks en planta.slx ==========\n\n');

all_blocks = find_system(MODEL, 'LookUnderMasks', 'all', ...
    'FollowLinks', 'on', 'Type', 'Block');

udp_send_blocks = {};
for k = 1:length(all_blocks)
    try, mt = get_param(all_blocks{k}, 'MaskType'); catch, mt = ''; end
    try, bt = get_param(all_blocks{k}, 'BlockType'); catch, bt = ''; end
    nm = get_param(all_blocks{k}, 'Name');
    combined = lower([mt ' ' bt ' ' nm]);
    if contains(combined, 'udp') && contains(combined, 'send')
        udp_send_blocks{end+1} = all_blocks{k}; %#ok<AGROW>
    end
end

logf('UDP Send blocks encontrados: %d\n', length(udp_send_blocks));
for k = 1:length(udp_send_blocks)
    blk = udp_send_blocks{k};
    logf('\nBloque: %s\n', blk);
    try, mt = get_param(blk, 'MaskType'); catch, mt = ''; end
    try, bt = get_param(blk, 'BlockType'); catch, bt = ''; end
    logf('  MaskType: %s | BlockType: %s\n', mt, bt);

    % Intentar obtener parámetros de puerto
    port_params = {'remotePort','localPort','RemoteIPPort','LocalIPPort', ...
                   'remoteURL','RemoteIPAddress'};
    for p = 1:length(port_params)
        try
            v = get_param(blk, port_params{p});
            if ~isempty(v)
                logf('  %s = %s\n', port_params{p}, num2str(v));
            end
        catch
        end
    end
    % Todos los dialog params
    try
        dialog = get_param(blk, 'DialogParameters');
        if ~isempty(dialog)
            fns = fieldnames(dialog);
            for fn = 1:length(fns)
                try
                    v = get_param(blk, fns{fn});
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

if isempty(udp_send_blocks)
    logf('\n[WARN] No se encontraron UDP Send blocks. Verificar que planta.slx tiene el bloque agregado.\n');
    logf('       Buscando por nombre (sin filtro de tipo)...\n');
    for k = 1:length(all_blocks)
        nm = get_param(all_blocks{k}, 'Name');
        if contains(lower(nm), 'udp')
            try, bt = get_param(all_blocks{k}, 'BlockType'); catch, bt = '?'; end
            logf('  Bloque con UDP en nombre: %s (%s)\n', all_blocks{k}, bt);
        end
    end
end

% =====================================================
% PARTE 2: Rastrear hacia atrás desde UDP Send hasta el Mux
% =====================================================
logf('\n\n========== PARTE 2: Mux de entrada al UDP Send ==========\n\n');

for k = 1:length(udp_send_blocks)
    blk = udp_send_blocks{k};
    logf('\n--- UDP Send: %s ---\n', blk);

    try
        ph = get_param(blk, 'PortHandles');
        if isempty(ph.Inport)
            logf('[WARN] Sin puertos de entrada\n');
            continue;
        end

        % Rastrear línea de entrada hasta encontrar Mux
        line_h = get_param(ph.Inport(1), 'Line');
        mux_blk = find_mux_source(line_h, 10);

        if isempty(mux_blk)
            logf('[WARN] No se encontró Mux fuente. Rastreo directo:\n');
            chain = trace_back(line_h, 10);
            logf('  Fuente directa: %s\n', chain);
        else
            logf('Mux encontrado: %s\n', mux_blk);
            try
                n_in = get_param(mux_blk, 'Inputs');
                logf('  Inputs: %s\n', n_in);
            catch
            end

            % Listar todas las entradas del Mux
            ph_mux = get_param(mux_blk, 'PortHandles');
            logf('\n  Señales conectadas al Mux (orden = índice en paquete UDP):\n');
            for j = 1:length(ph_mux.Inport)
                ln = get_param(ph_mux.Inport(j), 'Line');
                chain = trace_back(ln, 10);
                logf('  in[%2d] <- %s\n', j, chain);
            end
        end
    catch ME
        logf('[ERR] %s\n', ME.message);
    end
end

% =====================================================
% PARTE 3: Todos los bloques Mux en la raíz de planta.slx
% =====================================================
logf('\n\n========== PARTE 3: Todos los Mux en planta (SearchDepth=2) ==========\n\n');

try
    mux_list = find_system(MODEL, 'SearchDepth', 2, 'BlockType', 'Mux');
    logf('Mux encontrados: %d\n', length(mux_list));
    for k = 1:length(mux_list)
        logf('\nMux: %s\n', mux_list{k});
        try, logf('  Inputs: %s\n', get_param(mux_list{k}, 'Inputs')); catch, end
        ph = get_param(mux_list{k}, 'PortHandles');
        for j = 1:length(ph.Inport)
            ln = get_param(ph.Inport(j), 'Line');
            chain = trace_back(ln, 8);
            logf('  in[%2d] <- %s\n', j, chain);
        end
        % Ver hacia dónde va la salida del Mux
        for j = 1:length(ph.Outport)
            ln = get_param(ph.Outport(j), 'Line');
            if ln > 0
                try
                    dst = get_param(ln, 'DstBlockHandle');
                    if ~isempty(dst) && any(dst > 0)
                        dst_name = get_param(dst(1), 'Name');
                        dst_type = get_param(dst(1), 'BlockType');
                        logf('  out[%d] -> %s (%s)\n', j, dst_name, dst_type);
                    end
                catch
                end
            end
        end
    end
catch ME
    logf('[ERR] Mux search: %s\n', ME.message);
end

logf('\n===== FIN AUDIT =====\n');
fclose(fid);
fprintf('\n>> Output guardado en %s\n', out_path);

% =====================================================
% Helper: busca el primer Mux retrocediendo desde una línea
% =====================================================
function mux_blk = find_mux_source(line_h, max_depth)
    mux_blk = '';
    if line_h <= 0 || max_depth <= 0, return; end
    try
        src = get_param(line_h, 'SrcBlockHandle');
    catch
        return;
    end
    if src <= 0, return; end
    src_type = get_param(src, 'BlockType');
    if strcmp(src_type, 'Mux')
        mux_blk = getfullname(src);
        return;
    end
    % Seguir hacia atrás a través de bloques transparentes
    transparent = {'Delay','UnitDelay','Gain','Derivative','Integrator','Saturate', ...
                   'DataTypeConversion','Sum','Product','SignalConversion', ...
                   'SubSystem','Goto','From'};
    if any(strcmp(src_type, transparent))
        try
            sph = get_param(src, 'PortHandles');
            if ~isempty(sph.Inport)
                next_line = get_param(sph.Inport(1), 'Line');
                mux_blk = find_mux_source(next_line, max_depth - 1);
            end
        catch
        end
    end
end

% =====================================================
% Helper: rastrea hacia atrás para obtener el nombre real de la señal
% =====================================================
function s = trace_back(line_h, max_depth)
    s = '-';
    if line_h <= 0, return; end
    try
        nm = get_param(line_h, 'Name');
        if ~isempty(nm)
            s = sprintf('line[%s]', nm);
            return;
        end
    catch
    end
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
    if strcmp(src_type, 'Inport')
        s = sprintf('Inport[%s]', src_name);
        return;
    end
    if strcmp(src_type, 'Constant')
        try, v = get_param(src, 'Value'); catch, v = '?'; end
        s = sprintf('Const[%s=%s]', src_name, v);
        return;
    end
    transparent = {'Delay','UnitDelay','Gain','Derivative','Integrator','Saturate', ...
                   'DataTypeConversion','Sum','Product','SignalConversion'};
    if any(strcmp(src_type, transparent)) && max_depth > 0
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
