%% ver_respuesta.m — Visualización de respuesta de Carro e Izaje
% Corre dos escenarios y grafica entradas/salidas clave.
clear; clc; close all;

%% ── Inicializar ──────────────────────────────────────────────────────────
init_plant_parameters;
modelName = 'controlador_torque';
load_system(modelName);
bypass_signal_editor(modelName);
set_param([modelName '/Manual Switch'],  'sw','1');   % BRK_t  libre
set_param([modelName '/Manual Switch1'], 'sw','1');   % BRK_h  libre
set_param([modelName '/Manual Switch2'], 'sw','1');   % BRK_hE libre
set_param([modelName '/Manual Switch3'], 'sw','0');   % TLK    enganchado

BRK_t_state=0; BRK_h_state=0; BRK_he_state=0; TLK_state=1;
anti_sway_estate=1;

%% ── Escenario 1: CARRO ───────────────────────────────────────────────────
fprintf('Simulando carro...\n');
Mc_X = Mc_max;   % peor caso: contenedor lleno (50 t)
vx_cmd = 1.5;    % comando de velocidad [m/s]
vh     = 0;
T_sim  = 15;  t_step = 2;

out_c = sim(modelName, 'StopTime', num2str(T_sim), 'SrcWorkspace','current');
t_c   = out_c.v_td.Time;
v_td  = out_c.v_td.Data(:);

% Referencia rampa-limitada (lo mismo que ve el PI internamente)
r_c = zeros(size(t_c));
mask = t_c >= t_step;
r_c(mask) = min(vx_cmd, at_max*(t_c(mask)-t_step));

vx_cmd_c = vx_cmd;   % guardar antes de cambiar para izaje

%% ── Escenario 2: IZAJE ───────────────────────────────────────────────────
fprintf('Simulando izaje...\n');
vx_cmd = 0;      % carro quieto
vh     = 0.5;    % comando velocidad izaje [m/s]
T_sim  = 15;  t_step = 2;

out_h  = sim(modelName, 'StopTime', num2str(T_sim), 'SrcWorkspace','current');
t_h    = out_h.whm_t.Time;
whm    = out_h.whm_t.Data(:);
v_cab  = -whm * rhd/(2*ih);   % velocidad lineal cable [m/s] (signo corregido)

% Referencia
r_h = zeros(size(t_h));
mask = t_h >= t_step;
r_h(mask) = min(vh, ah_max*(t_h(mask)-t_step));

%% ── Figura ───────────────────────────────────────────────────────────────
fig = figure('Name','Respuesta Controladores','NumberTitle','off', ...
             'Position',[100 80 1100 720]);

COLOR_REF  = [0.85 0.33 0.10];   % naranja
COLOR_OUT  = [0.00 0.45 0.74];   % azul
COLOR_GRID = [0.85 0.85 0.85];

%% — Panel 1: velocidad carro ──────────────────────────────────────────────
ax1 = subplot(2,2,1);
hold on; grid on;
plot(t_c, r_c,  '--', 'Color',COLOR_REF, 'LineWidth',1.4, 'DisplayName','Referencia');
plot(t_c, v_td, '-',  'Color',COLOR_OUT, 'LineWidth',1.8, 'DisplayName','v_{td} (tambor)');
xlabel('Tiempo [s]'); ylabel('Velocidad [m/s]');
title('CARRO — Velocidad (Mc = 50 t)');
legend('Location','southeast');
xlim([0 15]); ylim([-0.1 2.0]);

% Métricas en texto
err_final = abs(vx_cmd_c - v_td(end));
ov = max(0, (max(v_td) - vx_cmd_c)/vx_cmd_c*100);
text(0.97,0.05, sprintf('Error final: %.3f m/s\nOvershoot: %.1f%%', err_final, ov), ...
    'Units','normalized','HorizontalAlignment','right','FontSize',8, ...
    'BackgroundColor','w','EdgeColor',COLOR_GRID);

%% — Panel 2: velocidad de tambor completa ────────────────────────────────
ax2 = subplot(2,2,2);
hold on; grid on;
plot(t_c, v_td, '-', 'Color',COLOR_OUT, 'LineWidth',1.8);
yline(vx_cmd,   '--', 'Color',COLOR_REF, 'LineWidth',1.2, 'Label','cmd');
yline(0,        ':', 'Color',[0.5 0.5 0.5], 'LineWidth',0.8);
xlabel('Tiempo [s]'); ylabel('v_{td} [m/s]');
title('CARRO — v_{td} detalle');
xlim([0 15]);

%% — Panel 3: velocidad izaje (cable) ─────────────────────────────────────
ax3 = subplot(2,2,3);
hold on; grid on;
plot(t_h, r_h,    '--', 'Color',COLOR_REF, 'LineWidth',1.4, 'DisplayName','Referencia');
plot(t_h, v_cab,  '-',  'Color',[0.47 0.67 0.19], 'LineWidth',1.8, 'DisplayName','v_{cable}');
xlabel('Tiempo [s]'); ylabel('Velocidad [m/s]');
title('IZAJE — Velocidad cable');
legend('Location','southeast');
xlim([0 15]); ylim([-0.05 0.7]);

err_h  = abs(vh - v_cab(end));
ov_h   = max(0, (max(v_cab) - vh)/vh*100);
text(0.97,0.05, sprintf('Error final: %.3f m/s\nOvershoot: %.1f%%', err_h, ov_h), ...
    'Units','normalized','HorizontalAlignment','right','FontSize',8, ...
    'BackgroundColor','w','EdgeColor',COLOR_GRID);

%% — Panel 4: velocidad angular motor izaje ───────────────────────────────
ax4 = subplot(2,2,4);
hold on; grid on;
whm_ref = r_h * 2*ih/rhd;   % referencia en [rad/s]
plot(t_h, whm_ref, '--', 'Color',COLOR_REF, 'LineWidth',1.4, 'DisplayName','\omega_{hm}^{ref}');
plot(t_h, -whm,    '-',  'Color',[0.47 0.67 0.19], 'LineWidth',1.8, 'DisplayName','\omega_{hm}');
xlabel('Tiempo [s]'); ylabel('\omega_{hm} [rad/s]');
title('IZAJE — Velocidad angular motor');
legend('Location','southeast');
xlim([0 15]);

sgtitle(sprintf('Controladores Óptimos — Carro: wn=%.1f rad/s  ζ=%.2f  |  Izaje: wn=%.1f rad/s  ζ=%.2f', ...
    wn_t, zitta_t, wn_h, zitta_h), 'FontSize',11,'FontWeight','bold');

saveas(fig, 'respuesta_controladores.png');
fprintf('\nGráfica guardada: respuesta_controladores.png\n');
fprintf('Carro  — max=%.3f m/s  final=%.3f m/s  ov=%.1f%%\n', max(v_td), v_td(end), ov);
fprintf('  (ref cmd=%.2f m/s, Mc=%.0f kg)\n', vx_cmd_c, Mc_X);
fprintf('Izaje  — max=%.3f m/s  final=%.3f m/s  ov=%.1f%%\n', max(v_cab), v_cab(end), ov_h);
