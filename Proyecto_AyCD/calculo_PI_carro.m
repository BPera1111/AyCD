%% Script principal — identificación y sintonía PI del carro
T0_c         = 200;       % N·m — escalón de torque (más chico que izaje)
w_cl_factor_c = 2;         % factor de velocidad de lazo
buffer_w_c   = [];
buffer_t_c   = [];

out = sim('controlador_torque.slx');

[Kp_c, Ki_c, identificado_c] = auto_tune_carro( ...
    T0_c, rtd, it, w_cl_factor_c, true, ...
    out.v_td.Data, out.v_td.Time);

if identificado_c
    fprintf('Carro — Identificación completa: Kp_c=%.4f, Ki_c=%.4f\n', Kp_c, Ki_c);
else
    fprintf('Carro — Falló la identificación\n')
end

%% Función de identificación del carro
function [B_eq, J_eq, Kp, Ki] = identificar_planta_carro( ...
        T0, r_td, i_t, v_td_signal, t_signal, w_cl_factor)
    % Entradas:
    %   T0          — torque de escalón aplicado [N·m]
    %   r_td        — radio primitivo del tambor de carro [m]
    %   i_t         — relación de transmisión del carro
    %   v_td_signal — vector de v_td medido en lazo abierto [m/s]
    %   t_signal    — vector de tiempo correspondiente [s]
    %   w_cl_factor — factor de velocidad de lazo (ej: 8)

    % 1. Condición inicial y valor final
    v0    = v_td_signal(1);
    v_inf = mean(v_td_signal(end-100:end));

    % 2. Umbral del 63.2%
    v_tau = v0 + 0.632 * (v_inf - v0);

    % 3. Buscar tau
    idx = find(v_td_signal >= v_tau, 1, 'first');
    tau = t_signal(idx);

    % 4. Parámetros físicos
    % G_t(s) = (r_td/i_t) / (J_eq·s + B_eq)
    % v_inf = (r_td/i_t) * T0 / B_eq
    B_eq = (r_td / i_t) * T0 / (v_inf - v0);
    J_eq = tau * B_eq;
    p_OL = -B_eq / J_eq;    % = -1/tau

    % 5. Colocación de polos — polo doble en -w_cl
    % EC lazo cerrado: s² + (B_eq + (r_td/i_t)·Kp)/J_eq·s + (r_td/i_t)·Ki/J_eq = 0
    % Deseado: s² + 2·w_cl·s + w_cl²
    w_cl = w_cl_factor * abs(p_OL);
    Kp   = (2 * w_cl * J_eq - B_eq) * i_t / r_td;
    Ki   = w_cl^2 * J_eq * i_t / r_td;

    fprintf('--- Identificación carro ---\n')
    fprintf('v0=%.3f  v_inf=%.3f  tau=%.3f s\n', v0, v_inf, tau)
    fprintf('B_eq=%.2f  J_eq=%.2f  p_OL=%.4f\n', B_eq, J_eq, p_OL)
    fprintf('w_cl=%.3f  Kp=%.4f  Ki=%.4f\n', w_cl, Kp, Ki)
end

%% Wrapper auto_tune para el carro
function [Kp, Ki, identificado] = auto_tune_carro(T0, r_td, i_t, ...
        w_cl_factor, activar, buffer_v, buffer_t)
    persistent Kp_out Ki_out done

    if isempty(done)
        Kp_out = 0; Ki_out = 0; done = false;
    end

    Kp = Kp_out;
    Ki = Ki_out;
    identificado = done;

    if activar && ~done
        if length(buffer_v) > 500
            [~, ~, Kp_out, Ki_out] = identificar_planta_carro( ...
                T0, r_td, i_t, buffer_v, buffer_t, w_cl_factor);
            done    = true;
            Kp      = Kp_out;
            Ki      = Ki_out;
        end
    end

    identificado = done;
end