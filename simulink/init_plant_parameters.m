%% Proyecto Global Integrador 2025 - Autómatas y Control Discreto
% Parámetros de la Planta Continua: Grúa Portacontenedores STS

clear; clc;

%% 0. Frecuencias - Niveles de Control lpm
Ts0 = 0.02;
Ts1 = 0.02;
Ts2 = 0.001; 

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
tau_hm = Ts2;             % Constante de tiempo modulador torque [s] [cite: 235, 299]
Thm_Max = 20e3;             % Torque máximo motor izaje [N.m] [cite: 299]

% Cable de Izaje (Wirerope)
khwu = 236e6;               % Rigidez unitaria a tracción [N/m * m] [cite: 299]
bhwu = 150;                 % Amortiguamiento unitario [(N/m/s)/m] [cite: 299]
Lh0 = 110;                  % Longitud de despliegue fijo [m] [cite: 299]


Jh_eq = Jhm_hb+Jhd_hEb/ih^2;
bh_eq = bhm+bhd/ih^2;

yh_min = -20;
yh_max = 40;
vh_max = 3;
vh_nom= 1.5;
ah_max = 0.75; 
P_nom = 956150;          % [W] Potencia nominal

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
tau_tm = Ts2;             % Constante de tiempo modulador torque [s] [cite: 314]
Ttm_Max = 4.0e3;            % Torque máximo motor carro [N.m] [cite: 314]

xt_min = -30.0;      % [m] Límite mínimo posición carro
xt_max = 50.0;       % [m] Límite máximo posición carro
vt_max = 4.0;        % [m/s] Velocidad máxima carro
at_max = 0.80;       % [m/s^2] Aceleración máxima carro

Jt_eq = Jtm_tb+Jtd/it^2;
bt_eq = btm+btd/it^2;

%Controlador de Balanceo
zitta = 0.5;

%% 5. Parámetros de Contacto (Interacción con el Ambiente)
Kcy = 1.8e9;                % Rigidez compresión vertical [N/m] [cite: 296]
bcy = 10.0e6;               % Amortiguamiento compresión vertical [N/(m/s)] [cite: 299]
bcx = 1.0e6;                % Fricción de arrastre horizontal [N/(m/s)] [cite: 299]

%% Perfil de obstaculos (Entorno)
N_xt = floor((xt_max-xt_min)/Wc)+1;                         % Cantidad de índices programados en el eje X
alt_borde = 2.8;                                            % [m] Altura del borde del muelle 

yc0_vec_inicial = [ 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, alt_borde,... 
                  3, 5, 6, 3, 5, 6, 6, 4, 1, 1, -4, -5, -2, -1, 2, 6, 4, 2, 5,...
                  alt_borde] * Hc;                          % Vector inicial del perfil de obstáculos

%yc0_vec_inicial = h_vec_inicial;  % Perfil inicial efectivamente medido (zona aún no escaneada = 0)
x_LIDAR = 3;                                                % [m] Offset del sensor lidar respecto al carro hacia +xt

envolvent = [ones(1,N_xt)]*30;

%% CN2 - Controlador de movimiento - Carro
Kf = it/rtd;                                        % Ganancia de conversión torque motor a fuerza lineal en el carro

zitta_t = 1.4;                                      % (orig 1.1)
wn_t = 0.8;                                         % (orig 0.95)

Kp_c = (2*zitta_t*wn_t*Mt)/Kf;                      % Ganancia proporcional lazo velocidad carro
Ki_c = (wn_t^2*Mt)/Kf; 

%% CN2 - Controlador de movimiento - Izaje
zitta_h = 2;                                      % Puede tomar valores entre 0.707 y 2
wn_h = 8;                                        % [rad/s] Puede tomar valores entre 0.5 y 10 rad/s

Kp_i = 2*zitta_h*wn_h*Jh_eq;                        % Ganancia proporcional lazo velocidad izaje
Ki_i = (wn_h^2)*Jh_eq;                              % Ganancia integral lazo velocidad izaje

%% CN2 - Observador de estado - Carro


polos_obs_c = 20*-bt_eq/Jt_eq;

k_tita_c = 3 * abs(polos_obs_c);   % Ganancia del observador de estado para el carro
k_omega_c = 3 * abs(polos_obs_c)^2;  % Ganancia del observador de estado para el carro
k_i_c = abs(polos_obs_c)^3;     % Ganancia del observador de estado para el carro

%% CN2 - Observador de estado - Izaje
%A_aug_h = [0, 1, 0; 0, -bh_eq/Jh_eq, 1/Jh_eq; 0, 0, 0];   
%C_aug_h = [1, 0, 0];
%polo_veloz_h = min(eig(A_aug_h));   

polos_obs_h = 20*-bh_eq/Jh_eq;

k_tita_h = 3 * abs(polos_obs_h)-bh_eq/Jh_eq;   % Ganancia del observador de estado para el izaje
k_omega_h = 3 * abs(polos_obs_h)^2-k_tita_h*bh_eq/Jh_eq;  % Ganancia del observador de estado para el izaje
k_i_h = abs(polos_obs_h)^3;     % Ganancia del observador de estado para el izaje


%wh_obs = 20 * polo_veloz_h;                         % 20 veces la frecuencia del polo más rápido
%polos_obs_h = [wh_obs, wh_obs*1.01, wh_obs*1.02];   % Separamos polos ligeramente (1-2%) para evitar problemas con 'place'
%Lh = place(A_aug_h', C_aug_h', polos_obs_h)';       % Cálculo de ganancias
%% Modo Automático
% Lista de índices de columna válidos para selección (excluye bordes 1, 13, 33)
%i_lista = [2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30, 32];



%% Condiciones iniciales
vt_0 = 0;    
xt_0 = 5;
xl_0 = 5; % integradores carga y perfil de obstaculos 
yh_0 = 20; % integradores carga y perfil de obstaculos 
lh_0 = Yt0-yh_0; % Integrador accionamiento de izaje
Ttm_0 = 0;                                    % [Nm] Torque inicial en el motor del carro
Thm_0 = 0;


l_0 = (1/2*Ms*g)/(2*khwu/(2*lh_0+Lh0))+lh_0;  % [m] Longitud real estirada del cable por el peso del spreader
yl_0 = Yt0 - l_0;                             % [m] Posición Y inicial real carga


xtd_0 = xt_0;  
titatm_0 = xtd_0/(rtd/it); 
titahm_0 = yl_0/(rhd/(2*ih)); 

vh_0 = 0;


periodo_pulsos = 100;               % Pulsos cada 100 ms
timeout = 300;                      % [ms] Tiempo antes de detectar error
counter_limit = timeout/(Ts0*1000); % Pulsos a contar antes de detectar error

%% Fin
fprintf('Parámetros de la planta cargados correctamente.\n');

% %% Cargar modelo y compilar Accelerator
% model_name = 'planta';
% script_dir = fileparts(mfilename('fullpath'));
% model_path = fullfile(script_dir, [model_name '.slx']);

% if ~bdIsLoaded(model_name)
%     load_system(model_path);
%     fprintf('Modelo ''%s'' cargado.\n', model_name);
% else
%     fprintf('Modelo ''%s'' ya estaba cargado.\n', model_name);
% end

% set_param(model_name, 'SimulationMode', 'accelerator');
% fprintf('Compilando Accelerator (puede tardar ~30s la primera vez)...\n');
% try
%     accelbuild(model_name);
%     fprintf('Accelerator compilado. Listo para simular.\n');
% catch e
%     fprintf('[WARN] accelbuild: %s\n', e.message);
% end
