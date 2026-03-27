function [B_eq, J_eq, Kp, Ki] = identificar_planta_izaje(T0, w_hm_signal, t_signal, ih, w_cl_factor)
    % Entradas:
    %   T0          — torque de escalón aplicado [N·m]
    %   w_hm_signal — vector de w_hm medido en lazo abierto
    %   t_signal    — vector de tiempo correspondiente
    %   ih          — relación de transmisión
    %   w_cl_factor — cuántas veces más rápido que p_OL (ej: 10)

    % 1. Condición inicial y valor final
    w0    = w_hm_signal(1);
    w_inf = mean(w_hm_signal(end-100:end));  % promedio últimos 100 puntos

    % 2. Umbral del 63.2%
    w_tau = w0 + 0.632 * (w_inf - w0);

    % 3. Buscar tau — primer instante que cruza w_tau
    idx = find(w_hm_signal >= w_tau, 1, 'first');
    tau = t_signal(idx);

    % 4. Parámetros físicos
    B_eq = ih * T0 / (w_inf - w0);
    J_eq = tau * B_eq;
    p_OL = -B_eq / J_eq;       % = -1/tau

    % 5. Ganancias PI por colocación de polos
    w_cl = w_cl_factor * abs(p_OL);
    Kp   = (2 * w_cl * J_eq - B_eq) / ih;
    Ki   = w_cl^2 * J_eq / ih;

    fprintf('--- Identificación automática ---\n')
    fprintf('w0=%.2f  w_inf=%.2f  tau=%.3f s\n', w0, w_inf, tau)
    fprintf('B_eq=%.1f  J_eq=%.1f  p_OL=%.4f\n', B_eq, J_eq, p_OL)
    fprintf('w_cl=%.3f  Kp=%.4f  Ki=%.4f\n', w_cl, Kp, Ki)
end
```

### Paso 2 — Integración en Simulink como fase de arranque

En Simulink podés implementar esto como una **secuencia de inicialización** antes de habilitar el PI. La estructura es:
```
t < t_id  →  Modo identificación: T_hm* = T0 (escalón fijo, PI desconectado)
t = t_id  →  Ejecutar identificar_planta_izaje() con datos grabados
t > t_id  →  Modo control: PI activo con Kp y Ki calculados
```

En el modelo usás un `MATLAB Function` block o un `Stateflow` chart con dos estados:
```
Estado IDENTIFICACION:
  - Aplicar T0 fijo por t_id segundos (ej: 15 s)
  - Grabar w_hm en buffer circular
  - Al salir: llamar función identificación → setear Kp, Ki en workspace

Estado CONTROL:
  - PI activo con Kp, Ki identificados
  - Operación normal



function [Kp, Ki, identificado] = auto_tune(w_hm, t, T0, ih, w_cl_factor, ...
                                             activar, buffer_w, buffer_t)
    persistent Kp_out Ki_out done

    if isempty(done)
        Kp_out = 0; Ki_out = 0; done = false;
    end

    identificado = done;
    Kp = Kp_out;
    Ki = Ki_out;

    if activar && ~done
        % Acumular datos en buffer (manejado externamente)
        % Cuando buffer lleno, identificar:
        if length(buffer_w) > 500
            [~, ~, Kp_out, Ki_out] = identificar_planta_izaje(...
                T0, buffer_w, buffer_t, ih, w_cl_factor);
            done = true;
            Kp = Kp_out;
            Ki = Ki_out;
        end
    end
end