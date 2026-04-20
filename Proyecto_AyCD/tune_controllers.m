%% tune_controllers.m
% Barrido paramétrico de controladores PI y observadores.
% Optimiza por separado Carro e Izaje.
%
% Señales disponibles en `out` (sólo dos ToWorkspace en el modelo):
%   out.v_td      velocidad del tambor del carro [m/s]
%   out.whm_t     velocidad angular del motor de izaje [rad/s]
%
% Como vt_ref y vh_ref no están expuestos, se construye la referencia a
% partir de los comandos (escalón) + rate limiter at_max/ah_max.
%
% Los 4 Manual Switches del root (BRK_t, BRK_h, BRK_he, TLK) se fuerzan
% a sw=1 (= selecciona 0 para frenos, 1 para TLK según posición).

clear; clc;

%% 1) Planta + modelo
init_plant_parameters;

modelName = 'controlador_torque';
load_system(modelName);

% Manual Switches del root: sw=1 emite el input-2 = 0 (frenos liberados)
% El 3er switch es TLK: sw=0 emite Constant7=1 (spreader enganchado)
set_param([modelName '/Manual Switch'],  'sw','1');  % BRK_t = 0
set_param([modelName '/Manual Switch1'], 'sw','1');  % BRK_h = 0
set_param([modelName '/Manual Switch2'], 'sw','1');  % BRK_hE = 0
set_param([modelName '/Manual Switch3'], 'sw','0');  % TLK = 1

% El modelo tiene un Signal Editor hardcoded que alimenta vx_cmd con una
% señal del .mat, ignorando la variable del workspace. Lo reemplazamos por
% un Constant que sí lee vx_cmd del workspace.
bypass_signal_editor(modelName);

% Estados auxiliares (el path alterno usa BRK_*_state; lo dejamos coherente)
BRK_t_state  = 0;
BRK_h_state  = 0;
BRK_he_state = 0;
TLK_state    = 1;
anti_sway_estate = 1;
Mc_X = Mc_max;
M_carro_total = Mt + Ms + Mc_X;
Kf = it/rtd;
J_motor_izaje = Jhm_hb + Jhd_hEb/ih^2;

%% 2) Barrido CARRO
fprintf('\n=== Barrido Controlador+Observador CARRO ===\n');

% Escalón del carro a partir de t=2s, hasta fin de sim. Izaje quieto.
% vx_step pequeño para operar en régimen lineal (no saturar torque).
t_step_c = 2;
T_sim_c  = 15;
vx_step  = 0.15;
vx_cmd   = vx_step;
vh       = 0;

% Mallas (chicas para ciclo inicial rápido — subir luego si el óptimo toca borde)
grid_c.wn    = [0.8 1.2 1.6 2.2];
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
                                'SrcWorkspace','current', 'SaveOutput','on');
        [Jcost, m] = costo_carro(simOut, t_step_c, vx_step, at_max, Ttm_Max);
    catch ME
        fprintf('  [%2d/%d] wn=%.2f zit=%.2f kobs=%d  FALLO: %s\n', ...
                k, N_c, wn_t, zitta_t, grid_c.kobs(io), strtrim(ME.message));
        resultados_c{k} = struct('wn_t',wn_t,'zitta_t',zitta_t, ...
                                 'p_obs_c',p_obs_c,'J',inf,'m',[]);
        continue;
    end

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

%% 3) Barrido IZAJE
fprintf('\n=== Barrido Controlador+Observador IZAJE ===\n');

% Aplicar mejor carro (el acoplamiento existe por anti-sway y cable)
wn_t    = best_c.wn_t;
zitta_t = best_c.zitta_t;
p_obs_c = best_c.p_obs_c;
Kp_c = (2*zitta_t*wn_t*M_carro_total)/Kf;
Ki_c = (wn_t^2      *M_carro_total)/Kf;
k_tita_c  = 3*p_obs_c;   k_omega_c = 3*p_obs_c^2;   k_i_c = p_obs_c^3;

% Ahora el carro queda quieto y probamos izaje: subir a vh_step
t_step_h = 2;
T_sim_h  = 20;
vh_step  = 0.5;    % moderado (vh_nom=1.5)
vx_cmd   = 0;
vh       = vh_step;

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
                                'SrcWorkspace','current', 'SaveOutput','on');
        [Jcost, m] = costo_izaje(simOut, t_step_h, vh_step, ah_max, Thm_Max, ih, rhd);
    catch ME
        fprintf('  [%2d/%d] wn=%.2f zit=%.2f kobs=%d  FALLO: %s\n', ...
                k, N_h, wn_h, zitta_h, grid_h.kobs(io), strtrim(ME.message));
        resultados_h{k} = struct('wn_h',wn_h,'zitta_h',zitta_h, ...
                                 'p_obs_h',p_obs_h,'J',inf,'m',[]);
        continue;
    end

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

%% 4) Aplicar óptimos al workspace
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

fprintf('\n====== ÓPTIMO APLICADO ======\n');
fprintf('Carro  | wn_t=%.3f  zitta_t=%.3f | Kp_c=%.1f  Ki_c=%.1f | p_obs_c=%.2f\n', ...
        wn_t, zitta_t, Kp_c, Ki_c, p_obs_c);
fprintf('Izaje  | wn_h=%.3f  zitta_h=%.3f | Kp_i=%.1f  Ki_i=%.1f | p_obs_h=%.2f\n', ...
        wn_h, zitta_h, Kp_i, Ki_i, p_obs_h);

save('tune_results.mat','best_c','best_h','resultados_c','resultados_h','grid_c','grid_h');
fprintf('Resultados guardados en tune_results.mat\n');


%% =========== Funciones auxiliares ==================
function r = construye_ref(t, t_step, amp, rate)
    % Rampa limitada por rate hasta alcanzar amp, desde t_step
    r = zeros(size(t));
    mask = t >= t_step;
    r(mask) = min(amp, rate * (t(mask) - t_step));
end

function [J, m] = costo_carro(simOut, t_step, vx_step, at_max, Ttm_Max) %#ok<INUSD>
    t = simOut.v_td.Time;
    y = simOut.v_td.Data(:);
    r = construye_ref(t, t_step, vx_step, at_max);

    m = metricas_respuesta(y, r, t, struct('banda',0.02,'t_inicio',t_step));
    m.sat_ratio = 0;    % no tenemos T_tm expuesto
    m.swing_rms = 0;    % no tenemos tita_l expuesto

    J = 1.0 *m.IAE ...
      + 50  *m.overshoot ...
      + 5.0 *min(m.settling, 30);
end

function [J, m] = costo_izaje(simOut, t_step, vh_step, ah_max, Thm_Max, ih, rhd) %#ok<INUSD>
    t   = simOut.whm_t.Time;
    whm = simOut.whm_t.Data(:);
    y   = whm * rhd / (2*ih);          % velocidad lineal del cable [m/s]
    r   = construye_ref(t, t_step, vh_step, ah_max);

    m = metricas_respuesta(y, r, t, struct('banda',0.02,'t_inicio',t_step));
    m.sat_ratio = 0;
    m.swing_rms = 0;

    J = 1.0 *m.IAE ...
      + 50  *m.overshoot ...
      + 5.0 *min(m.settling, 30);
end
