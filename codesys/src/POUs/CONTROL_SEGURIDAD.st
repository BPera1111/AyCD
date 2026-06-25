(*
 * CONTROL_SEGURIDAD (Nivel 0)
 * Capa de seguridad: watchdog, límites, emergencia, control de frenos.
 * Ejecutar en Task_Seguridad cada 20 ms.
 *
 * STUB INICIAL: estructura básica. La lógica completa de transiciones
 * debe replicar el chart Stateflow `planta/Nivel 0` de simulink/planta.slx
 *)
FUNCTION_BLOCK CONTROL_SEGURIDAD
VAR_INPUT
    // Recibidas vía COM_UDP_RX (desde GVL_COMMS.udp_from_sim)
    BTN_Emerg          : BOOL;
    BTN_Reset          : BOOL;
    FCE_der            : BOOL;
    FCE_inf            : BOOL;
    FCE_izq            : BOOL;
    FCE_sup            : BOOL;
    vh_obs             : LREAL;
    vt_obs             : LREAL;
    m_container        : LREAL;
    recup_ok           : BOOL;
    heartbeat_L1       : INT;       // pulso desde L1
END_VAR
VAR_OUTPUT
    BRK_hE_N0          : INT;       // 1 = liberado, 0 = frenado
    BRK_t_N0           : INT;
    FALLA_MAN          : BOOL;
    FALLA_WD           : BOOL;
    FALLA_IZAJE_SV     : BOOL;
    FALLA_IZAJE_INF    : BOOL;
    FALLA_IZAJE_SUP    : BOOL;
    FALLA_CARRO_DER    : BOOL;
    FALLA_CARRO_IZQ    : BOOL;
    FALLA_CARRO_SV     : BOOL;
    vh_lim             : LREAL;     // velocidad izaje límite dinámica
END_VAR
VAR
    estado             : (SISTEMA_OK, EMERG_MANUAL, EMERG_CARRO, EMERG_IZAJE,
                          EMERG_WD, MODO_RECUPERACION) := SISTEMA_OK;
    wd_state           : (WD_DOWN, WD_UP, WD_FALLO) := WD_DOWN;
    wd_counter         : DINT := 0;
    heartbeat_prev     : INT := -1;
    rTemp              : LREAL;
END_VAR

(* ============================================================
 * 1. WATCHDOG - detecta pérdida de heartbeat desde L1
 * ============================================================ *)
IF heartbeat_L1 <> heartbeat_prev THEN
    wd_state := WD_UP;
    wd_counter := 0;
    heartbeat_prev := heartbeat_L1;
ELSE
    wd_counter := wd_counter + 1;
    IF wd_counter >= GVL_PARAMS.counter_limit THEN
        wd_state := WD_FALLO;
    END_IF
END_IF

(* ============================================================
 * 2. ENVOLVENTE DE VELOCIDAD - vh_lim según masa container
 * ============================================================ *)
rTemp := GVL_PARAMS.P_nom / ((m_container + GVL_PARAMS.Ms) * GVL_PARAMS.g);
vh_lim := MIN(GVL_PARAMS.vh_max, MAX(GVL_PARAMS.vh_nom, rTemp));

(* ============================================================
 * 3. MAQUINA DE ESTADOS PRINCIPAL
 * TODO: replicar transiciones exactas del chart Stateflow.
 * Por ahora: estructura mínima funcional.
 * ============================================================ *)
CASE estado OF
    SISTEMA_OK:
        BRK_hE_N0 := 1;
        BRK_t_N0  := 1;
        FALLA_MAN := FALSE;
        FALLA_WD  := FALSE;

        IF BTN_Emerg THEN
            estado := EMERG_MANUAL;
        ELSIF wd_state = WD_FALLO THEN
            estado := EMERG_WD;
        ELSIF FCE_der OR FCE_izq THEN
            estado := EMERG_CARRO;
        ELSIF FCE_sup OR FCE_inf OR (ABS(vh_obs) > 1.15 * vh_lim) THEN
            estado := EMERG_IZAJE;
        END_IF

    EMERG_MANUAL:
        BRK_hE_N0 := 0;
        BRK_t_N0  := 0;
        FALLA_MAN := TRUE;
        IF NOT BTN_Emerg AND BTN_Reset THEN
            estado := MODO_RECUPERACION;
        END_IF

    EMERG_CARRO:
        BRK_hE_N0 := 1;        // izaje libre
        BRK_t_N0  := 0;        // carro frenado
        FALLA_CARRO_DER := FCE_der;
        FALLA_CARRO_IZQ := FCE_izq;
        IF BTN_Reset THEN
            estado := MODO_RECUPERACION;
        END_IF

    EMERG_IZAJE:
        BRK_hE_N0 := 0;
        BRK_t_N0  := 1;
        FALLA_IZAJE_INF := FCE_inf;
        FALLA_IZAJE_SUP := FCE_sup;
        FALLA_IZAJE_SV  := ABS(vh_obs) > 1.15 * vh_lim;
        IF BTN_Reset THEN
            estado := MODO_RECUPERACION;
        END_IF

    EMERG_WD:
        BRK_hE_N0 := 0;
        BRK_t_N0  := 0;
        FALLA_WD  := TRUE;
        IF wd_state <> WD_FALLO AND BTN_Reset THEN
            estado := MODO_RECUPERACION;
        END_IF

    MODO_RECUPERACION:
        BRK_hE_N0 := 0;
        BRK_t_N0  := 0;
        IF recup_ok THEN
            FALLA_MAN := FALSE;
            FALLA_WD  := FALSE;
            FALLA_IZAJE_INF := FALSE;
            FALLA_IZAJE_SUP := FALSE;
            FALLA_IZAJE_SV  := FALSE;
            FALLA_CARRO_DER := FALSE;
            FALLA_CARRO_IZQ := FALSE;
            FALLA_CARRO_SV  := FALSE;
            estado := SISTEMA_OK;
        END_IF
END_CASE

(* ============================================================
 * 4. Publicar a GVL_PROCESS para que L1 lea
 * ============================================================ *)
GVL_PROCESS.FALLA_GLOBAL := FALLA_MAN OR FALLA_WD OR FALLA_IZAJE_SV
                          OR FALLA_IZAJE_INF OR FALLA_IZAJE_SUP
                          OR FALLA_CARRO_DER OR FALLA_CARRO_IZQ OR FALLA_CARRO_SV;
GVL_PROCESS.FALLA_MAN_L0       := FALLA_MAN;
GVL_PROCESS.FALLA_WD_L0        := FALLA_WD;
GVL_PROCESS.FALLA_SV_L0        := FALLA_IZAJE_SV;
GVL_PROCESS.FALLA_CARRO_DER_L0 := FALLA_CARRO_DER;
GVL_PROCESS.FALLA_CARRO_IZQ_L0 := FALLA_CARRO_IZQ;
GVL_PROCESS.FALLA_CARRO_SV_L0  := FALLA_CARRO_SV;
GVL_PROCESS.FALLA_IZAJE_INF_L0 := FALLA_IZAJE_INF;
GVL_PROCESS.FALLA_IZAJE_SUP_L0 := FALLA_IZAJE_SUP;
GVL_PROCESS.FALLA_IZAJE_SV_L0  := FALLA_IZAJE_SV;
GVL_PROCESS.RECUPERAR_L0       := (estado = MODO_RECUPERACION);
GVL_PROCESS.vh_lim_L0          := vh_lim;
GVL_PROCESS.BRK_h_N0           := BRK_hE_N0;
GVL_PROCESS.BRK_t_N0           := BRK_t_N0;
