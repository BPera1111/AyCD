%% agregar_modo_auto.m
% Agrega selección de índices desde lista y MODO_AUTO simple al chart de nivel_1.slx
%
% USO:
%   1. Ejecutar init_plant_parameters.m primero (para tener i_lista en workspace)
%   2. Ejecutar este script desde la carpeta simulink/
%   3. Conectar cable manualmente si add_line falla (ver mensaje al final)
%
% FLUJO IMPLEMENTADO:
%   REPOSO --[BTN_Auto]--> SELECCION --[BTN_TLK]--> MODO_AUTO/SUBIR-->MOVER-->POSICION_MANUAL
%   SELECCION --[BTN_Reset]--> REPOSO
%   POSICION_MANUAL --[BTN_Auto]--> SELECCION (nueva misión)
%   (BTN_Reset desde cualquier estado → RECUPERACION, como antes)

clear; clc;
mdl = 'nivel_1';

%% 1. Cargar modelo
load_system(mdl);
rt = sfroot;
machine = rt.find('-isa','Stateflow.Machine','Name',mdl);
chart   = machine.find('-isa','Stateflow.Chart','Name','Chart');

automata = chart.find('-isa','Stateflow.State','Name','AUTOMATA_PRINCIPAL');
reposo   = chart.find('-isa','Stateflow.State','Name','REPOSO');

fprintf('Modelo cargado: %s\n', mdl);

%% 2. Expandir AUTOMATA_PRINCIPAL (hace lugar para SELECCION y MODO_AUTO abajo)
automata.Position = [20, 124, 1401, 1380];
fprintf('AUTOMATA_PRINCIPAL expandido.\n');

%% 3. Parámetro i_lista (hereda valor del workspace)
d = Stateflow.Data(chart);
d.Name  = 'i_lista';
d.Scope = 'PARAMETER_DATA';
fprintf('Dato i_lista agregado como PARAMETER.\n');

%% 4. Entrada BTN_Auto (port 15 del chart)
d = Stateflow.Data(chart);
d.Name  = 'BTN_Auto';
d.Scope = 'INPUT_DATA';
d.Port  = 15;
fprintf('Entrada BTN_Auto agregada (port 15).\n');

%% 5. Variables locales nuevas
new_locals = {
    'i_sel',          '1';
    'i_obj',          '1';
    'x_obj',          '0';
    'modo_auto',      '0';
    'modo_seleccion', '0';
    'debounce',       '0';
    'y_max_ruta',     '0';
    'y_segura',       '0';
    'err_x',          '0'
};
for k = 1:size(new_locals,1)
    d = Stateflow.Data(chart);
    d.Name  = new_locals{k,1};
    d.Scope = 'LOCAL_DATA';
    d.Props.InitialValue = new_locals{k,2};
end
fprintf('Variables locales agregadas (%d).\n', size(new_locals,1));

%% 6. Estado SELECCION
%    Posición: arriba a la izquierda de AUTOMATA_PRINCIPAL
%    El operador mueve Joy_X para ciclar la lista, BTN_TLK confirma
s_sel = Stateflow.State(automata);
s_sel.Name     = 'SELECCION';
s_sel.Position = [50, 148, 720, 240];
s_sel.LabelString = [...
    'SELECCION' newline ...
    'entry:' newline ...
    '  i_sel = 1; debounce = 0;' newline ...
    '  modo_seleccion = 1;' newline ...
    '  BRK_t_N1 = 0; BRK_h_N1 = 0;' newline ...
    '  x_obj = xt_min + (i_lista(1)-1)*Wc + Wc/2;' newline ...
    'during:' newline ...
    '  debounce = debounce + 1;' newline ...
    '  if (debounce > 25)' newline ...
    '    if (Joy_CMD_X > dead_zone)' newline ...
    '      i_sel = mod(i_sel, length(i_lista)) + 1;' newline ...
    '      debounce = 0;' newline ...
    '    elseif (Joy_CMD_X < -dead_zone)' newline ...
    '      i_sel = mod(i_sel-2, length(i_lista)) + 1;' newline ...
    '      debounce = 0;' newline ...
    '    end' newline ...
    '  end' newline ...
    '  x_obj = xt_min + (i_lista(i_sel)-1)*Wc + Wc/2;' newline ...
    'exit:' newline ...
    '  i_obj = i_lista(i_sel);' newline ...
    '  modo_seleccion = 0;'];
fprintf('Estado SELECCION creado.\n');

%% 7. Estado MODO_AUTO (padre de SUBIR, MOVER, POSICION_MANUAL)
s_auto = Stateflow.State(automata);
s_auto.Name     = 'MODO_AUTO';
s_auto.Position = [50, 1020, 1370, 450];
s_auto.LabelString = [...
    'MODO_AUTO' newline ...
    'entry:' newline ...
    '  modo_auto = 1;' newline ...
    '  BRK_t_N1 = 1; BRK_h_N1 = 1;' newline ...
    'exit:' newline ...
    '  modo_auto = 0;'];

% ── Sub-estado SUBIR ──────────────────────────────────────────────────────────
%    Sube automáticamente hasta y_segura (max del perfil en la ruta + margen)
s_sub = Stateflow.State(s_auto);
s_sub.Name     = 'SUBIR';
s_sub.Position = [70, 1110, 360, 320];
s_sub.LabelString = [...
    'SUBIR' newline ...
    'entry:' newline ...
    '  y_max_ruta = 0;' newline ...
    '  for k = min(i_carro,i_obj):max(i_carro,i_obj)' newline ...
    '    if yc0_vec(k) > y_max_ruta' newline ...
    '      y_max_ruta = yc0_vec(k);' newline ...
    '    end' newline ...
    '  end' newline ...
    '  y_segura = min(y_max_ruta + Hc + 1.0, yh_max - 1.0);' newline ...
    'during:' newline ...
    '  vx_target = 0;' newline ...
    '  vy_target = vh_lim;'];

% ── Sub-estado MOVER ──────────────────────────────────────────────────────────
%    Control proporcional de posición horizontal hacia x_obj
s_mov = Stateflow.State(s_auto);
s_mov.Name     = 'MOVER';
s_mov.Position = [470, 1110, 360, 320];
s_mov.LabelString = [...
    'MOVER' newline ...
    'entry:' newline ...
    '  x_obj = xt_min + (i_obj-1)*Wc + Wc/2;' newline ...
    'during:' newline ...
    '  err_x = x_obj - xt_enc;' newline ...
    '  vx_target = max(-vt_max, min(vt_max, 3.0*err_x));' newline ...
    '  vy_target = 0;'];

% ── Sub-estado POSICION_MANUAL ────────────────────────────────────────────────
%    Posicionamiento fino: Joy_X muy reducido, Joy_Y libre para bajar/subir
%    El operador opera los twistlocks con BTN_TLK
s_pos = Stateflow.State(s_auto);
s_pos.Name     = 'POSICION_MANUAL';
s_pos.Position = [870, 1110, 360, 320];
s_pos.LabelString = [...
    'POSICION_MANUAL' newline ...
    'entry: modo_auto = 0;' newline ...
    'during:' newline ...
    '  if (abs(Joy_CMD_X) < dead_zone)' newline ...
    '    vx_target = 0;' newline ...
    '  else' newline ...
    '    vx_target = Joy_CMD_X * vt_max * 0.05;' newline ...
    '  end' newline ...
    '  if (abs(Joy_CMD_Y) < dead_zone)' newline ...
    '    vy_target = 0;' newline ...
    '  else' newline ...
    '    vy_target = Joy_CMD_Y * vh_lim;' newline ...
    '  end'];

fprintf('Estado MODO_AUTO y sub-estados creados.\n');

%% 8. Transiciones internas de MODO_AUTO

% Default → SUBIR
t = Stateflow.Transition(s_auto);
t.Destination      = s_sub;
t.DestinationOClock = 12;

% SUBIR → MOVER: cuando alcanzó altura segura y frenó
t = Stateflow.Transition(s_auto);
t.Source      = s_sub;
t.Destination = s_mov;
t.LabelString = '[yh_enc >= y_segura && abs(vh_obs) < 0.1]';
t.SourceOClock      = 3;
t.DestinationOClock = 9;

% MOVER → POSICION_MANUAL: cuando llegó a la columna objetivo y frenó
t = Stateflow.Transition(s_auto);
t.Source      = s_mov;
t.Destination = s_pos;
t.LabelString = '[abs(xt_enc - x_obj) < 0.15 && abs(vt_obs) < 0.1]';
t.SourceOClock      = 3;
t.DestinationOClock = 9;

fprintf('Transiciones internas de MODO_AUTO creadas.\n');

%% 9. Transiciones en AUTOMATA_PRINCIPAL

% REPOSO → SELECCION
t = Stateflow.Transition(automata);
t.Source      = reposo;
t.Destination = s_sel;
t.LabelString = '[BTN_Auto == 1]';
t.SourceOClock      = 9;
t.DestinationOClock = 3;

% SELECCION → MODO_AUTO (confirmar con BTN_TLK)
t = Stateflow.Transition(automata);
t.Source      = s_sel;
t.Destination = s_auto;
t.LabelString = '[BTN_TLK == 1]';
t.SourceOClock      = 6;
t.DestinationOClock = 12;

% SELECCION → REPOSO (cancelar con BTN_Reset)
t = Stateflow.Transition(automata);
t.Source      = s_sel;
t.Destination = reposo;
t.LabelString = '[BTN_Reset == 1]';
t.SourceOClock      = 12;
t.DestinationOClock = 12;

% POSICION_MANUAL → SELECCION (nueva misión con BTN_Auto)
t = Stateflow.Transition(automata);
t.Source      = s_pos;
t.Destination = s_sel;
t.LabelString = '[BTN_Auto == 1]';

fprintf('Transiciones en AUTOMATA_PRINCIPAL creadas.\n');

%% 10. Proteger TWISTLOCKS: VACIO→CERRANDO no dispara durante selección
%     Agrega && modo_seleccion == 0 a la condición existente
all_trans = chart.find('-isa','Stateflow.Transition');
for k = 1:length(all_trans)
    tr = all_trans(k);
    if ~isempty(tr.Source) && isa(tr.Source,'Stateflow.State') && ...
       strcmp(tr.Source.Name,'VACIO') && ...
       ~isempty(tr.Destination) && isa(tr.Destination,'Stateflow.State') && ...
       strcmp(tr.Destination.Name,'CERRANDO_TLK')
        old_lbl = tr.LabelString;
        % Reemplaza el cierre de corchete al final
        new_lbl = strrep(old_lbl, 'hay_cont == 1]', ...
                                   'hay_cont == 1 && modo_seleccion == 0]');
        tr.LabelString = new_lbl;
        fprintf('Transicion VACIO->CERRANDO_TLK actualizada.\n');
    end
end

%% 11. Conectar BTN_Auto en diagrama Simulink raíz
%     Control Joystick puerto 5 (X/BTN_AUTO) → Chart puerto 15 (BTN_Auto)
try
    add_line(mdl, 'Control Joystick /5', 'Chart/15', 'autorouting', 'on');
    fprintf('Cable BTN_Auto conectado automaticamente.\n');
catch e
    fprintf(['AVISO: Conectar manualmente en Simulink:\n'...
             '  "Control Joystick " puerto 5  →  "Chart" puerto 15\n'...
             '  Error: %s\n'], e.message);
end

%% 12. Guardar
save_system(mdl);
fprintf('\n=== LISTO ===\n');
fprintf('nivel_1.slx guardado.\n');
fprintf('Asegurarse de que i_lista este en el workspace (ejecutar init_plant_parameters.m).\n');
