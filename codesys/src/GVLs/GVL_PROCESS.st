(*
 * GVL_PROCESS - Señales compartidas entre L0 (CONTROL_SEGURIDAD)
 * y L1 (CONTROL_SUPERVISOR). Solo un POU escribe cada variable.
 *)
VAR_GLOBAL
    // === Escrito por L1, leído por L0 ===
    heartbeat_L1       : INT  := 0;          // pulso watchdog (toggle por ciclo L1)
    m_container_L1     : LREAL := 0.0;       // masa container estimada [kg]
    modo_muerto_L1     : BOOL := FALSE;      // flag modo muerto desde supervisor

    // === Escrito por L0, leído por L1 ===
    FALLA_GLOBAL       : BOOL := FALSE;      // cualquier falla activa
    FALLA_MAN_L0       : BOOL := FALSE;      // emergencia manual
    FALLA_WD_L0        : BOOL := FALSE;      // timeout watchdog
    FALLA_SV_L0        : BOOL := FALSE;      // sobrevelocidad
    FALLA_CARRO_DER_L0 : BOOL := FALSE;
    FALLA_CARRO_IZQ_L0 : BOOL := FALSE;
    FALLA_CARRO_SV_L0  : BOOL := FALSE;
    FALLA_IZAJE_INF_L0 : BOOL := FALSE;
    FALLA_IZAJE_SUP_L0 : BOOL := FALSE;
    FALLA_IZAJE_SV_L0  : BOOL := FALSE;
    RECUPERAR_L0       : BOOL := FALSE;      // pedido de recuperación a L1
    vh_lim_L0          : LREAL := 3.0;       // velocidad izaje límite dinámica

    // === Salidas de frenos (ambos niveles) ===
    BRK_h_N0           : INT  := 0;          // 0 = liberado, 1 = frenado
    BRK_t_N0           : INT  := 0;
    BRK_h_N1           : INT  := 0;
    BRK_t_N1           : INT  := 0;

    // === Salidas supervisor ===
    TLK_OUT            : INT  := 0;
    vx_suave           : LREAL := 0.0;
    vy_suave           : LREAL := 0.0;
    i_sel_OUT          : INT  := 0;
    recuperacion_OUT   : BOOL := FALSE;
    yc0_vec_OUT        : ARRAY[1..33] OF LREAL;
END_VAR
