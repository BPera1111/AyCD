%% add_telemetry.m
% Agrega un bloque de telemetría a nivel_1_full.slx que escribe el estado
% de la simulación a C:\Temp\crane_state.json a 50 Hz.
%
% Ejecutar UNA SOLA VEZ en MATLAB antes de usar el dashboard.
% El bloque usa coder.extrinsic para escribir JSON — funciona en modo normal.
%
% USO:
%   cd <repo>/simulink
%   run('add_telemetry.m')

%% Capturar ruta del script ANTES del clear (mfilename es función, sobrevive)
script_dir_pre = fileparts(mfilename('fullpath'));

%% Cargar parámetros (init_plant_parameters.m hace clear; clc; — borra workspace)
fprintf('Cargando parámetros...\n');
run(fullfile(script_dir_pre, 'init_plant_parameters.m'));

%% Re-definir TODAS las vars de configuración (workspace fue borrado por clear)
TEMP_DIR   = 'C:\Temp';
JSON_FILE  = fullfile(TEMP_DIR, 'crane_state.json');
MODEL_NAME = 'nivel_1_full';
BLOCK_NAME = 'UDP_Telemetry';
script_dir = fileparts(mfilename('fullpath'));
model_path = fullfile(script_dir, [MODEL_NAME '.slx']);

%% Crear C:\Temp si no existe
if ~exist(TEMP_DIR, 'dir')
    mkdir(TEMP_DIR);
    fprintf('Creado directorio: %s\n', TEMP_DIR);
end

fprintf('Cargando modelo: %s\n', model_path);
load_system(model_path);

%% Capturar IDs de charts existentes ANTES de tocar el modelo
rt       = sfroot();
m        = rt.find('-isa', 'Simulink.BlockDiagram', 'Name', MODEL_NAME);
pre_chts = m.find('-isa', 'Stateflow.EMChart');
pre_ids  = [pre_chts.id];   % [] si no hay charts aún

%% Verificar si el bloque ya existe
full_block = [MODEL_NAME '/' BLOCK_NAME];
if ~isempty(find_system(MODEL_NAME, 'SearchDepth', 1, 'Name', BLOCK_NAME))
    fprintf('El bloque "%s" ya existe. Eliminando para recrear...\n', BLOCK_NAME);
    delete_block(full_block);
    % Actualizar pre_ids tras el delete (el chart del bloque viejo desapareció)
    pre_chts = m.find('-isa', 'Stateflow.EMChart');
    pre_ids  = [pre_chts.id];
end

%% Encontrar posición libre en el modelo (esquina superior derecha)
all_blocks = find_system(MODEL_NAME, 'SearchDepth', 1, 'Type', 'block');
max_x = 100;
max_y = 100;
for i = 1:length(all_blocks)
    try
        pos = get_param(all_blocks{i}, 'Position');
        if pos(3) > max_x, max_x = pos(3); end
        if pos(4) > max_y, max_y = pos(4); end
    catch
    end
end
blk_pos = [max_x + 60, 30, max_x + 220, 110];

%% Agregar bloque MATLAB Function
fprintf('Agregando bloque MATLAB Function "%s"...\n', BLOCK_NAME);
add_block('simulink/User-Defined Functions/MATLAB Function', ...
          full_block, ...
          'Position', blk_pos);

%% Código de la función de telemetría
% Restricciones de codegen en MATLAB Function blocks:
%   - fid (mxArray de fopen) NO puede usarse en expresiones (if fid>0) — solo como arg extrinsic
%   - struct() con campos dinámicos no es analizable estáticamente → usar fprintf con formato
%   - jsonencode puede no estar disponible en codegen context
fcn_code = [...
'function write_telemetry(xt, yh, vt, vh, freno_c, freno_h, estado, modo, tlk, caught)\n'...
'%#codegen\n'...
'coder.extrinsic(''fopen'', ''fclose'', ''fprintf'');\n'...
'fid = fopen(''C:\Temp\crane_state.json'', ''w'');\n'...
'fprintf(fid, ''{"xt":%g,"yh":%g,"vt":%g,"vh":%g,"freno_c":%g,"freno_h":%g,"estado":%g,"modo":%g,"tlk":%g,"caught":%g}'', ...\n'...
'        double(xt), double(yh), double(vt), double(vh), ...\n'...
'        double(freno_c), double(freno_h), double(estado), ...\n'...
'        double(modo), double(tlk), double(caught));\n'...
'fclose(fid);\n'...
];

%% Inyectar código: encontrar el chart nuevo por diferencia de IDs
post_chts = m.find('-isa', 'Stateflow.EMChart');
our_chart = [];
for i = 1:numel(post_chts)
    if ~ismember(post_chts(i).id, pre_ids)
        our_chart = post_chts(i);
        break;
    end
end

script_text = strrep(fcn_code, '\n', char(10));

if ~isempty(our_chart)
    injected = false;

    % Intento 1: API alto nivel — Stateflow.EMFunction
    fn = our_chart.find('-isa', 'Stateflow.EMFunction');
    if isempty(fn)
        open_system(full_block); pause(2);
        fn = our_chart.find('-isa', 'Stateflow.EMFunction');
    end
    if ~isempty(fn)
        fn(1).Script = script_text;
        fprintf('Código configurado (API alto nivel).\n');
        injected = true;
    end

    % Intento 2: sf() API bajo nivel
    if ~injected
        try
            chart_id = our_chart.id;
            fn_ids   = sf('get', chart_id, '.fns');
            if ~isempty(fn_ids)
                sf('set', fn_ids(1), '.script', script_text);
                fprintf('Código configurado (sf API bajo nivel).\n');
                injected = true;
            end
        catch e2
            fprintf('[INFO] sf() API: %s\n', e2.message);
        end
    end

    % Fallback: guardar código en archivo para pegado manual
    if ~injected
        paste_file = fullfile(script_dir, 'telemetry_code_to_paste.m');
        fid2 = fopen(paste_file, 'w');
        fprintf(fid2, '%s', script_text);
        fclose(fid2);
        fprintf('\n[ACCION REQUERIDA] Inyección automática falló.\n');
        fprintf('  1. Doble-click en bloque UDP_Telemetry en Simulink\n');
        fprintf('  2. Ctrl+A para seleccionar todo el código default\n');
        fprintf('  3. Borrar y pegar el contenido de:\n');
        fprintf('     %s\n', paste_file);
        fprintf('  4. Guardar (Ctrl+S en el editor)\n');
    end
else
    fprintf('[WARN] Chart no encontrado. Diagnóstico:\n');
    post_ids = arrayfun(@(c) c.id, post_chts);
    fprintf('  pre_ids:  %s\n', mat2str(pre_ids));
    fprintf('  post_ids: %s\n', mat2str(post_ids));
end

%% Sample time: el bloque MATLAB Function hereda del input por defecto.
% Cuando conectes señales que corren a Ts1, automáticamente correrá a Ts1.
% Si necesitás forzarlo, en Simulink GUI: doble click en el bloque →
%   Edit Data → seleccionar input → Properties → Sample time = Ts1.

%% Intentar conectar señales conocidas
% Buscar señales de salida de subsistemas clave
fprintf('\nBuscando señales para conectar al bloque de telemetría...\n');

% Listar outports del modelo
outports = find_system(MODEL_NAME, 'SearchDepth', 1, 'BlockType', 'Outport');
fprintf('Outports disponibles en el modelo raíz: %d\n', length(outports));
for i = 1:length(outports)
    fprintf('  [%d] %s\n', i, outports{i});
end

fprintf('\nSEÑALES PENDIENTES DE CONECTAR MANUALMENTE.\n');
fprintf('El bloque "%s" fue agregado en posición [%d %d %d %d].\n', ...
        BLOCK_NAME, blk_pos(1), blk_pos(2), blk_pos(3), blk_pos(4));
fprintf('\nPara conectar manualmente en Simulink:\n');
fprintf('  1. Abrir nivel_1_full.slx\n');
fprintf('  2. Localizar el bloque "%s"\n', BLOCK_NAME);
fprintf('  3. Conectar las señales: xt, yh, vt, vh, freno_c, freno_h, estado, modo, tlk, caught\n');
fprintf('  4. Guardar el modelo\n');
fprintf('\nSi las señales no son visibles como líneas nombradas, ejecutar:\n');
fprintf('  run(''discover_signals.m'')\n');
fprintf('para ver qué hay disponible.\n');

%% Guardar modelo
save_system(MODEL_NAME);
fprintf('\nModelo guardado: %s\n', model_path);
fprintf('=== add_telemetry.m completado ===\n');
fprintf('Archivo de telemetría: %s\n', JSON_FILE);
fprintf('El dashboard Python leerá este archivo a 50 Hz.\n');
