(*
 * GVL_PARAMS - Constantes físicas y de configuración
 * Espejo de simulink/init_plant_parameters.m
 *)
VAR_GLOBAL CONSTANT
    // === Tiempos de muestreo ===
    Ts0                : LREAL := 0.02;          // [s] Nivel 0 (seguridad)
    Ts1                : LREAL := 0.02;          // [s] Nivel 1 (supervisor)
    Ts2                : LREAL := 0.001;         // [s] Nivel 2 (torque)

    // === Constantes universales ===
    g                  : LREAL := 9.80665;       // [m/s^2] gravedad
    Yt0                : LREAL := 45.0;          // [m] altura poleas
    Ysb                : LREAL := 5.0;           // [m] despeje sobre testera

    // === Masas y containers ===
    Ms                 : LREAL := 15000.0;       // [kg] spreader + headblock
    Mc_max             : LREAL := 50000.0;       // [kg] container máximo
    Mc_min             : LREAL := 2000.0;        // [kg] container vacío
    Hc                 : LREAL := 2.59;          // [m] altura container ISO
    Wc                 : LREAL := 2.44;          // [m] ancho container ISO

    // === Izaje (hoist) ===
    rhd                : LREAL := 0.75;          // [m] radio tambor izaje
    ih                 : LREAL := 22.0;          // relación transmisión izaje
    yh_min             : LREAL := -20.0;         // [m] límite inferior
    yh_max             : LREAL := 40.0;          // [m] límite superior
    vh_max             : LREAL := 3.0;           // [m/s] vel max sin carga
    vh_nom             : LREAL := 1.5;           // [m/s] vel nominal
    ah_max             : LREAL := 0.75;          // [m/s^2] aceleración max
    P_nom              : LREAL := 956150.0;      // [W] potencia nominal

    // === Carro (trolley) ===
    Mt                 : LREAL := 30000.0;       // [kg] masa carro
    rtd                : LREAL := 0.50;          // [m] radio tambor carro
    it                 : LREAL := 30.0;          // relación transmisión carro
    xt_min             : LREAL := -30.0;         // [m] límite mínimo
    xt_max             : LREAL := 50.0;          // [m] límite máximo
    vt_max             : LREAL := 4.0;           // [m/s] vel max
    at_max             : LREAL := 0.80;          // [m/s^2] acel max

    // === Watchdog y comunicación ===
    periodo_pulsos     : LREAL := 0.1;           // [s] pulso heartbeat cada 100 ms
    timeout_wd         : LREAL := 0.3;           // [s] timeout watchdog
    counter_limit      : DINT  := 15;            // ciclos (= timeout/Ts0)

    // === Modo manual ===
    dead_zone          : LREAL := 0.1;           // zona muerta joystick

    // === Perfil ===
    N_xt               : INT   := 33;            // cantidad de columnas perfil
    alt_borde          : LREAL := 2.8;           // [m] altura borde muelle

    // === UDP ===
    UDP_PORT_RX        : UINT  := 25000;         // PLC escucha (Sim TX)
    UDP_PORT_TX        : UINT  := 25001;         // PLC envía (Sim RX)
    UDP_REMOTE_IP      : STRING := '127.0.0.1';

    // === Tamaños paquetes ===
    UDP_RX_SIZE        : UDINT := 248;           // bytes paquete TX_FROM_SIM
    UDP_TX_SIZE        : UDINT := 424;           // bytes paquete RX_TO_SIM
END_VAR
