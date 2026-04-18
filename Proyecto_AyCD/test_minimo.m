%% Test mínimo diagnóstico - usa parámetros del init sin override
init_plant_parameters;

% Escenario
escenario = 'con_tlk_con_vx';   % 'frenos_puestos' | 'sin_tlk_sin_vx' | 'con_tlk_sin_vx' | 'con_tlk_con_vx' | 'sin_tlk_con_vx'

% Convención: Manual Switch sw=1 -> input 2 (Constant=0, freno liberado)
%             Manual Switch sw=0 -> input 1 (Constant=1, freno puesto)
switch escenario
    case 'frenos_puestos'
        sw_brk_t=0; sw_brk_h=0; sw_brk_he=0; sw_tlk=1; amp_vx=0;  % todos frenos activos, sin tlk
    case 'sin_tlk_sin_vx'
        sw_brk_t=1; sw_brk_h=1; sw_brk_he=1; sw_tlk=1; amp_vx=0;
    case 'con_tlk_sin_vx'
        sw_brk_t=1; sw_brk_h=1; sw_brk_he=1; sw_tlk=0; amp_vx=0;
    case 'con_tlk_con_vx'
        sw_brk_t=1; sw_brk_h=1; sw_brk_he=1; sw_tlk=0; amp_vx=1.5;
    case 'sin_tlk_con_vx'
        sw_brk_t=1; sw_brk_h=1; sw_brk_he=1; sw_tlk=1; amp_vx=1.5;
end

% Forzar los Manual Switches del root (bypassean BRK_*_state)
load_system('controlador_torque');
set_param('controlador_torque/Manual Switch',  'sw', num2str(sw_brk_t));
set_param('controlador_torque/Manual Switch1', 'sw', num2str(sw_brk_h));
set_param('controlador_torque/Manual Switch2', 'sw', num2str(sw_brk_he));
set_param('controlador_torque/Manual Switch3', 'sw', num2str(sw_tlk));

% Inputs del modelo (los BRK_*_state son usados por el path alterno, no por el Manual Switch)
vx_cmd = amp_vx; vh = 0;
anti_sway_estate = 1;
BRK_t_state = 1 - sw_brk_t;  % Manual Switch sw=1 -> emite 0, sw=0 -> emite 1
BRK_h_state = 1 - sw_brk_h;
BRK_he_state = 1 - sw_brk_he;
TLK_state = 1 - sw_tlk;
Mc_X = Mc_max;

fprintf('=== Escenario: %s (Stop=12s) ===\n', escenario);
fprintf('Ganancias: Kp_c=%.1f Ki_c=%.1f Kp_i=%.1f Ki_i=%.1f\n', Kp_c, Ki_c, Kp_i, Ki_i);
tic;
out = sim('controlador_torque','StopTime','12');
dt_sim = toc;
fprintf('OK en %.1f s (walltime)\n', dt_sim);
fprintf('max v_td: %.3f m/s  max whm_t: %.1f rad/s\n', ...
        max(abs(out.v_td.Data)), max(abs(out.whm_t.Data)));
