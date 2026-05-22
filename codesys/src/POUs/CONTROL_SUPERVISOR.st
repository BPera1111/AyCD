(*
 * CONTROL_SUPERVISOR (Nivel 1)
 * Capa de supervisión: máquina principal manual/auto/error, twistlocks,
 * generación de heartbeat, suavizado cinemático, selección de trayectoria.
 * Ejecutar en Task_Supervisor cada 20 ms.
 *
 * STUB INICIAL: estructura básica. La lógica completa debe replicar
 * el chart Stateflow `planta/Nivel 1` de simulink/planta.slx
 *)
FUNCTION_BLOCK CONTROL_SUPERVISOR
VAR_INPUT
    // Recibidas vía COM_UDP_RX (desde GVL_COMMS.udp_from_sim)
    BTN_ON_OFF         : BOOL;
    BTN_TLK            : BOOL;
    BTN_Auto           : BOOL;
    BTN_Reset          : BOOL;
    Joy_XY             : ARRAY[1..2] OF LREAL;
    theta_l            : LREAL;
    theta_l_dot        : LREAL;
    vh_obs             : LREAL;
    vt_obs             : LREAL;
    Fhw                : LREAL;
    yh_enc             : LREAL;
    xt_enc             : LREAL;
    FC_der             : BOOL;
    FC_inf             : BOOL;
    FC_izq             : BOOL;
    FC_sup             : BOOL;
    T_hm               : LREAL;
    T_tm               : LREAL;
    // De L0 (vía GVL_PROCESS)
    FALLA_GLOBAL       : BOOL;
    RECUPERAR_L0       : BOOL;
END_VAR
VAR_OUTPUT
    BRK_h_N1           : INT;
    BRK_t_N1           : INT;
    TLK_OUT            : INT;
    yc0_vec_OUT        : ARRAY[1..33] OF LREAL;
    i_sel_OUT          : LREAL;
    vx_suave           : LREAL;
    vy_suave           : LREAL;
    recuperacion_OUT   : BOOL;
    modo_muerto        : BOOL;
    heartbeat_OUT      : INT;
    m_container_OUT    : LREAL;
END_VAR
VAR
    estado             : (STAND_BY, MANUAL, AUTO, PASO_STAND_BY,
                          ERROR_GENERICO, RECUPERACION) := STAND_BY;
    sub_auto           : (AUTO_INIT, SEL_INDICE_INI, SEL_INDICE_FIN,
                          SEL_TRAYECTORIA, MOV_CURVO, MOV_SEGURO,
                          MANUAL_SIMPLE) := AUTO_INIT;
    twistlock          : (TLK_VACIO, TLK_CERRANDO, TLK_CARGADO,
                          TLK_ABRIENDO) := TLK_VACIO;
    heartbeat_int      : INT := 0;
    i_origen           : INT := 0;
    i_destino          : INT := 0;
    i_sel              : INT := 1;
    cont_valido        : BOOL := FALSE;
    tlk_cerrado        : BOOL := FALSE;
    rAcc               : LREAL := 0.0;
    yc0_vec_initialized: BOOL := FALSE;
END_VAR

(* ============================================================
 * 1. INIT - cargar perfil inicial (una vez)
 * ============================================================ *)
IF NOT yc0_vec_initialized THEN
    (* Perfil inicial de containers (espejo h_vec_inicial * Hc en init_plant_parameters.m).
       Valores escalados por Hc=2.59. Editar si difieren los del chart Stateflow real. *)
    yc0_vec_OUT[1]  := 0.0;
    yc0_vec_OUT[2]  := 0.0;
    yc0_vec_OUT[3]  := GVL_PARAMS.Hc;
    yc0_vec_OUT[4]  := 0.0;
    yc0_vec_OUT[5]  := 0.0;
    yc0_vec_OUT[6]  := GVL_PARAMS.Hc;
    yc0_vec_OUT[7]  := 0.0;
    yc0_vec_OUT[8]  := 0.0;
    yc0_vec_OUT[9]  := 0.0;
    yc0_vec_OUT[10] := 0.0;
    yc0_vec_OUT[11] := 0.0;
    yc0_vec_OUT[12] := 0.0;
    yc0_vec_OUT[13] := GVL_PARAMS.alt_borde * GVL_PARAMS.Hc;
    yc0_vec_OUT[14] := 3.0 * GVL_PARAMS.Hc;
    yc0_vec_OUT[15] := 5.0 * GVL_PARAMS.Hc;
    yc0_vec_OUT[16] := 6.0 * GVL_PARAMS.Hc;
    yc0_vec_OUT[17] := 3.0 * GVL_PARAMS.Hc;
    yc0_vec_OUT[18] := 5.0 * GVL_PARAMS.Hc;
    yc0_vec_OUT[19] := 6.0 * GVL_PARAMS.Hc;
    yc0_vec_OUT[20] := 6.0 * GVL_PARAMS.Hc;
    yc0_vec_OUT[21] := 4.0 * GVL_PARAMS.Hc;
    yc0_vec_OUT[22] := 1.0 * GVL_PARAMS.Hc;
    yc0_vec_OUT[23] := 1.0 * GVL_PARAMS.Hc;
    yc0_vec_OUT[24] := -4.0 * GVL_PARAMS.Hc;
    yc0_vec_OUT[25] := -5.0 * GVL_PARAMS.Hc;
    yc0_vec_OUT[26] := -2.0 * GVL_PARAMS.Hc;
    yc0_vec_OUT[27] := -1.0 * GVL_PARAMS.Hc;
    yc0_vec_OUT[28] := 2.0 * GVL_PARAMS.Hc;
    yc0_vec_OUT[29] := 6.0 * GVL_PARAMS.Hc;
    yc0_vec_OUT[30] := 4.0 * GVL_PARAMS.Hc;
    yc0_vec_OUT[31] := 2.0 * GVL_PARAMS.Hc;
    yc0_vec_OUT[32] := 5.0 * GVL_PARAMS.Hc;
    yc0_vec_OUT[33] := GVL_PARAMS.alt_borde * GVL_PARAMS.Hc;
    yc0_vec_initialized := TRUE;
END_IF

(* ============================================================
 * 2. HEARTBEAT - toggle por ciclo para el watchdog de L0
 * ============================================================ *)
IF heartbeat_int = 0 THEN
    heartbeat_int := 1;
ELSE
    heartbeat_int := 0;
END_IF
heartbeat_OUT := heartbeat_int;
GVL_PROCESS.heartbeat_L1 := heartbeat_int;

(* ============================================================
 * 3. ESTIMACION DE MASA - cuando twistlock cerrado y carga colgando
 * TODO: replicar lógica del chart Stateflow
 * ============================================================ *)
IF tlk_cerrado THEN
    m_container_OUT := MAX(0.0, ABS(Fhw) / GVL_PARAMS.g - GVL_PARAMS.Ms);
ELSE
    m_container_OUT := 0.0;
END_IF
GVL_PROCESS.m_container_L1 := m_container_OUT;

(* ============================================================
 * 4. MAQUINA TWISTLOCKS (paralela a la principal)
 * ============================================================ *)
CASE twistlock OF
    TLK_VACIO:
        TLK_OUT := 0;
        IF BTN_TLK AND ABS(Fhw) > 100.0 THEN
            twistlock := TLK_CERRANDO;
        END_IF
    TLK_CERRANDO:
        TLK_OUT := 1;
        tlk_cerrado := TRUE;
        twistlock := TLK_CARGADO;
    TLK_CARGADO:
        TLK_OUT := 1;
        IF BTN_TLK AND ABS(Fhw) < 100.0 THEN
            twistlock := TLK_ABRIENDO;
        END_IF
    TLK_ABRIENDO:
        TLK_OUT := 0;
        tlk_cerrado := FALSE;
        twistlock := TLK_VACIO;
END_CASE

(* ============================================================
 * 5. MAQUINA PRINCIPAL
 * STUB - replicar transiciones exactas del chart Stateflow
 * ============================================================ *)
CASE estado OF
    STAND_BY:
        BRK_h_N1 := 0;
        BRK_t_N1 := 0;
        vx_suave := 0.0;
        vy_suave := 0.0;
        modo_muerto := TRUE;
        IF FALLA_GLOBAL THEN
            estado := ERROR_GENERICO;
        ELSIF BTN_ON_OFF AND NOT BTN_Auto THEN
            estado := MANUAL;
        ELSIF BTN_Auto THEN
            estado := AUTO;
            sub_auto := AUTO_INIT;
        END_IF

    MANUAL:
        BRK_h_N1 := 1;
        BRK_t_N1 := 1;
        modo_muerto := FALSE;
        // Aplicar zona muerta al joystick
        IF ABS(Joy_XY[1]) > GVL_PARAMS.dead_zone THEN
            vx_suave := Joy_XY[1] * GVL_PARAMS.vt_max;
        ELSE
            vx_suave := 0.0;
        END_IF
        IF ABS(Joy_XY[2]) > GVL_PARAMS.dead_zone THEN
            vy_suave := Joy_XY[2] * GVL_PARAMS.vh_max;
        ELSE
            vy_suave := 0.0;
        END_IF
        IF FALLA_GLOBAL THEN
            estado := ERROR_GENERICO;
        ELSIF NOT BTN_ON_OFF THEN
            estado := STAND_BY;
        END_IF

    AUTO:
        BRK_h_N1 := 1;
        BRK_t_N1 := 1;
        modo_muerto := FALSE;
        // Sub-máquina (TODO: completar transiciones reales)
        CASE sub_auto OF
            AUTO_INIT:
                sub_auto := SEL_INDICE_INI;
            SEL_INDICE_INI:
                IF ABS(Joy_XY[1]) > GVL_PARAMS.dead_zone THEN
                    // ajustar índice según signo del joystick
                    ;
                END_IF
                IF BTN_TLK THEN
                    i_origen := i_sel;
                    sub_auto := SEL_INDICE_FIN;
                END_IF
            SEL_INDICE_FIN:
                IF BTN_TLK THEN
                    i_destino := i_sel;
                    sub_auto := SEL_TRAYECTORIA;
                END_IF
            SEL_TRAYECTORIA:
                sub_auto := MOV_CURVO;
            MOV_CURVO:
                // mover hasta i_destino
                ;
            MOV_SEGURO:
                ;
            MANUAL_SIMPLE:
                ;
        END_CASE
        IF FALLA_GLOBAL THEN
            estado := ERROR_GENERICO;
        ELSIF NOT BTN_Auto THEN
            estado := PASO_STAND_BY;
        END_IF
        i_sel_OUT := DINT_TO_LREAL(i_sel);

    PASO_STAND_BY:
        vx_suave := 0.0;
        vy_suave := 0.0;
        IF ABS(vh_obs) < 0.01 AND ABS(vt_obs) < 0.01 THEN
            estado := STAND_BY;
        END_IF

    ERROR_GENERICO:
        BRK_h_N1 := 0;
        BRK_t_N1 := 0;
        vx_suave := 0.0;
        vy_suave := 0.0;
        modo_muerto := TRUE;
        IF RECUPERAR_L0 THEN
            estado := RECUPERACION;
        END_IF

    RECUPERACION:
        // Mover a posición segura (TODO: lógica completa)
        recuperacion_OUT := TRUE;
        IF NOT FALLA_GLOBAL THEN
            recuperacion_OUT := FALSE;
            estado := STAND_BY;
        END_IF
END_CASE

(* ============================================================
 * 6. Publicar a GVL_PROCESS y GVL_COMMS.udp_to_sim
 * ============================================================ *)
GVL_PROCESS.BRK_h_N1         := BRK_h_N1;
GVL_PROCESS.BRK_t_N1         := BRK_t_N1;
GVL_PROCESS.TLK_OUT          := TLK_OUT;
GVL_PROCESS.vx_suave         := vx_suave;
GVL_PROCESS.vy_suave         := vy_suave;
GVL_PROCESS.i_sel_OUT        := i_sel;
GVL_PROCESS.recuperacion_OUT := recuperacion_OUT;
GVL_PROCESS.modo_muerto_L1   := modo_muerto;
GVL_PROCESS.yc0_vec_OUT      := yc0_vec_OUT;
