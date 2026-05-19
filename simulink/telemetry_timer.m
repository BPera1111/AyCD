%% telemetry_timer.m
% Telemetría EXTERNA — lee señales de nivel_1_full.slx en ejecución
% SIN modificar el modelo. Escribe C:\Temp\crane_state.json a 50 Hz.
%
% USO:
%   cd <repo>/simulink
%   run('telemetry_timer.m')
%   Luego: Open nivel_1_full.slx → presionar Play
%
% Para detener el timer:
%   stop(crane_telemetry_timer); delete(crane_telemetry_timer)
%
% El formato JSON resultante es idéntico al de add_telemetry.m.
% El backend Python (server.py) no necesita cambios.

%% Capturar ruta ANTES de init (mfilename es función, sobrevive al clear)
script_dir_pre = fileparts(mfilename('fullpath'));

%% Cargar parámetros — init hace clear; borra TODO el workspace
fprintf('Cargando parámetros...\n');
run(fullfile(script_dir_pre, 'init_plant_parameters.m'));

%% Re-definir TODAS las vars de configuración (workspace fue borrado por clear)
MODEL     = 'nivel_1_full';
JSON_FILE = 'C:\Temp\crane_state.json';
TMP_FILE  = 'C:\Temp\crane_state.tmp';
RATE_HZ   = 50;
script_dir = fileparts(mfilename('fullpath'));
model_path = fullfile(script_dir, [MODEL '.slx']);

fprintf('Cargando modelo: %s\n', model_path);
load_system(model_path);

if ~exist('C:\Temp', 'dir')
    mkdir('C:\Temp');
end

%% Descubrir handles de señales por nombre
SIGNAL_FIELDS = {'xt','yh','vt','vh','freno_c','freno_h','estado','modo','tlk','caught'};
handles = struct();

fprintf('\nDescubriendo señales en "%s"...\n', MODEL);
for k = 1:length(SIGNAL_FIELDS)
    sig  = SIGNAL_FIELDS{k};
    found = false;

    % Estrategia 1: línea con nombre → handle del bloque fuente → RuntimeObject
    lns = find_system(MODEL, 'FindAll','on', 'Type','line', 'Name',sig);
    if ~isempty(lns)
        src_blk    = get(lns(1), 'SrcBlockHandle');
        src_port_h = get(lns(1), 'SrcPortHandle');
        ph = get_param(src_blk, 'PortHandles');
        src_port = find(ph.Outport == src_port_h, 1);
        if isempty(src_port), src_port = 1; end
        handles.(sig) = struct('strategy','runtime', ...
                               'blk', src_blk, 'port', src_port, 'ws_var','');
        fprintf('  [runtime]    %s\n', sig);
        found = true;
    end

    % Estrategia 2: bloque To Workspace cuya VariableName coincide
    if ~found
        tw_blocks = find_system(MODEL, 'BlockType','ToWorkspace');
        for j = 1:length(tw_blocks)
            if strcmp(get_param(tw_blocks{j}, 'VariableName'), sig)
                handles.(sig) = struct('strategy','workspace', ...
                                       'blk',[], 'port',0, 'ws_var',sig);
                fprintf('  [workspace]  %s\n', sig);
                found = true;
                break;
            end
        end
    end

    if ~found
        handles.(sig) = struct('strategy','none','blk',[],'port',0,'ws_var','');
        fprintf('  [no hallada] %s  (escribe 0 — conectar señal o renombrarla)\n', sig);
    end
end

%% Detener timer previo si existe
if evalin('base', 'exist(''crane_telemetry_timer'',''var'')')
    t_old = evalin('base', 'crane_telemetry_timer');
    try, stop(t_old); delete(t_old); catch, end
end

%% Estado inicial guardado en UserData (el timer es handle — persiste entre ticks)
last_state = struct('xt',0,'yh',20,'vt',0,'vh',0, ...
                    'freno_c',1,'freno_h',1,'estado',0, ...
                    'modo',0,'tlk',0,'caught',0);

ud = struct('model',   MODEL, ...
            'handles', handles, ...
            'json',    JSON_FILE, ...
            'tmp',     TMP_FILE, ...
            'last',    last_state);

%% Crear y arrancar el timer
t = timer('Name',          'CraneTelemetry', ...
          'ExecutionMode', 'fixedRate', ...
          'Period',        1/RATE_HZ, ...
          'UserData',      ud, ...
          'TimerFcn',      @crane_timer_cb, ...
          'ErrorFcn',      @(o,e) fprintf('[telemetry] Error en timer: %s\n', ...
                                          e.Data.message));
start(t);
assignin('base', 'crane_telemetry_timer', t);

fprintf('\nTimer iniciado a %d Hz.\n', RATE_HZ);
fprintf('→ Presionar Play en nivel_1_full.slx para empezar telemetría.\n');
fprintf('→ Para detener: stop(crane_telemetry_timer); delete(crane_telemetry_timer)\n');
fprintf('→ Archivo JSON: %s\n', JSON_FILE);

%% ── Callback del timer ────────────────────────────────────────────────────────
function crane_timer_cb(t, ~)
    ud      = t.UserData;
    MODEL   = ud.model;
    handles = ud.handles;
    data    = ud.last;

    % Verificar si la simulación está corriendo
    try
        sim_status = get_param(MODEL, 'SimulationStatus');
        is_running = any(strcmp(sim_status, {'running','paused'}));
    catch
        return;
    end

    % Leer señales solo si la simulación está activa
    if is_running
        FIELDS = fieldnames(handles);
        for k = 1:length(FIELDS)
            sig = FIELDS{k};
            h   = handles.(sig);
            try
                switch h.strategy
                    case 'runtime'
                        ro = get_param(h.blk, 'RuntimeObject');
                        if ~isempty(ro)
                            data.(sig) = double(ro.OutputPort(h.port).Data);
                        end
                    case 'workspace'
                        ws_val = evalin('base', h.ws_var);
                        if isa(ws_val, 'timeseries')
                            data.(sig) = double(ws_val.Data(end));
                        elseif isstruct(ws_val) && isfield(ws_val, 'Data')
                            data.(sig) = double(ws_val.Data(end));
                        end
                end
            catch
                % Mantener último valor conocido si hay error de lectura
            end
        end
        ud.last    = data;
        t.UserData = ud;
    end

    % Escritura atómica: .tmp → rename a .json (evita lectura parcial en Python)
    try
        json_str = jsonencode(data);
        fid = fopen(ud.tmp, 'w');
        if fid > 0
            fprintf(fid, '%s', json_str);
            fclose(fid);
            movefile(ud.tmp, ud.json, 'f');
        end
    catch
    end
end
