%% discover_signals.m
% Abre nivel_1_full.slx y lista señales y bloques de salida disponibles.
% Ejecutar en MATLAB para conocer los nombres exactos antes de add_telemetry.m.

script_dir_pre = fileparts(mfilename('fullpath'));

fprintf('=== Cargando parámetros ===\n');
run(fullfile(script_dir_pre, 'init_plant_parameters.m'));

% Re-definir vars borradas por clear en init
model      = 'nivel_1_full';
model_path = fullfile(fileparts(mfilename('fullpath')), [model '.slx']);

fprintf('\n=== Cargando modelo: %s ===\n', model_path);
load_system(model_path);

fprintf('\n--- Outports del modelo raíz ---\n');
outports = find_system(model, 'SearchDepth', 1, 'BlockType', 'Outport');
for i = 1:length(outports)
    pn = get_param(outports{i}, 'PortNumber');
    fprintf('  Outport[%s]: %s\n', pn, outports{i});
end

fprintf('\n--- Señales con nombre (SignalName ~= "") ---\n');
all_lines = find_system(model, 'FindAll', 'on', 'Type', 'line');
named = 0;
for i = 1:length(all_lines)
    name = get(all_lines(i), 'Name');
    if ~isempty(name)
        src = get(all_lines(i), 'SrcBlockHandle');
        try
            src_name = get_param(src, 'Name');
        catch
            src_name = '?';
        end
        fprintf('  Señal "%s"  (desde bloque: %s)\n', name, src_name);
        named = named + 1;
        if named > 60
            fprintf('  ... (truncado, más de 60 señales nombradas)\n');
            break;
        end
    end
end
if named == 0
    fprintf('  (ninguna señal nombrada encontrada)\n');
end

fprintf('\n--- Bloques To Workspace ---\n');
to_ws = find_system(model, 'BlockType', 'ToWorkspace');
for i = 1:length(to_ws)
    vn = get_param(to_ws{i}, 'VariableName');
    fprintf('  ToWorkspace: %s  →  workspace var "%s"\n', to_ws{i}, vn);
end
if isempty(to_ws)
    fprintf('  (ninguno)\n');
end

fprintf('\n--- Bloques Stateflow (Chart) ---\n');
charts = find_system(model, 'BlockType', 'SubSystem');
for i = 1:length(charts)
    try
        mask = get_param(charts{i}, 'MaskType');
        if contains(charts{i}, 'Chart') || contains(mask, 'Stateflow')
            fprintf('  Chart: %s\n', charts{i});
            op = get_param(charts{i}, 'PortHandles');
            fprintf('    Outports: %d\n', length(op.Outport));
        end
    catch
    end
end

fprintf('\n--- Subsistemas de primer nivel ---\n');
top_sub = find_system(model, 'SearchDepth', 1, 'BlockType', 'SubSystem');
for i = 1:length(top_sub)
    if ~strcmp(top_sub{i}, model)
        fprintf('  Subsistema: %s\n', top_sub{i});
    end
end

fprintf('\n=== Listo. Cerrando modelo. ===\n');
close_system(model, 0);
