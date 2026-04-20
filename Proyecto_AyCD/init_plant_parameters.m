%% Proyecto Global Integrador 2025 - Autómatas y Control Discreto
% Parámetros de la Planta Continua: Grúa Portacontenedores STS

clear; clc;

%% 1. Constantes Universales y Geometría Fija
g = 9.80665;                % Aceleración gravitatoria [m/s^2] [cite: 291]
Yt0 = 45.0;                 % Altura fija de poleas en el carro [m] [cite: 104, 285]
Ysb = 5.0;                  % Despeje mínimo sobre viga testera [m] [cite: 105]

%% 2. Masas y Contenedores
Ms = 15000;                 % Masa Spreader + Headblock [kg] [cite: 289]
Mc_max = 50000;             % Masa nominal máxima del container [kg] [cite: 289]
Mc_min = 2000;              % Masa container vacío [kg] [cite: 290]
Hc = 2.59;                  % Altura estándar del container [m] [cite: 287]
Wc = 2.44;                  % Ancho estándar del container [m] [cite: 287]

%% 3. Parámetros del Sistema de Izaje (Hoist)
% Eje Lento (Tambor y Freno de Emergencia)
rhd = 0.75;                 % Radio primitivo del tambor [m] [cite: 299]
Jhd_hEb = 3800;             % Inercia equivalente eje lento [kg.m^2] [cite: 299]
bhd = 8.0;                  % Fricción viscosa eje lento [N.m/(rad/s)] [cite: 299]
bhEb = 2.2e9;               % Fricción viscosa freno emergencia cerrado [N.m/(rad/s)] [cite: 299]
ThEb_Max = 1.1e6;           % Torque máximo freno emergencia [N.m] [cite: 299]

% Transmisión y Eje Rápido (Motor)
ih = 22.0;                  % Relación de transmisión [cite: 299]
Jhm_hb = 30.0;              % Inercia equivalente eje rápido [kg.m^2] [cite: 299]
bhm = 18.0;                 % Fricción viscosa eje rápido [N.m/(rad/s)] [cite: 299]
bhb = 100e6;                % Fricción viscosa freno operación cerrado [N.m/(rad/s)] [cite: 299]
Thb_Max = 50e3;             % Torque máximo freno operación [N.m] [cite: 299]
tau_hm = 0.001;             % Constante de tiempo modulador torque [s] [cite: 235, 299]
Thm_Max = 20e3;             % Torque máximo motor izaje [N.m] [cite: 299]

% Cable de Izaje (Wirerope)
khwu = 236e6;               % Rigidez unitaria a tracción [N/m * m] [cite: 299]
bhwu = 150;                 % Amortiguamiento unitario [(N/m/s)/m] [cite: 299]
Lh0 = 110;                  % Longitud de despliegue fijo [m] [cite: 299]

vh_nom=1.5;

Jh_eq = (2*Jhd_hEb+2*Jhm_hb*ih^2)/rhd;
bh_eq = (2*bhd + 2*bhm*ih^2)/rhd;

vh_lim = vh_nom;
ah_max = 0.75; 
vh_0 = 0;

%% 4. Parámetros del Carro (Trolley)
Mt = 30000;                 % Masa equivalente del carro [kg] [cite: 299]
bt = 90.0;                  % Fricción viscosa del carro [N/(m/s)] [cite: 299]
Ktw = 480e3;                % Rigidez total cable carro [N/m] [cite: 299]
btw = 3.0e3;                % Amortiguamiento cable carro [N/(m/s)] [cite: 299]

% Accionamiento del Carro
rtd = 0.50;                 % Radio primitivo tambor carro [m] [cite: 299]
Jtd = 1200;                 % Inercia equivalente eje lento [kg.m^2] [cite: 299]
btd = 1.8;                  % Fricción viscosa eje lento [N.m/(rad/s)] [cite: 299]
it = 30.0;                  % Relación de transmisión carro [cite: 299]
Jtm_tb = 7.0;               % Inercia equivalente eje rápido [kg.m^2] [cite: 305]
btm = 6.0;                  % Fricción viscosa eje rápido [N.m/(rad/s)] [cite: 309]
btb = 5.0e6;                % Fricción viscosa freno operación cerrado [N.m/(rad/s)] [cite: 310]
Ttb_Max = 5.0e3;            % Torque máximo freno operación [N.m] [cite: 311]
tau_tm = 0.001;             % Constante de tiempo modulador torque [s] [cite: 314]
%tau_tm = 1;
Ttm_Max = 4.0e3;            % Torque máximo motor carro [N.m] [cite: 314]

xt_min = -30.0;      % [m] Límite mínimo posición carro
xt_max = 50.0;       % [m] Límite máximo posición carro
vt_max = 4.0;        % [m/s] Velocidad máxima carro
at_max = 0.80;       % [m/s^2] Aceleración máxima carro

Jt_eq = (Jtd+Jtm_tb*it^2)/rtd;
bt_eq = (btd + btm*it^2)/rtd;

%Controlador de Balanceo
zitta = 0.5;

%% 5. Parámetros de Contacto (Interacción con el Ambiente)
Kcy = 1.8e9;                % Rigidez compresión vertical [N/m] [cite: 296]
bcy = 10.0e6;               % Amortiguamiento compresión vertical [N/(m/s)] [cite: 299]
bcx = 1.0e6;                % Fricción de arrastre horizontal [N/(m/s)] [cite: 299]
%Kcy = 2e6;      % N/m  - misma frecuencia natural pero tratable
%bcy = 2*sqrt(Kcy * 40000) * 0.7;  % amortiguamiento critico 70%
%% Asignacion aleatoria de la masa del carro (Entorno)
%Mc_Xvect=
Mc_X=25000;

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

ml_total = Ms + Mc_X;          % 40000 kg
f_contact = (1/(2*pi)) * sqrt(Kcy / ml_total);
dt_required = 1 / (20 * f_contact);

fprintf('Frecuencia natural contacto: %.1f Hz\n', f_contact);
fprintf('Paso máximo requerido:       %.2e s\n', dt_required);
fprintf('Min step actual (1e-10):     %s\n', string(dt_required > 1e-10));

%% CN2 - Controlador de movimiento - Carro
% Parámetros óptimos hallados por tune_controllers.m (barrido 2025-04-20)
%   wn_t=0.80 rad/s, zitta_t=0.70, kobs=3  →  J=24.37, ov=1.5%, set=4.67s
Kf = it/rtd;
M_carro_total = Mt + Ms + Mc_X;

zitta_t = 0.70;
wn_t    = 0.80;

Kp_c = (2*zitta_t*wn_t*M_carro_total)/Kf;
Ki_c = (wn_t^2      *M_carro_total)/Kf;

%% CN2 - Controlador de movimiento - Izaje
% Parámetros óptimos: wn_h=5.00 rad/s, zitta_h=0.70, kobs=8  →  J=1.10, ov=0.2%, set=0.20s
J_motor_izaje = Jhm_hb + Jhd_hEb/ih^2;
Jh_eq_eq = Jh_eq * rhd/(2*ih^2);    % conservado para compatibilidad

zitta_h = 0.70;
wn_h    = 5.00;

Kp_i = 2*zitta_h*wn_h*J_motor_izaje;
Ki_i = (wn_h^2)      *J_motor_izaje;

%% CN2 - Observador de estado - Carro
% Polos triples en p_obs_c = kobs*wn_t = 3*0.8 = 2.4 rad/s
p_obs_c   = 3 * wn_t;
k_tita_c  = 3 * p_obs_c;
k_omega_c = 3 * p_obs_c^2;
k_i_c     =     p_obs_c^3;

%% CN2 - Observador de estado - Izaje
% Polos triples en p_obs_h = kobs*wn_h = 8*5 = 40 rad/s
p_obs_h   = 8 * wn_h;
k_tita_h  = 3*p_obs_h      - bh_eq/Jh_eq;
k_omega_h = 3*p_obs_h^2    - k_tita_h*bh_eq/Jh_eq;
k_i_h     =   p_obs_h^3;

% Conservado para compatibilidad (no usado por el modelo, sólo referencia)
A_aug_h = [0, 1, 0; 0, -bh_eq/Jh_eq, 1/Jh_eq; 0, 0, 0];
C_aug_h = [1, 0, 0];
Lh = place(A_aug_h', C_aug_h', [-p_obs_h, -p_obs_h*1.01, -p_obs_h*1.02])';

%% Fin
fprintf('Parámetros de la planta cargados correctamente.\n');


% %% Condiciones iniciales consistentes
% % Spreader suspendido, detenido, centrado, a altura y_h_ini sobre el muelle

% y_h_ini  = 10.0;          % altura inicial del spreader [m] (sobre muelle)
% x_t_ini  = 0.0;           % posicion inicial del carro [m]
% x_l_ini  = 0.0;           % carga centrada bajo el carro
% lh_ini   = Yt0 - y_h_ini; % longitud cable tambor = 45 - 10 = 35 m
% l_ini    = lh_ini;         % cable sin elongacion inicial (equilibrio)

% % Velocidades todas cero
% vt_ini   = 0;
% vlx_ini  = 0;
% vly_ini  = 0;
% whd_ini  = 0;
% whm_ini  = 0;
% wtd_ini  = 0;
% wtm_ini  = 0;
vt_0 = 0;    
xt_0 = 25;
xl_0 = 25; % integradores carga y perfil de obstaculos 
yl_0 = 20; % integradores carga y perfil de obstaculos 
lh_0 = 25; % Integrador accionamiento de izaje
Ttm_0 = 0;                                    % [Nm] Torque inicial en el motor del carro
Thm_0 = 0;


xtd_0 = xt_0;  