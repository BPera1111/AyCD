%% diag_una_corrida.m
% Corre UNA sola simulación con los parámetros del sweep y muestra
% respuesta real del carro: v_td(t) en varios instantes clave, estadísticas,
% y verifica que los parámetros del PI estén efectivamente llegando.

clear; clc;
init_plant_parameters;

modelName = 'controlador_torque';
load_system(modelName);

% Switches: frenos liberados, spreader enganchado
set_param([modelName '/Manual Switch'],  'sw','1');
set_param([modelName '/Manual Switch1'], 'sw','1');
set_param([modelName '/Manual Switch2'], 'sw','1');
set_param([modelName '/Manual Switch3'], 'sw','0');

BRK_t_state = 0; BRK_h_state = 0; BRK_he_state = 0; TLK_state = 1;
anti_sway_estate = 0;      % DESACTIVADO para aislar respuesta del PI
Mc_X = Mc_max;
M_carro_total = Mt + Ms + Mc_X;
Kf = it/rtd;
J_motor_izaje = Jhm_hb + Jhd_hEb/ih^2;

% Escenario carro
vx_cmd = 1.5; vh = 0;

% Set 1: ganancias AGRESIVAS
wn_t = 2.5; zitta_t = 0.85; p_obs_c = 5*wn_t;
Kp_c = (2*zitta_t*wn_t*M_carro_total)/Kf;
Ki_c = (wn_t^2 * M_carro_total)/Kf;
k_tita_c = 3*p_obs_c; k_omega_c = 3*p_obs_c^2; k_i_c = p_obs_c^3;

% Izaje: ganancias por defecto (no importa aquí)
wn_h = 3; zitta_h = 0.85; p_obs_h = 5*wn_h;
Kp_i = 2*zitta_h*wn_h*J_motor_izaje;
Ki_i = (wn_h^2)*J_motor_izaje;
k_tita_h = 3*p_obs_h - bh_eq/Jh_eq;
k_omega_h = 3*p_obs_h^2 - k_tita_h*bh_eq/Jh_eq;
k_i_h = p_obs_h^3;

fprintf('>> Kp_c=%.2f  Ki_c=%.2f  wn_t=%.2f  zitta_t=%.2f\n', Kp_c, Ki_c, wn_t, zitta_t);
fprintf('>> M_carro_total=%.0f kg  Kf=%.2f\n', M_carro_total, Kf);

simOut = sim(modelName, 'StopTime','20', 'SrcWorkspace','current', 'SaveOutput','on');

t = simOut.v_td.Time;
y = simOut.v_td.Data(:);
fprintf('\n== v_td ==\n');
fprintf('  length=%d  t_end=%.2f\n', numel(t), t(end));
fprintf('  min=%.4f  max=%.4f  final=%.4f\n', min(y), max(y), y(end));
idx = [1 round(numel(t)*0.1) round(numel(t)*0.25) round(numel(t)*0.5) round(numel(t)*0.75) numel(t)];
for k = idx
    fprintf('  t=%6.2f  v_td=%.4f\n', t(k), y(k));
end

% Set 2: ganancias ORIGINALES (wn=0.8, zitta=1.4 pero con M_carro_total)
wn_t = 0.8; zitta_t = 1.4; p_obs_c = 5*wn_t;
Kp_c = (2*zitta_t*wn_t*M_carro_total)/Kf;
Ki_c = (wn_t^2 * M_carro_total)/Kf;
k_tita_c = 3*p_obs_c; k_omega_c = 3*p_obs_c^2; k_i_c = p_obs_c^3;
fprintf('\n>> CASO 2: Kp_c=%.2f  Ki_c=%.2f  wn_t=%.2f\n', Kp_c, Ki_c, wn_t);
simOut2 = sim(modelName, 'StopTime','20', 'SrcWorkspace','current', 'SaveOutput','on');
y2 = simOut2.v_td.Data(:);
t2 = simOut2.v_td.Time;
fprintf('  min=%.4f  max=%.4f  final=%.4f  v_td@t=10=%.4f\n', min(y2), max(y2), y2(end), interp1(t2,y2,10));

% Comparación:
if abs(max(y)-max(y2)) < 1e-4
    fprintf('\n*** ALERTA: SALIDA IDÉNTICA entre CASO 1 y CASO 2 → ganancias no se propagan al modelo\n');
else
    fprintf('\n*** OK: ganancias SÍ afectan la salida (max delta=%.4f)\n', abs(max(y)-max(y2)));
end
