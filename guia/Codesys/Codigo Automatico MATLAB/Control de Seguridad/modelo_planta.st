(*
 *
 * File: modelo_planta.st
 *
 * IEC 61131-3 Structured Text (ST) code generated for subsystem "modelo_planta/Control Nivel 0"
 *
 * Model name                      : modelo_planta
 * Model version                   : 5.74
 * Model creator                   : Nahuel
 * Model last modified by          : nahue
 * Model last modified on          : Thu Mar 12 12:31:50 2026
 * Model sample time               : 0.001s
 * Subsystem name                  : modelo_planta/Control Nivel 0
 * Subsystem sample time           : 0.02s
 * Simulink PLC Coder version      : 25.2 (R2025b) 28-Jul-2025
 * ST code generated on            : Thu Mar 12 16:31:46 2026
 *
 * Target IDE selection            : CODESYS 3.5
 * Test Bench included             : No
 *
 *)
FUNCTION_BLOCK Control
VAR_INPUT
    ssMethodType: SINT;
    BTN_Emerg: BOOL;
    FCE_der: BOOL;
    FCE_sup: BOOL;
    vh_obs: LREAL;
    FCE_izq: BOOL;
    FCE_inf: BOOL;
    BTN_Reset: BOOL;
    heartbeat: LREAL;
    m_container: LREAL;
    recup_ok: LREAL;
END_VAR
VAR_OUTPUT
    FALLA: LREAL;
    BRK_hE_N0: LREAL;
    BRK_t_N0: LREAL;
    RECUPERAR: LREAL;
    FALLA_MANUAL: LREAL;
    FALLA_IZAJE: LREAL;
    FALLA_CARRO: LREAL;
    FALLA_WD: LREAL;
END_VAR
VAR
    vh_lim: LREAL;
    WD_counter: LREAL;
    is_WATCHDOG: USINT;
    is_ESTADOS_SEGURIDAD: USINT;
    is_active_c7_Control: USINT;
END_VAR
VAR_TEMP
    temp1: BOOL;
    temp2: LREAL;
END_VAR
CASE ssMethodType OF
    SS_INITIALIZE: 
        (* SystemInitialize for Chart: '<Root>/Control Nivel 0' incorporates:
         *  Outport: '<Root>/FALLA'
         *  Outport: '<Root>/FALLA_CARRO'
         *  Outport: '<Root>/FALLA_IZAJE'
         *  Outport: '<Root>/FALLA_MANUAL'
         *  Outport: '<Root>/FALLA_WD'
         *  Outport: '<Root>/RECUPERAR' *)
        FALLA := 0.0;
        RECUPERAR := 0.0;
        FALLA_MANUAL := 0.0;
        FALLA_IZAJE := 0.0;
        FALLA_CARRO := 0.0;
        FALLA_WD := 0.0;
        WD_counter := 0.0;
        vh_lim := 0.0;
        is_active_c7_Control := 0;
        is_ESTADOS_SEGURIDAD := Control_IN_NO_ACTIVE_CHILD;
        is_WATCHDOG := Control_IN_NO_ACTIVE_CHILD;
    SS_STEP: 
        (* Chart: '<Root>/Control Nivel 0' incorporates:
         *  Outport: '<Root>/FALLA'
         *  Outport: '<Root>/FALLA_CARRO'
         *  Outport: '<Root>/FALLA_IZAJE'
         *  Outport: '<Root>/FALLA_MANUAL'
         *  Outport: '<Root>/FALLA_WD'
         *  Outport: '<Root>/RECUPERAR' *)
        (* Gateway: Control Nivel 0 *)
        (* During: Control Nivel 0 *)
        IF is_active_c7_Control = 0 THEN 
            (* Entry: Control Nivel 0 *)
            is_active_c7_Control := 1;
            (* Entry Internal: Control Nivel 0 *)
            (* Entry 'ESTADOS_SEGURIDAD': '<S1>:74' *)
            (* '<S1>:74:2' vh_lim = vh_max_unloaded; *)
            vh_lim := 3.0;
            (* Entry Internal 'ESTADOS_SEGURIDAD': '<S1>:74' *)
            (* Transition: '<S1>:23' *)
            is_ESTADOS_SEGURIDAD := Control_IN_SISTEMA_OK;
            (* Outport: '<Root>/BRK_hE_N0' *)
            (* Entry 'SISTEMA_OK': '<S1>:22' *)
            (* '<S1>:22:3' BRK_hE_N0 = 1; *)
            BRK_hE_N0 := 1.0;
            (* Outport: '<Root>/BRK_t_N0' *)
            (* '<S1>:22:3' BRK_t_N0 = 1; *)
            BRK_t_N0 := 1.0;
            (* '<S1>:22:4' FALLA_MANUAL = 0; *)
            FALLA_MANUAL := 0.0;
            (* '<S1>:22:5' FALLA_IZAJE = 0; *)
            FALLA_IZAJE := 0.0;
            (* '<S1>:22:5' FALLA_CARRO = 0; *)
            FALLA_CARRO := 0.0;
            (* '<S1>:22:6' FALLA = 0; *)
            FALLA := 0.0;
            (* '<S1>:22:6' FALLA_WD = 0; *)
            FALLA_WD := 0.0;
            (* '<S1>:22:7' RECUPERAR = 0; *)
            RECUPERAR := 0.0;
            (* Entry Internal 'WATCHDOG': '<S1>:54' *)
            (* Transition: '<S1>:80' *)
            is_WATCHDOG := Control_IN_HEARTBEAT_DOWN;
            (* Entry 'HEARTBEAT_DOWN': '<S1>:62' *)
            (* '<S1>:62:3' WD_counter = 0; *)
            WD_counter := 0.0;
        ELSE 
            (* During 'ESTADOS_SEGURIDAD': '<S1>:74' *)
            CASE is_ESTADOS_SEGURIDAD OF
                Control_IN_EMERGENCIA_CARRO: 
                    (* Outport: '<Root>/BRK_hE_N0' *)
                    BRK_hE_N0 := 1.0;
                    (* Outport: '<Root>/BRK_t_N0' *)
                    BRK_t_N0 := 0.0;
                    FALLA_CARRO := 1.0;
                    FALLA := 1.0;
                    (* During 'EMERGENCIA_CARRO': '<S1>:26' *)
                    (* '<S1>:46:1' sf_internal_predicateOutput = 0 | (BTN_Reset); *)
                    IF BTN_Reset THEN 
                        (* Transition: '<S1>:46' *)
                        is_ESTADOS_SEGURIDAD := c_Control_IN_MODO_RECUPERAC;
                        (* Outport: '<Root>/BRK_t_N0' *)
                        (* Entry 'MODO_RECUPERACION': '<S1>:41' *)
                        (* '<S1>:41:3' BRK_hE_N0 = 1; *)
                        (* '<S1>:41:3' BRK_t_N0 = 1; *)
                        BRK_t_N0 := 1.0;
                        (* '<S1>:41:4' RECUPERAR = 1; *)
                        RECUPERAR := 1.0;
                    END_IF;
                Control_IN_EMERGENCIA_IZAJE: 
                    (* Outport: '<Root>/BRK_hE_N0' *)
                    BRK_hE_N0 := 0.0;
                    (* Outport: '<Root>/BRK_t_N0' *)
                    BRK_t_N0 := 1.0;
                    FALLA_IZAJE := 1.0;
                    FALLA := 1.0;
                    (* During 'EMERGENCIA_IZAJE': '<S1>:30' *)
                    (* '<S1>:45:1' sf_internal_predicateOutput = 0 | (BTN_Reset); *)
                    IF BTN_Reset THEN 
                        (* Transition: '<S1>:45' *)
                        is_ESTADOS_SEGURIDAD := c_Control_IN_MODO_RECUPERAC;
                        (* Outport: '<Root>/BRK_hE_N0' *)
                        (* Entry 'MODO_RECUPERACION': '<S1>:41' *)
                        (* '<S1>:41:3' BRK_hE_N0 = 1; *)
                        BRK_hE_N0 := 1.0;
                        (* '<S1>:41:3' BRK_t_N0 = 1; *)
                        (* '<S1>:41:4' RECUPERAR = 1; *)
                        RECUPERAR := 1.0;
                    END_IF;
                c_Control_IN_EMERGENCIA_MAN: 
                    (* Outport: '<Root>/BRK_hE_N0' *)
                    BRK_hE_N0 := 0.0;
                    (* Outport: '<Root>/BRK_t_N0' *)
                    BRK_t_N0 := 0.0;
                    FALLA_MANUAL := 1.0;
                    FALLA := 1.0;
                    (* During 'EMERGENCIA_MANUAL': '<S1>:24' *)
                    (* '<S1>:42:1' sf_internal_predicateOutput = 0 | (BTN_Reset); *)
                    IF BTN_Reset THEN 
                        (* Transition: '<S1>:42' *)
                        is_ESTADOS_SEGURIDAD := c_Control_IN_MODO_RECUPERAC;
                        (* Outport: '<Root>/BRK_hE_N0' *)
                        (* Entry 'MODO_RECUPERACION': '<S1>:41' *)
                        (* '<S1>:41:3' BRK_hE_N0 = 1; *)
                        BRK_hE_N0 := 1.0;
                        (* Outport: '<Root>/BRK_t_N0' *)
                        (* '<S1>:41:3' BRK_t_N0 = 1; *)
                        BRK_t_N0 := 1.0;
                        (* '<S1>:41:4' RECUPERAR = 1; *)
                        RECUPERAR := 1.0;
                    END_IF;
                Control_IN_EMERGENCIA_WD: 
                    (* Outport: '<Root>/BRK_hE_N0' *)
                    BRK_hE_N0 := 0.0;
                    (* Outport: '<Root>/BRK_t_N0' *)
                    BRK_t_N0 := 0.0;
                    FALLA := 1.0;
                    (* During 'EMERGENCIA_WD': '<S1>:84' *)
                    (* '<S1>:88:1' sf_internal_predicateOutput = 0 | (BTN_Reset); *)
                    IF BTN_Reset THEN 
                        (* Transition: '<S1>:88' *)
                        is_ESTADOS_SEGURIDAD := c_Control_IN_MODO_RECUPERAC;
                        (* Outport: '<Root>/BRK_hE_N0' *)
                        (* Entry 'MODO_RECUPERACION': '<S1>:41' *)
                        (* '<S1>:41:3' BRK_hE_N0 = 1; *)
                        BRK_hE_N0 := 1.0;
                        (* Outport: '<Root>/BRK_t_N0' *)
                        (* '<S1>:41:3' BRK_t_N0 = 1; *)
                        BRK_t_N0 := 1.0;
                        (* '<S1>:41:4' RECUPERAR = 1; *)
                        RECUPERAR := 1.0;
                    END_IF;
                c_Control_IN_MODO_RECUPERAC: 
                    (* Outport: '<Root>/BRK_hE_N0' *)
                    BRK_hE_N0 := 1.0;
                    (* Outport: '<Root>/BRK_t_N0' *)
                    BRK_t_N0 := 1.0;
                    RECUPERAR := 1.0;
                    (* During 'MODO_RECUPERACION': '<S1>:41' *)
                    (* '<S1>:101:1' sf_internal_predicateOutput = 0 | (recup_ok == 1); *)
                    IF recup_ok = 1.0 THEN 
                        (* Transition: '<S1>:101' *)
                        is_ESTADOS_SEGURIDAD := Control_IN_SISTEMA_OK;
                        (* Entry 'SISTEMA_OK': '<S1>:22' *)
                        (* '<S1>:22:3' BRK_hE_N0 = 1; *)
                        (* '<S1>:22:3' BRK_t_N0 = 1; *)
                        (* '<S1>:22:4' FALLA_MANUAL = 0; *)
                        FALLA_MANUAL := 0.0;
                        (* '<S1>:22:5' FALLA_IZAJE = 0; *)
                        FALLA_IZAJE := 0.0;
                        (* '<S1>:22:5' FALLA_CARRO = 0; *)
                        FALLA_CARRO := 0.0;
                        (* '<S1>:22:6' FALLA = 0; *)
                        FALLA := 0.0;
                        (* '<S1>:22:6' FALLA_WD = 0; *)
                        FALLA_WD := 0.0;
                        (* '<S1>:22:7' RECUPERAR = 0; *)
                        RECUPERAR := 0.0;
                    END_IF;
                ELSE
                    (* Outport: '<Root>/BRK_hE_N0' *)
                    BRK_hE_N0 := 1.0;
                    (* Outport: '<Root>/BRK_t_N0' *)
                    BRK_t_N0 := 1.0;
                    FALLA_MANUAL := 0.0;
                    FALLA_IZAJE := 0.0;
                    FALLA_CARRO := 0.0;
                    FALLA := 0.0;
                    RECUPERAR := 0.0;
                    (* During 'SISTEMA_OK': '<S1>:22' *)
                    (* '<S1>:25:1' sf_internal_predicateOutput = 0 | (BTN_Emerg); *)
                    IF BTN_Emerg THEN 
                        (* Transition: '<S1>:25' *)
                        is_ESTADOS_SEGURIDAD := c_Control_IN_EMERGENCIA_MAN;
                        (* Outport: '<Root>/BRK_hE_N0' *)
                        (* Entry 'EMERGENCIA_MANUAL': '<S1>:24' *)
                        (* '<S1>:24:3' BRK_hE_N0 = 0; *)
                        BRK_hE_N0 := 0.0;
                        (* Outport: '<Root>/BRK_t_N0' *)
                        (* '<S1>:24:3' BRK_t_N0 = 0; *)
                        BRK_t_N0 := 0.0;
                        (* '<S1>:24:4' FALLA_MANUAL = 1; *)
                        FALLA_MANUAL := 1.0;
                        (* '<S1>:24:5' FALLA = 1; *)
                        FALLA := 1.0;
                    ELSE 
                        (* '<S1>:29:1' sf_internal_predicateOutput = 0 | (FCE_izq == 1 || FCE_der == 1); *)
                        IF FCE_izq OR FCE_der THEN 
                            (* Transition: '<S1>:29' *)
                            is_ESTADOS_SEGURIDAD := Control_IN_EMERGENCIA_CARRO;
                            (* Outport: '<Root>/BRK_t_N0' *)
                            (* Entry 'EMERGENCIA_CARRO': '<S1>:26' *)
                            (* '<S1>:26:3' BRK_hE_N0 = 1; *)
                            (* '<S1>:26:3' BRK_t_N0 = 0; *)
                            BRK_t_N0 := 0.0;
                            (* '<S1>:26:4' FALLA_CARRO = 1; *)
                            FALLA_CARRO := 1.0;
                            (* '<S1>:26:5' FALLA = 1; *)
                            FALLA := 1.0;
                        ELSE 
                            (* '<S1>:32:1' sf_internal_predicateOutput = 0 | (abs(vh_obs) > (1.15 * vh_lim) ||... *)
                            (* '<S1>:32:2'  FCE_sup == 1 || FCE_inf == 1); *)
                            temp1 := FALSE;
                            IF ABS(vh_obs) > (1.15 * vh_lim) THEN 
                                temp1 := TRUE;
                            ELSIF FCE_sup OR FCE_inf THEN 
                                temp1 := TRUE;
                            ELSE 
                                (* '<S1>:85:1' sf_internal_predicateOutput = 0 | (FALLA_WD==1); *)
                                IF FALLA_WD = 1.0 THEN 
                                    (* Transition: '<S1>:85' *)
                                    is_ESTADOS_SEGURIDAD := Control_IN_EMERGENCIA_WD;
                                    (* Outport: '<Root>/BRK_hE_N0' *)
                                    (* Entry 'EMERGENCIA_WD': '<S1>:84' *)
                                    (* '<S1>:84:3' BRK_hE_N0 = 0; *)
                                    BRK_hE_N0 := 0.0;
                                    (* Outport: '<Root>/BRK_t_N0' *)
                                    (* '<S1>:84:3' BRK_t_N0 = 0; *)
                                    BRK_t_N0 := 0.0;
                                    (* '<S1>:84:4' FALLA = 1; *)
                                    FALLA := 1.0;
                                ELSE 
                                    (* '<S1>:22:9' vh_lim = min(vh_max_unloaded,... *)
                                    (* '<S1>:22:10'       max(vh_nom, (P_nom / ((m_container+Ms) * g)))); *)
                                    temp2 := MAX(1.5, 956150.0 / ((m_container + 15000.0) * 9.80665));
                                    vh_lim := MIN(3.0, temp2);
                                END_IF;
                            END_IF;
                            IF temp1 THEN 
                                (* Transition: '<S1>:32' *)
                                is_ESTADOS_SEGURIDAD := Control_IN_EMERGENCIA_IZAJE;
                                (* Outport: '<Root>/BRK_hE_N0' *)
                                (* Entry 'EMERGENCIA_IZAJE': '<S1>:30' *)
                                (* '<S1>:30:3' BRK_hE_N0 = 0; *)
                                BRK_hE_N0 := 0.0;
                                (* '<S1>:30:3' BRK_t_N0 = 1; *)
                                (* '<S1>:30:4' FALLA_IZAJE = 1; *)
                                FALLA_IZAJE := 1.0;
                                (* '<S1>:30:5' FALLA = 1; *)
                                FALLA := 1.0;
                            END_IF;
                        END_IF;
                    END_IF;
            END_CASE;
            (* During 'WATCHDOG': '<S1>:54' *)
            CASE is_WATCHDOG OF
                Control_IN_DETECCION_FALLO: 
                    (* During 'DETECCION_FALLO': '<S1>:63' *)
                    (* '<S1>:78:1' sf_internal_predicateOutput = 0 | (FALLA_WD==0); *)
                    IF FALLA_WD = 0.0 THEN 
                        (* Transition: '<S1>:78' *)
                        is_WATCHDOG := Control_IN_HEARTBEAT_DOWN;
                        (* Entry 'HEARTBEAT_DOWN': '<S1>:62' *)
                        (* '<S1>:62:3' WD_counter = 0; *)
                        WD_counter := 0.0;
                    END_IF;
                Control_IN_HEARTBEAT_DOWN: 
                    (* During 'HEARTBEAT_DOWN': '<S1>:62' *)
                    (* '<S1>:60:1' sf_internal_predicateOutput = 0 | (heartbeat==1); *)
                    IF heartbeat = 1.0 THEN 
                        (* Transition: '<S1>:60' *)
                        is_WATCHDOG := Control_IN_HEARTBEAT_UP;
                        (* Entry 'HEARTBEAT_UP': '<S1>:57' *)
                        (* '<S1>:57:3' WD_counter = 0; *)
                        WD_counter := 0.0;
                    ELSE 
                        (* '<S1>:67:1' sf_internal_predicateOutput = 0 | (WD_counter >= counter_limit); *)
                        IF WD_counter >= 15.0 THEN 
                            (* Transition: '<S1>:67' *)
                            is_WATCHDOG := Control_IN_DETECCION_FALLO;
                            (* Entry 'DETECCION_FALLO': '<S1>:63' *)
                            (* '<S1>:63:3' FALLA_WD = 1; *)
                            FALLA_WD := 1.0;
                        ELSE 
                            (* '<S1>:62:5' WD_counter = WD_counter + 1; *)
                            WD_counter := WD_counter + 1.0;
                        END_IF;
                    END_IF;
                ELSE
                    (* During 'HEARTBEAT_UP': '<S1>:57' *)
                    (* '<S1>:61:1' sf_internal_predicateOutput = 0 | (heartbeat==0); *)
                    IF heartbeat = 0.0 THEN 
                        (* Transition: '<S1>:61' *)
                        is_WATCHDOG := Control_IN_HEARTBEAT_DOWN;
                        (* Entry 'HEARTBEAT_DOWN': '<S1>:62' *)
                        (* '<S1>:62:3' WD_counter = 0; *)
                        WD_counter := 0.0;
                    ELSE 
                        (* '<S1>:68:1' sf_internal_predicateOutput = 0 | (WD_counter >= counter_limit); *)
                        IF WD_counter >= 15.0 THEN 
                            (* Transition: '<S1>:68' *)
                            is_WATCHDOG := Control_IN_DETECCION_FALLO;
                            (* Entry 'DETECCION_FALLO': '<S1>:63' *)
                            (* '<S1>:63:3' FALLA_WD = 1; *)
                            FALLA_WD := 1.0;
                        ELSE 
                            (* '<S1>:57:5' WD_counter = WD_counter + 1; *)
                            WD_counter := WD_counter + 1.0;
                        END_IF;
                    END_IF;
            END_CASE;
        END_IF;
        (* End of Chart: '<Root>/Control Nivel 0' *)
END_CASE;
END_FUNCTION_BLOCK
VAR_GLOBAL CONSTANT
    Control_IN_NO_ACTIVE_CHILD: USINT := 0;
    Control_IN_EMERGENCIA_CARRO: USINT := 1;
    Control_IN_EMERGENCIA_IZAJE: USINT := 2;
    c_Control_IN_EMERGENCIA_MAN: USINT := 3;
    Control_IN_EMERGENCIA_WD: USINT := 4;
    c_Control_IN_MODO_RECUPERAC: USINT := 5;
    Control_IN_SISTEMA_OK: USINT := 6;
    Control_IN_DETECCION_FALLO: USINT := 1;
    Control_IN_HEARTBEAT_DOWN: USINT := 2;
    Control_IN_HEARTBEAT_UP: USINT := 3;
    SS_INITIALIZE: SINT := 0;
    SS_STEP: SINT := 1;
END_VAR
