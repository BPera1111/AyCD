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
Ttm_Max = 4.0e3;            % Torque máximo motor carro [N.m] [cite: 314]

%% 5. Parámetros de Contacto (Interacción con el Ambiente)
Kcy = 1.8e9;                % Rigidez compresión vertical [N/m] [cite: 296]
bcy = 10.0e6;               % Amortiguamiento compresión vertical [N/(m/s)] [cite: 299]
bcx = 1.0e6;                % Fricción de arrastre horizontal [N/(m/s)] [cite: 299]

fprintf('Parámetros de la planta cargados correctamente.\n');