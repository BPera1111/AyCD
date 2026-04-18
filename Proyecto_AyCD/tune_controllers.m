%% tune_controllers.m
% Barrido paramétrico de controladores PI y observadores.
% Optimiza por separado Carro e Izaje para mantener la malla manejable.
%
% Flujo:
%   1) Carga parámetros de la planta y defaults del manejo_simulink
%   2) Barre (wn_t, zitta_t, kobs_c) con escalón de traslación del carro
%   3) Barre (wn_h, zitta_h, kobs_h) con escalón de izaje
%   4) Aplica al workspace la mejor combinación de cada uno
%
% Requiere: controlador_torque.slx, init_plant_parameters.m,
%           manejo_simulink.m, metricas_respuesta.m
%
% Señales que lee del workspace 'out' (mínimo soportado):
%   out.v_td  out.vt_ref  out.vt_obs   (carro)
%   out.whm_t out.vh_ref  out.vh_obs   (izaje, se convierte whm_t -> v lineal)
%   out.tita_l (opcional, para swing residual)
%   out.T_tm_consigna  out.T_hm_consigna (opcional, para penalizar saturación)

clear;  clc;

%% 1) Cargar planta y defaults
init_plant_parameters;
manejo_simulink;

modelName = 'controlador_torque';

% Escenario común: frenos liberados, spreader enganchado, anti-sway ON
BRK_t_state   = 1;
BRK_h_state   = 1;
BRK_he_state  = 0;
TLK_state     = 1;
anti_sway_estate = 1;
Mc_X = Mc_max;                 % peor caso de masa
M_carro_total = Mt + Ms + Mc_X;
Kf = it/rtd;
J_motor_izaje = Jhm_hb + Jhd_hEb/ih^2;

% Convertir vh a signo coherente (vh>0 sube carga). Nota: manejo_simulink usa
% escalón positivo = comando hacia arriba según convención del modelo.

%% 2) Barrido Carro
fprintf('\n=== Barrido Controlador+Observador CARRO ===\n');

% Escalón carro activo, izaje inactivo
paso_vx_cmd = vt_max;   time_vx_cmdi = 3;   time_vx_cmdf = 25;
paso_vh     = 0;        time_vhi     = 0;   time_vhf     = 0;
T_sim_c = 30;

grid_c.wn    = [0.8 1.2 1.6 2.0];
grid_c.zit   = [0.7 0.85 1.0];
grid_c.kobs  = [3 5 8];

N_c = numel(grid_c.wn)*numel(grid_c.zit)*numel(grid_c.kobs);
resultados_c = cell(N_c,1);
k = 0;  best_c = struct('J', inf);

t_start_c = tic;
for iw = 1:numel(grid_c.wn)
for iz = 1:numel(grid_c.zit)
for io = 1:numel(grid_c.kobs)
    k = k + 1;
    wn_t    = grid_c.wn(iw);
    zitta_t = grid_c.zit(iz);
    p_obs_c = grid_c.kobs(io) * wn_t;

    Kp_c = (2*zitta_t*wn_t*M_carro_total)/Kf;
    Ki_c = (wn_t^2      *M_carro_total)/Kf;
    k_tita_c  = 3*p_obs_c;
    k_omega_c = 3*p_obs_c^2;
    k_i_c     =   p_obs_c^3;

    try
        simOut = sim(modelName, 'StopTime', num2str(T_sim_c), ...
                                'SrcWorkspace','current', ...
                                'SaveOutput','on');
    catch ME
        fprintf('  [%2d/%d] wn=%.2f zit=%.2f kobs=%d  FALLO: %s\n', ...
                k, N_c, wn_t, zitta_t, grid_c.kobs(io), ME.message);
        continue;
    end

    [Jcost, m] = costo_carro(simOut, time_vx_cmdi);
    resultados_c{k} = struct('wn_t',wn_t,'zitta_t',zitta_t, ...
                             'p_obs_c',p_obs_c,'J',Jcost,'m',m);

    fprintf('  [%2d/%d] wn=%4.2f zit=%4.2f kobs=%d | J=%7.2f ov=%4.1f%% set=%5.2fs IAE=%6.2f sat=%4.1f%%\n', ...
            k, N_c, wn_t, zitta_t, grid_c.kobs(io), Jcost, ...
            100*m.overshoot, m.settling, m.IAE, 100*m.sat_ratio);

    if Jcost < best_c.J
        best_c = resultados_c{k};
    end
end, end, end
fprintf('Tiempo barrido carro: %.1f s\n', toc(t_start_c));

fprintf('\n>>> Mejor carro: wn_t=%.3f  zitta_t=%.3f  p_obs_c=%.3f  J=%.3f\n', ...
        best_c.wn_t, best_c.zitta_t, best_c.p_obs_c, best_c.J);

%% 3) Barrido Izaje
fprintf('\n=== Barrido Controlador+Observador IZAJE ===\n');

% Aplicar ya el mejor carro para que haya acoplamiento realista
wn_t    = best_c.wn_t;
zitta_t = best_c.zitta_t;
p_obs_c = best_c.p_obs_c;
Kp_c = (2*zitta_t*wn_t*M_carro_total)/Kf;
Ki_c = (wn_t^2      *M_carro_total)/Kf;
k_tita_c  = 3*p_obs_c;   k_omega_c = 3*p_obs_c^2;   k_i_c = p_obs_c^3;

% Escalón izaje activo, carro inactivo
paso_vx_cmd = 0;         time_vx_cmdi = 0;   time_vx_cmdf = 0;
paso_vh     = vh_nom;    time_vhi     = 3;   time_vhf     = 25;
T_sim_h = 30;

grid_h.wn   = [1 2 3 5 8];
grid_h.zit  = [0.7 0.85 1.0];
grid_h.kobs = [3 5 8];

N_h = numel(grid_h.wn)*numel(grid_h.zit)*numel(grid_h.kobs);
resultados_h = cell(N_h,1);
k = 0;  best_h = struct('J', inf);

t_start_h = tic;
for iw = 1:numel(grid_h.wn)
for iz = 1:numel(grid_h.zit)
for io = 1:numel(grid_h.kobs)
    k = k + 1;
    wn_h    = grid_h.wn(iw);
    zitta_h = grid_h.zit(iz);
    p_obs_h = grid_h.kobs(io) * wn_h;

    Kp_i = 2*zitta_h*wn_h*J_motor_izaje;
    Ki_i = (wn_h^2)      *J_motor_izaje;
    k_tita_h  = 3*p_obs_h      - bh_eq/Jh_eq;
    k_omega_h = 3*p_obs_h^2    - k_tita_h*bh_eq/Jh_eq;
    k_i_h     =   p_obs_h^3;

    try
        simOut = sim(modelName, 'StopTime', num2str(T_sim_h), ...
                                'SrcWorkspace','current', ...
                                'SaveOutput','on');
    catch ME
        fprintf('  [%2d/%d] wn=%.2f zit=%.2f kobs=%d  FALLO: %s\n', ...
                k, N_h, wn_h, zitta_h, grid_h.kobs(io), ME.message);
        continue;
    end

    [Jcost, m] = costo_izaje(simOut, time_vhi, ih, rhd);
    resultados_h{k} = struct('wn_h',wn_h,'zitta_h',zitta_h, ...
                             'p_obs_h',p_obs_h,'J',Jcost,'m',m);

    fprintf('  [%2d/%d] wn=%4.2f zit=%4.2f kobs=%d | J=%7.2f ov=%4.1f%% set=%5.2fs IAE=%6.2f sat=%4.1f%%\n', ...
            k, N_h, wn_h, zitta_h, grid_h.kobs(io), Jcost, ...
            100*m.overshoot, m.settling, m.IAE, 100*m.sat_ratio);

    if Jcost < best_h.J
        best_h = resultados_h{k};
    end
end, end, end
fprintf('Tiempo barrido izaje: %.1f s\n', toc(t_start_h));

fprintf('\n>>> Mejor izaje: wn_h=%.3f  zitta_h=%.3f  p_obs_h=%.3f  J=%.3f\n', ...
        best_h.wn_h, best_h.zitta_h, best_h.p_obs_h, best_h.J);

%% 4) Aplicar mejor combinación al workspace
wn_t    = best_c.wn_t;    zitta_t = best_c.zitta_t;   p_obs_c = best_c.p_obs_c;
wn_h    = best_h.wn_h;    zitta_h = best_h.zitta_h;   p_obs_h = best_h.p_obs_h;

Kp_c = (2*zitta_t*wn_t*M_carro_total)/Kf;
Ki_c = (wn_t^2      *M_carro_total)/Kf;
k_tita_c  = 3*p_obs_c;   k_omega_c = 3*p_obs_c^2;   k_i_c = p_obs_c^3;

Kp_i = 2*zitta_h*wn_h*J_motor_izaje;
Ki_i = (wn_h^2)      *J_motor_izaje;
k_tita_h  = 3*p_obs_h      - bh_eq/Jh_eq;
k_omega_h = 3*p_obs_h^2    - k_tita_h*bh_eq/Jh_eq;
k_i_h     =   p_obs_h^3;

fprintf('\n====== RESUMEN ÓPTIMO APLICADO ======\n');
fprintf('Carro  | wn_t=%.3f  zitta_t=%.3f | Kp_c=%.1f  Ki_c=%.1f | p_obs_c=%.2f\n', ...
        wn_t, zitta_t, Kp_c, Ki_c, p_obs_c);
fprintf('Izaje  | wn_h=%.3f  zitta_h=%.3f | Kp_i=%.1f  Ki_i=%.1f | p_obs_h=%.2f\n', ...
        wn_h, zitta_h, Kp_i, Ki_i, p_obs_h);

save('tune_results.mat','best_c','best_h','resultados_c','resultados_h','grid_c','grid_h');
fprintf('Resultados guardados en tune_results.mat\n');


%% =========== Funciones auxiliares ==================
function [J, m] = costo_carro(simOut, t_step)
    t = simOut.vt_ref.Time;
    r = simOut.vt_ref.Data(:);
    y = simOut.v_td.Data(:);
    if size(r,2)>1, r = r(:,1); end
    if size(y,2)>1, y = y(:,1); end

    m = metricas_respuesta(y, r, t, struct('banda',0.02,'t_inicio',t_step));

    % saturación torque
    if isfield(simOut,'T_tm_consigna')
        Tt = simOut.T_tm_consigna.Data(:);
        Tmax = evalin('base','Ttm_Max');
        m.sat_ratio = mean(abs(Tt) >= 0.95*Tmax);
    else
        m.sat_ratio = 0;
    end

    % swing residual (después de que la referencia vuelve a ~0)
    if isfield(simOut,'tita_l')
        tl = simOut.tita_l.Data(:);
        idx = simOut.tita_l.Time > t(end) - 5;
        m.swing_rms = sqrt(mean(tl(idx).^2));
    else
        m.swing_rms = 0;
    end

    J = 1.0 *m.IAE ...
      + 50  *m.overshoot ...
      + 5.0 *min(m.settling, 30) ...
      + 100 *m.sat_ratio ...
      + 20  *m.swing_rms;
end

function [J, m] = costo_izaje(simOut, t_step, ih, rhd)
    t = simOut.vh_ref.Time;
    r = simOut.vh_ref.Data(:);
    % velocidad lineal real: whm es rpm del motor; vh_real = whm*rhd/(2*ih)
    % (2 ramales de cable por poleas)
    whm = simOut.whm_t.Data(:);
    y = whm * rhd / (2*ih);
    if size(r,2)>1, r = r(:,1); end

    m = metricas_respuesta(y, r, t, struct('banda',0.02,'t_inicio',t_step));

    if isfield(simOut,'T_hm_consigna')
        Th = simOut.T_hm_consigna.Data(:);
        Tmax = evalin('base','Thm_Max');
        m.sat_ratio = mean(abs(Th) >= 0.95*Tmax);
    else
        m.sat_ratio = 0;
    end

    m.swing_rms = 0;

    J = 1.0 *m.IAE ...
      + 50  *m.overshoot ...
      + 5.0 *min(m.settling, 30) ...
      + 100 *m.sat_ratio;
end
