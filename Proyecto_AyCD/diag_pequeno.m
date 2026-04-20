%% diag_pequeno.m — barrido casero con setpoint pequeño para aislar dinámica lineal
clear; clc;
init_plant_parameters;
modelName = 'controlador_torque';
load_system(modelName);
bypass_signal_editor(modelName);
set_param([modelName '/Manual Switch'],  'sw','1');
set_param([modelName '/Manual Switch1'], 'sw','1');
set_param([modelName '/Manual Switch2'], 'sw','1');
set_param([modelName '/Manual Switch3'], 'sw','0');
BRK_t_state=0; BRK_h_state=0; BRK_he_state=0; TLK_state=1;
anti_sway_estate=1; Mc_X=Mc_max;
M_carro_total = Mt+Ms+Mc_X; Kf=it/rtd;
J_motor_izaje = Jhm_hb + Jhd_hEb/ih^2;
vh = 0;

% Izaje: dejamos valores por defecto (no afectan carro)
wn_h=3; zitta_h=0.85; p_obs_h=5*wn_h;
Kp_i=2*zitta_h*wn_h*J_motor_izaje;
Ki_i=(wn_h^2)*J_motor_izaje;
k_tita_h=3*p_obs_h - bh_eq/Jh_eq;
k_omega_h=3*p_obs_h^2 - k_tita_h*bh_eq/Jh_eq;
k_i_h=p_obs_h^3;

vx_cmd_values = [0.05 0.15 0.3 0.6 1.0 1.5];
for vv = vx_cmd_values
    vx_cmd = vv;
    wn_t=1.5; zitta_t=0.85; p_obs_c=5*wn_t;
    Kp_c=(2*zitta_t*wn_t*M_carro_total)/Kf;
    Ki_c=(wn_t^2*M_carro_total)/Kf;
    k_tita_c=3*p_obs_c; k_omega_c=3*p_obs_c^2; k_i_c=p_obs_c^3;
    simOut = sim(modelName,'StopTime','15','SrcWorkspace','current','SaveOutput','on');
    t = simOut.v_td.Time; y = simOut.v_td.Data(:);
    fprintf('vx_cmd=%.2f  max=%.4f  min=%.4f  @t=5=%.4f  @t=10=%.4f  final=%.4f\n', ...
        vv, max(y), min(y), interp1(t,y,5,'linear','extrap'), ...
        interp1(t,y,10,'linear','extrap'), y(end));
end
