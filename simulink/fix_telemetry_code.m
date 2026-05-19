%% fix_telemetry_code.m
% Inyecta el código correcto en UDP_Telemetry SIN borrar conexiones.
% Ejecutar en MATLAB desde el directorio simulink/.

script_dir_pre = fileparts(mfilename('fullpath'));
fprintf('Cargando parámetros...\n');
run(fullfile(script_dir_pre, 'init_plant_parameters.m'));

MODEL_NAME = 'nivel_1_full';
BLOCK_NAME = 'UDP_Telemetry';
script_dir = fileparts(mfilename('fullpath'));
model_path = fullfile(script_dir, [MODEL_NAME '.slx']);
full_block = [MODEL_NAME '/' BLOCK_NAME];

fprintf('Cargando modelo...\n');
load_system(model_path);

%% Código correcto (sin if fid>0, sin jsonencode, sin struct dinámico)
new_script = [...
    'function write_telemetry(xt, yh, vt, vh, freno_c, freno_h, estado, modo, tlk, caught)', char(10), ...
    '%#codegen', char(10), ...
    'coder.extrinsic(''fopen'', ''fclose'', ''fprintf'');', char(10), ...
    'fid = fopen(''C:\Temp\crane_state.json'', ''w'');', char(10), ...
    'fprintf(fid, ''{"xt":%g,"yh":%g,"vt":%g,"vh":%g,"freno_c":%g,"freno_h":%g,"estado":%g,"modo":%g,"tlk":%g,"caught":%g}'', ...', char(10), ...
    '        double(xt), double(yh), double(vt), double(vh), ...', char(10), ...
    '        double(freno_c), double(freno_h), double(estado), ...', char(10), ...
    '        double(modo), double(tlk), double(caught));', char(10), ...
    'fclose(fid);', char(10) ...
];

%% Buscar EMChart del bloque por Path
rt = sfroot();
m  = rt.find('-isa', 'Simulink.BlockDiagram', 'Name', MODEL_NAME);
all_charts = m.find('-isa', 'Stateflow.EMChart');

fprintf('Charts encontrados: %d\n', numel(all_charts));
our_chart = [];
for i = 1:numel(all_charts)
    fprintf('  Chart[%d]: Path="%s"\n', i, all_charts(i).Path);
    if strcmp(all_charts(i).Path, full_block)
        our_chart = all_charts(i);
    end
end

if isempty(our_chart)
    fprintf('[ERROR] No se encontró chart con Path="%s"\n', full_block);
    fprintf('Paths disponibles listados arriba.\n');
    return;
end

%% Inyectar código
fn = our_chart.find('-isa', 'Stateflow.EMFunction');
fprintf('EMFunctions encontradas: %d\n', numel(fn));

if isempty(fn)
    fprintf('[ERROR] EMFunction vacía. El bloque necesita abrirse en GUI primero.\n');
    fprintf('Abriendo editor del bloque...\n');
    open_system(full_block);
    pause(3);
    fn = our_chart.find('-isa', 'Stateflow.EMFunction');
    fprintf('EMFunctions después de open: %d\n', numel(fn));
end

if ~isempty(fn)
    fn(1).Script = new_script;
    fprintf('\n=== CÓDIGO INYECTADO CORRECTAMENTE ===\n');
    fprintf('Script actual (primeras 2 líneas):\n');
    lines = strsplit(fn(1).Script, char(10));
    for k = 1:min(2, numel(lines))
        fprintf('  %s\n', lines{k});
    end
else
    fprintf('[ERROR] Inyección falló. Código para pegar manualmente guardado en:\n');
    fprintf('  %s\n', fullfile(script_dir, 'telemetry_code_to_paste.m'));
    return;
end

%% Guardar
save_system(MODEL_NAME);
fprintf('\nModelo guardado. Correr: sim(''%s'')\n', MODEL_NAME);
