%[text] # PROYECTO GLOBAL INTEGRADOR – AUTÓMATAS Y CONTROL DISCRETO
%[text:tableOfContents]{"heading":"Table of Contents"}
clear; clc;
%%
%[text] ## TIEMPOS DE MUESTREO
Ts2 = 1e-3;           % [s] Nivel 2 – Control regulatorio
Ts1 = 20e-3;          % [s] Nivel 1 – Control supervisor
Ts0 = 20e-3;          % [s] Nivel 0 – Seguridad / Protección
%%
%[text] ## PARÁMETROS GENERALES
g = 9.80665;          % [m/s^2] Aceleración gravitatoria estándar
%%
%[text] ## GEOMETRÍA DEL SISTEMA
Yt0 = 45.0;           % [m] Altura fija de poleas de izaje en el carro
Hc  = 2.59;           % [m] Altura del container estándar ISO
Wc  = 2.44;           % [m] Ancho del container estándar ISO
%%
%[text] ## MASAS
Ms = 15000;          % [kg] Masa spreader + headblock (sin container)
Mc_max = 50000;      % [kg] Masa máxima container cargado
Mc_min = 2000;       % [kg] Masa mínima container vacío
M_base = 32500;      % [kg] Carga base para curva de potencia
%%
%[text] ## LÍMITES OPERATIVOS – CARRO (eje x)
xt_min = -30.0;      % [m] Límite mínimo posición carro
xt_max = 50.0;       % [m] Límite máximo posición carro
vt_max = 4.0;        % [m/s] Velocidad máxima carro
at_max = 0.80;       % [m/s^2] Aceleración máxima carro
%%
%[text] ## LÍMITES OPERATIVOS – IZAJE (eje y)
yh_min = -20.0;          % [m] Posición mínima de izaje (y_h = Yt0 - l_h)
yh_max = 40.0;           % [m] Posición máxima de izaje
vh_nom = 1.5;            % [m/s] Velocidad nominal izaje
vh_max_unloaded = 3.0;   % [m/s] Velocidad máx izaje sin carga
ah_max = 0.75;           % [m/s^2] Aceleración máxima izaje
P_nom = 956150;          % [W] Potencia nominal
%%
%[text] ## CONTACTO CARGA – APOYO
Kcy = 1.8e9;         % [N/m] Rigidez de contacto vertical (compresión)
bcy = 10.0e6;        % [N/(m/s)] Amortiguamiento vertical de contacto
bcx = 1.0e6;         % [N/(m/s)] Fricción/arrastre horizontal en contacto
%%
%[text] ## CABLE DE IZAJE (parámetros unitarios)
khwu = 236e6;        % [N]     Parámetro de rigidez unitaria "escalado"
bhwu = 150;          % [N/(m·s)] Amortiguamiento unitario por metro
Lh0  = 110;          % [m] Longitud fija de cable (sin péndulo)
%%
%[text] ## ACCIONAMIENTO DE IZAJE
rhd = 0.75;                   % [m] Radio del tambor de izaje
J_hd_hEb = 3800;              % [kg·m^2] Inercia eje lento (tambor + freno emer.)
bhd = 8.0;                    % [N·m/(rad/s)] Fricción viscosa eje lento

bhEb = 2.2e9;                 % [N·m/(rad/s)] Fricción viscosa freno emergencia (cerrado)
ThEb_Max = 1.1e6;             % [N·m] Torque máx freno emergencia

ih = 22.0;                    % [-] Relación de reducción izaje

J_hm_hb = 30.0;               % [kg·m^2] Inercia eje rápido (motor + freno op.)
bhm = 18.0;                   % [N·m/(rad/s)] Fricción viscosa eje rápido

bhb = 100e6;                  % [N·m/(rad/s)] Fricción viscosa freno operación (cerrado)
Thb_Max = 50e3;               % [N·m] Torque máx freno operación

tau_hm = 1.0e-3;              % [s] Constante de tiempo modulador de torque (izaje)
Thm_Max = 20e3;               % [N·m] Torque máximo motor izaje
whm_rated = vh_nom*2*ih/rhd;  % [rad/s] Velocidad angular nominal del motor de izaje

Jh_eq = J_hm_hb + J_hd_hEb/(ih^2);  % Inercia equivalente reflejada al eje del motor de izaje
bh_eq = bhm + bhd/(ih^2);           % Fricción equivalente reflejada al eje del motor de izaje
%%
%[text] ## CARRO – MASA Y CABLE
Mt = 30000;           % [kg] Masa equivalente del carro
bt = 90.0;            % [N/(m/s)] Fricción viscosa del carro
Ktw = 480e3;          % [N/m] Rigidez total cable de carro
btw = 3.0e3;          % [N/(m/s)] Amortiguamiento total cable de carro
%%
%[text] ## ACCIONAMIENTO DE CARRO
rtd = 0.50;           % [m] Radio tambor carro
Jtd = 1200;           % [kg·m^2] Inercia eje lento carro
btd = 1.8;            % [N·m/(rad/s)] Fricción viscosa eje lento

it = 30.0;            % [-] Relación de reducción carro

Jtm_tb = 7.0;         % [kg·m^2] Inercia eje rápido carro
btm = 6.0;            % [N·m/(rad/s)] Fricción viscosa eje rápido

btb = 5.0e6;          % [N·m/(rad/s)] Fricción viscosa freno operación carro (cerrado)
Ttb_Max = 5.0e3;      % [N·m] Torque máx freno carro

tau_tm = 1.0e-3;      % [s] Constante de tiempo modulador torque carro
Ttm_Max = 4.0e3;      % [N·m] Torque máximo motor carro

Jt_eq = Jtm_tb + Jtd/(it^2); % Inercia equivalente reflejada al eje del motor de carro
bt_eq = btm + btd/(it^2);    % Fricción equivalente reflejada al eje del motor de carro
%%
%[text] ## PERFIL DE RELIEVE INICIAL
N_xt = floor((xt_max-xt_min)/Wc)+1;                         % Cantidad de índices programados en el eje X
is_scanned_vec_inicial = [ones(1,12), zeros(1,N_xt-12)];    % Vector de índices escaneados (1 = escaneado, 0 = no escaneado)
alt_borde = 2.8;                                            % [m] Altura del borde del muelle 

h_vec_inicial = [ 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, alt_borde,... 
                  3, 5, 6, 3, 5, 9, 8, 4, 1, -1, -4, -5, -2, -1, 2, 6, 8, 8, 5,...
                  alt_borde] * Hc;                          % Vector inicial del perfil de obstáculos

yc0_vec_inicial = [h_vec_inicial(1:12), zeros(1,N_xt-12)];  % Perfil inicial efectivamente medido (zona aún no escaneada = 0)
x_LIDAR = 3;                                                % [m] Offset del sensor lidar respecto al carro hacia +xt
%%
%[text] ## PARÁMETROS CONTROLADOR CARRO
Kf = it/rtd;                                        % Ganancia de conversión torque motor a fuerza lineal en el carro

zitta_t = 1.4;                                      % (orig 1.1)
wn_t = 0.8;                                         % (orig 0.95)
N_t = 8;                                            % Factor de separación para lazo de posición (orig 6.5)

Kp_t = (2*zitta_t*wn_t*Mt)/Kf;                      % Ganancia proporcional lazo velocidad carro
Ki_t = (wn_t^2*Mt)/Kf;                              % Ganancia integral lazo velocidad carro

% OBSERVADOR CARRO
A_aug_t = [0, 1, 0; 0, -bt_eq/Jt_eq, 1/Jt_eq; 0, 0, 0];   
C_aug_t = [1, 0, 0];
polo_veloz_t = min(eig(A_aug_t));                   % Polo más rápido del carro

wt_obs = 20 * polo_veloz_t;                         % 20 veces la frecuencia del polo más rápido
polos_obs_t = [wt_obs, wt_obs*1.01, wt_obs*1.02];   % Separamos polos ligeramente (1-2%) para evitar problemas con 'place'
Lt = place(A_aug_t', C_aug_t', polos_obs_t)';       % Cálculo de ganancias
%%
%[text] ## PARÁMETROS CONTROLADOR IZAJE
zitta_h = 1.1;                                      % Puede tomar valores entre 0.707 y 2
wn_h = 0.95;                                        % [rad/s] Puede tomar valores entre 0.5 y 10 rad/s
N_h = 2.5;                                          % Factor de separación. Puede tomar valores entre 2 y 10

Kp_h = 2*zitta_h*wn_h*Jh_eq;                        % Ganancia proporcional lazo velocidad izaje
Ki_h = (wn_h^2)*Jh_eq;                              % Ganancia integral lazo velocidad izaje

% OBSERVADOR IZAJE
A_aug_h = [0, 1, 0; 0, -bh_eq/Jh_eq, 1/Jh_eq; 0, 0, 0];   
C_aug_h = [1, 0, 0];
polo_veloz_h = min(eig(A_aug_h));                   % Polo más rápido del izaje

wh_obs = 20 * polo_veloz_h;                         % 20 veces la frecuencia del polo más rápido
polos_obs_h = [wh_obs, wh_obs*1.01, wh_obs*1.02];   % Separamos polos ligeramente (1-2%) para evitar problemas con 'place'
Lh = place(A_aug_h', C_aug_h', polos_obs_h)';       % Cálculo de ganancias
%%
%[text] ## PARÁMETROS CONTROLADOR BALANCEO
lambda = 0.45;        % Factor de amortiguamiento del balanceo (lo mismo que zitta)
%%
%[text] ## PARÁMETROS WATCHDOG
periodo_pulsos = 100;               % Pulsos cada 100 ms
timeout = 300;                      % [ms] Tiempo antes de detectar error
counter_limit = timeout/(Ts0*1000); % Pulsos a contar antes de detectar error
%%
%[text] ## CONDICIONES INICIALES
% CARRO
vt_0 = 0;                                     % [m/s] Velocidad inicial carro
xt_0 = 25;                                   % [m] Posición inicial carro
xtd_0 = xt_0;                                 % [m] Posición inicial respecto al tambor del carro (cable infinitamente rígido)

wtm_0 = 0;                                    % [rad/s] Velocidad inicial motor carro
titatm_0 = xtd_0/(rtd/it);                    % [rad] Posición angular inical motor carro

% IZAJE
yh_0 = 20;                                    % [m] Altura geométrica inicial de la carga (consigna ideal) 
vh_0 = 0;                                     % [m/s] Velocidad inicial carga
lh_0 = Yt0 - yh_0;                            % [m] Longitud de cable "sin estirar" desenrollada del tambor

whm_0 = 0;                                    % [rad/s] Velocidad inicial motor izaje
titahm_0 = yh_0/(rhd/(2*ih));                 % [rad] Posición angular inicial motor izaje

l_0 = (1/2*Ms*g)/(2*khwu/(2*lh_0+Lh0))+lh_0;  % [m] Longitud real estirada del cable por el peso del spreader
yl_0 = Yt0 - l_0;                             % [m] Posición Y inicial real carga
xl_0 = xt_0;                                  % [m] Posición X inicial carga (debe ser igual a la del carro para no pendular)

vly_0 = 0;                                    % [m/s] Velocidad Y inicial carga
vlx_0 = 0;                                    % [m/s] Velocidad X inicial carga

% MOTORES
Thm_0 = Ms*g*rhd/(2*ih);                      % [Nm] Torque inicial en el motor de izaje
Ttm_0 = 0;                                    % [Nm] Torque inicial en el motor del carro
%%
%% Perfil de obstaculos (Entorno)
% N=ceil(80/Wc);
% dmax=ceil(Yt0/2); %Altura maxima de apilado (Asumida)
% step = Hc; %Paso de apilado
% valores = 0:step:dmax; %Posibles valores de 0 a dmax, con paso step
% y0 = valores(randi(numel(valores),1,N)); %Vector de perfil de obstaculos
% y0(15)=0; %Setea en cero la altura correspondiente al borde entre el agua y el muelle

% Generacion de perfil de obstaculos para apilamiento de containers
% Muelle a la izquierda (contenores aislados, llegada por camiones)
% Barco a la derecha (apilamiento por bloques / mesetas)

N = ceil(80/Wc);
dmax = ceil(Yt0/2);
step = Hc;

% Indice del borde agua–muelle
idx_borde = ceil(30/Wc);

% Definicion de zonas
quay_idx = 1:(idx_borde-1);      % muelle (izquierda)
ship_idx = (idx_borde+1):N;      % barco (derecha)

% Alturas maximas por zona (en niveles discretos)
maxShip = max(2, floor(0.90*dmax/step));
maxQuay = max(1, floor(0.60*dmax/step));

% Parametros de correlacion espacial
Lship = 4;   % bloques mas largos en barco
Lquay = 2;   % menor correlacion en muelle

% Señal correlacionada simple
corrSignal = @(n,L) filter(ones(1,max(1,L))/max(1,L), 1, randn(1,n));

% Normalizacion suave a [0,1] para evitar extremos
to01 = @(z) max(0, min(1, 0.5 + 0.20*z));

% ----- BARCO: apilamiento por bloques -----
zShip = corrSignal(numel(ship_idx), Lship);
uShip = to01(zShip);

gammaShip = 1.6;    % controla sesgo hacia alturas medias
lvlShip = round((uShip.^(1/gammaShip)) * maxShip);

% Suavizado adicional para generar mesetas
lvlShip = round(filter([1 2 3 2 1]/9, 1, lvlShip));
lvlShip = max(0, min(maxShip, lvlShip));

% ----- MUELLE: contenedores aislados -----
zQuay = corrSignal(numel(quay_idx), Lquay);
uQuay = to01(zQuay);

gammaQuay = 2.4;    % mayor sesgo a alturas bajas
lvlQuay = round((uQuay.^(1/gammaQuay)) * maxQuay);
lvlQuay = max(0, min(maxQuay, lvlQuay));

% Pequeña irregularidad vertical
jitterProb = 0.10;
jitter = (rand(size(lvlQuay)) < jitterProb) .* (randi(3, size(lvlQuay)) - 2);
lvlQuay = max(0, min(maxQuay, lvlQuay + jitter));

% Mascara de ocupacion para generar stacks aislados
p_single = 0.12;    % stacks individuales
p_pair   = 0.03;    % pares ocasionales

nq = numel(lvlQuay);
mask = false(1, nq);

i = 1;
while i <= nq
    r = rand;
    if r < p_pair && i < nq
        mask(i) = true;
        mask(i+1) = true;
        i = i + 3;      % dejo un hueco para evitar bloques largos
    elseif r < (p_pair + p_single)
        mask(i) = true;
        i = i + 2;      % dejo un hueco
    else
        i = i + 1;
    end
end

lvlQuay(~mask) = 0;

% Evito triples consecutivos dejando solo el central
for k = 2:(nq-1)
    if lvlQuay(k)>0 && lvlQuay(k-1)>0 && lvlQuay(k+1)>0
        lvlQuay(k-1) = 0;
        lvlQuay(k+1) = 0;
    end
end

% ----- Construccion del perfil final -----
y0 = zeros(1, N);
y0(quay_idx) = lvlQuay * step;
y0(ship_idx) = lvlShip * step;

% Altura cero en el borde agua–muelle
y0(idx_borde) = 0;

% Limite al salto maximo entre columnas para evitar picos no realistas
maxStepJump = 2*step;
for k = 2:N
    if y0(k) > y0(k-1) + maxStepJump
        y0(k) = y0(k-1) + maxStepJump;
    elseif y0(k) < y0(k-1) - maxStepJump
        y0(k) = y0(k-1) - maxStepJump;
    end
end

y0(idx_borde) = 0;

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"inline","rightPanelPercent":40}
%---
