function [T_hm, vh_obs] = nivel2_izaje(BRK, tita_hm, m_cont, vh_target)
%NIVEL2_IZAJE  Nivel 2 control izaje — pegar directamente en MATLAB Function block
%
%  Edit Data (Scope=Parameter, Type=double, Size=-1):
%    Kp_i, Ki_i, k_tita_h, k_omega_h, k_i_h,
%    Jh_eq, bh_eq, g, rhd, ih, Ms, Ts2, ah_max, vh_max
%#codegen

persistent int_e prev_e theta_hat omega_hat x3 T_prev rl_state;
if isempty(theta_hat)
    int_e     = 0;
    prev_e    = 0;
    theta_hat = double(tita_hm);
    omega_hat = 0;
    x3        = 0;
    T_prev    = 0;
    rl_state  = 0;
end

%% 1. Modulación de referencia
vh_sat   = max(min(double(vh_target), vh_max), -vh_max);
delta    = vh_sat - rl_state;
rl_state = rl_state + max(min(delta, ah_max * Ts2), -ah_max * Ts2);
vh_ref   = rl_state;

%% 2. Observador de Luenberger
tita    = double(tita_hm);
err_pos = tita - theta_hat;

v_est     = omega_hat + k_tita_h * err_pos;
omega_dot = -(bh_eq / Jh_eq) * v_est + T_prev / Jh_eq ...
            + k_i_h * x3 + k_omega_h * err_pos;

theta_hat = theta_hat + Ts2 * v_est;
omega_hat = omega_hat + Ts2 * omega_dot;
x3        = x3        + Ts2 * err_pos;

vh_obs = v_est * (rhd / (2 * ih));

%% 3. PI trapezoidal con reset anti-windup
err = vh_ref - vh_obs;
if ~double(BRK)
    int_e = 0;
else
    int_e = int_e + (Ts2 / 2) * (err + prev_e);
end
prev_e = err;

m_total = Ms + double(m_cont);
T_hm    = Kp_i * err + Ki_i * int_e + m_total * g * (rhd / (2 * ih));
T_prev  = T_hm;
