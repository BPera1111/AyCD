(*
 * T_UDP_RX_TO_SIM
 * Estructura del paquete UDP que envía PLC a Simulink (puerto 25001).
 * Total: 53 LREAL = 424 bytes
 * Destino: planta_codesys.slx Demux (21 lanes, con yc0_vec=[1x33])
 *)
TYPE T_UDP_RX_TO_SIM :
STRUCT
    BRK_h_N1           : LREAL;            // 1  - freno izaje L1 (0/1)
    BRK_t_N1           : LREAL;            // 2  - freno carro L1 (0/1)
    TLK                : LREAL;            // 3  - twistlock cerrado (0/1)
    yc0_vec            : ARRAY[1..33] OF LREAL;  // 4-36 - perfil alturas containers
    i_sel              : LREAL;            // 37 - índice waypoint seleccionado
    vx_suave           : LREAL;            // 38 - velocidad carro suavizada [m/s]
    vy_suave           : LREAL;            // 39 - velocidad izaje suavizada [m/s]
    recuperacion       : LREAL;            // 40 - flag recuperación
    modo_muerto        : LREAL;            // 41 - flag modo muerto
    heartbeat          : LREAL;            // 42 - pulso watchdog
    m_container        : LREAL;            // 43 - masa container estimada [kg]
    BRK_hE_N0          : LREAL;            // 44 - freno izaje L0 (0/1)
    BRK_t_N0           : LREAL;            // 45 - freno carro L0 (0/1)
    FALLA_IZAJE_SV     : LREAL;            // 46 - falla sobrevelocidad izaje
    FALLA_MAN          : LREAL;            // 47 - falla manual (emergencia)
    FALLA_WD           : LREAL;            // 48 - falla watchdog
    FALLA_CARRO_DER    : LREAL;            // 49 - falla fin carrera carro derecho
    FALLA_CARRO_IZQ    : LREAL;            // 50 - falla fin carrera carro izquierdo
    FALLA_IZAJE_INF    : LREAL;            // 51 - falla fin carrera izaje inferior
    FALLA_IZAJE_SUP    : LREAL;            // 52 - falla fin carrera izaje superior
    FALLA_CARRO_SV     : LREAL;            // 53 - falla sobrevelocidad carro
END_STRUCT
END_TYPE
