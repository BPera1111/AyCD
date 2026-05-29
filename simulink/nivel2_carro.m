function [T_tm, vt_obs] = nivel2_carro(BRK_t, tita_tm, tita_l, tita_hm, vt_target)
%NIVEL2_CARRO  Nivel 2 control carro — pegar directamente en MATLAB Function block
%
%  Edit Data (Scope=Parameter, Type=double, Size=-1):
%    Kp_c, Ki_c, k_tita_c, k_omega_c, k_i_c,
%    Jt_eq, g, rhd, ih, rtd, it, Ts2, at_max, vt_max, Yt0, zitta
%#codegen

persistent int_e prev_e theta_hat omega_hat x3 tita_prev rl_state T_prev;
if isempty(theta_hat)
    int_e     = 0;
    prev_e    = 0;
    theta_hat = double(tita_tm);
    omega_hat = 0;
    x3        = 0;
    tita_prev = double(tita_tm);
    rl_state  = 0;
    T_prev    = 0;
end

%% 1. Anti-sway
yh     = double(tita_hm) * (rhd / (2 * ih));
h      = max(Yt0 - yh, 0.5);
v_sway = double(tita_l) * 2 * zitta * sqrt(g * h);

%% 2. Corrección de referencia
vt_cmd   = double(vt_target) + v_sway;
vt_sat   = max(min(vt_cmd, vt_max), -vt_max);
delta    = vt_sat - rl_state;
rl_state = rl_state + max(min(delta, at_max * Ts2), -at_max * Ts2);
vt_ref   = rl_state;

%% 3. Observador de Luenberger
tita_delayed = tita_prev;
tita_prev    = double(tita_tm);

err_pos   = tita_delayed - theta_hat;
v_est     = omega_hat + k_tita_c * err_pos;
omega_dot = T_prev / Jt_eq + k_i_c * x3 + k_omega_c * err_pos;

theta_hat = theta_hat + Ts2 * v_est;
omega_hat = omega_hat + Ts2 * omega_dot;
x3        = x3        + Ts2 * err_pos;

vt_obs = v_est * (rtd / it);

%% 4. PI trapezoidal con reset anti-windup
err = vt_ref - vt_obs;
if ~double(BRK_t)
    int_e = 0;
else
    int_e = int_e + (Ts2 / 2) * (err + prev_e);
end
prev_e = err;

T_tm   = Kp_c * err + Ki_c * int_e;
T_prev = T_tm;
