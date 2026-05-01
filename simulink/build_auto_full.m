%% build_auto_full.m
% Construye el Modo Automático 100% (Full Auto) usando la API de Stateflow
% Crea nivel_1_full.slx desde nivel_1.slx con layout limpio y sin colisiones.

clear; clc;

%% 0. Cargar modelo
script_dir = fileparts(mfilename('fullpath'));
mdl = 'nivel_1_full';
try
    copyfile(fullfile(script_dir, 'nivel_1.slx'), fullfile(script_dir, [mdl '.slx']), 'f');
catch e
    error('No se pudo copiar nivel_1.slx. %s', e.message);
end
load_system(fullfile(script_dir, mdl));
rt = sfroot;
machine = rt.find('-isa','Stateflow.Machine','Name',mdl);
chart   = machine.find('-isa','Stateflow.Chart','Name','Chart');
automata = chart.find('-isa','Stateflow.State','Name','AUTOMATA_PRINCIPAL');
reposo   = chart.find('-isa','Stateflow.State','Name','REPOSO');

fprintf('Modelo cargado: %s\n', mdl);

%% 1. Limpiar estados viejos si existían
old_states = {'SELECCION', 'MODO_AUTO', 'MODO_AUTO_FULL', 'SEL_ORIGEN', 'SEL_DESTINO'};
for i = 1:length(old_states)
    st = automata.find('-isa','Stateflow.State','Name',old_states{i});
    if ~isempty(st)
        st.delete;
        fprintf('Estado viejo eliminado: %s\n', old_states{i});
    end
end

%% 2. Calcular Y_start para los nuevos estados
states = chart.find('-isa','Stateflow.State');
max_y_existente = 0;
for i = 1:length(states)
    p = states(i).Path;
    if contains(p, 'AUTOMATA_PRINCIPAL') && ~contains(states(i).Name, 'AUTOMATA_PRINCIPAL')
        bottom_edge = states(i).Position(2) + states(i).Position(4);
        if bottom_edge > max_y_existente
            max_y_existente = bottom_edge;
        end
    end
end
y_start = max_y_existente + 50;
fprintf('Coordenada Y inicial calculada para modo automatico: %f\n', y_start);

%% 3. Expandir AUTOMATA_PRINCIPAL (más estrecho para no colisionar)
automata.Position = [20, 124, 1250, y_start + 1100];
fprintf('AUTOMATA_PRINCIPAL expandido a Y = %f.\n', y_start + 1100);

%% 4. Agregar Variables
add_data_safe(chart, 'i_lista', 'Parameter');
add_data_safe(chart, 'BTN_Auto', 'Input', '', 15);
add_data_safe(chart, 'modo_auto', 'Local', '0');
add_data_safe(chart, 'modo_seleccion', 'Local', '0');

new_locals = {
    'i_sel',          '1';
    'i_origen',       '1';
    'i_destino',      '1';
    'x_origen',       '0';
    'x_destino',      '0';
    'x_inicio',       '0';
    'cmd_auto_tlk',   '0';
    'y_obj',          '0';
    'altura_apoyo',   '0';
    'debounce',       '0';
    'y_max_ruta',     '0';
    'y_segura_origen','0';
    'y_segura_destino','0';
    'y_segura_inicio','0';
    'err_x',          '0';
    'err_y',          '0'
};
for k = 1:size(new_locals,1)
    add_data_safe(chart, new_locals{k,1}, 'Local', new_locals{k,2});
end

%% 5. Fix yc0_vec
yc0 = chart.find('-isa', 'Stateflow.Data', 'Name', 'yc0_vec');
if ~isempty(yc0)
    yc0.Props.Array.Size = '33';
    fprintf('Corregido tamano de yc0_vec a [33]\n');
end

%% 6. Crear estados de Selección dentro de AUTOMATA_PRINCIPAL
s_sel_ori = Stateflow.State(chart);
s_sel_ori.Name = 'SEL_ORIGEN';
s_sel_ori.Position = [50, y_start, 320, 240];
s_sel_ori.LabelString = [...
    'SEL_ORIGEN' newline ...
    'entry:' newline ...
    '  i_sel = 1; debounce = 0;' newline ...
    '  x_inicio = xt_enc;' newline ...
    '  x_origen = xt_min + (i_lista(1)-1)*Wc + Wc/2;' newline ...
    'during:' newline ...
    '  debounce = debounce + 1;' newline ...
    '  if (debounce > 25)' newline ...
    '    if (Joy_CMD_X > dead_zone)' newline ...
    '      i_sel = mod(i_sel, length(i_lista)) + 1; debounce = 0;' newline ...
    '    elseif (Joy_CMD_X < -dead_zone)' newline ...
    '      i_sel = mod(i_sel-2, length(i_lista)) + 1; debounce = 0;' newline ...
    '    end' newline ...
    '  end' newline ...
    '  x_origen = xt_min + (i_lista(i_sel)-1)*Wc + Wc/2;' newline ...
    'exit:' newline ...
    '  i_origen = i_lista(i_sel);'];
% Mover al contenedor correcto
try, s_sel_ori.move(automata); catch e, fprintf('Move SEL_ORIGEN: %s\n', e.message); end
fprintf('Estado SEL_ORIGEN creado.\n');

s_sel_des = Stateflow.State(chart);
s_sel_des.Name = 'SEL_DESTINO';
s_sel_des.Position = [420, y_start, 320, 240];
s_sel_des.LabelString = [...
    'SEL_DESTINO' newline ...
    'entry:' newline ...
    '  i_sel = 1; debounce = 0;' newline ...
    '  x_destino = xt_min + (i_lista(1)-1)*Wc + Wc/2;' newline ...
    'during:' newline ...
    '  debounce = debounce + 1;' newline ...
    '  if (debounce > 25)' newline ...
    '    if (Joy_CMD_X > dead_zone)' newline ...
    '      i_sel = mod(i_sel, length(i_lista)) + 1; debounce = 0;' newline ...
    '    elseif (Joy_CMD_X < -dead_zone)' newline ...
    '      i_sel = mod(i_sel-2, length(i_lista)) + 1; debounce = 0;' newline ...
    '    end' newline ...
    '  end' newline ...
    '  x_destino = xt_min + (i_lista(i_sel)-1)*Wc + Wc/2;' newline ...
    'exit:' newline ...
    '  i_destino = i_lista(i_sel);'];
try, s_sel_des.move(automata); catch e, fprintf('Move SEL_DESTINO: %s\n', e.message); end
fprintf('Estado SEL_DESTINO creado.\n');

%% 7. Crear MODO_AUTO_FULL y sus sub-estados
y_maf = y_start + 280;
s_auto = Stateflow.State(chart);
s_auto.Name = 'MODO_AUTO_FULL';
s_auto.Position = [50, y_maf, 1100, 800];
s_auto.LabelString = [...
    'MODO_AUTO_FULL' newline ...
    'entry:' newline ...
    '  modo_auto = 1; BRK_t_N1 = 1; BRK_h_N1 = 1;' newline ...
    'exit:' newline ...
    '  modo_auto = 0;'];
try, s_auto.move(automata); catch e, fprintf('Move MODO_AUTO_FULL: %s\n', e.message); end
fprintf('Estado MODO_AUTO_FULL creado.\n');

% Posiciones relativas dentro de MODO_AUTO_FULL
y1 = y_maf + 60;
y2 = y_maf + 280;
y3 = y_maf + 500;

% FASE 1: Buscar
s_sub1 = Stateflow.State(s_auto); s_sub1.Name = 'SUBIR_INICIAL'; s_sub1.Position = [80, y1, 300, 180];
s_sub1.LabelString = ['SUBIR_INICIAL' newline 'entry:' newline ...
    '  y_max_ruta = 0;' newline ...
    '  for k = min(i_carro,i_origen):max(i_carro,i_origen)' newline ...
    '    if yc0_vec(k) > y_max_ruta, y_max_ruta = yc0_vec(k); end' newline '  end' newline ...
    '  y_segura_origen = min(y_max_ruta + Hc + 1.0, yh_max - 1.0);' newline ...
    'during: vx_target = 0; vy_target = vh_lim;'];

s_ir1 = Stateflow.State(s_auto); s_ir1.Name = 'IR_ORIGEN'; s_ir1.Position = [430, y1, 280, 180];
s_ir1.LabelString = ['IR_ORIGEN' newline 'during:' newline ...
    '  err_x = x_origen - xt_enc;' newline ...
    '  vx_target = max(-vt_max, min(vt_max, 3.0*err_x));' newline ...
    '  vy_target = 0;'];

s_baj1 = Stateflow.State(s_auto); s_baj1.Name = 'BAJAR_ORIGEN'; s_baj1.Position = [760, y1, 300, 180];
s_baj1.LabelString = ['BAJAR_ORIGEN' newline 'entry:' newline ...
    '  y_obj = yc0_vec(i_origen) + 0.5;' newline ...
    'during:' newline ...
    '  err_y = y_obj - yh_enc;' newline ...
    '  vy_target = max(-vh_lim, min(vh_lim, 3.0*err_y));' newline ...
    '  vx_target = 0;'];

s_eng = Stateflow.State(s_auto); s_eng.Name = 'ENGANCHAR'; s_eng.Position = [80, y2, 240, 180];
s_eng.LabelString = ['ENGANCHAR' newline 'entry:' newline ...
    '  vy_target = 0; cmd_auto_tlk = 1;' newline ...
    'exit: cmd_auto_tlk = 0;'];

% FASE 2: Trasladar (izquierda)
s_sub2 = Stateflow.State(s_auto); s_sub2.Name = 'SUBIR_CARGADO'; s_sub2.Position = [430, y2, 300, 180];
s_sub2.LabelString = ['SUBIR_CARGADO' newline 'entry:' newline ...
    '  y_max_ruta = 0;' newline ...
    '  for k = min(i_origen,i_destino):max(i_origen,i_destino)' newline ...
    '    if yc0_vec(k) > y_max_ruta, y_max_ruta = yc0_vec(k); end' newline '  end' newline ...
    '  y_segura_destino = min(y_max_ruta + Hc + 1.0, yh_max - 1.0);' newline ...
    'during: vx_target = 0; vy_target = vh_lim;'];

s_ir2 = Stateflow.State(s_auto); s_ir2.Name = 'IR_DESTINO'; s_ir2.Position = [760, y2, 280, 180];
s_ir2.LabelString = ['IR_DESTINO' newline 'during:' newline ...
    '  err_x = x_destino - xt_enc;' newline ...
    '  vx_target = max(-vt_max, min(vt_max, 3.0*err_x));' newline ...
    '  vy_target = 0;'];

s_baj2 = Stateflow.State(s_auto); s_baj2.Name = 'BAJAR_DESTINO'; s_baj2.Position = [80, y3, 280, 180];
s_baj2.LabelString = ['BAJAR_DESTINO' newline 'entry:' newline ...
    '  altura_apoyo = yc0_vec(i_destino) + Hc + 0.5;' newline ...
    'during:' newline ...
    '  err_y = altura_apoyo - yh_enc;' newline ...
    '  vy_target = max(-vh_lim, min(vh_lim, 3.0*err_y));' newline ...
    '  vx_target = 0;'];

s_deseng = Stateflow.State(s_auto); s_deseng.Name = 'DESENGANCHAR'; s_deseng.Position = [430, y3, 280, 180];
s_deseng.LabelString = ['DESENGANCHAR' newline 'entry:' newline ...
    '  vy_target = 0; cmd_auto_tlk = 1;' newline ...
    'exit: cmd_auto_tlk = 0;'];

% FASE 3: Volver (derecha)
s_sub3 = Stateflow.State(s_auto); s_sub3.Name = 'SUBIR_VACIO'; s_sub3.Position = [760, y3, 300, 180];
s_sub3.LabelString = ['SUBIR_VACIO' newline 'entry:' newline ...
    '  y_max_ruta = 0;' newline ...
    '  for k = min(i_destino,i_carro):max(i_destino,i_carro)' newline ...
    '    if yc0_vec(k) > y_max_ruta, y_max_ruta = yc0_vec(k); end' newline '  end' newline ...
    '  y_segura_inicio = min(y_max_ruta + Hc + 1.0, yh_max - 1.0);' newline ...
    'during: vx_target = 0; vy_target = vh_lim;'];

s_volv = Stateflow.State(s_auto); s_volv.Name = 'VOLVER_INICIO'; s_volv.Position = [80, y_maf + 720, 280, 180];
s_volv.LabelString = ['VOLVER_INICIO' newline 'during:' newline ...
    '  err_x = x_inicio - xt_enc;' newline ...
    '  vx_target = max(-vt_max, min(vt_max, 3.0*err_x));' newline ...
    '  vy_target = 0;'];

s_fin = Stateflow.State(s_auto); s_fin.Name = 'FIN_MISION'; s_fin.Position = [430, y_maf + 720, 200, 150];
s_fin.LabelString = ['FIN_MISION' newline 'entry:' newline '  vx_target = 0; vy_target = 0;'];
fprintf('Sub-estados de MODO_AUTO_FULL creados.\n');

%% 8. Transiciones Internas MODO_AUTO_FULL
% Default -> SUBIR_INICIAL
add_trans(s_auto, [], s_sub1);
add_trans(s_auto, s_sub1, s_ir1, '[yh_enc >= y_segura_origen]');
add_trans(s_auto, s_ir1, s_baj1, '[abs(xt_enc - x_origen) < 0.15 && abs(vt_obs) < 0.1]');
add_trans(s_auto, s_baj1, s_eng, '[hay_cont == 1]');
add_trans(s_auto, s_eng, s_sub2, '[TLK == 1]', 3, 9); % ENG -> SUBIR_CARGADO
add_trans(s_auto, s_sub2, s_ir2, '[yh_enc >= y_segura_destino]');
add_trans(s_auto, s_ir2, s_baj2, '[abs(xt_enc - x_destino) < 0.15 && abs(vt_obs) < 0.1]');
add_trans(s_auto, s_baj2, s_deseng, '[yh_enc <= altura_apoyo || Fhw < (Ms*g/2 * 0.8)]');
add_trans(s_auto, s_deseng, s_sub3, '[TLK == 0]', 3, 9); % DESENG -> SUBIR_VACIO
add_trans(s_auto, s_sub3, s_volv, '[yh_enc >= y_segura_inicio]');
add_trans(s_auto, s_volv, s_fin, '[abs(xt_enc - x_inicio) < 0.15]');
fprintf('Transiciones internas de MODO_AUTO_FULL creadas.\n');

%% 9. Transiciones Externas (AUTOMATA_PRINCIPAL)
add_trans(automata, reposo, s_sel_ori, '[BTN_Auto == 1]');
add_trans(automata, s_sel_ori, s_sel_des, '[BTN_TLK == 1]');
add_trans(automata, s_sel_des, s_auto, '[BTN_TLK == 1]');
add_trans(automata, s_sel_ori, reposo, '[BTN_Reset == 1]', 12, 6);
add_trans(automata, s_sel_des, reposo, '[BTN_Reset == 1]', 12, 6);
add_trans(automata, s_fin, reposo, '', 3, 6);
fprintf('Transiciones externas creadas.\n');

%% 10. Modificar TWISTLOCKS (agregar cmd_auto_tlk)
all_trans = chart.find('-isa','Stateflow.Transition');
for k = 1:length(all_trans)
    tr = all_trans(k);
    if ~isempty(tr.Source) && isa(tr.Source,'Stateflow.State') && ~isempty(tr.Destination) && isa(tr.Destination,'Stateflow.State')
        if strcmp(tr.Source.Name,'VACIO') && strcmp(tr.Destination.Name,'CERRANDO_TLK')
            tr.LabelString = strrep(tr.LabelString, 'BTN_TLK == 1', '(BTN_TLK == 1 || cmd_auto_tlk == 1)');
            fprintf('TWISTLOCKS (VACIO->CERRANDO) actualizada.\n');
        elseif strcmp(tr.Source.Name,'CARGADO') && strcmp(tr.Destination.Name,'ABRIENDO_TLK')
            tr.LabelString = strrep(tr.LabelString, 'BTN_TLK == 1', '(BTN_TLK == 1 || cmd_auto_tlk == 1)');
            fprintf('TWISTLOCKS (CARGADO->ABRIENDO) actualizada.\n');
        end
    end
end

%% 11. Conectar BTN_Auto y arreglar InputPortWidth
try
    set_param([mdl '/Control Joystick /Selector'], 'InputPortWidth', '8');
    fprintf('InputPortWidth del Selector corregido a 8.\n');
catch e, end
try
    add_line(mdl, 'Control Joystick /5', 'Chart/15', 'autorouting', 'on');
    fprintf('Cable BTN_Auto conectado.\n');
catch e, end

save_system(mdl);
fprintf('\n=== EXITO: nivel_1_full.slx MODIFICADO Y GUARDADO ===\n');
close_system(mdl, 0);

%% ===== LOCAL FUNCTIONS =====

function add_data_safe(chart, name, scope, initVal, portNum)
    if isempty(chart.find('-isa','Stateflow.Data','Name',name))
        d = Stateflow.Data(chart);
        d.Name = name;
        d.Scope = scope;
        if strcmp(scope, 'Local') && nargin >= 4
            d.Props.InitialValue = initVal;
        end
        if strcmp(scope, 'Input') && nargin >= 5
            d.Port = portNum;
        end
        fprintf('  Variable agregada: %s\n', name);
    end
end

function add_trans(parent, src, dst, lbl, srcClock, dstClock)
    t = Stateflow.Transition(parent);
    if nargin >= 5, t.SourceOClock = srcClock; else, t.SourceOClock = 3; end
    if nargin >= 6, t.DestinationOClock = dstClock; else, t.DestinationOClock = 9; end
    if isempty(src)
        t.Destination = dst;
        dp = dst.Position;
        t.SourceEndpoint = [dp(1), dp(2) - 25];
        t.MidPoint = [dp(1), dp(2) - 12];
        t.DestinationOClock = 12;
    else
        t.Source = src;
        t.Destination = dst;
        t.LabelString = lbl;
    end
end
