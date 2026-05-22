(*
 * T_UDP_TX_FROM_SIM
 * Estructura del paquete UDP que envía Simulink al PLC (puerto 25000).
 * Total: 31 LREAL = 248 bytes
 * Origen: planta_codesys.slx Mux (30 lanes, con Joy_XY=[1x2])
 *)
TYPE T_UDP_TX_FROM_SIM :
STRUCT
    BTN_Emerg          : LREAL;            // 1  - botón emergencia (0/1)
    BTN_Reset          : LREAL;            // 2  - botón reset (0/1)
    FCE_der            : LREAL;            // 3  - fin carrera carro derecho (0/1)
    FCE_inf            : LREAL;            // 4  - fin carrera izaje inferior (0/1)
    FCE_izq            : LREAL;            // 5  - fin carrera carro izquierdo (0/1)
    FCE_sup            : LREAL;            // 6  - fin carrera izaje superior (0/1)
    recup_ok           : LREAL;            // 7  - señal recuperación echo
    yh_enc             : LREAL;            // 8  - posición izaje real [m]
    modo_muerto        : LREAL;            // 9  - flag modo muerto echo
    heartbeat_echo     : LREAL;            // 10 - eco heartbeat
    m_container_echo   : LREAL;            // 11 - eco masa container [kg]
    BTN_ON_OFF         : LREAL;            // 12 - botón on/off (0/1)
    Joy_XY             : ARRAY[1..2] OF LREAL;  // 13-14 - joystick X,Y [-1..1]
    theta_l            : LREAL;            // 15 - ángulo carga [rad]
    theta_l_dot        : LREAL;            // 16 - velocidad angular carga [rad/s]
    vh_obs             : LREAL;            // 17 - velocidad izaje observada [m/s]
    vt_obs             : LREAL;            // 18 - velocidad carro observada [m/s]
    Fhw                : LREAL;            // 19 - fuerza horizontal cables [N]
    BTN_TLK            : LREAL;            // 20 - botón twistlock (0/1)
    xt_enc             : LREAL;            // 21 - posición carro real [m]
    FC_der             : LREAL;            // 22 - fin carrera carro der suave (0/1)
    FC_inf             : LREAL;            // 23 - fin carrera izaje inf suave (0/1)
    FC_izq             : LREAL;            // 24 - fin carrera carro izq suave (0/1)
    FC_sup             : LREAL;            // 25 - fin carrera izaje sup suave (0/1)
    BTN_Auto           : LREAL;            // 26 - botón auto (0/1)
    FALLA_MAN_fb       : LREAL;            // 27 - feedback falla manual
    FALLA_WD_fb        : LREAL;            // 28 - feedback falla watchdog
    FALLA_SV_fb        : LREAL;            // 29 - feedback falla sobrevelocidad
    T_hm               : LREAL;            // 30 - torque motor izaje [Nm]
    T_tm               : LREAL;            // 31 - torque motor carro [Nm]
END_STRUCT
END_TYPE
