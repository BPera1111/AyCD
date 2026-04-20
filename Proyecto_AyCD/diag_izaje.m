%% diag_izaje.m — verifica que vh del workspace llega al modelo post-bypass
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
M_carro_total=Mt+Ms+Mc_X; Kf=it/rtd;
J_motor_izaje=Jhm_hb+Jhd_hEb/ih^2;

wn_t=0.8; zitta_t=0.85; p_obs_c=5*wn_t;
Kp_c=(2*zitta_t*wn_t*M_carro_total)/Kf;
Ki_c=(wn_t^2*M_carro_total)/Kf;
k_tita_c=3*p_obs_c; k_omega_c=3*p_obs_c^2; k_i_c=p_obs_c^3;

vh_values = [0.0 0.1 0.3 0.5];
for vv = vh_values
    vh = vv; vx_cmd = 0;
    wn_h=3; zitta_h=0.85; p_obs_h=5*wn_h;
    Kp_i=2*zitta_h*wn_h*J_motor_izaje;
    Ki_i=(wn_h^2)*J_motor_izaje;
    k_tita_h=3*p_obs_h - bh_eq/Jh_eq;
    k_omega_h=3*p_obs_h^2 - k_tita_h*bh_eq/Jh_eq;
    k_i_h=p_obs_h^3;
    simOut = sim(modelName,'StopTime','12','SrcWorkspace','current','SaveOutput','on');
    t = simOut.whm_t.Time;
    y_wh = simOut.whm_t.Data(:);
    y_v  = y_wh * rhd/(2*ih);   % velocidad lineal cable
    fprintf('vh=%.2f  max_whm=%.1f rad/s  max_vcable=%.4f m/s  @t=8=%.4f  final=%.4f\n', ...
        vv, max(abs(y_wh)), max(abs(y_v)), interp1(t,y_v,8), y_v(end));
end
