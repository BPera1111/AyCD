% Audit complementario: compila planta.slx forzando para sacar dims propagadas
% Workaround del bug Joystick: deshabilitamos temporalmente Control Joystick

clc;
this_dir = fileparts(mfilename('fullpath'));
proj_root = fileparts(this_dir);
cd(proj_root);

try
    run(fullfile(this_dir, 'init_plant_parameters.m'));
catch
end

this_dir = fileparts(mfilename('fullpath'));
proj_root = fileparts(this_dir);
out_path = fullfile(this_dir, 'audit_dims_output.txt');
fid = fopen(out_path, 'w');
logf = @(varargin) (fprintf(fid, varargin{:}) + fprintf(varargin{:}));

logf('===== AUDIT DIMS — %s =====\n\n', datestr(now));

% --- Cargar planta.slx y comentar el Control Joystick ---
mdl = 'planta';
load_system('simulink/planta.slx');

% Comentar (deshabilitar) bloques que rompen el compile
% Buscar bloques cuyo nombre empiece con "Control Joystick" (puede tener espacio final)
all_subs = find_system(mdl, 'SearchDepth', 1, 'BlockType', 'SubSystem');
joy_blocks = {};
for ii = 1:length(all_subs)
    nm = get_param(all_subs{ii}, 'Name');
    if startsWith(strtrim(nm), 'Control Joystick')
        joy_blocks{end+1} = all_subs{ii}; %#ok<SAGROW>
    end
end
for k = 1:length(joy_blocks)
    try
        orig_state = get_param(joy_blocks{k}, 'Commented');
        set_param(joy_blocks{k}, 'Commented', 'on');
        logf('[OK] Comentado: %s (orig=%s)\n', joy_blocks{k}, orig_state);
    catch ME
        logf('[ERR] no se pudo comentar %s: %s\n', joy_blocks{k}, ME.message);
    end
end

% Intentar compile
compiled = false;
try
    set_param(mdl, 'SimulationCommand', 'update');
    compiled = true;
    logf('[OK] Modelo compilado\n');
catch ME
    logf('[ERR] compile falló: %s\n', ME.message);
    for c = 1:length(ME.cause)
        logf('  cause[%d]: %s\n', c, ME.cause{c}.message);
    end
end

% Si compiló, sacar dims propagadas de Nivel 0 y Nivel 1
if compiled
    for nivel = {'Nivel 0', 'Nivel 1'}
        bloque = [mdl '/' nivel{1}];
        logf('\n--- %s (compiled) ---\n', bloque);
        try
            ph = get_param(bloque, 'PortHandles');
            logf('INPUTS:\n');
            for k = 1:length(ph.Inport)
                try
                    dims = get_param(ph.Inport(k), 'CompiledPortDimensions');
                    dtype = get_param(ph.Inport(k), 'CompiledPortDataType');
                    logf('  in[%2d] dims=%s dtype=%s\n', k, mat2str(dims), dtype);
                catch ME2
                    logf('  in[%2d] [err: %s]\n', k, ME2.message);
                end
            end
            logf('OUTPUTS:\n');
            for k = 1:length(ph.Outport)
                try
                    dims = get_param(ph.Outport(k), 'CompiledPortDimensions');
                    dtype = get_param(ph.Outport(k), 'CompiledPortDataType');
                    logf('  out[%2d] dims=%s dtype=%s\n', k, mat2str(dims), dtype);
                catch ME2
                    logf('  out[%2d] [err: %s]\n', k, ME2.message);
                end
            end
        catch ME
            logf('[ERR] %s: %s\n', bloque, ME.message);
        end
    end
end

% Restaurar
try
    set_param(mdl, 'SimulationCommand', 'term');
catch
end
for k = 1:length(joy_blocks)
    try, set_param(joy_blocks{k}, 'Commented', 'off'); catch, end
end

% --- planta_codesys.slx: dims propagadas de Demux/Mux ---
mdl2 = 'planta_codesys';
load_system('simulink/planta_codesys.slx');
all_subs2 = find_system(mdl2, 'SearchDepth', 1, 'BlockType', 'SubSystem');
joy_blocks2 = {};
for ii = 1:length(all_subs2)
    nm = get_param(all_subs2{ii}, 'Name');
    if startsWith(strtrim(nm), 'Control Joystick')
        joy_blocks2{end+1} = all_subs2{ii}; %#ok<SAGROW>
    end
end
for k = 1:length(joy_blocks2)
    try, set_param(joy_blocks2{k}, 'Commented', 'on'); catch, end
end

compiled2 = false;
try
    set_param(mdl2, 'SimulationCommand', 'update');
    compiled2 = true;
    logf('\n[OK] planta_codesys compilado\n');
catch ME
    logf('\n[ERR] compile planta_codesys: %s\n', ME.message);
    for c = 1:length(ME.cause)
        logf('  cause[%d]: %s\n', c, ME.cause{c}.message);
    end
end

if compiled2
    % Demux principal — dims por lane
    logf('\n--- Demux principal (PLC -> Sim, 104 doubles) ---\n');
    demux_h = find_system(mdl2, 'SearchDepth', 1, 'BlockType', 'Demux');
    for k = 1:length(demux_h)
        if ~contains(demux_h{k}, 'Joystick')
            logf('Demux: %s\n', demux_h{k});
            ph = get_param(demux_h{k}, 'PortHandles');
            total = 0;
            for j = 1:length(ph.Outport)
                try
                    dims = get_param(ph.Outport(j), 'CompiledPortDimensions');
                    dst_h = get_param(get_param(ph.Outport(j), 'Line'), 'DstBlockHandle');
                    tag = '?';
                    if any(dst_h > 0)
                        d = dst_h(1);
                        if strcmp(get_param(d, 'BlockType'), 'Goto')
                            tag = get_param(d, 'GotoTag');
                        end
                    end
                    sz = prod(dims(dims > 0));
                    total = total + sz;
                    logf('  out[%2d] tag=%-20s dims=%s size=%d\n', j, tag, mat2str(dims), sz);
                catch ME2
                    logf('  out[%2d] [err: %s]\n', j, ME2.message);
                end
            end
            logf('  TOTAL elementos: %d\n', total);
        end
    end

    % Mux principal — dims por lane
    logf('\n--- Mux principal (Sim -> PLC) ---\n');
    mux_h = find_system(mdl2, 'SearchDepth', 1, 'BlockType', 'Mux');
    for k = 1:length(mux_h)
        if ~contains(mux_h{k}, 'Joystick')
            logf('Mux: %s\n', mux_h{k});
            ph = get_param(mux_h{k}, 'PortHandles');
            total = 0;
            for j = 1:length(ph.Inport)
                try
                    dims = get_param(ph.Inport(j), 'CompiledPortDimensions');
                    src_h = get_param(get_param(ph.Inport(j), 'Line'), 'SrcBlockHandle');
                    tag = '?';
                    if src_h > 0
                        if strcmp(get_param(src_h, 'BlockType'), 'From')
                            tag = get_param(src_h, 'GotoTag');
                        else
                            tag = get_param(src_h, 'Name');
                        end
                    end
                    sz = prod(dims(dims > 0));
                    total = total + sz;
                    logf('  in[%2d] tag=%-20s dims=%s size=%d\n', j, tag, mat2str(dims), sz);
                catch ME2
                    logf('  in[%2d] [err: %s]\n', j, ME2.message);
                end
            end
            logf('  TOTAL elementos: %d\n', total);
        end
    end
end

% Restaurar
try, set_param(mdl2, 'SimulationCommand', 'term'); catch, end
for k = 1:length(joy_blocks2)
    try, set_param(joy_blocks2{k}, 'Commented', 'off'); catch, end
end

logf('\n===== FIN =====\n');
fclose(fid);
fprintf('\n>> %s\n', out_path);
