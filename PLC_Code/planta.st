(*
 *
 * File: planta.st
 *
 * IEC 61131-3 Structured Text (ST) code generated for subsystem "planta/Nivel 1"
 *
 * Model name                      : planta
 * Model version                   : 3.75
 * Model creator                   : lauta
 * Model last modified by          : bruno
 * Model last modified on          : Thu May 28 19:57:44 2026
 * Model sample time               : 0s
 * Subsystem name                  : planta/Nivel 1
 * Subsystem sample time           : 0.001s
 * Simulink PLC Coder version      : 25.2 (R2025b) 28-Jul-2025
 * ST code generated on            : Fri May 29 22:26:18 2026
 *
 * Target IDE selection            : CODESYS 3.5
 * Test Bench included             : No
 *
 *)
FUNCTION_BLOCK Nivel
VAR_INPUT
    ssMethodType: SINT;
    B: LREAL;
    Joy_XY: ARRAY [0..1] OF LREAL;
    tita_l: LREAL;
    theta_l_dot: LREAL;
    vh_obs: LREAL;
    vt_obs: LREAL;
    Fhw: LREAL;
    yh: LREAL;
    A: BOOL;
    xt: LREAL;
    b_RESET: BOOL;
    FC_der: BOOL;
    FC_INF: BOOL;
    FC_izq: BOOL;
    FC_sup: BOOL;
    X: BOOL;
    FALLA_MAN: LREAL;
    FALLA_WD: LREAL;
    FALLA_IZAJE_SV: LREAL;
    T_hm: LREAL;
    T_tm: LREAL;
END_VAR
VAR_OUTPUT
    BRK_h_N1: LREAL;
    BRK_t_N1: LREAL;
    TLK: LREAL;
    yc0_vec: ARRAY [0..32] OF LREAL;
    i_sel: LREAL;
    vx_suave: LREAL;
    vy_suave: LREAL;
    recuperacion: LREAL;
    modo_muerto: LREAL;
    heartbeat: LREAL;
    m_container: LREAL;
    modo_auto: LREAL;
    modo_manual: LREAL;
    modo_manual_auto: LREAL;
    modo_reposo: LREAL;
    modo_error: LREAL;
    sobrecarga: LREAL;
END_VAR
VAR
    Nivel1_yc0_vec_inicial: ARRAY [0..32] OF LREAL := 0.0,0.0,2.59,0.0,0.0,2.59,0.0,0.0,0.0,0.0,0.0,0.0,
        7.2519999999999989,7.77,12.95,15.54,7.77,12.95,15.54,15.54,10.36,2.59,2.59,-10.36,-12.95,-5.18,-2.59,5.18,
        15.54,10.36,5.18,12.95,7.2519999999999989;
    b_yc0_vec: ARRAY [0..32] OF LREAL;
    i_usado: LREAL;
    i_carro: LREAL;
    last_i_ref: LREAL;
    temporalCounter_i2: USINT;
    temporalCounter_i1: USINT;
    temporalCounter_i3: PLC_CODER_TIMER;
    b_sobrecarga: LREAL;
    b_modo_error: LREAL;
    b_modo_reposo: LREAL;
    b_modo_manual_auto: LREAL;
    b_modo_manual: LREAL;
    b_modo_auto: LREAL;
    ciclo_doble: LREAL;
    ejec_mov_final: LREAL;
    home: LREAL;
    b_m_container: LREAL;
    m_est: LREAL;
    flag2: LREAL;
    scan: LREAL;
    flag1: LREAL;
    b_heartbeat: LREAL;
    b_modo_muerto: LREAL;
    error_otro: LREAL;
    b_recuperacion: LREAL;
    ya_vuelvo: LREAL;
    vy_target: LREAL;
    vx_target: LREAL;
    b_vy_suave: LREAL;
    b_vx_suave: LREAL;
    jerk_max: LREAL;
    ay_act: LREAL;
    ax_act: LREAL;
    b_i_sel: LREAL;
    cont: LREAL;
    estado: LREAL;
    manual_ok: LREAL;
    invalido: LREAL;
    i_destino: LREAL;
    i_origen: LREAL;
    error_sup: LREAL;
    error_izq: LREAL;
    error_inf: LREAL;
    error_der: LREAL;
    vel_error: LREAL;
    vh_lim: LREAL;
    TLK_anterior: LREAL;
    y_start: LREAL;
    hay_cont: LREAL;
    b_TLK: LREAL;
    dead_zone: LREAL;
    b_BRK_t_N1: LREAL;
    b_BRK_h_N1: LREAL;
    is_MODO_AUTO: USINT;
    is_AUTOMATA_PRINCIPAL: USINT;
    tp_AUTOMATA_PRINCIPAL: USINT;
    is_WATCHDOG_HEARTBEAT: USINT;
    tp_INDICES_PERFIL: USINT;
    is_TWISTLOCKS: USINT;
    tp_TWISTLOCKS: USINT;
    is_c3_Nivel: USINT;
    is_active_c3_Nivel: USINT;
    durationCounter_1: UDINT;
    durationCounter_1_m: UDINT;
    durationCounter_2: UDINT;
    i0_Suavizador_Cinematico: Suavizador_Cinematico;
    i0_isMember: isMember;
END_VAR
VAR_TEMP
    TLK_fall: BOOL;
    e_hoisted_cond: BOOL;
    perfil_seguro: ARRAY [0..32] OF LREAL;
    b_i: DINT;
    c_i: DINT;
    H_extra: LREAL;
    i_obj: LREAL;
    i_act: DINT;
    x_dest: LREAL;
    b_step: DINT;
    h_obst_fwd: DINT;
    limite_vx_sinc: LREAL;
    dy: LREAL;
    vx_max_permitida: LREAL;
    limite_vx_final: LREAL;
    y_target: LREAL;
    c_k: DINT;
    d_k: DINT;
    b_H_extra: LREAL;
    b_i_obj: LREAL;
    b_i_act: DINT;
    b_x_dest: LREAL;
    b_b_step: DINT;
    b_h_obst_fwd: LREAL;
    e_k: LREAL;
    b_limite_vx_sinc: LREAL;
    b_dy: LREAL;
    b_vx_max_permitida: LREAL;
    b_limite_vx_final: LREAL;
    b_h_dest_final: LREAL;
    b_y_target: LREAL;
    f_k: DINT;
    g_k: DINT;
    T_retardo: LREAL;
    dist: LREAL;
    envolvente: ARRAY [0..32] OF LREAL;
    i: DINT;
    i_carro_tmp: LREAL;
    temp1: BOOL;
    temp2: BOOL;
    temp3: BOOL;
    temp4: BOOL;
    b_temp2: LREAL;
    b_temp3: LREAL;
    b_temp4: LREAL;
    temp5: LREAL;
    temp6: LREAL;
    temp7: LREAL;
    temp8: LREAL;
    temp9: LREAL;
    temp10: LREAL;
    temp11: LREAL;
    temp12: LREAL;
    temp13: LREAL;
    temp14: LREAL;
    temp15: LREAL;
    temp16: LREAL;
    temp17: LREAL;
END_VAR
CASE ssMethodType OF
    SS_INITIALIZE: 
        plc_ts_counter1 := 0;
        (* SystemInitialize for Chart: '<Root>/Nivel 1' *)
        temporalCounter_i3(timerAction := 1, maxTime := 0);
        temporalCounter_i1 := 0;
        temporalCounter_i2 := 0;
        (* '<S1>:310:7' last_i_ref = -1; *)
        last_i_ref := -1.0;
        b_BRK_h_N1 := 0.0;
        b_BRK_t_N1 := 0.0;
        dead_zone := 0.0;
        b_TLK := 0.0;
        hay_cont := 0.0;
        y_start := 0.0;
        (* SystemInitialize for Chart: '<Root>/Nivel 1' *)
        FOR i := 0 TO 32 DO 
            b_yc0_vec[i] := 0.0;
        END_FOR;
        TLK_anterior := 0.0;
        i_carro := 0.0;
        vh_lim := 0.0;
        vel_error := 0.0;
        error_der := 0.0;
        error_inf := 0.0;
        error_izq := 0.0;
        error_sup := 0.0;
        i_origen := 1.0;
        i_destino := 1.0;
        invalido := 0.0;
        manual_ok := 0.0;
        i_usado := 0.0;
        estado := 0.0;
        cont := 0.0;
        b_i_sel := 1.0;
        ax_act := 0.0;
        ay_act := 0.0;
        jerk_max := 0.0;
        b_vx_suave := 0.0;
        b_vy_suave := 0.0;
        vx_target := 0.0;
        vy_target := 0.0;
        ya_vuelvo := 0.0;
        b_recuperacion := 0.0;
        error_otro := 0.0;
        b_modo_muerto := 0.0;
        b_heartbeat := 0.0;
        flag1 := 0.0;
        scan := 0.0;
        flag2 := 0.0;
        m_est := 0.0;
        b_m_container := 0.0;
        home := 0.0;
        ejec_mov_final := 0.0;
        ciclo_doble := 0.0;
        b_modo_auto := 0.0;
        b_modo_manual := 0.0;
        b_modo_manual_auto := 0.0;
        b_modo_reposo := 0.0;
        b_modo_error := 0.0;
        b_sobrecarga := 0.0;
        is_active_c3_Nivel := 0;
        is_c3_Nivel := Nivel_IN_NO_ACTIVE_CHILD;
        tp_TWISTLOCKS := 0;
        is_TWISTLOCKS := Nivel_IN_NO_ACTIVE_CHILD;
        tp_INDICES_PERFIL := 0;
        is_WATCHDOG_HEARTBEAT := Nivel_IN_NO_ACTIVE_CHILD;
        tp_AUTOMATA_PRINCIPAL := 0;
        is_AUTOMATA_PRINCIPAL := Nivel_IN_NO_ACTIVE_CHILD;
        is_MODO_AUTO := Nivel_IN_NO_ACTIVE_CHILD;
    SS_STEP: 
        IF plc_ts_counter1 = 0 THEN 
            (* Chart: '<Root>/Nivel 1' *)
            (* Gateway: Nivel 1 *)
            IF temporalCounter_i1 < 50 THEN 
                temporalCounter_i1 := DINT_TO_USINT(USINT_TO_DINT(temporalCounter_i1) + 1);
            END_IF;
            IF temporalCounter_i2 < 50 THEN 
                temporalCounter_i2 := DINT_TO_USINT(USINT_TO_DINT(temporalCounter_i2) + 1);
            END_IF;
            (* During: Nivel 1 *)
            IF is_active_c3_Nivel = 0 THEN 
                (* Entry: Nivel 1 *)
                is_active_c3_Nivel := 1;
                (* Entry Internal: Nivel 1 *)
                (* Transition: '<S1>:364' *)
                is_c3_Nivel := Nivel_IN_Muerto;
                (* Entry 'Muerto': '<S1>:362' *)
                (* '<S1>:362:3' modo_muerto=1; *)
                b_modo_muerto := 1.0;
                (* '<S1>:362:4' BRK_h_N1=0; *)
                b_BRK_h_N1 := 0.0;
                (* '<S1>:362:5' BRK_t_N1=0; *)
                b_BRK_t_N1 := 0.0;
                (* '<S1>:362:6' modo_reposo =0; *)
                b_modo_reposo := 0.0;
                durationCounter_1_m := 0;
                (* '<S1>:362:7' TLK = 0; *)
                b_TLK := 0.0;
            ELSE 
                CASE is_c3_Nivel OF
                    Nivel_IN_Automata: 
                        (* During 'Automata': '<S1>:361' *)
                        (* '<S1>:366:1' sf_internal_predicateOutput = 0 | (duration((BTN_ON_OFF==0 && modo_reposo == 1),sec)>2 && ...  *)
                        (* '<S1>:366:2' duration(TLK==0,sec)>2); *)
                        IF (B <> 0.0) OR (b_modo_reposo <> 1.0) THEN 
                            durationCounter_1_m := 0;
                        END_IF;
                        temp1 := FALSE;
                        IF durationCounter_1_m > 100 THEN 
                            IF b_TLK <> 0.0 THEN 
                                durationCounter_2 := 0;
                            END_IF;
                            IF durationCounter_2 > 100 THEN 
                                (* Transition: '<S1>:366' *)
                                (* Exit Internal 'Automata': '<S1>:361' *)
                                (* Exit Internal 'AUTOMATA_PRINCIPAL': '<S1>:1' *)
                                CASE is_AUTOMATA_PRINCIPAL OF
                                    Nivel_IN_ERROR_FC_izq_der: 
                                        is_AUTOMATA_PRINCIPAL := Nivel_IN_NO_ACTIVE_CHILD;
                                    Nivel_IN_ERROR_FC_sup_inf: 
                                        is_AUTOMATA_PRINCIPAL := Nivel_IN_NO_ACTIVE_CHILD;
                                    Nivel_IN_ERROR_OTRO: 
                                        is_AUTOMATA_PRINCIPAL := Nivel_IN_NO_ACTIVE_CHILD;
                                    Nivel_IN_MANUAL: 
                                        (* Exit 'MANUAL': '<S1>:9' *)
                                        (* '<S1>:9:23' modo_manual = 0; *)
                                        b_modo_manual := 0.0;
                                        is_AUTOMATA_PRINCIPAL := Nivel_IN_NO_ACTIVE_CHILD;
                                    Nivel_IN_MODO_AUTO: 
                                        (* Exit Internal 'MODO_AUTO': '<S1>:240' *)
                                        CASE is_MODO_AUTO OF
                                            Nivel_IN_AUTO_INIT: 
                                                is_MODO_AUTO := Nivel_IN_NO_ACTIVE_CHILD;
                                            Nivel_IN_MODO_MANUAL_SIMPLE: 
                                                (* Exit 'MODO_MANUAL_SIMPLE': '<S1>:250' *)
                                                (* '<S1>:250:23' estado = estado + 1; *)
                                                estado := estado + 1.0;
                                                (* '<S1>:250:24' modo_manual_auto = 0; *)
                                                b_modo_manual_auto := 0.0;
                                                is_MODO_AUTO := Nivel_IN_NO_ACTIVE_CHILD;
                                            Nivel_IN_MOVIMIENTO_CURVO: 
                                                (* Exit 'MOVIMIENTO_CURVO': '<S1>:297' *)
                                                (* '<S1>:297:18' ejec_mov = 0; *)
                                                is_MODO_AUTO := Nivel_IN_NO_ACTIVE_CHILD;
                                            c_Nivel_IN_MOVIMIENTO_CURVO: 
                                                (* Exit 'MOVIMIENTO_CURVO_FINAL': '<S1>:386' *)
                                                (* '<S1>:386:15' ejec_mov_final = 0; *)
                                                ejec_mov_final := 0.0;
                                                is_MODO_AUTO := Nivel_IN_NO_ACTIVE_CHILD;
                                            c_Nivel_IN_SELECCION_TRAYEC: 
                                                is_MODO_AUTO := Nivel_IN_NO_ACTIVE_CHILD;
                                            Nivel_IN_SEL_DESTINO: 
                                                (* Exit 'SEL_DESTINO': '<S1>:311' *)
                                                (* '<S1>:311:17' i_destino = i_sel; *)
                                                i_destino := b_i_sel;
                                                is_MODO_AUTO := Nivel_IN_NO_ACTIVE_CHILD;
                                            Nivel_IN_SEL_ORIGEN: 
                                                (* Exit 'SEL_ORIGEN': '<S1>:190' *)
                                                (* '<S1>:190:14' i_origen = i_sel; *)
                                                i_origen := b_i_sel;
                                                is_MODO_AUTO := Nivel_IN_NO_ACTIVE_CHILD;
                                        END_CASE;
                                        (* Exit 'MODO_AUTO': '<S1>:240' *)
                                        (* '<S1>:240:10' if(ya_vuelvo == 0) *)
                                        IF ya_vuelvo = 0.0 THEN 
                                            (* '<S1>:240:11' modo_auto = 0; *)
                                            b_modo_auto := 0.0;
                                            (* '<S1>:240:12' modo_manual_auto = 0; *)
                                            b_modo_manual_auto := 0.0;
                                            (* '<S1>:240:13' ejec_mov = 0; *)
                                        END_IF;
                                        is_AUTOMATA_PRINCIPAL := Nivel_IN_NO_ACTIVE_CHILD;
                                    Nivel_IN_RECUPERACION: 
                                        (* Exit 'RECUPERACION': '<S1>:118' *)
                                        (* '<S1>:118:32' recuperacion = 0; *)
                                        b_recuperacion := 0.0;
                                        (* modo_error = 1; *)
                                        is_AUTOMATA_PRINCIPAL := Nivel_IN_NO_ACTIVE_CHILD;
                                    Nivel_IN_REPOSO: 
                                        (* Exit 'REPOSO': '<S1>:5' *)
                                        (* '<S1>:5:12' modo_reposo = 0; *)
                                        is_AUTOMATA_PRINCIPAL := Nivel_IN_NO_ACTIVE_CHILD;
                                END_CASE;
                                tp_AUTOMATA_PRINCIPAL := 0;
                                (* Exit Internal 'WATCHDOG_HEARTBEAT': '<S1>:369' *)
                                CASE is_WATCHDOG_HEARTBEAT OF
                                    Nivel_IN_PULSOS_DOWN: 
                                        is_WATCHDOG_HEARTBEAT := Nivel_IN_NO_ACTIVE_CHILD;
                                    Nivel_IN_PULSOS_UP: 
                                        is_WATCHDOG_HEARTBEAT := Nivel_IN_NO_ACTIVE_CHILD;
                                END_CASE;
                                (* Exit Internal 'INDICES_PERFIL': '<S1>:80' *)
                                tp_INDICES_PERFIL := 0;
                                (* Exit Internal 'TWISTLOCKS': '<S1>:42' *)
                                CASE is_TWISTLOCKS OF
                                    Nivel_IN_ABRIENDO_TLK: 
                                        is_TWISTLOCKS := Nivel_IN_NO_ACTIVE_CHILD;
                                    Nivel_IN_CARGADO: 
                                        is_TWISTLOCKS := Nivel_IN_NO_ACTIVE_CHILD;
                                    Nivel_IN_CERRANDO_TLK: 
                                        is_TWISTLOCKS := Nivel_IN_NO_ACTIVE_CHILD;
                                    Nivel_IN_VACIO: 
                                        is_TWISTLOCKS := Nivel_IN_NO_ACTIVE_CHILD;
                                END_CASE;
                                tp_TWISTLOCKS := 0;
                                is_c3_Nivel := Nivel_IN_Muerto;
                                (* Entry 'Muerto': '<S1>:362' *)
                                (* '<S1>:362:3' modo_muerto=1; *)
                                b_modo_muerto := 1.0;
                                (* '<S1>:362:4' BRK_h_N1=0; *)
                                b_BRK_h_N1 := 0.0;
                                (* '<S1>:362:5' BRK_t_N1=0; *)
                                b_BRK_t_N1 := 0.0;
                                (* '<S1>:362:6' modo_reposo =0; *)
                                b_modo_reposo := 0.0;
                                durationCounter_1_m := 0;
                                (* '<S1>:362:7' TLK = 0; *)
                                b_TLK := 0.0;
                            ELSE 
                                temp1 := TRUE;
                            END_IF;
                        ELSE 
                            temp1 := TRUE;
                        END_IF;
                        IF temp1 THEN 
                            (* During 'TWISTLOCKS': '<S1>:42' *)
                            CASE is_TWISTLOCKS OF
                                Nivel_IN_ABRIENDO_TLK: 
                                    (* During 'ABRIENDO_TLK': '<S1>:43' *)
                                    (* '<S1>:40:1' sf_internal_predicateOutput = 0 | (Fhw > (Ms*g/2*0.8) &&... *)
                                    (* '<S1>:40:2'  abs(yh_enc - y_start) > 0.3 &&... *)
                                    (* '<S1>:40:3'  abs(vt_obs) < 0.01); *)
                                    temp2 := FALSE;
                                    IF Fhw > 58839.9 THEN 
                                        IF ABS(yh - y_start) > 0.3 THEN 
                                            IF ABS(vt_obs) < 0.01 THEN 
                                                (* Transition: '<S1>:40' *)
                                                is_TWISTLOCKS := Nivel_IN_VACIO;
                                                (* Entry 'VACIO': '<S1>:38' *)
                                                (* '<S1>:38:3' TLK = 0; *)
                                                b_TLK := 0.0;
                                                (* '<S1>:38:4' m_est = Ms; *)
                                                m_est := 15000.0;
                                                (* '<S1>:38:5' sobrecarga = 0; *)
                                                b_sobrecarga := 0.0;
                                            ELSE 
                                                temp2 := TRUE;
                                            END_IF;
                                        ELSE 
                                            temp2 := TRUE;
                                        END_IF;
                                    ELSE 
                                        temp2 := TRUE;
                                    END_IF;
                                    IF temp2 THEN 
                                        (* '<S1>:43:8' m_est = max(Ms, Fhw * 2 / g); *)
                                        m_est := MAX(15000.0, (Fhw * 2.0) / 9.80665);
                                        (* '<S1>:43:9' vh_lim = 0.1; *)
                                        vh_lim := 0.1;
                                        (* '<S1>:43:10' vx_target = 0; *)
                                        vx_target := 0.0;
                                    END_IF;
                                Nivel_IN_CARGADO: 
                                    (* During 'CARGADO': '<S1>:35' *)
                                    (* '<S1>:37:1' sf_internal_predicateOutput = 0 | ((BTN_TLK == 1) &&... *)
                                    (* '<S1>:37:2'  Fhw < ((m_est*g/2)*0.8) &&... *)
                                    (* '<S1>:37:3' ~ismember(i_carro, [1, 13, 33])); *)
                                    temp2 := FALSE;
                                    IF A THEN 
                                        IF Fhw < (((m_est * 9.80665) / 2.0) * 0.8) THEN 
                                            i0_isMember(a := i_carro);
                                            IF  NOT i0_isMember.tf THEN 
                                                (* Transition: '<S1>:37' *)
                                                is_TWISTLOCKS := Nivel_IN_ABRIENDO_TLK;
                                                (* Entry 'ABRIENDO_TLK': '<S1>:43' *)
                                                (* '<S1>:43:3' TLK = 0; *)
                                                b_TLK := 0.0;
                                                (* '<S1>:43:4' y_start = yh_enc; *)
                                                y_start := yh;
                                                (* '<S1>:43:5' m_container = 0; *)
                                                b_m_container := 0.0;
                                                (* '<S1>:43:6' sobrecarga = 0; *)
                                                b_sobrecarga := 0.0;
                                            ELSE 
                                                temp2 := TRUE;
                                            END_IF;
                                        ELSE 
                                            temp2 := TRUE;
                                        END_IF;
                                    ELSE 
                                        temp2 := TRUE;
                                    END_IF;
                                    IF temp2 THEN 
                                        (* m_est = max(Ms, (Fhw * 2 / g)); *)
                                        (* '<S1>:35:9' vh_lim = min(vh_max,... *)
                                        (* '<S1>:35:10'        max(vh_nom, P_nom / ((m_container + Ms) * g))); *)
                                        b_temp2 := MAX(1.5, 956150.0 / ((b_m_container + 15000.0) * 9.80665));
                                        vh_lim := MIN(3.0, b_temp2);
                                        (* '<S1>:35:11' if (sobrecarga == 1) *)
                                        IF b_sobrecarga = 1.0 THEN 
                                            (* '<S1>:35:12' vh_lim = 0.1; *)
                                            vh_lim := 0.1;
                                            (* '<S1>:35:12' vx_target = 0; *)
                                            vx_target := 0.0;
                                            (* '<S1>:35:13' if (vy_target > 0) *)
                                            IF vy_target > 0.0 THEN 
                                                (* '<S1>:35:13' vy_target = 0; *)
                                                vy_target := 0.0;
                                            END_IF;
                                        END_IF;
                                    END_IF;
                                Nivel_IN_CERRANDO_TLK: 
                                    (* During 'CERRANDO_TLK': '<S1>:34' *)
                                    (* '<S1>:41:1' sf_internal_predicateOutput = 0 | (Fhw > (Ms*g/2 * 1.2) &&... *)
                                    (* '<S1>:41:2'  abs(yh_enc - y_start) > 0.3 &&... *)
                                    (* '<S1>:41:3'  abs(vt_obs) < 0.01); *)
                                    temp2 := FALSE;
                                    IF Fhw > 88259.849999999991 THEN 
                                        IF ABS(yh - y_start) > 0.3 THEN 
                                            IF ABS(vt_obs) < 0.01 THEN 
                                                (* Transition: '<S1>:41' *)
                                                is_TWISTLOCKS := Nivel_IN_CARGADO;
                                                (* Entry 'CARGADO': '<S1>:35' *)
                                                (* '<S1>:35:3' m_container = m_est - Ms; *)
                                                b_m_container := m_est - 15000.0;
                                                (* Masa estimada container *)
                                                (* '<S1>:35:4' if (m_container > (Mc_max + 100)) *)
                                                IF b_m_container > 50100.0 THEN 
                                                    (* Margen de 100kg *)
                                                    (* '<S1>:35:5' sobrecarga = 1; *)
                                                    b_sobrecarga := 1.0;
                                                END_IF;
                                            ELSE 
                                                temp2 := TRUE;
                                            END_IF;
                                        ELSE 
                                            temp2 := TRUE;
                                        END_IF;
                                    ELSE 
                                        temp2 := TRUE;
                                    END_IF;
                                    IF temp2 THEN 
                                        (* '<S1>:34:6' vh_lim = 0.1; *)
                                        vh_lim := 0.1;
                                        (* '<S1>:34:7' vx_target = 0; *)
                                        vx_target := 0.0;
                                        (* Filtro *)
                                        (* '<S1>:34:9' m_est = m_est + 0.1 *... *)
                                        (* '<S1>:34:10'        (max(Ms, (Fhw * 2 / g)) - m_est); *)
                                        m_est := ((MAX(15000.0, (Fhw * 2.0) / 9.80665) - m_est) * 0.1) + m_est;
                                        (* '<S1>:34:11' m_container=m_est-Ms; *)
                                        b_m_container := m_est - 15000.0;
                                    END_IF;
                                ELSE
                                    (* During 'VACIO': '<S1>:38' *)
                                    (* '<S1>:36:1' sf_internal_predicateOutput = 0 | ((BTN_TLK == 1) &&... *)
                                    (* '<S1>:36:2'  Fhw < (Ms*g/2 * 0.8) &&... *)
                                    (* '<S1>:36:3'  hay_cont == 1); *)
                                    temp2 := FALSE;
                                    IF A THEN 
                                        IF Fhw < 58839.9 THEN 
                                            IF hay_cont = 1.0 THEN 
                                                (* Transition: '<S1>:36' *)
                                                is_TWISTLOCKS := Nivel_IN_CERRANDO_TLK;
                                                (* Entry 'CERRANDO_TLK': '<S1>:34' *)
                                                (* '<S1>:34:3' TLK = 1; *)
                                                b_TLK := 1.0;
                                                durationCounter_2 := 0;
                                                (* '<S1>:34:4' y_start = yh_enc; *)
                                                y_start := yh;
                                            ELSE 
                                                temp2 := TRUE;
                                            END_IF;
                                        ELSE 
                                            temp2 := TRUE;
                                        END_IF;
                                    ELSE 
                                        temp2 := TRUE;
                                    END_IF;
                                    IF temp2 THEN 
                                        (* '<S1>:38:7' hay_cont = Check_Container... *)
                                        (* '<S1>:38:8'        (i_carro, yc0_vec); *)
                                        hay_cont := Check_Container(i_pos := i_carro, y0_vec := b_yc0_vec);
                                        (* '<S1>:38:9' vh_lim = vh_max; *)
                                        vh_lim := 3.0;
                                    END_IF;
                            END_CASE;
                            (* During 'INDICES_PERFIL': '<S1>:80' *)
                            (* During 'INDICES': '<S1>:83' *)
                            (* '<S1>:83:5' i_carro = floor((xt_enc - xt_min)/Wc) + 1; *)
                            i_carro_tmp := rt_floord(u := (xt - -30.0) / 2.44) + 1.0;
                            i_carro := i_carro_tmp;
                            (* '<S1>:83:6' i_lidar = floor((xt_enc+x_LIDAR-xt_min)/Wc)+1; *)
                            (* '<S1>:83:7' i_carro = min(max(i_carro,1),33); *)
                            b_temp3 := MAX(i_carro, 1.0);
                            i_carro := MIN(b_temp3, 33.0);
                            (* '<S1>:83:8' i_lidar = min(max(i_lidar ,1),33); *)
                            b_temp4 := rt_floord(u := ((xt + 3.0) - -30.0) / 2.44);
                            temp5 := MAX(b_temp4 + 1.0, 1.0);
                            i := TRUNC(MIN(temp5, 33.0));
                            (* During 'ACTUALIZAR_PERFIL_ALTURAS': '<S1>:76' *)
                            (* '<S1>:76:6' TLK_rise  = (TLK_anterior == 0) && (TLK == 1); *)
                            IF (TLK_anterior = 0.0) AND (b_TLK = 1.0) THEN 
                                e_hoisted_cond := TRUE;
                            ELSE 
                                e_hoisted_cond := FALSE;
                            END_IF;
                            (* '<S1>:76:7' TLK_fall  = (TLK_anterior == 1) && (TLK == 0); *)
                            IF (TLK_anterior = 1.0) AND (b_TLK = 0.0) THEN 
                                TLK_fall := TRUE;
                            ELSE 
                                TLK_fall := FALSE;
                            END_IF;
                            (* '<S1>:76:8' if(TLK_rise) *)
                            IF e_hoisted_cond THEN 
                                (* Si agarré un container, hay que bajar el perfi *)
                                (* '<S1>:76:9' yc0_vec(i_carro) = yc0_vec(i_carro) - Hc; *)
                                b_yc0_vec[TRUNC(i_carro) - 1] := b_yc0_vec[TRUNC(i_carro) - 1] - 2.59;
                            ELSIF TLK_fall THEN 
                                (* '<S1>:76:10' elseif(TLK_fall) *)
                                (* Si solté un container, hay que subir el perfil *)
                                (* '<S1>:76:11' yc0_vec(i_carro) = yc0_vec(i_carro) + Hc; *)
                                b_yc0_vec[TRUNC(i_carro) - 1] := b_yc0_vec[TRUNC(i_carro) - 1] + 2.59;
                            END_IF;
                            (* '<S1>:76:13' TLK_anterior = TLK; *)
                            TLK_anterior := b_TLK;
                            (* '<S1>:76:13' yc0 = yc0_vec(i_carro); *)
                            (* '<S1>:76:14' envolvente = Generar_Envolvente(yc0_vec); *)
                            (* MATLAB Function 'Generar_Envolvente': '<S1>:323' *)
                            (* '<S1>:323:4' N = 33; *)
                            (* No puedo usar N_xt, da error *)
                            (* '<S1>:323:5' h_seguridad = Hc/2; *)
                            (* Margen fijo (ajustable) *)
                            (* '<S1>:323:6' escaneado_vec = ones(N,1); *)
                            (* '<S1>:323:7' perfil_seguro = zeros(N,1); *)
                            (* '<S1>:323:8' for i = 1:N *)
                            (* '<S1>:323:16' envolvente_f = perfil_seguro; *)
                            FOR b_i := 0 TO 32 DO 
                                (* '<S1>:323:9' if escaneado_vec(i) == 1 *)
                                (* '<S1>:323:10' perfil_seguro(i) = perfil_escaneado_vec(i) + h_seguridad; *)
                                T_retardo := b_yc0_vec[b_i] + 1.295;
                                perfil_seguro[b_i] := T_retardo;
                                envolvente[b_i] := T_retardo;
                            END_FOR;
                            (* '<S1>:323:18' for i = 1:N *)
                            FOR c_i := 0 TO 32 DO 
                                (* '<S1>:323:19' if escaneado_vec(i) == 0 *)
                                (* '<S1>:323:23' e_i = perfil_seguro(i); *)
                                (* vecino izquierdo *)
                                (* '<S1>:323:25' if i > 1 && escaneado_vec(i-1) == 1 *)
                                IF c_i > 0 THEN 
                                    (* '<S1>:323:26' if e_i > perfil_seguro(i-1) *)
                                    T_retardo := perfil_seguro[c_i];
                                    IF T_retardo > perfil_seguro[c_i - 1] THEN 
                                        (* '<S1>:323:27' envolvente_f(i-1) = max(envolvente_f(i-1), e_i); *)
                                        envolvente[c_i - 1] := MAX(envolvente[c_i - 1], T_retardo);
                                    END_IF;
                                END_IF;
                                (* vecino derecho *)
                                (* '<S1>:323:31' if i < N && escaneado_vec(i+1) == 1 *)
                                IF (c_i + 1) < 33 THEN 
                                    (* '<S1>:323:32' if e_i > perfil_seguro(i+1) *)
                                    T_retardo := perfil_seguro[c_i];
                                    IF T_retardo > perfil_seguro[c_i + 1] THEN 
                                        (* '<S1>:323:33' envolvente_f(i+1) = max(envolvente_f(i+1), e_i); *)
                                        envolvente[c_i + 1] := MAX(envolvente[c_i + 1], T_retardo);
                                    END_IF;
                                END_IF;
                            END_FOR;
                            (* '<S1>:323:38' for i = 1:N *)
                            (* During 'Escaneo': '<S1>:381' *)
                            (* '<S1>:381:7' if i_lidar ==33 *)
                            IF i = 33 THEN 
                                (* '<S1>:381:8' flag1 = 1; *)
                                flag1 := 1.0;
                            END_IF;
                            (* '<S1>:381:10' if i_lidar==2 *)
                            IF i = 2 THEN 
                                (* '<S1>:381:11' flag2 = 1; *)
                                flag2 := 1.0;
                            END_IF;
                            (* '<S1>:381:13' if flag1 == 1 && flag2 ==1 *)
                            IF (flag1 = 1.0) AND (flag2 = 1.0) THEN 
                                (* '<S1>:381:14' scan=1; *)
                                scan := 1.0;
                            END_IF;
                            (* During 'VELOCIDAD_LIMITES': '<S1>:84' *)
                            (* LÍMITE INFERIOR DE IZAJE *)
                            (* '<S1>:84:4' if (TLK == 1) *)
                            IF b_TLK = 1.0 THEN 
                                (* '<S1>:84:5' dist = yh_enc - (yc0 + 0.5 + Hc); *)
                                dist := yh - ((b_yc0_vec[TRUNC(i_carro) - 1] + 0.5) + 2.59);
                                (* '<S1>:84:5' T_retardo = 0.8; *)
                                T_retardo := 0.8;
                            ELSE 
                                (* '<S1>:84:6' else *)
                                (* '<S1>:84:7' dist = yh_enc - (yc0 + 0.5); *)
                                dist := yh - (b_yc0_vec[TRUNC(i_carro) - 1] + 0.5);
                                (* '<S1>:84:7' T_retardo = 0.4; *)
                                T_retardo := 0.4;
                            END_IF;
                            (* Compensación con retardo dinámico *)
                            (* '<S1>:84:10' dist_efectiva = dist - (abs(vy_suave) * T_retardo); *)
                            dist := dist - (ABS(b_vy_suave) * T_retardo);
                            (* '<S1>:84:11' if (dist_efectiva < 0) *)
                            IF dist < 0.0 THEN 
                                (* '<S1>:84:12' dist_efectiva = 0; *)
                                dist := 0.0;
                            END_IF;
                            (* '<S1>:84:14' acc_plan = ah_max * 0.5; *)
                            (* '<S1>:84:15' v_segura = sqrt(0.01 + 2 * acc_plan * dist_efectiva); *)
                            dist := SQRT((0.75 * dist) + 0.01);
                            (* '<S1>:84:16' if (v_segura > vh_lim) *)
                            IF dist > vh_lim THEN 
                                (* '<S1>:84:17' v_segura = vh_lim; *)
                                dist := vh_lim;
                            END_IF;
                            (* Si pide moverse más rápido, se recorta *)
                            (* '<S1>:84:20' if (vy_suave < -v_segura) *)
                            IF b_vy_suave < ( -dist) THEN 
                                (* '<S1>:84:21' vy_suave = -v_segura; *)
                                b_vy_suave :=  -dist;
                            END_IF;
                            (* LÍMITE SUPERIOR DE IZAJE *)
                            (* '<S1>:84:24' dist = (yh_max - 2) - yh_enc; *)
                            (* '<S1>:84:25' dist_efectiva = dist - (abs(vy_suave) * T_retardo); *)
                            dist := (38.0 - yh) - (ABS(b_vy_suave) * T_retardo);
                            (* '<S1>:84:26' if (dist_efectiva < 0) *)
                            IF dist < 0.0 THEN 
                                (* '<S1>:84:27' dist_efectiva = 0; *)
                                dist := 0.0;
                            END_IF;
                            (* '<S1>:84:29' v_segura = sqrt(0.01 + 2 * acc_plan * dist_efectiva); *)
                            dist := SQRT((0.75 * dist) + 0.01);
                            (* '<S1>:84:30' if (v_segura > vh_lim) *)
                            IF dist > vh_lim THEN 
                                (* '<S1>:84:31' v_segura = vh_lim; *)
                                dist := vh_lim;
                            END_IF;
                            (* '<S1>:84:33' if (vy_suave > v_segura) *)
                            IF b_vy_suave > dist THEN 
                                (* '<S1>:84:34' vy_suave = v_segura; *)
                                b_vy_suave := dist;
                            END_IF;
                            (* LÍMITE DERECHO DEL CARRO *)
                            (* '<S1>:84:37' T_retardo = 5; *)
                            (* Retardo mayor para el carro *)
                            (* '<S1>:84:38' dist = (xt_max - 2) - xt_enc; *)
                            (* '<S1>:84:39' dist_efectiva = dist - (abs(vx_suave) * T_retardo); *)
                            dist := (48.0 - xt) - (ABS(b_vx_suave) * 5.0);
                            (* '<S1>:84:40' if (dist_efectiva < 0) *)
                            IF dist < 0.0 THEN 
                                (* '<S1>:84:41' dist_efectiva = 0; *)
                                dist := 0.0;
                            END_IF;
                            (* '<S1>:84:43' acc_plan = at_max * 0.5; *)
                            (* '<S1>:84:44' v_segura = sqrt(0.01 + 2 * acc_plan * dist_efectiva); *)
                            dist := SQRT((0.8 * dist) + 0.01);
                            (* '<S1>:84:45' if (vx_suave > v_segura) *)
                            IF b_vx_suave > dist THEN 
                                (* '<S1>:84:46' vx_suave = v_segura; *)
                                b_vx_suave := dist;
                            END_IF;
                            (* LÍMITE IZQUIERDO DEL CARRO *)
                            (* '<S1>:84:49' dist = xt_enc - (xt_min + 2); *)
                            (* '<S1>:84:50' dist_efectiva = dist - (abs(vx_suave) * T_retardo); *)
                            dist := (xt - -28.0) - (ABS(b_vx_suave) * 5.0);
                            (* '<S1>:84:51' if (dist_efectiva < 0) *)
                            IF dist < 0.0 THEN 
                                (* '<S1>:84:52' dist_efectiva = 0; *)
                                dist := 0.0;
                            END_IF;
                            (* '<S1>:84:54' v_segura = sqrt(0.01 + 2 * acc_plan * dist_efectiva); *)
                            dist := SQRT((0.8 * dist) + 0.01);
                            (* '<S1>:84:55' if (vx_suave < -v_segura) *)
                            IF b_vx_suave < ( -dist) THEN 
                                (* '<S1>:84:56' vx_suave = -v_segura; *)
                                b_vx_suave :=  -dist;
                            END_IF;
                            (* During 'SUAVIZADO_VELOCIDAD': '<S1>:335' *)
                            (* '<S1>:335:8' [vx_suave, ax_act] = Suavizador_Cinematico... *)
                            (* '<S1>:335:9'         (vx_target, vx_suave, ax_act, at_max, jerk_max); *)
                            i0_Suavizador_Cinematico(v_target := vx_target, v_act := b_vx_suave, a_act := ax_act, A_MAX := 0.8, J_MAX := jerk_max);
                            b_vx_suave := i0_Suavizador_Cinematico.v_out;
                            ax_act := i0_Suavizador_Cinematico.a_out;
                            (* '<S1>:335:10' [vy_suave, ay_act] = Suavizador_Cinematico... *)
                            (* '<S1>:335:11'         (vy_target, vy_suave, ay_act, ah_max, jerk_max); *)
                            i0_Suavizador_Cinematico(v_target := vy_target, v_act := b_vy_suave, a_act := ay_act, A_MAX := 0.75, J_MAX := jerk_max);
                            b_vy_suave := i0_Suavizador_Cinematico.v_out;
                            ay_act := i0_Suavizador_Cinematico.a_out;
                            (* During 'WATCHDOG_HEARTBEAT': '<S1>:369' *)
                            CASE is_WATCHDOG_HEARTBEAT OF
                                Nivel_IN_PULSOS_DOWN: 
                                    b_heartbeat := 1.0;
                                    (* During 'PULSOS_DOWN': '<S1>:372' *)
                                    (* '<S1>:371:1' sf_internal_predicateOutput = 0 | (after(periodo_pulsos, msec)); *)
                                    temporalCounter_i3(timerAction := 2, maxTime := 100);
                                    e_hoisted_cond := temporalCounter_i3.done;
                                    IF e_hoisted_cond THEN 
                                        (* Transition: '<S1>:371' *)
                                        temporalCounter_i3(timerAction := 1, maxTime := 0);
                                        is_WATCHDOG_HEARTBEAT := Nivel_IN_PULSOS_UP;
                                        (* Entry 'PULSOS_UP': '<S1>:374' *)
                                        (* '<S1>:374:3' heartbeat = 0; *)
                                        b_heartbeat := 0.0;
                                    END_IF;
                                ELSE
                                    b_heartbeat := 0.0;
                                    (* During 'PULSOS_UP': '<S1>:374' *)
                                    (* '<S1>:370:1' sf_internal_predicateOutput = 0 | (after(periodo_pulsos, msec)); *)
                                    temporalCounter_i3(timerAction := 2, maxTime := 100);
                                    e_hoisted_cond := temporalCounter_i3.done;
                                    IF e_hoisted_cond THEN 
                                        (* Transition: '<S1>:370' *)
                                        temporalCounter_i3(timerAction := 1, maxTime := 0);
                                        is_WATCHDOG_HEARTBEAT := Nivel_IN_PULSOS_DOWN;
                                        (* Entry 'PULSOS_DOWN': '<S1>:372' *)
                                        (* '<S1>:372:3' heartbeat = 1; *)
                                        b_heartbeat := 1.0;
                                    END_IF;
                            END_CASE;
                            (* During 'AUTOMATA_PRINCIPAL': '<S1>:1' *)
                            (* '<S1>:1:11' Joy_CMD_X = Joy_XY(1); *)
                            (* '<S1>:1:12' Joy_CMD_Y = Joy_XY(2); *)
                            temp2 := FALSE;
                            temp1 := FALSE;
                            CASE is_AUTOMATA_PRINCIPAL OF
                                Nivel_IN_ERROR_FC_izq_der: 
                                    (* During 'ERROR_FC_izq_der': '<S1>:164' *)
                                    (* Transition: '<S1>:169' *)
                                    (* '<S1>:162:1' sf_internal_predicateOutput = 0 | (BTN_Reset==1); *)
                                    IF b_RESET THEN 
                                        (* Transition: '<S1>:162' *)
                                        is_AUTOMATA_PRINCIPAL := Nivel_IN_RECUPERACION;
                                        (* Entry 'RECUPERACION': '<S1>:118' *)
                                        (* '<S1>:118:3' BRK_t_N1 = 1; *)
                                        b_BRK_t_N1 := 1.0;
                                        (* '<S1>:118:3' BRK_h_N1 = 1; *)
                                        b_BRK_h_N1 := 1.0;
                                        (* '<S1>:118:4' vel_error = 0.1; *)
                                        vel_error := 0.1;
                                        (* '<S1>:118:5' recuperacion = 1; *)
                                        b_recuperacion := 1.0;
                                    END_IF;
                                Nivel_IN_ERROR_FC_sup_inf: 
                                    (* During 'ERROR_FC_sup_inf': '<S1>:104' *)
                                    (* Transition: '<S1>:168' *)
                                    (* '<S1>:162:1' sf_internal_predicateOutput = 0 | (BTN_Reset==1); *)
                                    IF b_RESET THEN 
                                        (* Transition: '<S1>:162' *)
                                        is_AUTOMATA_PRINCIPAL := Nivel_IN_RECUPERACION;
                                        (* Entry 'RECUPERACION': '<S1>:118' *)
                                        (* '<S1>:118:3' BRK_t_N1 = 1; *)
                                        b_BRK_t_N1 := 1.0;
                                        (* '<S1>:118:3' BRK_h_N1 = 1; *)
                                        b_BRK_h_N1 := 1.0;
                                        (* '<S1>:118:4' vel_error = 0.1; *)
                                        vel_error := 0.1;
                                        (* '<S1>:118:5' recuperacion = 1; *)
                                        b_recuperacion := 1.0;
                                    END_IF;
                                Nivel_IN_ERROR_OTRO: 
                                    (* During 'ERROR_OTRO': '<S1>:353' *)
                                    (* Transition: '<S1>:354' *)
                                    (* '<S1>:162:1' sf_internal_predicateOutput = 0 | (BTN_Reset==1); *)
                                    IF b_RESET THEN 
                                        (* Transition: '<S1>:162' *)
                                        is_AUTOMATA_PRINCIPAL := Nivel_IN_RECUPERACION;
                                        (* Entry 'RECUPERACION': '<S1>:118' *)
                                        (* '<S1>:118:3' BRK_t_N1 = 1; *)
                                        b_BRK_t_N1 := 1.0;
                                        (* '<S1>:118:3' BRK_h_N1 = 1; *)
                                        b_BRK_h_N1 := 1.0;
                                        (* '<S1>:118:4' vel_error = 0.1; *)
                                        vel_error := 0.1;
                                        (* '<S1>:118:5' recuperacion = 1; *)
                                        b_recuperacion := 1.0;
                                    END_IF;
                                Nivel_IN_MANUAL: 
                                    (* During 'MANUAL': '<S1>:9' *)
                                    (* Transition: '<S1>:103' *)
                                    (* '<S1>:113:1' sf_internal_predicateOutput = 0 | ((FC_inf == 1&&... *)
                                    (* '<S1>:113:2' error_inf==0) ||... *)
                                    (* '<S1>:113:3' (FC_sup == 1&&... *)
                                    (* '<S1>:113:4' error_sup==0)); *)
                                    IF (FC_INF AND (error_inf = 0.0)) OR (FC_sup AND (error_sup = 0.0)) THEN 
                                        (* Transition: '<S1>:113' *)
                                        (* Exit 'MANUAL': '<S1>:9' *)
                                        (* '<S1>:9:23' modo_manual = 0; *)
                                        b_modo_manual := 0.0;
                                        is_AUTOMATA_PRINCIPAL := Nivel_IN_ERROR_FC_sup_inf;
                                        (* Entry 'ERROR_FC_sup_inf': '<S1>:104' *)
                                        (* '<S1>:104:3' BRK_t_N1 = 1; *)
                                        b_BRK_t_N1 := 1.0;
                                        (* '<S1>:104:3' BRK_h_N1 = 0; *)
                                        b_BRK_h_N1 := 0.0;
                                        (* '<S1>:104:4' vy_target = 0; *)
                                        vy_target := 0.0;
                                        (* '<S1>:104:5' recuperacion = 0; *)
                                        b_recuperacion := 0.0;
                                        (* '<S1>:104:6' if FC_inf==1 *)
                                        IF FC_INF THEN 
                                            (* '<S1>:104:7' error_inf=1; *)
                                            error_inf := 1.0;
                                        ELSIF FC_sup THEN 
                                            (* '<S1>:104:8' elseif FC_sup==1 *)
                                            (* '<S1>:104:8' ; *)
                                            (* '<S1>:104:9' error_sup=1; *)
                                            error_sup := 1.0;
                                        END_IF;
                                        (* '<S1>:104:11' modo_error = 1; *)
                                        b_modo_error := 1.0;
                                    ELSE 
                                        (* '<S1>:165:1' sf_internal_predicateOutput = 0 | ((FC_izq == 1&&... *)
                                        (* '<S1>:165:2' error_izq==0)||... *)
                                        (* '<S1>:165:3' (FC_der == 1&&... *)
                                        (* '<S1>:165:4' error_der==0)); *)
                                        IF (FC_izq AND (error_izq = 0.0)) OR (FC_der AND (error_der = 0.0)) THEN 
                                            (* Transition: '<S1>:165' *)
                                            (* Exit 'MANUAL': '<S1>:9' *)
                                            (* '<S1>:9:23' modo_manual = 0; *)
                                            b_modo_manual := 0.0;
                                            is_AUTOMATA_PRINCIPAL := Nivel_IN_ERROR_FC_izq_der;
                                            (* Entry 'ERROR_FC_izq_der': '<S1>:164' *)
                                            (* '<S1>:164:3' BRK_t_N1 = 0; *)
                                            b_BRK_t_N1 := 0.0;
                                            (* '<S1>:164:3' BRK_h_N1 = 1; *)
                                            b_BRK_h_N1 := 1.0;
                                            (* '<S1>:164:4' vx_target = 0; *)
                                            vx_target := 0.0;
                                            (* '<S1>:164:5' recuperacion = 0; *)
                                            b_recuperacion := 0.0;
                                            (* '<S1>:164:6' if FC_der==1 *)
                                            IF FC_der THEN 
                                                (* '<S1>:164:6' ; *)
                                                (* '<S1>:164:7' error_der=1; *)
                                                error_der := 1.0;
                                            ELSIF FC_izq THEN 
                                                (* '<S1>:164:8' elseif FC_izq==1 *)
                                                (* '<S1>:164:8' ; *)
                                                (* '<S1>:164:9' error_izq=1; *)
                                                error_izq := 1.0;
                                            END_IF;
                                            (* '<S1>:164:11' modo_error = 1; *)
                                            b_modo_error := 1.0;
                                        ELSE 
                                            (* '<S1>:355:1' sf_internal_predicateOutput = 0 | ((FALLA_MAN == 1 ||... *)
                                            (* '<S1>:355:2'  FALLA_WD == 1 ||... *)
                                            (* '<S1>:355:3'  FALLA_SV ==1) &&... *)
                                            (* '<S1>:355:4'  error_otro == 0); *)
                                            IF (((FALLA_MAN = 1.0) OR (FALLA_WD = 1.0)) OR (FALLA_IZAJE_SV = 1.0)) AND (error_otro = 0.0) THEN 
                                                (* Transition: '<S1>:355' *)
                                                (* Exit 'MANUAL': '<S1>:9' *)
                                                (* '<S1>:9:23' modo_manual = 0; *)
                                                b_modo_manual := 0.0;
                                                is_AUTOMATA_PRINCIPAL := Nivel_IN_ERROR_OTRO;
                                                (* Entry 'ERROR_OTRO': '<S1>:353' *)
                                                (* '<S1>:353:3' BRK_t_N1 = 0; *)
                                                b_BRK_t_N1 := 0.0;
                                                (* '<S1>:353:3' BRK_h_N1 = 0; *)
                                                b_BRK_h_N1 := 0.0;
                                                (* '<S1>:353:4' recuperacion = 0; *)
                                                b_recuperacion := 0.0;
                                                (* '<S1>:353:5' error_otro = 1; *)
                                                error_otro := 1.0;
                                                (* '<S1>:353:6' vx_target=0 *)
                                                vx_target := 0.0;
                                                (* '<S1>:353:6' vy_target=0; *)
                                                vy_target := 0.0;
                                                (* '<S1>:353:7' modo_error = 1; *)
                                                b_modo_error := 1.0;
                                            ELSE 
                                                (* '<S1>:14:1' sf_internal_predicateOutput = 0 | (duration((abs(Joy_XY(1)) < 0.1 &&... *)
                                                (* '<S1>:14:2'  abs(Joy_XY(2)) < 0.1 &&... *)
                                                (* '<S1>:14:3'  abs(vt_obs) < 0.01 &&... *)
                                                (* '<S1>:14:4'  abs(vh_obs) < 0.01 &&... *)
                                                (* '<S1>:14:5'  abs(theta_l_dot) < 0.006 &&... *)
                                                (* '<S1>:14:6'  abs(theta_l) < 0.006), sec) > 1); *)
                                                T_retardo := ABS(Joy_XY[0]);
                                                IF T_retardo < 0.1 THEN 
                                                    IF ABS(Joy_XY[1]) < 0.1 THEN 
                                                        IF ABS(vt_obs) < 0.01 THEN 
                                                            IF ABS(vh_obs) < 0.01 THEN 
                                                                IF ABS(theta_l_dot) < 0.006 THEN 
                                                                    IF ABS(tita_l) < 0.006 THEN 
                                                                        ;
                                                                        ;
                                                                    ELSE 
                                                                        durationCounter_1 := 0;
                                                                    END_IF;
                                                                ELSE 
                                                                    durationCounter_1 := 0;
                                                                END_IF;
                                                            ELSE 
                                                                durationCounter_1 := 0;
                                                            END_IF;
                                                        ELSE 
                                                            durationCounter_1 := 0;
                                                        END_IF;
                                                    ELSE 
                                                        durationCounter_1 := 0;
                                                    END_IF;
                                                ELSE 
                                                    durationCounter_1 := 0;
                                                END_IF;
                                                IF durationCounter_1 > 50 THEN 
                                                    (* Transition: '<S1>:14' *)
                                                    (* Exit 'MANUAL': '<S1>:9' *)
                                                    (* '<S1>:9:23' modo_manual = 0; *)
                                                    is_AUTOMATA_PRINCIPAL := Nivel_IN_REPOSO;
                                                    (* Entry 'REPOSO': '<S1>:5' *)
                                                    (* '<S1>:5:3' modo_reposo = 1; *)
                                                    b_modo_reposo := 1.0;
                                                    IF B <> 0.0 THEN 
                                                        durationCounter_1_m := 0;
                                                    END_IF;
                                                    (* '<S1>:5:4' BRK_t_N1 = 0; *)
                                                    b_BRK_t_N1 := 0.0;
                                                    (* '<S1>:5:4' BRK_h_N1 = 0; *)
                                                    b_BRK_h_N1 := 0.0;
                                                    (* '<S1>:5:5' modo_manual = 0; *)
                                                    b_modo_manual := 0.0;
                                                    (* '<S1>:5:6' modo_manual_auto =0; *)
                                                    b_modo_manual_auto := 0.0;
                                                    (* '<S1>:5:7' error_der = 0; *)
                                                    error_der := 0.0;
                                                    (* '<S1>:5:7' error_izq = 0; *)
                                                    error_izq := 0.0;
                                                    (* '<S1>:5:8' error_sup = 0; *)
                                                    error_sup := 0.0;
                                                    (* '<S1>:5:8' error_inf = 0; *)
                                                    error_inf := 0.0;
                                                    (* '<S1>:5:9' error_otro =0; *)
                                                    error_otro := 0.0;
                                                    (* '<S1>:5:10' modo_error = 0; *)
                                                    b_modo_error := 0.0;
                                                ELSE 
                                                    (* '<S1>:9:6' if (abs(T_hm)>(m_container+Ms)*g*0.02) *)
                                                    IF ABS(T_hm) > (((b_m_container + 15000.0) * 9.80665) * 0.02) THEN 
                                                        (* '<S1>:9:7' BRK_h_N1=1; *)
                                                        b_BRK_h_N1 := 1.0;
                                                    END_IF;
                                                    (* '<S1>:9:9' if (abs(T_tm)>(m_container+Ms)*g*0.0002) *)
                                                    IF ABS(T_tm) > (((b_m_container + 15000.0) * 9.80665) * 0.0002) THEN 
                                                        (* '<S1>:9:10' BRK_t_N1=1; *)
                                                        b_BRK_t_N1 := 1.0;
                                                    END_IF;
                                                    (* '<S1>:9:12' if (abs(Joy_CMD_X) < dead_zone) *)
                                                    IF T_retardo < dead_zone THEN 
                                                        (* '<S1>:9:13' vx_target = 0; *)
                                                        vx_target := 0.0;
                                                    ELSE 
                                                        (* '<S1>:9:14' else *)
                                                        (* '<S1>:9:15' vx_target = Joy_CMD_X * vt_max; *)
                                                        vx_target := Joy_XY[0] * 4.0;
                                                    END_IF;
                                                    (* '<S1>:9:17' if (abs(Joy_CMD_Y) < dead_zone) *)
                                                    IF ABS(Joy_XY[1]) < dead_zone THEN 
                                                        (* '<S1>:9:18' vy_target = 0; *)
                                                        vy_target := 0.0;
                                                    ELSE 
                                                        (* '<S1>:9:19' else *)
                                                        (* '<S1>:9:20' vy_target = Joy_CMD_Y * vh_lim; *)
                                                        vy_target := Joy_XY[1] * vh_lim;
                                                    END_IF;
                                                END_IF;
                                            END_IF;
                                        END_IF;
                                    END_IF;
                                Nivel_IN_MODO_AUTO: 
                                    (* During 'MODO_AUTO': '<S1>:240' *)
                                    (* '<S1>:218:1' sf_internal_predicateOutput = 0 | (BTN_Reset == 1); *)
                                    IF b_RESET THEN 
                                        (* Transition: '<S1>:218' *)
                                        temp2 := TRUE;
                                    ELSE 
                                        (* '<S1>:326:1' sf_internal_predicateOutput = 0 | (ejec_mov_final == 1 &&... *)
                                        (* '<S1>:326:2'  (sobrecarga==1 || (TLK == 0 &&... *)
                                        (* '<S1>:326:3'  abs(yh_enc - envolvent(i_usado))<0.1 &&... *)
                                        (* '<S1>:326:4'  abs(vh_obs) < 0.1 && estado == 3)&&... *)
                                        (* '<S1>:326:5'  i_carro == i_usado && abs(vt_obs)<0.1)); *)
                                        IF ejec_mov_final = 1.0 THEN 
                                            IF b_sobrecarga = 1.0 THEN 
                                                (* Transition: '<S1>:326' *)
                                                temp2 := TRUE;
                                            ELSIF b_TLK = 0.0 THEN 
                                                IF ABS(yh - 10.0) < 0.1 THEN 
                                                    IF ABS(vh_obs) < 0.1 THEN 
                                                        IF (estado = 3.0) AND (i_carro = i_usado) THEN 
                                                            IF ABS(vt_obs) < 0.1 THEN 
                                                                (* Transition: '<S1>:326' *)
                                                                temp2 := TRUE;
                                                            ELSE 
                                                                e_hoisted_cond := FALSE;
                                                                temp1 := TRUE;
                                                            END_IF;
                                                        ELSE 
                                                            e_hoisted_cond := FALSE;
                                                            temp1 := TRUE;
                                                        END_IF;
                                                    ELSE 
                                                        e_hoisted_cond := FALSE;
                                                        temp1 := TRUE;
                                                    END_IF;
                                                ELSE 
                                                    e_hoisted_cond := FALSE;
                                                    temp1 := TRUE;
                                                END_IF;
                                            ELSE 
                                                e_hoisted_cond := FALSE;
                                                temp1 := TRUE;
                                            END_IF;
                                        ELSE 
                                            e_hoisted_cond := FALSE;
                                            temp1 := TRUE;
                                        END_IF;
                                    END_IF;
                                Nivel_IN_RECUPERACION: 
                                    (* During 'RECUPERACION': '<S1>:118' *)
                                    (* '<S1>:125:1' sf_internal_predicateOutput = 0 | ((yh_enc < yh_max*0.99) &&... *)
                                    (* '<S1>:125:2'  (yh_enc > yh_min*0.99) &&... *)
                                    (* '<S1>:125:3'  (xt_enc < xt_max*0.99) &&... *)
                                    (* '<S1>:125:4'  (xt_enc > xt_min*0.99)); *)
                                    IF (((yh < 39.6) AND (yh > -19.8)) AND (xt < 49.5)) AND (xt > -29.7) THEN 
                                        (* Transition: '<S1>:125' *)
                                        (* Exit 'RECUPERACION': '<S1>:118' *)
                                        (* '<S1>:118:32' recuperacion = 0; *)
                                        b_recuperacion := 0.0;
                                        (* modo_error = 1; *)
                                        is_AUTOMATA_PRINCIPAL := Nivel_IN_REPOSO;
                                        (* Entry 'REPOSO': '<S1>:5' *)
                                        (* '<S1>:5:3' modo_reposo = 1; *)
                                        b_modo_reposo := 1.0;
                                        IF B <> 0.0 THEN 
                                            durationCounter_1_m := 0;
                                        END_IF;
                                        (* '<S1>:5:4' BRK_t_N1 = 0; *)
                                        b_BRK_t_N1 := 0.0;
                                        (* '<S1>:5:4' BRK_h_N1 = 0; *)
                                        b_BRK_h_N1 := 0.0;
                                        (* '<S1>:5:5' modo_manual = 0; *)
                                        b_modo_manual := 0.0;
                                        (* '<S1>:5:6' modo_manual_auto =0; *)
                                        b_modo_manual_auto := 0.0;
                                        (* '<S1>:5:7' error_der = 0; *)
                                        error_der := 0.0;
                                        (* '<S1>:5:7' error_izq = 0; *)
                                        error_izq := 0.0;
                                        (* '<S1>:5:8' error_sup = 0; *)
                                        error_sup := 0.0;
                                        (* '<S1>:5:8' error_inf = 0; *)
                                        error_inf := 0.0;
                                        (* '<S1>:5:9' error_otro =0; *)
                                        error_otro := 0.0;
                                        (* '<S1>:5:10' modo_error = 0; *)
                                        b_modo_error := 0.0;
                                    ELSE 
                                        (* Transition: '<S1>:127' *)
                                        (* '<S1>:113:1' sf_internal_predicateOutput = 0 | ((FC_inf == 1&&... *)
                                        (* '<S1>:113:2' error_inf==0) ||... *)
                                        (* '<S1>:113:3' (FC_sup == 1&&... *)
                                        (* '<S1>:113:4' error_sup==0)); *)
                                        IF (FC_INF AND (error_inf = 0.0)) OR (FC_sup AND (error_sup = 0.0)) THEN 
                                            (* Transition: '<S1>:113' *)
                                            (* Exit 'RECUPERACION': '<S1>:118' *)
                                            (* '<S1>:118:32' recuperacion = 0; *)
                                            (* modo_error = 1; *)
                                            is_AUTOMATA_PRINCIPAL := Nivel_IN_ERROR_FC_sup_inf;
                                            (* Entry 'ERROR_FC_sup_inf': '<S1>:104' *)
                                            (* '<S1>:104:3' BRK_t_N1 = 1; *)
                                            b_BRK_t_N1 := 1.0;
                                            (* '<S1>:104:3' BRK_h_N1 = 0; *)
                                            b_BRK_h_N1 := 0.0;
                                            (* '<S1>:104:4' vy_target = 0; *)
                                            vy_target := 0.0;
                                            (* '<S1>:104:5' recuperacion = 0; *)
                                            b_recuperacion := 0.0;
                                            (* '<S1>:104:6' if FC_inf==1 *)
                                            IF FC_INF THEN 
                                                (* '<S1>:104:7' error_inf=1; *)
                                                error_inf := 1.0;
                                            ELSIF FC_sup THEN 
                                                (* '<S1>:104:8' elseif FC_sup==1 *)
                                                (* '<S1>:104:8' ; *)
                                                (* '<S1>:104:9' error_sup=1; *)
                                                error_sup := 1.0;
                                            END_IF;
                                            (* '<S1>:104:11' modo_error = 1; *)
                                            b_modo_error := 1.0;
                                        ELSE 
                                            (* '<S1>:165:1' sf_internal_predicateOutput = 0 | ((FC_izq == 1&&... *)
                                            (* '<S1>:165:2' error_izq==0)||... *)
                                            (* '<S1>:165:3' (FC_der == 1&&... *)
                                            (* '<S1>:165:4' error_der==0)); *)
                                            IF (FC_izq AND (error_izq = 0.0)) OR (FC_der AND (error_der = 0.0)) THEN 
                                                (* Transition: '<S1>:165' *)
                                                (* Exit 'RECUPERACION': '<S1>:118' *)
                                                (* '<S1>:118:32' recuperacion = 0; *)
                                                (* modo_error = 1; *)
                                                is_AUTOMATA_PRINCIPAL := Nivel_IN_ERROR_FC_izq_der;
                                                (* Entry 'ERROR_FC_izq_der': '<S1>:164' *)
                                                (* '<S1>:164:3' BRK_t_N1 = 0; *)
                                                b_BRK_t_N1 := 0.0;
                                                (* '<S1>:164:3' BRK_h_N1 = 1; *)
                                                b_BRK_h_N1 := 1.0;
                                                (* '<S1>:164:4' vx_target = 0; *)
                                                vx_target := 0.0;
                                                (* '<S1>:164:5' recuperacion = 0; *)
                                                b_recuperacion := 0.0;
                                                (* '<S1>:164:6' if FC_der==1 *)
                                                IF FC_der THEN 
                                                    (* '<S1>:164:6' ; *)
                                                    (* '<S1>:164:7' error_der=1; *)
                                                    error_der := 1.0;
                                                ELSIF FC_izq THEN 
                                                    (* '<S1>:164:8' elseif FC_izq==1 *)
                                                    (* '<S1>:164:8' ; *)
                                                    (* '<S1>:164:9' error_izq=1; *)
                                                    error_izq := 1.0;
                                                END_IF;
                                                (* '<S1>:164:11' modo_error = 1; *)
                                                b_modo_error := 1.0;
                                            ELSE 
                                                (* '<S1>:355:1' sf_internal_predicateOutput = 0 | ((FALLA_MAN == 1 ||... *)
                                                (* '<S1>:355:2'  FALLA_WD == 1 ||... *)
                                                (* '<S1>:355:3'  FALLA_SV ==1) &&... *)
                                                (* '<S1>:355:4'  error_otro == 0); *)
                                                IF (((FALLA_MAN = 1.0) OR (FALLA_WD = 1.0)) OR (FALLA_IZAJE_SV = 1.0)) AND (error_otro = 0.0) THEN 
                                                    (* Transition: '<S1>:355' *)
                                                    (* Exit 'RECUPERACION': '<S1>:118' *)
                                                    (* '<S1>:118:32' recuperacion = 0; *)
                                                    (* modo_error = 1; *)
                                                    is_AUTOMATA_PRINCIPAL := Nivel_IN_ERROR_OTRO;
                                                    (* Entry 'ERROR_OTRO': '<S1>:353' *)
                                                    (* '<S1>:353:3' BRK_t_N1 = 0; *)
                                                    b_BRK_t_N1 := 0.0;
                                                    (* '<S1>:353:3' BRK_h_N1 = 0; *)
                                                    b_BRK_h_N1 := 0.0;
                                                    (* '<S1>:353:4' recuperacion = 0; *)
                                                    b_recuperacion := 0.0;
                                                    (* '<S1>:353:5' error_otro = 1; *)
                                                    error_otro := 1.0;
                                                    (* '<S1>:353:6' vx_target=0 *)
                                                    vx_target := 0.0;
                                                    (* '<S1>:353:6' vy_target=0; *)
                                                    vy_target := 0.0;
                                                    (* '<S1>:353:7' modo_error = 1; *)
                                                    b_modo_error := 1.0;
                                                ELSE 
                                                    (* '<S1>:118:7' if (abs(Joy_CMD_X) < dead_zone) *)
                                                    IF ABS(Joy_XY[0]) < dead_zone THEN 
                                                        (* '<S1>:118:8' vx_target = 0; *)
                                                        vx_target := 0.0;
                                                    ELSE 
                                                        (* '<S1>:118:9' else *)
                                                        (* '<S1>:118:10' vx_target = Joy_CMD_X * vt_max/3; *)
                                                        vx_target := (Joy_XY[0] * 4.0) / 3.0;
                                                        (* '<S1>:118:11' if (error_der == 1) *)
                                                        IF error_der = 1.0 THEN 
                                                            (* '<S1>:118:12' vx_target = Joy_CMD_X * vel_error; *)
                                                            vx_target := Joy_XY[0] * vel_error;
                                                            (* '<S1>:118:13' if (vx_target > 0) *)
                                                            IF vx_target > 0.0 THEN 
                                                                (* '<S1>:118:13' vx_target = 0; *)
                                                                vx_target := 0.0;
                                                            END_IF;
                                                        ELSIF error_izq = 1.0 THEN 
                                                            (* '<S1>:118:14' elseif (error_izq == 1) *)
                                                            (* '<S1>:118:15' vx_target = Joy_CMD_X * vel_error; *)
                                                            vx_target := Joy_XY[0] * vel_error;
                                                            (* '<S1>:118:16' if (vx_target < 0) *)
                                                            IF vx_target < 0.0 THEN 
                                                                (* '<S1>:118:16' vx_target = 0; *)
                                                                vx_target := 0.0;
                                                            END_IF;
                                                        END_IF;
                                                    END_IF;
                                                    (* '<S1>:118:19' if (abs(Joy_CMD_Y) < dead_zone) *)
                                                    IF ABS(Joy_XY[1]) < dead_zone THEN 
                                                        (* '<S1>:118:20' vy_target = 0; *)
                                                        vy_target := 0.0;
                                                    ELSE 
                                                        (* '<S1>:118:21' else *)
                                                        (* '<S1>:118:22' vy_target = Joy_CMD_Y * vh_lim/3; *)
                                                        vy_target := (Joy_XY[1] * vh_lim) / 3.0;
                                                        (* '<S1>:118:23' if (error_sup == 1) *)
                                                        IF error_sup = 1.0 THEN 
                                                            (* '<S1>:118:24' vy_target = Joy_CMD_Y * vel_error; *)
                                                            vy_target := Joy_XY[1] * vel_error;
                                                            (* '<S1>:118:25' if (vy_target > 0) *)
                                                            IF vy_target > 0.0 THEN 
                                                                (* '<S1>:118:25' vy_target = 0; *)
                                                                vy_target := 0.0;
                                                            END_IF;
                                                        ELSIF error_inf = 1.0 THEN 
                                                            (* '<S1>:118:26' elseif (error_inf == 1) *)
                                                            (* '<S1>:118:27' vy_target = Joy_CMD_Y * vel_error; *)
                                                            vy_target := Joy_XY[1] * vel_error;
                                                            (* '<S1>:118:28' if (vy_target < 0) *)
                                                            IF vy_target < 0.0 THEN 
                                                                (* '<S1>:118:28' vy_target = 0; *)
                                                                vy_target := 0.0;
                                                            END_IF;
                                                        END_IF;
                                                    END_IF;
                                                END_IF;
                                            END_IF;
                                        END_IF;
                                    END_IF;
                                ELSE
                                    (* During 'REPOSO': '<S1>:5' *)
                                    (* '<S1>:13:1' sf_internal_predicateOutput = 0 | (abs(Joy_XY(1)) > dead_zone ||... *)
                                    (* '<S1>:13:2'  abs(Joy_XY(2)) > dead_zone); *)
                                    temp3 := FALSE;
                                    IF ABS(Joy_XY[0]) > dead_zone THEN 
                                        temp3 := TRUE;
                                    ELSIF ABS(Joy_XY[1]) > dead_zone THEN 
                                        temp3 := TRUE;
                                    ELSE 
                                        (* '<S1>:215:1' sf_internal_predicateOutput = 0 | (BTN_Auto == 1 && scan==1); *)
                                        IF X AND (scan = 1.0) THEN 
                                            (* Transition: '<S1>:215' *)
                                            (* Exit 'REPOSO': '<S1>:5' *)
                                            (* '<S1>:5:12' modo_reposo = 0; *)
                                            b_modo_reposo := 0.0;
                                            durationCounter_1_m := 0;
                                            is_AUTOMATA_PRINCIPAL := Nivel_IN_MODO_AUTO;
                                            (* Entry 'MODO_AUTO': '<S1>:240' *)
                                            (* '<S1>:240:3' if(ya_vuelvo == 1) *)
                                            IF ya_vuelvo = 1.0 THEN 
                                                (* '<S1>:240:4' BRK_t_N1 = 1; *)
                                                b_BRK_t_N1 := 1.0;
                                                (* '<S1>:240:4' BRK_h_N1 = 1; *)
                                                b_BRK_h_N1 := 1.0;
                                            ELSE 
                                                (* '<S1>:240:5' else *)
                                                (* '<S1>:240:5' ya_vuelvo = 0; *)
                                                ya_vuelvo := 0.0;
                                            END_IF;
                                            (* '<S1>:240:7' ciclo_doble=0; *)
                                            ciclo_doble := 0.0;
                                            (* '<S1>:240:8' ejec_mov_final = 0; *)
                                            ejec_mov_final := 0.0;
                                            (* Entry Internal 'MODO_AUTO': '<S1>:240' *)
                                            (* Transition: '<S1>:238' *)
                                            (* '<S1>:349:1' sf_internal_predicateOutput = 0 | (ya_vuelvo == 1); *)
                                            IF ya_vuelvo = 1.0 THEN 
                                                (* Transition: '<S1>:349' *)
                                                is_MODO_AUTO := Nivel_IN_MOVIMIENTO_CURVO;
                                                (* Entry 'MOVIMIENTO_CURVO': '<S1>:297' *)
                                                (* '<S1>:297:2' ejec_mov = 1; *)
                                                (* '<S1>:297:2' ya_vuelvo=0; *)
                                                ya_vuelvo := 0.0;
                                            ELSE 
                                                (* Transition: '<S1>:348' *)
                                                is_MODO_AUTO := Nivel_IN_AUTO_INIT;
                                                (* Entry 'AUTO_INIT': '<S1>:284' *)
                                                (* '<S1>:284:3' BRK_t_N1 = 0; *)
                                                b_BRK_t_N1 := 0.0;
                                                (* '<S1>:284:3' BRK_h_N1 = 0; *)
                                                b_BRK_h_N1 := 0.0;
                                                (* '<S1>:284:4' home = 13; *)
                                                home := 13.0;
                                                (* '<S1>:284:5' estado = 1; *)
                                                estado := 1.0;
                                                (* Etapa de movimiento *)
                                                (* '<S1>:284:6' if (TLK == 1) *)
                                                IF b_TLK = 1.0 THEN 
                                                    (* '<S1>:284:7' estado = 2; *)
                                                    estado := 2.0;
                                                    (* '<S1>:284:8' i_origen = 0; *)
                                                    i_origen := 0.0;
                                                END_IF;
                                            END_IF;
                                        END_IF;
                                    END_IF;
                                    IF temp3 THEN 
                                        (* Transition: '<S1>:13' *)
                                        (* Exit 'REPOSO': '<S1>:5' *)
                                        (* '<S1>:5:12' modo_reposo = 0; *)
                                        b_modo_reposo := 0.0;
                                        durationCounter_1_m := 0;
                                        durationCounter_1 := 0;
                                        is_AUTOMATA_PRINCIPAL := Nivel_IN_MANUAL;
                                        (* Entry 'MANUAL': '<S1>:9' *)
                                        (* BRK_t_N1 = 1; BRK_h_N1 = 1; *)
                                        (* '<S1>:9:4' modo_manual = 1; *)
                                        b_modo_manual := 1.0;
                                    END_IF;
                            END_CASE;
                            IF temp1 THEN 
                                (* Transition: '<S1>:351' *)
                                (* '<S1>:113:1' sf_internal_predicateOutput = 0 | ((FC_inf == 1&&... *)
                                (* '<S1>:113:2' error_inf==0) ||... *)
                                (* '<S1>:113:3' (FC_sup == 1&&... *)
                                (* '<S1>:113:4' error_sup==0)); *)
                                IF (FC_INF AND (error_inf = 0.0)) OR (FC_sup AND (error_sup = 0.0)) THEN 
                                    (* Transition: '<S1>:113' *)
                                    (* Exit Internal 'MODO_AUTO': '<S1>:240' *)
                                    CASE is_MODO_AUTO OF
                                        Nivel_IN_AUTO_INIT: 
                                            is_MODO_AUTO := Nivel_IN_NO_ACTIVE_CHILD;
                                        Nivel_IN_MODO_MANUAL_SIMPLE: 
                                            (* Exit 'MODO_MANUAL_SIMPLE': '<S1>:250' *)
                                            (* '<S1>:250:23' estado = estado + 1; *)
                                            estado := estado + 1.0;
                                            (* '<S1>:250:24' modo_manual_auto = 0; *)
                                            b_modo_manual_auto := 0.0;
                                            is_MODO_AUTO := Nivel_IN_NO_ACTIVE_CHILD;
                                        Nivel_IN_MOVIMIENTO_CURVO: 
                                            (* Exit 'MOVIMIENTO_CURVO': '<S1>:297' *)
                                            (* '<S1>:297:18' ejec_mov = 0; *)
                                            is_MODO_AUTO := Nivel_IN_NO_ACTIVE_CHILD;
                                        c_Nivel_IN_MOVIMIENTO_CURVO: 
                                            (* Exit 'MOVIMIENTO_CURVO_FINAL': '<S1>:386' *)
                                            (* '<S1>:386:15' ejec_mov_final = 0; *)
                                            ejec_mov_final := 0.0;
                                            is_MODO_AUTO := Nivel_IN_NO_ACTIVE_CHILD;
                                        c_Nivel_IN_SELECCION_TRAYEC: 
                                            is_MODO_AUTO := Nivel_IN_NO_ACTIVE_CHILD;
                                        Nivel_IN_SEL_DESTINO: 
                                            (* Exit 'SEL_DESTINO': '<S1>:311' *)
                                            (* '<S1>:311:17' i_destino = i_sel; *)
                                            i_destino := b_i_sel;
                                            is_MODO_AUTO := Nivel_IN_NO_ACTIVE_CHILD;
                                        Nivel_IN_SEL_ORIGEN: 
                                            (* Exit 'SEL_ORIGEN': '<S1>:190' *)
                                            (* '<S1>:190:14' i_origen = i_sel; *)
                                            i_origen := b_i_sel;
                                            is_MODO_AUTO := Nivel_IN_NO_ACTIVE_CHILD;
                                    END_CASE;
                                    (* Exit 'MODO_AUTO': '<S1>:240' *)
                                    (* '<S1>:240:10' if(ya_vuelvo == 0) *)
                                    IF ya_vuelvo = 0.0 THEN 
                                        (* '<S1>:240:11' modo_auto = 0; *)
                                        b_modo_auto := 0.0;
                                        (* '<S1>:240:12' modo_manual_auto = 0; *)
                                        b_modo_manual_auto := 0.0;
                                        (* '<S1>:240:13' ejec_mov = 0; *)
                                    END_IF;
                                    is_AUTOMATA_PRINCIPAL := Nivel_IN_ERROR_FC_sup_inf;
                                    (* Entry 'ERROR_FC_sup_inf': '<S1>:104' *)
                                    (* '<S1>:104:3' BRK_t_N1 = 1; *)
                                    b_BRK_t_N1 := 1.0;
                                    (* '<S1>:104:3' BRK_h_N1 = 0; *)
                                    b_BRK_h_N1 := 0.0;
                                    (* '<S1>:104:4' vy_target = 0; *)
                                    vy_target := 0.0;
                                    (* '<S1>:104:5' recuperacion = 0; *)
                                    b_recuperacion := 0.0;
                                    (* '<S1>:104:6' if FC_inf==1 *)
                                    IF FC_INF THEN 
                                        (* '<S1>:104:7' error_inf=1; *)
                                        error_inf := 1.0;
                                    ELSIF FC_sup THEN 
                                        (* '<S1>:104:8' elseif FC_sup==1 *)
                                        (* '<S1>:104:8' ; *)
                                        (* '<S1>:104:9' error_sup=1; *)
                                        error_sup := 1.0;
                                    END_IF;
                                    (* '<S1>:104:11' modo_error = 1; *)
                                    b_modo_error := 1.0;
                                ELSE 
                                    (* '<S1>:165:1' sf_internal_predicateOutput = 0 | ((FC_izq == 1&&... *)
                                    (* '<S1>:165:2' error_izq==0)||... *)
                                    (* '<S1>:165:3' (FC_der == 1&&... *)
                                    (* '<S1>:165:4' error_der==0)); *)
                                    IF (FC_izq AND (error_izq = 0.0)) OR (FC_der AND (error_der = 0.0)) THEN 
                                        (* Transition: '<S1>:165' *)
                                        (* Exit Internal 'MODO_AUTO': '<S1>:240' *)
                                        CASE is_MODO_AUTO OF
                                            Nivel_IN_AUTO_INIT: 
                                                is_MODO_AUTO := Nivel_IN_NO_ACTIVE_CHILD;
                                            Nivel_IN_MODO_MANUAL_SIMPLE: 
                                                (* Exit 'MODO_MANUAL_SIMPLE': '<S1>:250' *)
                                                (* '<S1>:250:23' estado = estado + 1; *)
                                                estado := estado + 1.0;
                                                (* '<S1>:250:24' modo_manual_auto = 0; *)
                                                b_modo_manual_auto := 0.0;
                                                is_MODO_AUTO := Nivel_IN_NO_ACTIVE_CHILD;
                                            Nivel_IN_MOVIMIENTO_CURVO: 
                                                (* Exit 'MOVIMIENTO_CURVO': '<S1>:297' *)
                                                (* '<S1>:297:18' ejec_mov = 0; *)
                                                is_MODO_AUTO := Nivel_IN_NO_ACTIVE_CHILD;
                                            c_Nivel_IN_MOVIMIENTO_CURVO: 
                                                (* Exit 'MOVIMIENTO_CURVO_FINAL': '<S1>:386' *)
                                                (* '<S1>:386:15' ejec_mov_final = 0; *)
                                                ejec_mov_final := 0.0;
                                                is_MODO_AUTO := Nivel_IN_NO_ACTIVE_CHILD;
                                            c_Nivel_IN_SELECCION_TRAYEC: 
                                                is_MODO_AUTO := Nivel_IN_NO_ACTIVE_CHILD;
                                            Nivel_IN_SEL_DESTINO: 
                                                (* Exit 'SEL_DESTINO': '<S1>:311' *)
                                                (* '<S1>:311:17' i_destino = i_sel; *)
                                                i_destino := b_i_sel;
                                                is_MODO_AUTO := Nivel_IN_NO_ACTIVE_CHILD;
                                            Nivel_IN_SEL_ORIGEN: 
                                                (* Exit 'SEL_ORIGEN': '<S1>:190' *)
                                                (* '<S1>:190:14' i_origen = i_sel; *)
                                                i_origen := b_i_sel;
                                                is_MODO_AUTO := Nivel_IN_NO_ACTIVE_CHILD;
                                        END_CASE;
                                        (* Exit 'MODO_AUTO': '<S1>:240' *)
                                        (* '<S1>:240:10' if(ya_vuelvo == 0) *)
                                        IF ya_vuelvo = 0.0 THEN 
                                            (* '<S1>:240:11' modo_auto = 0; *)
                                            b_modo_auto := 0.0;
                                            (* '<S1>:240:12' modo_manual_auto = 0; *)
                                            b_modo_manual_auto := 0.0;
                                            (* '<S1>:240:13' ejec_mov = 0; *)
                                        END_IF;
                                        is_AUTOMATA_PRINCIPAL := Nivel_IN_ERROR_FC_izq_der;
                                        (* Entry 'ERROR_FC_izq_der': '<S1>:164' *)
                                        (* '<S1>:164:3' BRK_t_N1 = 0; *)
                                        b_BRK_t_N1 := 0.0;
                                        (* '<S1>:164:3' BRK_h_N1 = 1; *)
                                        b_BRK_h_N1 := 1.0;
                                        (* '<S1>:164:4' vx_target = 0; *)
                                        vx_target := 0.0;
                                        (* '<S1>:164:5' recuperacion = 0; *)
                                        b_recuperacion := 0.0;
                                        (* '<S1>:164:6' if FC_der==1 *)
                                        IF FC_der THEN 
                                            (* '<S1>:164:6' ; *)
                                            (* '<S1>:164:7' error_der=1; *)
                                            error_der := 1.0;
                                        ELSIF FC_izq THEN 
                                            (* '<S1>:164:8' elseif FC_izq==1 *)
                                            (* '<S1>:164:8' ; *)
                                            (* '<S1>:164:9' error_izq=1; *)
                                            error_izq := 1.0;
                                        END_IF;
                                        (* '<S1>:164:11' modo_error = 1; *)
                                        b_modo_error := 1.0;
                                    ELSE 
                                        (* '<S1>:355:1' sf_internal_predicateOutput = 0 | ((FALLA_MAN == 1 ||... *)
                                        (* '<S1>:355:2'  FALLA_WD == 1 ||... *)
                                        (* '<S1>:355:3'  FALLA_SV ==1) &&... *)
                                        (* '<S1>:355:4'  error_otro == 0); *)
                                        IF (((FALLA_MAN = 1.0) OR (FALLA_WD = 1.0)) OR (FALLA_IZAJE_SV = 1.0)) AND (error_otro = 0.0) THEN 
                                            (* Transition: '<S1>:355' *)
                                            (* Exit Internal 'MODO_AUTO': '<S1>:240' *)
                                            CASE is_MODO_AUTO OF
                                                Nivel_IN_AUTO_INIT: 
                                                    is_MODO_AUTO := Nivel_IN_NO_ACTIVE_CHILD;
                                                Nivel_IN_MODO_MANUAL_SIMPLE: 
                                                    (* Exit 'MODO_MANUAL_SIMPLE': '<S1>:250' *)
                                                    (* '<S1>:250:23' estado = estado + 1; *)
                                                    estado := estado + 1.0;
                                                    (* '<S1>:250:24' modo_manual_auto = 0; *)
                                                    b_modo_manual_auto := 0.0;
                                                    is_MODO_AUTO := Nivel_IN_NO_ACTIVE_CHILD;
                                                Nivel_IN_MOVIMIENTO_CURVO: 
                                                    (* Exit 'MOVIMIENTO_CURVO': '<S1>:297' *)
                                                    (* '<S1>:297:18' ejec_mov = 0; *)
                                                    is_MODO_AUTO := Nivel_IN_NO_ACTIVE_CHILD;
                                                c_Nivel_IN_MOVIMIENTO_CURVO: 
                                                    (* Exit 'MOVIMIENTO_CURVO_FINAL': '<S1>:386' *)
                                                    (* '<S1>:386:15' ejec_mov_final = 0; *)
                                                    ejec_mov_final := 0.0;
                                                    is_MODO_AUTO := Nivel_IN_NO_ACTIVE_CHILD;
                                                c_Nivel_IN_SELECCION_TRAYEC: 
                                                    is_MODO_AUTO := Nivel_IN_NO_ACTIVE_CHILD;
                                                Nivel_IN_SEL_DESTINO: 
                                                    (* Exit 'SEL_DESTINO': '<S1>:311' *)
                                                    (* '<S1>:311:17' i_destino = i_sel; *)
                                                    i_destino := b_i_sel;
                                                    is_MODO_AUTO := Nivel_IN_NO_ACTIVE_CHILD;
                                                Nivel_IN_SEL_ORIGEN: 
                                                    (* Exit 'SEL_ORIGEN': '<S1>:190' *)
                                                    (* '<S1>:190:14' i_origen = i_sel; *)
                                                    i_origen := b_i_sel;
                                                    is_MODO_AUTO := Nivel_IN_NO_ACTIVE_CHILD;
                                            END_CASE;
                                            (* Exit 'MODO_AUTO': '<S1>:240' *)
                                            (* '<S1>:240:10' if(ya_vuelvo == 0) *)
                                            IF ya_vuelvo = 0.0 THEN 
                                                (* '<S1>:240:11' modo_auto = 0; *)
                                                b_modo_auto := 0.0;
                                                (* '<S1>:240:12' modo_manual_auto = 0; *)
                                                b_modo_manual_auto := 0.0;
                                                (* '<S1>:240:13' ejec_mov = 0; *)
                                            END_IF;
                                            is_AUTOMATA_PRINCIPAL := Nivel_IN_ERROR_OTRO;
                                            (* Entry 'ERROR_OTRO': '<S1>:353' *)
                                            (* '<S1>:353:3' BRK_t_N1 = 0; *)
                                            b_BRK_t_N1 := 0.0;
                                            (* '<S1>:353:3' BRK_h_N1 = 0; *)
                                            b_BRK_h_N1 := 0.0;
                                            (* '<S1>:353:4' recuperacion = 0; *)
                                            b_recuperacion := 0.0;
                                            (* '<S1>:353:5' error_otro = 1; *)
                                            error_otro := 1.0;
                                            (* '<S1>:353:6' vx_target=0 *)
                                            vx_target := 0.0;
                                            (* '<S1>:353:6' vy_target=0; *)
                                            vy_target := 0.0;
                                            (* '<S1>:353:7' modo_error = 1; *)
                                            b_modo_error := 1.0;
                                        ELSE 
                                            CASE is_MODO_AUTO OF
                                                Nivel_IN_AUTO_INIT: 
                                                    (* During 'AUTO_INIT': '<S1>:284' *)
                                                    (* Transition: '<S1>:253' *)
                                                    (* '<S1>:255:1' sf_internal_predicateOutput = 0 | (TLK == 1); *)
                                                    IF b_TLK = 1.0 THEN 
                                                        (* Transition: '<S1>:255' *)
                                                        temporalCounter_i1 := 0;
                                                        temporalCounter_i2 := 0;
                                                        is_MODO_AUTO := Nivel_IN_SEL_DESTINO;
                                                        (* Entry 'SEL_DESTINO': '<S1>:311' *)
                                                        (* '<S1>:311:3' i_sel = i_origen; *)
                                                        b_i_sel := i_origen;
                                                        (* '<S1>:311:4' i_destino = 0; *)
                                                        i_destino := 0.0;
                                                        (* '<S1>:311:5' invalido = 1; *)
                                                        invalido := 1.0;
                                                    ELSE 
                                                        (* '<S1>:260:1' sf_internal_predicateOutput = 0 | (TLK == 0); *)
                                                        IF b_TLK = 0.0 THEN 
                                                            (* Transition: '<S1>:260' *)
                                                            temporalCounter_i1 := 0;
                                                            temporalCounter_i2 := 0;
                                                            is_MODO_AUTO := Nivel_IN_SEL_ORIGEN;
                                                            (* Entry 'SEL_ORIGEN': '<S1>:190' *)
                                                            (* '<S1>:190:3' i_sel = 1; *)
                                                            b_i_sel := 1.0;
                                                            (* '<S1>:190:4' i_origen = 0; *)
                                                            i_origen := 0.0;
                                                            (* '<S1>:190:5' cont =0; *)
                                                            cont := 0.0;
                                                        END_IF;
                                                    END_IF;
                                                Nivel_IN_MODO_MANUAL_SIMPLE: 
                                                    (* During 'MODO_MANUAL_SIMPLE': '<S1>:250' *)
                                                    (* '<S1>:390:1' sf_internal_predicateOutput = 0 | (TLK == 0 && yh_enc > (envolvente(i_usado) + Hc) &&... *)
                                                    (* '<S1>:390:2'  abs(vh_obs) < 0.1 && estado == 2 && ciclo_doble ==1); *)
                                                    temp3 := FALSE;
                                                    IF b_TLK = 0.0 THEN 
                                                        IF yh > (envolvente[TRUNC(i_usado) - 1] + 2.59) THEN 
                                                            IF ABS(vh_obs) < 0.1 THEN 
                                                                IF (estado = 2.0) AND (ciclo_doble = 1.0) THEN 
                                                                    (* Transition: '<S1>:390' *)
                                                                    (* Exit 'MODO_MANUAL_SIMPLE': '<S1>:250' *)
                                                                    (* '<S1>:250:23' estado = estado + 1; *)
                                                                    (* '<S1>:250:24' modo_manual_auto = 0; *)
                                                                    b_modo_manual_auto := 0.0;
                                                                    is_MODO_AUTO := Nivel_IN_AUTO_INIT;
                                                                    (* Entry 'AUTO_INIT': '<S1>:284' *)
                                                                    (* '<S1>:284:3' BRK_t_N1 = 0; *)
                                                                    b_BRK_t_N1 := 0.0;
                                                                    (* '<S1>:284:3' BRK_h_N1 = 0; *)
                                                                    b_BRK_h_N1 := 0.0;
                                                                    (* '<S1>:284:4' home = 13; *)
                                                                    home := 13.0;
                                                                    (* '<S1>:284:5' estado = 1; *)
                                                                    estado := 1.0;
                                                                    (* Etapa de movimiento *)
                                                                    (* '<S1>:284:6' if (TLK == 1) *)
                                                                ELSE 
                                                                    temp3 := TRUE;
                                                                END_IF;
                                                            ELSE 
                                                                temp3 := TRUE;
                                                            END_IF;
                                                        ELSE 
                                                            temp3 := TRUE;
                                                        END_IF;
                                                    ELSE 
                                                        temp3 := TRUE;
                                                    END_IF;
                                                    IF temp3 THEN 
                                                        (* '<S1>:259:1' sf_internal_predicateOutput = 0 | ((TLK == 1 && yh_enc > (envolvente(i_usado) + Hc) &&... *)
                                                        (* '<S1>:259:2'  abs(vh_obs) < 0.1 && estado == 1) ||... *)
                                                        (* '<S1>:259:3' (TLK == 0 && yh_enc > (envolvente(i_usado) + Hc) &&... *)
                                                        (* '<S1>:259:4'  abs(vh_obs) < 0.1 && estado == 2)); *)
                                                        temp1 := FALSE;
                                                        temp3 := FALSE;
                                                        temp4 := FALSE;
                                                        IF b_TLK = 1.0 THEN 
                                                            IF yh > (envolvente[TRUNC(i_usado) - 1] + 2.59) THEN 
                                                                IF ABS(vh_obs) < 0.1 THEN 
                                                                    IF estado = 1.0 THEN 
                                                                        temp3 := TRUE;
                                                                    ELSE 
                                                                        temp4 := TRUE;
                                                                    END_IF;
                                                                ELSE 
                                                                    temp4 := TRUE;
                                                                END_IF;
                                                            ELSE 
                                                                temp4 := TRUE;
                                                            END_IF;
                                                        ELSE 
                                                            temp4 := TRUE;
                                                        END_IF;
                                                        IF temp4 THEN 
                                                            IF b_TLK = 0.0 THEN 
                                                                IF yh > (envolvente[TRUNC(i_usado) - 1] + 2.59) THEN 
                                                                    IF ABS(vh_obs) < 0.1 THEN 
                                                                        IF estado = 2.0 THEN 
                                                                            temp3 := TRUE;
                                                                        ELSE 
                                                                            temp1 := TRUE;
                                                                        END_IF;
                                                                    ELSE 
                                                                        temp1 := TRUE;
                                                                    END_IF;
                                                                ELSE 
                                                                    temp1 := TRUE;
                                                                END_IF;
                                                            ELSE 
                                                                temp1 := TRUE;
                                                            END_IF;
                                                        END_IF;
                                                        IF temp3 THEN 
                                                            (* Transition: '<S1>:259' *)
                                                            (* Exit 'MODO_MANUAL_SIMPLE': '<S1>:250' *)
                                                            (* '<S1>:250:23' estado = estado + 1; *)
                                                            estado := estado + 1.0;
                                                            (* '<S1>:250:24' modo_manual_auto = 0; *)
                                                            b_modo_manual_auto := 0.0;
                                                            is_MODO_AUTO := c_Nivel_IN_SELECCION_TRAYEC;
                                                            (* Entry 'SELECCION_TRAYECTORIA': '<S1>:244' *)
                                                            (* '<S1>:244:3' modo_auto = 1; *)
                                                            b_modo_auto := 1.0;
                                                            (* '<S1>:244:4' manual_ok = 0; *)
                                                            manual_ok := 0.0;
                                                            (* '<S1>:244:5' i_usado = 1; *)
                                                            (* '<S1>:244:6' if (estado == 1) *)
                                                            IF estado = 2.0 THEN 
                                                                (* '<S1>:244:8' elseif (estado == 2) *)
                                                                (* '<S1>:244:9' i_usado = i_destino; *)
                                                                i_usado := i_destino;
                                                            ELSE 
                                                                (* '<S1>:244:10' elseif (estado ==3) *)
                                                                (* '<S1>:244:10' ; *)
                                                                (* '<S1>:244:11' i_usado = home; *)
                                                                i_usado := home;
                                                            END_IF;
                                                        END_IF;
                                                        IF temp1 THEN 
                                                            (* '<S1>:250:6' if (abs(T_hm)>(m_container+Ms)*g*0.02) *)
                                                            IF ABS(T_hm) > (((b_m_container + 15000.0) * 9.80665) * 0.02) THEN 
                                                                (* '<S1>:250:7' BRK_h_N1=1; *)
                                                                b_BRK_h_N1 := 1.0;
                                                            END_IF;
                                                            (* '<S1>:250:9' if (abs(T_tm)>(m_container+Ms)*g*0.0002) *)
                                                            IF ABS(T_tm) > (((b_m_container + 15000.0) * 9.80665) * 0.0002) THEN 
                                                                (* '<S1>:250:10' BRK_t_N1=1; *)
                                                                b_BRK_t_N1 := 1.0;
                                                            END_IF;
                                                            (* '<S1>:250:12' if (abs(Joy_CMD_X) < dead_zone) *)
                                                            IF ABS(Joy_XY[0]) < dead_zone THEN 
                                                                (* '<S1>:250:13' vx_target = 0; *)
                                                                vx_target := 0.0;
                                                            ELSE 
                                                                (* '<S1>:250:14' else *)
                                                                (* '<S1>:250:15' vx_target = Joy_CMD_X * 0.05; *)
                                                                vx_target := Joy_XY[0] * 0.05;
                                                            END_IF;
                                                            (* '<S1>:250:17' if (abs(Joy_CMD_Y) < dead_zone) *)
                                                            IF ABS(Joy_XY[1]) < dead_zone THEN 
                                                                (* '<S1>:250:18' vy_target = 0; *)
                                                                vy_target := 0.0;
                                                            ELSE 
                                                                (* '<S1>:250:19' else *)
                                                                (* '<S1>:250:20' vy_target = Joy_CMD_Y * vh_lim; *)
                                                                vy_target := Joy_XY[1] * vh_lim;
                                                            END_IF;
                                                        END_IF;
                                                    END_IF;
                                                Nivel_IN_MOVIMIENTO_CURVO: 
                                                    (* During 'MOVIMIENTO_CURVO': '<S1>:297' *)
                                                    (* '<S1>:261:1' sf_internal_predicateOutput = 0 | (manual_ok == 1); *)
                                                    IF manual_ok = 1.0 THEN 
                                                        (* Transition: '<S1>:261' *)
                                                        (* Exit 'MOVIMIENTO_CURVO': '<S1>:297' *)
                                                        (* '<S1>:297:18' ejec_mov = 0; *)
                                                        is_MODO_AUTO := Nivel_IN_MODO_MANUAL_SIMPLE;
                                                        (* Entry 'MODO_MANUAL_SIMPLE': '<S1>:250' *)
                                                        (* '<S1>:250:3' modo_auto = 0; *)
                                                        b_modo_auto := 0.0;
                                                        (* '<S1>:250:4' modo_manual_auto = 1; *)
                                                        b_modo_manual_auto := 1.0;
                                                    ELSE 
                                                        (* '<S1>:346:1' sf_internal_predicateOutput = 0 | (ya_vuelvo==1); *)
                                                        IF ya_vuelvo = 1.0 THEN 
                                                            (* Transition: '<S1>:346' *)
                                                            (* Exit 'MOVIMIENTO_CURVO': '<S1>:297' *)
                                                            (* '<S1>:297:18' ejec_mov = 0; *)
                                                            is_MODO_AUTO := Nivel_IN_NO_ACTIVE_CHILD;
                                                            (* Exit 'MODO_AUTO': '<S1>:240' *)
                                                            (* '<S1>:240:10' if(ya_vuelvo == 0) *)
                                                            durationCounter_1 := 0;
                                                            is_AUTOMATA_PRINCIPAL := Nivel_IN_MANUAL;
                                                            (* Entry 'MANUAL': '<S1>:9' *)
                                                            (* BRK_t_N1 = 1; BRK_h_N1 = 1; *)
                                                            (* '<S1>:9:4' modo_manual = 1; *)
                                                            b_modo_manual := 1.0;
                                                        ELSE 
                                                            (* '<S1>:297:4' if (abs(T_hm)>(m_container+Ms)*g*0.02) *)
                                                            IF ABS(T_hm) > (((b_m_container + 15000.0) * 9.80665) * 0.02) THEN 
                                                                (* '<S1>:297:5' BRK_h_N1=1; *)
                                                                b_BRK_h_N1 := 1.0;
                                                            END_IF;
                                                            (* '<S1>:297:7' if (abs(T_tm)>(m_container+Ms)*g*0.0002) *)
                                                            IF ABS(T_tm) > (((b_m_container + 15000.0) * 9.80665) * 0.0002) THEN 
                                                                (* '<S1>:297:8' BRK_t_N1=1; *)
                                                                b_BRK_t_N1 := 1.0;
                                                            END_IF;
                                                            (* '<S1>:297:10' [vx_target, vy_target, manual_ok] = Planificador_Trayectoria_Vel(xt_enc,... *)
                                                            (* '<S1>:297:11'        yh_enc, vt_obs, vh_obs, i_usado, envolvente, TLK, theta_l, vh_lim); *)
                                                            (* 1. INICIALIZACIÓN *)
                                                            (* MATLAB Function 'Planificador_Trayectoria_Vel': '<S1>:310' *)
                                                            (* '<S1>:310:6' if isempty(last_i_ref) *)
                                                            (* '<S1>:310:9' if i_ref ~= last_i_ref *)
                                                            IF i_usado <> last_i_ref THEN 
                                                                (* '<S1>:310:10' last_i_ref = i_ref; *)
                                                                last_i_ref := i_usado;
                                                            END_IF;
                                                            (* 2. PARÁMETROS GLOBALES FÍSICOS *)
                                                            (* '<S1>:310:14' Kp_x = 0.20; *)
                                                            (* '<S1>:310:15' Kd_x = 0.15; *)
                                                            (* '<S1>:310:16' Kp_y = 0.38; *)
                                                            (* '<S1>:310:17' Kd_y = 0.25; *)
                                                            (* '<S1>:310:19' H_extra = double(twistlock == 1) * Hc; *)
                                                            b_H_extra := BOOL_TO_LREAL(b_TLK = 1.0) * 2.59;
                                                            (* 3. MAPEO DE LA RUTA Y OBSTÁCULOS *)
                                                            (* '<S1>:310:22' i_obj = min(max(i_ref, 1), 33); *)
                                                            temp6 := MAX(i_usado, 1.0);
                                                            b_i_obj := MIN(temp6, 33.0);
                                                            (* '<S1>:310:23' i_act = min(max(floor((x_real - xt_min) / Wc) + 1, 1), 33); *)
                                                            temp7 := MAX(i_carro_tmp, 1.0);
                                                            b_i_act := TRUNC(MIN(temp7, 33.0));
                                                            (* '<S1>:310:24' x_dest = xt_min + (i_obj - 0.5) * Wc; *)
                                                            b_x_dest := ((b_i_obj - 0.5) * 2.44) - 30.0;
                                                            (* '<S1>:310:26' step = sign(i_obj - i_act); *)
                                                            T_retardo := b_i_obj - DINT_TO_LREAL(b_i_act);
                                                            IF T_retardo < 0.0 THEN 
                                                                i := -1;
                                                            ELSIF T_retardo > 0.0 THEN 
                                                                i := 1;
                                                            ELSE 
                                                                i := 0;
                                                            END_IF;
                                                            b_b_step := i;
                                                            (* '<S1>:310:27' if step == 0 *)
                                                            IF i = 0 THEN 
                                                                (* '<S1>:310:27' ; *)
                                                                (* '<S1>:310:27' step = 1; *)
                                                                b_b_step := 1;
                                                            END_IF;
                                                            (* '<S1>:310:29' h_obst_fwd = 0; *)
                                                            b_h_obst_fwd := 0.0;
                                                            (* '<S1>:310:30' for k = i_act : step : i_obj *)
                                                            i := TRUNC((DINT_TO_LREAL(b_b_step - b_i_act) + b_i_obj) / DINT_TO_LREAL(b_b_step));
                                                            f_k := 0;
                                                            WHILE f_k <= (i - 1) DO
                                                                (* '<S1>:310:31' if envolvente_vec(k) > h_obst_fwd *)
                                                                T_retardo := envolvente[TRUNC((DINT_TO_LREAL(f_k) * DINT_TO_LREAL(b_b_step)) + DINT_TO_LREAL(b_i_act)) - 1];
                                                                IF T_retardo > b_h_obst_fwd THEN 
                                                                    (* '<S1>:310:32' h_obst_fwd = envolvente_vec(k); *)
                                                                    b_h_obst_fwd := T_retardo;
                                                                END_IF;
                                                                f_k := f_k + 1;
                                                            END_WHILE;
                                                            (* '<S1>:310:35' y_techo_ruta = h_obst_fwd + H_extra; *)
                                                            (* 4. SINCRONIZACIÓN CINEMÁTICA *)
                                                            (* Escaneamos las columnas por delante para ver cuánto tiempo necesitamos para subir *)
                                                            (* '<S1>:310:39' limite_vx_sinc = vt_max; *)
                                                            b_limite_vx_sinc := 4.0;
                                                            (* '<S1>:310:41' for k = i_act : step : i_obj *)
                                                            g_k := 0;
                                                            WHILE g_k <= (i - 1) DO
                                                                e_k := (DINT_TO_LREAL(g_k) * DINT_TO_LREAL(b_b_step)) + DINT_TO_LREAL(b_i_act);
                                                                (* '<S1>:310:42' techo_seguro = envolvente_vec(k) + H_extra; *)
                                                                (* '<S1>:310:43' dy = techo_seguro - y_real; *)
                                                                b_dy := (envolvente[TRUNC(e_k) - 1] + b_H_extra) - yh;
                                                                (* '<S1>:310:45' if dy > 0 *)
                                                                IF b_dy > 0.0 THEN 
                                                                    (* Si esa columna está más alta que mi posición actual *)
                                                                    (* '<S1>:310:46' xc = xt_min + (k - 0.5) * Wc; *)
                                                                    (* Distancia horizontal hasta la "pared" de esa celda *)
                                                                    (* '<S1>:310:49' dx = abs(xc - x_real) - (Wc / 2); *)
                                                                    (* '<S1>:310:50' dx = max(0.01, dx); *)
                                                                    (* Evitamos división por cero si estamos muy pegados *)
                                                                    (* Tiempo que nos tomará subir ese 'dy' yendo a velocidad de izaje *)
                                                                    (* '<S1>:310:53' tiempo_para_subir = dy / vh_limit; *)
                                                                    (* La velocidad en X permitida para que nos dé el tiempo de subir sin chocar *)
                                                                    (* '<S1>:310:56' vx_max_permitida = (dx + 1.5) / tiempo_para_subir; *)
                                                                    temp11 := ABS((((e_k - 0.5) * 2.44) - 30.0) - xt);
                                                                    b_vx_max_permitida := (MAX(0.01, temp11 - 1.22) + 1.5) / (b_dy / vh_lim);
                                                                    (* Nos quedamos siempre con el límite más restrictivo de todo el camino *)
                                                                    (* '<S1>:310:59' if vx_max_permitida < limite_vx_sinc *)
                                                                    IF b_vx_max_permitida < b_limite_vx_sinc THEN 
                                                                        (* '<S1>:310:60' limite_vx_sinc = vx_max_permitida; *)
                                                                        b_limite_vx_sinc := b_vx_max_permitida;
                                                                    END_IF;
                                                                END_IF;
                                                                g_k := g_k + 1;
                                                            END_WHILE;
                                                            (* Mantenemos una velocidad mínima de 0.10 m/s para que nunca se congele *)
                                                            (* '<S1>:310:66' limite_vx_final = max(0.10, min(vt_max, limite_vx_sinc)); *)
                                                            b_limite_vx_final := MAX(0.1, b_limite_vx_sinc);
                                                            (* Control PD para el carro *)
                                                            (* '<S1>:310:69' l = 45 - y_real; *)
                                                            (* '<S1>:310:70' x_carga   = x_real + l * sin(tita_l); *)
                                                            (* '<S1>:310:71' e_x   = x_dest - x_carga; *)
                                                            (* '<S1>:310:72' vx_req = Kp_x * e_x - Kd_x * vx_carro; *)
                                                            (* Saturamos la referencia con nuestro nuevo límite inteligente *)
                                                            (* '<S1>:310:75' vx_ref = max(-limite_vx_final, min(limite_vx_final, vx_req)); *)
                                                            temp8 := SIN(tita_l);
                                                            temp9 := MIN(b_limite_vx_final, ((b_x_dest - (((45.0 - yh) * temp8) + xt)) * 0.2) - (0.15 * vt_obs));
                                                            vx_target := MAX( -b_limite_vx_final, temp9);
                                                            (* 5. PLANIFICACIÓN VERTICAL EN Y *)
                                                            (* '<S1>:310:78' h_dest_final = envolvente_vec(i_obj) + H_extra; *)
                                                            b_h_dest_final := envolvente[TRUNC(b_i_obj) - 1] + b_H_extra;
                                                            (* '<S1>:310:80' if abs(x_real - x_dest) < (Wc * 0.4) *)
                                                            T_retardo := ABS(xt - b_x_dest);
                                                            IF T_retardo < 0.976 THEN 
                                                                (* '<S1>:310:81' y_target = h_dest_final; *)
                                                                b_y_target := b_h_dest_final;
                                                            ELSE 
                                                                (* '<S1>:310:82' else *)
                                                                (* '<S1>:310:83' y_target = max(h_dest_final, y_techo_ruta + 1); *)
                                                                b_y_target := MAX(b_h_dest_final, (b_h_obst_fwd + b_H_extra) + 1.0);
                                                            END_IF;
                                                            (* Control PD para el izaje *)
                                                            (* '<S1>:310:87' vy_req = Kp_y * (y_target - y_real) - Kd_y * vy_izaje; *)
                                                            (* '<S1>:310:88' vy_ref = max(-vh_limit, min(vh_limit, vy_req)); *)
                                                            temp10 := MIN(vh_lim, ((b_y_target - yh) * 0.38) - (0.25 * vh_obs));
                                                            vy_target := MAX( -vh_lim, temp10);
                                                            (* 6. SEÑAL DE LISTO *)
                                                            (* '<S1>:310:91' listo = double( ... *)
                                                            (* '<S1>:310:92'     abs(x_real - x_dest) < 0.05 && ...           *)
                                                            (* '<S1>:310:93'     abs(y_real - h_dest_final) < 0.1 && ...      *)
                                                            (* '<S1>:310:94'     abs(tita_l) < 0.0174 && ...                  *)
                                                            (* '<S1>:310:95'     abs(vx_carro) < 0.05 &&... *)
                                                            (* '<S1>:310:96'     abs(vy_izaje) < 0.05); *)
                                                            IF T_retardo < 0.05 THEN 
                                                                IF ABS(yh - b_h_dest_final) < 0.1 THEN 
                                                                    IF ABS(tita_l) < 0.0174 THEN 
                                                                        IF ABS(vt_obs) < 0.05 THEN 
                                                                            IF ABS(vh_obs) < 0.05 THEN 
                                                                                e_hoisted_cond := TRUE;
                                                                            END_IF;
                                                                        END_IF;
                                                                    END_IF;
                                                                END_IF;
                                                            END_IF;
                                                            manual_ok := BOOL_TO_LREAL(e_hoisted_cond);
                                                            (* '<S1>:297:12' if (abs(Joy_XY(1)) > dead_zone || abs(Joy_XY(2)) > dead_zone) *)
                                                            IF ABS(Joy_XY[0]) > dead_zone THEN 
                                                                (* '<S1>:297:13' ya_vuelvo = 1 *)
                                                                ya_vuelvo := 1.0;
                                                            ELSIF ABS(Joy_XY[1]) > dead_zone THEN 
                                                                (* '<S1>:297:13' ya_vuelvo = 1 *)
                                                                ya_vuelvo := 1.0;
                                                            END_IF;
                                                            (* '<S1>:297:15' if (BTN_Auto ==1) *)
                                                            IF X THEN 
                                                                (* '<S1>:297:16' ciclo_doble=1; *)
                                                                ciclo_doble := 1.0;
                                                            END_IF;
                                                        END_IF;
                                                    END_IF;
                                                c_Nivel_IN_MOVIMIENTO_CURVO: 
                                                    (* During 'MOVIMIENTO_CURVO_FINAL': '<S1>:386' *)
                                                    (* '<S1>:386:4' if (abs(T_hm)>(m_container+Ms)*g*0.02) *)
                                                    IF ABS(T_hm) > (((b_m_container + 15000.0) * 9.80665) * 0.02) THEN 
                                                        (* '<S1>:386:5' BRK_h_N1=1; *)
                                                        b_BRK_h_N1 := 1.0;
                                                    END_IF;
                                                    (* '<S1>:386:7' if (abs(T_tm)>(m_container+Ms)*g*0.0002) *)
                                                    IF ABS(T_tm) > (((b_m_container + 15000.0) * 9.80665) * 0.0002) THEN 
                                                        (* '<S1>:386:8' BRK_t_N1=1; *)
                                                        b_BRK_t_N1 := 1.0;
                                                    END_IF;
                                                    (* '<S1>:386:10' [vx_target, vy_target, manual_ok] = Planificador_Trayectoria_Vel(xt_enc,... *)
                                                    (* '<S1>:386:11'        yh_enc, vt_obs, vh_obs, i_usado, envolvent, TLK, theta_l, vh_lim); *)
                                                    (* 1. INICIALIZACIÓN *)
                                                    (* MATLAB Function 'Planificador_Trayectoria_Vel': '<S1>:310' *)
                                                    (* '<S1>:310:6' if isempty(last_i_ref) *)
                                                    (* '<S1>:310:9' if i_ref ~= last_i_ref *)
                                                    IF i_usado <> last_i_ref THEN 
                                                        (* '<S1>:310:10' last_i_ref = i_ref; *)
                                                        last_i_ref := i_usado;
                                                    END_IF;
                                                    (* 2. PARÁMETROS GLOBALES FÍSICOS *)
                                                    (* '<S1>:310:14' Kp_x = 0.20; *)
                                                    (* '<S1>:310:15' Kd_x = 0.15; *)
                                                    (* '<S1>:310:16' Kp_y = 0.38; *)
                                                    (* '<S1>:310:17' Kd_y = 0.25; *)
                                                    (* '<S1>:310:19' H_extra = double(twistlock == 1) * Hc; *)
                                                    H_extra := BOOL_TO_LREAL(b_TLK = 1.0) * 2.59;
                                                    (* 3. MAPEO DE LA RUTA Y OBSTÁCULOS *)
                                                    (* '<S1>:310:22' i_obj = min(max(i_ref, 1), 33); *)
                                                    temp12 := MAX(i_usado, 1.0);
                                                    i_obj := MIN(temp12, 33.0);
                                                    (* '<S1>:310:23' i_act = min(max(floor((x_real - xt_min) / Wc) + 1, 1), 33); *)
                                                    temp13 := MAX(i_carro_tmp, 1.0);
                                                    i_act := TRUNC(MIN(temp13, 33.0));
                                                    (* '<S1>:310:24' x_dest = xt_min + (i_obj - 0.5) * Wc; *)
                                                    x_dest := ((i_obj - 0.5) * 2.44) - 30.0;
                                                    (* '<S1>:310:26' step = sign(i_obj - i_act); *)
                                                    T_retardo := i_obj - DINT_TO_LREAL(i_act);
                                                    IF T_retardo < 0.0 THEN 
                                                        i := -1;
                                                    ELSIF T_retardo > 0.0 THEN 
                                                        i := 1;
                                                    ELSE 
                                                        i := 0;
                                                    END_IF;
                                                    b_step := i;
                                                    (* '<S1>:310:27' if step == 0 *)
                                                    IF i = 0 THEN 
                                                        (* '<S1>:310:27' ; *)
                                                        (* '<S1>:310:27' step = 1; *)
                                                        b_step := 1;
                                                    END_IF;
                                                    (* '<S1>:310:29' h_obst_fwd = 0; *)
                                                    h_obst_fwd := 0;
                                                    (* '<S1>:310:30' for k = i_act : step : i_obj *)
                                                    i := TRUNC((DINT_TO_LREAL(b_step - i_act) + i_obj) / DINT_TO_LREAL(b_step));
                                                    c_k := 0;
                                                    WHILE c_k <= (i - 1) DO
                                                        (* '<S1>:310:31' if envolvente_vec(k) > h_obst_fwd *)
                                                        IF h_obst_fwd < 10 THEN 
                                                            (* '<S1>:310:32' h_obst_fwd = envolvente_vec(k); *)
                                                            h_obst_fwd := 10;
                                                        END_IF;
                                                        c_k := c_k + 1;
                                                    END_WHILE;
                                                    (* '<S1>:310:35' y_techo_ruta = h_obst_fwd + H_extra; *)
                                                    (* 4. SINCRONIZACIÓN CINEMÁTICA *)
                                                    (* Escaneamos las columnas por delante para ver cuánto tiempo necesitamos para subir *)
                                                    (* '<S1>:310:39' limite_vx_sinc = vt_max; *)
                                                    limite_vx_sinc := 4.0;
                                                    (* '<S1>:310:41' for k = i_act : step : i_obj *)
                                                    d_k := 0;
                                                    WHILE d_k <= (i - 1) DO
                                                        (* '<S1>:310:42' techo_seguro = envolvente_vec(k) + H_extra; *)
                                                        (* '<S1>:310:43' dy = techo_seguro - y_real; *)
                                                        dy := (H_extra + 10.0) - yh;
                                                        (* '<S1>:310:45' if dy > 0 *)
                                                        IF dy > 0.0 THEN 
                                                            (* Si esa columna está más alta que mi posición actual *)
                                                            (* '<S1>:310:46' xc = xt_min + (k - 0.5) * Wc; *)
                                                            (* Distancia horizontal hasta la "pared" de esa celda *)
                                                            (* '<S1>:310:49' dx = abs(xc - x_real) - (Wc / 2); *)
                                                            (* '<S1>:310:50' dx = max(0.01, dx); *)
                                                            (* Evitamos división por cero si estamos muy pegados *)
                                                            (* Tiempo que nos tomará subir ese 'dy' yendo a velocidad de izaje *)
                                                            (* '<S1>:310:53' tiempo_para_subir = dy / vh_limit; *)
                                                            (* La velocidad en X permitida para que nos dé el tiempo de subir sin chocar *)
                                                            (* '<S1>:310:56' vx_max_permitida = (dx + 1.5) / tiempo_para_subir; *)
                                                            temp17 := ABS((((((DINT_TO_LREAL(d_k) * DINT_TO_LREAL(b_step)) + DINT_TO_LREAL(i_act)) - 0.5) * 2.44) - 30.0) - xt);
                                                            vx_max_permitida := (MAX(0.01, temp17 - 1.22) + 1.5) / (dy / vh_lim);
                                                            (* Nos quedamos siempre con el límite más restrictivo de todo el camino *)
                                                            (* '<S1>:310:59' if vx_max_permitida < limite_vx_sinc *)
                                                            IF vx_max_permitida < limite_vx_sinc THEN 
                                                                (* '<S1>:310:60' limite_vx_sinc = vx_max_permitida; *)
                                                                limite_vx_sinc := vx_max_permitida;
                                                            END_IF;
                                                        END_IF;
                                                        d_k := d_k + 1;
                                                    END_WHILE;
                                                    (* Mantenemos una velocidad mínima de 0.10 m/s para que nunca se congele *)
                                                    (* '<S1>:310:66' limite_vx_final = max(0.10, min(vt_max, limite_vx_sinc)); *)
                                                    limite_vx_final := MAX(0.1, limite_vx_sinc);
                                                    (* Control PD para el carro *)
                                                    (* '<S1>:310:69' l = 45 - y_real; *)
                                                    (* '<S1>:310:70' x_carga   = x_real + l * sin(tita_l); *)
                                                    (* '<S1>:310:71' e_x   = x_dest - x_carga; *)
                                                    (* '<S1>:310:72' vx_req = Kp_x * e_x - Kd_x * vx_carro; *)
                                                    (* Saturamos la referencia con nuestro nuevo límite inteligente *)
                                                    (* '<S1>:310:75' vx_ref = max(-limite_vx_final, min(limite_vx_final, vx_req)); *)
                                                    temp14 := SIN(tita_l);
                                                    temp15 := MIN(limite_vx_final, ((x_dest - (((45.0 - yh) * temp14) + xt)) * 0.2) - (0.15 * vt_obs));
                                                    vx_target := MAX( -limite_vx_final, temp15);
                                                    (* 5. PLANIFICACIÓN VERTICAL EN Y *)
                                                    (* '<S1>:310:78' h_dest_final = envolvente_vec(i_obj) + H_extra; *)
                                                    (* '<S1>:310:80' if abs(x_real - x_dest) < (Wc * 0.4) *)
                                                    T_retardo := ABS(xt - x_dest);
                                                    IF T_retardo < 0.976 THEN 
                                                        (* '<S1>:310:81' y_target = h_dest_final; *)
                                                        y_target := H_extra + 10.0;
                                                    ELSE 
                                                        (* '<S1>:310:82' else *)
                                                        (* '<S1>:310:83' y_target = max(h_dest_final, y_techo_ruta + 1); *)
                                                        y_target := MAX(H_extra + 10.0, (DINT_TO_LREAL(h_obst_fwd) + H_extra) + 1.0);
                                                    END_IF;
                                                    (* Control PD para el izaje *)
                                                    (* '<S1>:310:87' vy_req = Kp_y * (y_target - y_real) - Kd_y * vy_izaje; *)
                                                    (* '<S1>:310:88' vy_ref = max(-vh_limit, min(vh_limit, vy_req)); *)
                                                    temp16 := MIN(vh_lim, ((y_target - yh) * 0.38) - (0.25 * vh_obs));
                                                    vy_target := MAX( -vh_lim, temp16);
                                                    (* 6. SEÑAL DE LISTO *)
                                                    (* '<S1>:310:91' listo = double( ... *)
                                                    (* '<S1>:310:92'     abs(x_real - x_dest) < 0.05 && ...           *)
                                                    (* '<S1>:310:93'     abs(y_real - h_dest_final) < 0.1 && ...      *)
                                                    (* '<S1>:310:94'     abs(tita_l) < 0.0174 && ...                  *)
                                                    (* '<S1>:310:95'     abs(vx_carro) < 0.05 &&... *)
                                                    (* '<S1>:310:96'     abs(vy_izaje) < 0.05); *)
                                                    IF T_retardo < 0.05 THEN 
                                                        IF ABS(yh - (H_extra + 10.0)) < 0.1 THEN 
                                                            IF ABS(tita_l) < 0.0174 THEN 
                                                                IF ABS(vt_obs) < 0.05 THEN 
                                                                    IF ABS(vh_obs) < 0.05 THEN 
                                                                        e_hoisted_cond := TRUE;
                                                                    END_IF;
                                                                END_IF;
                                                            END_IF;
                                                        END_IF;
                                                    END_IF;
                                                    manual_ok := BOOL_TO_LREAL(e_hoisted_cond);
                                                    (* '<S1>:386:12' if (abs(Joy_XY(1)) > dead_zone || abs(Joy_XY(2)) > dead_zone) *)
                                                    IF ABS(Joy_XY[0]) > dead_zone THEN 
                                                        (* '<S1>:386:13' ya_vuelvo = 1 *)
                                                        ya_vuelvo := 1.0;
                                                    ELSIF ABS(Joy_XY[1]) > dead_zone THEN 
                                                        (* '<S1>:386:13' ya_vuelvo = 1 *)
                                                        ya_vuelvo := 1.0;
                                                    END_IF;
                                                c_Nivel_IN_SELECCION_TRAYEC: 
                                                    (* During 'SELECCION_TRAYECTORIA': '<S1>:244' *)
                                                    (* '<S1>:387:1' sf_internal_predicateOutput = 0 | (estado == 3); *)
                                                    IF estado = 3.0 THEN 
                                                        (* Transition: '<S1>:387' *)
                                                        is_MODO_AUTO := c_Nivel_IN_MOVIMIENTO_CURVO;
                                                        (* Entry 'MOVIMIENTO_CURVO_FINAL': '<S1>:386' *)
                                                        (* '<S1>:386:2' ejec_mov_final = 1; *)
                                                        ejec_mov_final := 1.0;
                                                        (* '<S1>:386:2' ya_vuelvo=0; *)
                                                        ya_vuelvo := 0.0;
                                                    ELSE 
                                                        (* Transition: '<S1>:246' *)
                                                        is_MODO_AUTO := Nivel_IN_MOVIMIENTO_CURVO;
                                                        (* Entry 'MOVIMIENTO_CURVO': '<S1>:297' *)
                                                        (* '<S1>:297:2' ejec_mov = 1; *)
                                                        (* '<S1>:297:2' ya_vuelvo=0; *)
                                                        ya_vuelvo := 0.0;
                                                    END_IF;
                                                Nivel_IN_SEL_DESTINO: 
                                                    (* During 'SEL_DESTINO': '<S1>:311' *)
                                                    (* '<S1>:258:1' sf_internal_predicateOutput = 0 | (BTN_TLK &&... *)
                                                    (* '<S1>:258:2'  invalido == 0); *)
                                                    IF A AND (invalido = 0.0) THEN 
                                                        (* Transition: '<S1>:258' *)
                                                        (* Exit 'SEL_DESTINO': '<S1>:311' *)
                                                        (* '<S1>:311:17' i_destino = i_sel; *)
                                                        i_destino := b_i_sel;
                                                        is_MODO_AUTO := c_Nivel_IN_SELECCION_TRAYEC;
                                                        (* Entry 'SELECCION_TRAYECTORIA': '<S1>:244' *)
                                                        (* '<S1>:244:3' modo_auto = 1; *)
                                                        b_modo_auto := 1.0;
                                                        (* '<S1>:244:4' manual_ok = 0; *)
                                                        manual_ok := 0.0;
                                                        (* '<S1>:244:5' i_usado = 1; *)
                                                        i_usado := 1.0;
                                                        (* '<S1>:244:6' if (estado == 1) *)
                                                        IF estado = 1.0 THEN 
                                                            (* '<S1>:244:7' i_usado = i_origen; *)
                                                            i_usado := i_origen;
                                                        ELSIF estado = 2.0 THEN 
                                                            (* '<S1>:244:8' elseif (estado == 2) *)
                                                            (* '<S1>:244:9' i_usado = i_destino; *)
                                                            i_usado := i_destino;
                                                        ELSIF estado = 3.0 THEN 
                                                            (* '<S1>:244:10' elseif (estado ==3) *)
                                                            (* '<S1>:244:10' ; *)
                                                            (* '<S1>:244:11' i_usado = home; *)
                                                            i_usado := home;
                                                        END_IF;
                                                    ELSE 
                                                        (* '<S1>:311:7' if (Joy_CMD_X > dead_zone) && every(50, tick) *)
                                                        temp3 := FALSE;
                                                        IF Joy_XY[0] > dead_zone THEN 
                                                            IF temporalCounter_i1 = 50 THEN 
                                                                (* '<S1>:311:8' i_sel = i_sel + 1; *)
                                                                b_i_sel := b_i_sel + 1.0;
                                                            ELSE 
                                                                temp3 := TRUE;
                                                            END_IF;
                                                        ELSE 
                                                            temp3 := TRUE;
                                                        END_IF;
                                                        IF temp3 THEN 
                                                            IF Joy_XY[0] < ( -dead_zone) THEN 
                                                                IF temporalCounter_i2 = 50 THEN 
                                                                    (* '<S1>:311:9' elseif (Joy_CMD_X < -dead_zone) && every(50, tick) *)
                                                                    (* '<S1>:311:10' i_sel = i_sel - 1; *)
                                                                    b_i_sel := b_i_sel - 1.0;
                                                                END_IF;
                                                            END_IF;
                                                        END_IF;
                                                        (* '<S1>:311:12' if (i_sel == 33 || i_sel == 13 || i_sel == 1|| i_sel==i_origen) *)
                                                        IF (((b_i_sel = 33.0) OR (b_i_sel = 13.0)) OR (b_i_sel = 1.0)) OR (b_i_sel = i_origen) THEN 
                                                            (* '<S1>:311:13' invalido = 1; *)
                                                            invalido := 1.0;
                                                        ELSE 
                                                            (* '<S1>:311:14' else *)
                                                            (* '<S1>:311:14' invalido = 0; *)
                                                            invalido := 0.0;
                                                        END_IF;
                                                    END_IF;
                                                ELSE
                                                    (* During 'SEL_ORIGEN': '<S1>:190' *)
                                                    (* '<S1>:256:1' sf_internal_predicateOutput = 0 | (BTN_TLK &&... *)
                                                    (* '<S1>:256:2'  cont == 1); *)
                                                    IF A AND (cont = 1.0) THEN 
                                                        (* Transition: '<S1>:256' *)
                                                        (* Exit 'SEL_ORIGEN': '<S1>:190' *)
                                                        (* '<S1>:190:14' i_origen = i_sel; *)
                                                        i_origen := b_i_sel;
                                                        temporalCounter_i1 := 0;
                                                        temporalCounter_i2 := 0;
                                                        is_MODO_AUTO := Nivel_IN_SEL_DESTINO;
                                                        (* Entry 'SEL_DESTINO': '<S1>:311' *)
                                                        (* '<S1>:311:3' i_sel = i_origen; *)
                                                        (* '<S1>:311:4' i_destino = 0; *)
                                                        i_destino := 0.0;
                                                        (* '<S1>:311:5' invalido = 1; *)
                                                        invalido := 1.0;
                                                    ELSE 
                                                        (* '<S1>:190:7' if (Joy_CMD_X > dead_zone) && every(50, tick) *)
                                                        temp3 := FALSE;
                                                        IF Joy_XY[0] > dead_zone THEN 
                                                            IF temporalCounter_i1 = 50 THEN 
                                                                (* '<S1>:190:8' i_sel = i_sel + 1; *)
                                                                b_i_sel := b_i_sel + 1.0;
                                                            ELSE 
                                                                temp3 := TRUE;
                                                            END_IF;
                                                        ELSE 
                                                            temp3 := TRUE;
                                                        END_IF;
                                                        IF temp3 THEN 
                                                            IF Joy_XY[0] < ( -dead_zone) THEN 
                                                                IF temporalCounter_i2 = 50 THEN 
                                                                    (* '<S1>:190:9' elseif (Joy_CMD_X < -dead_zone) && every(50, tick) *)
                                                                    (* '<S1>:190:10' i_sel = i_sel - 1; *)
                                                                    b_i_sel := b_i_sel - 1.0;
                                                                END_IF;
                                                            END_IF;
                                                        END_IF;
                                                        (* '<S1>:190:12' cont= Check_Container(i_sel,yc0_vec); *)
                                                        cont := Check_Container(i_pos := b_i_sel, y0_vec := b_yc0_vec);
                                                    END_IF;
                                            END_CASE;
                                        END_IF;
                                    END_IF;
                                END_IF;
                            END_IF;
                            IF temp2 THEN 
                                (* Exit Internal 'MODO_AUTO': '<S1>:240' *)
                                CASE is_MODO_AUTO OF
                                    Nivel_IN_AUTO_INIT: 
                                        is_MODO_AUTO := Nivel_IN_NO_ACTIVE_CHILD;
                                    Nivel_IN_MODO_MANUAL_SIMPLE: 
                                        (* Exit 'MODO_MANUAL_SIMPLE': '<S1>:250' *)
                                        (* '<S1>:250:23' estado = estado + 1; *)
                                        estado := estado + 1.0;
                                        (* '<S1>:250:24' modo_manual_auto = 0; *)
                                        is_MODO_AUTO := Nivel_IN_NO_ACTIVE_CHILD;
                                    Nivel_IN_MOVIMIENTO_CURVO: 
                                        (* Exit 'MOVIMIENTO_CURVO': '<S1>:297' *)
                                        (* '<S1>:297:18' ejec_mov = 0; *)
                                        is_MODO_AUTO := Nivel_IN_NO_ACTIVE_CHILD;
                                    c_Nivel_IN_MOVIMIENTO_CURVO: 
                                        (* Exit 'MOVIMIENTO_CURVO_FINAL': '<S1>:386' *)
                                        (* '<S1>:386:15' ejec_mov_final = 0; *)
                                        ejec_mov_final := 0.0;
                                        is_MODO_AUTO := Nivel_IN_NO_ACTIVE_CHILD;
                                    c_Nivel_IN_SELECCION_TRAYEC: 
                                        is_MODO_AUTO := Nivel_IN_NO_ACTIVE_CHILD;
                                    Nivel_IN_SEL_DESTINO: 
                                        (* Exit 'SEL_DESTINO': '<S1>:311' *)
                                        (* '<S1>:311:17' i_destino = i_sel; *)
                                        i_destino := b_i_sel;
                                        is_MODO_AUTO := Nivel_IN_NO_ACTIVE_CHILD;
                                    Nivel_IN_SEL_ORIGEN: 
                                        (* Exit 'SEL_ORIGEN': '<S1>:190' *)
                                        (* '<S1>:190:14' i_origen = i_sel; *)
                                        i_origen := b_i_sel;
                                        is_MODO_AUTO := Nivel_IN_NO_ACTIVE_CHILD;
                                END_CASE;
                                (* Exit 'MODO_AUTO': '<S1>:240' *)
                                (* '<S1>:240:10' if(ya_vuelvo == 0) *)
                                IF ya_vuelvo = 0.0 THEN 
                                    (* '<S1>:240:11' modo_auto = 0; *)
                                    b_modo_auto := 0.0;
                                    (* '<S1>:240:12' modo_manual_auto = 0; *)
                                    (* '<S1>:240:13' ejec_mov = 0; *)
                                END_IF;
                                is_AUTOMATA_PRINCIPAL := Nivel_IN_REPOSO;
                                (* Entry 'REPOSO': '<S1>:5' *)
                                (* '<S1>:5:3' modo_reposo = 1; *)
                                b_modo_reposo := 1.0;
                                IF B <> 0.0 THEN 
                                    durationCounter_1_m := 0;
                                END_IF;
                                (* '<S1>:5:4' BRK_t_N1 = 0; *)
                                b_BRK_t_N1 := 0.0;
                                (* '<S1>:5:4' BRK_h_N1 = 0; *)
                                b_BRK_h_N1 := 0.0;
                                (* '<S1>:5:5' modo_manual = 0; *)
                                b_modo_manual := 0.0;
                                (* '<S1>:5:6' modo_manual_auto =0; *)
                                b_modo_manual_auto := 0.0;
                                (* '<S1>:5:7' error_der = 0; *)
                                error_der := 0.0;
                                (* '<S1>:5:7' error_izq = 0; *)
                                error_izq := 0.0;
                                (* '<S1>:5:8' error_sup = 0; *)
                                error_sup := 0.0;
                                (* '<S1>:5:8' error_inf = 0; *)
                                error_inf := 0.0;
                                (* '<S1>:5:9' error_otro =0; *)
                                error_otro := 0.0;
                                (* '<S1>:5:10' modo_error = 0; *)
                                b_modo_error := 0.0;
                            END_IF;
                        END_IF;
                    ELSE
                        (* During 'Muerto': '<S1>:362' *)
                        (* '<S1>:365:1' sf_internal_predicateOutput = 0 | (BTN_ON_OFF==1); *)
                        IF B = 1.0 THEN 
                            (* Transition: '<S1>:365' *)
                            (* Exit 'Muerto': '<S1>:362' *)
                            (* '<S1>:362:9' modo_muerto=0; *)
                            b_modo_muerto := 0.0;
                            durationCounter_2 := 0;
                            durationCounter_1_m := 0;
                            is_c3_Nivel := Nivel_IN_Automata;
                            (* Entry Internal 'Automata': '<S1>:361' *)
                            tp_TWISTLOCKS := 1;
                            (* Entry 'TWISTLOCKS': '<S1>:42' *)
                            (* '<S1>:42:3' m_container=0; *)
                            b_m_container := 0.0;
                            (* Entry Internal 'TWISTLOCKS': '<S1>:42' *)
                            (* Transition: '<S1>:39' *)
                            is_TWISTLOCKS := Nivel_IN_VACIO;
                            (* Entry 'VACIO': '<S1>:38' *)
                            (* '<S1>:38:3' TLK = 0; *)
                            b_TLK := 0.0;
                            (* '<S1>:38:4' m_est = Ms; *)
                            m_est := 15000.0;
                            (* '<S1>:38:5' sobrecarga = 0; *)
                            b_sobrecarga := 0.0;
                            tp_INDICES_PERFIL := 1;
                            (* Entry Internal 'INDICES_PERFIL': '<S1>:80' *)
                            (* Entry 'INDICES': '<S1>:83' *)
                            (* '<S1>:83:3' i_carro = 1; *)
                            i_carro := 1.0;
                            (* '<S1>:83:3' i_lidar = 4; *)
                            (* Entry 'ACTUALIZAR_PERFIL_ALTURAS': '<S1>:76' *)
                            (* '<S1>:76:3' yc0_vec = yc0_vec_inicial; *)
                            FOR i := 0 TO 32 DO 
                                b_yc0_vec[i] := Nivel1_yc0_vec_inicial[i];
                            END_FOR;
                            (* '<S1>:76:3' yc0 = 0; *)
                            (* '<S1>:76:4' TLK_anterior = 0; *)
                            TLK_anterior := 0.0;
                            (* Entry 'Escaneo': '<S1>:381' *)
                            (* '<S1>:381:3' scan=1; *)
                            scan := 1.0;
                            (* '<S1>:381:4' flag1 =0; *)
                            flag1 := 0.0;
                            (* '<S1>:381:5' flag2=0; *)
                            flag2 := 0.0;
                            (* Entry 'SUAVIZADO_VELOCIDAD': '<S1>:335' *)
                            (* '<S1>:335:3' ax_act = 0; *)
                            ax_act := 0.0;
                            (* '<S1>:335:3' ay_act = 0; *)
                            ay_act := 0.0;
                            (* '<S1>:335:4' jerk_max = 1.5; *)
                            jerk_max := 1.5;
                            (* '<S1>:335:5' vx_suave = 0; *)
                            b_vx_suave := 0.0;
                            (* '<S1>:335:5' vy_suave = 0; *)
                            b_vy_suave := 0.0;
                            (* '<S1>:335:6' vx_target = 0; *)
                            vx_target := 0.0;
                            (* '<S1>:335:6' vy_target = 0; *)
                            vy_target := 0.0;
                            (* Entry Internal 'WATCHDOG_HEARTBEAT': '<S1>:369' *)
                            (* Transition: '<S1>:373' *)
                            temporalCounter_i3(timerAction := 1, maxTime := 0);
                            is_WATCHDOG_HEARTBEAT := Nivel_IN_PULSOS_UP;
                            (* Entry 'PULSOS_UP': '<S1>:374' *)
                            (* '<S1>:374:3' heartbeat = 0; *)
                            b_heartbeat := 0.0;
                            tp_AUTOMATA_PRINCIPAL := 1;
                            (* Entry 'AUTOMATA_PRINCIPAL': '<S1>:1' *)
                            (* '<S1>:1:3' ya_vuelvo = 0; *)
                            ya_vuelvo := 0.0;
                            (* '<S1>:1:4' dead_zone = 0.1; *)
                            dead_zone := 0.1;
                            (* Zona muerta joystick *)
                            (* error_der = 0; error_izq = 0; *)
                            (* error_sup = 0; error_inf = 0; *)
                            (* error_otro =1; *)
                            (* modo_manual_auto = 0; *)
                            (* ya_vuelvo = 0; *)
                            (* Entry Internal 'AUTOMATA_PRINCIPAL': '<S1>:1' *)
                            (* Transition: '<S1>:4' *)
                            is_AUTOMATA_PRINCIPAL := Nivel_IN_REPOSO;
                            (* Entry 'REPOSO': '<S1>:5' *)
                            (* '<S1>:5:3' modo_reposo = 1; *)
                            b_modo_reposo := 1.0;
                            (* '<S1>:5:4' BRK_t_N1 = 0; *)
                            b_BRK_t_N1 := 0.0;
                            (* '<S1>:5:4' BRK_h_N1 = 0; *)
                            b_BRK_h_N1 := 0.0;
                            (* '<S1>:5:5' modo_manual = 0; *)
                            b_modo_manual := 0.0;
                            (* '<S1>:5:6' modo_manual_auto =0; *)
                            b_modo_manual_auto := 0.0;
                            (* '<S1>:5:7' error_der = 0; *)
                            error_der := 0.0;
                            (* '<S1>:5:7' error_izq = 0; *)
                            error_izq := 0.0;
                            (* '<S1>:5:8' error_sup = 0; *)
                            error_sup := 0.0;
                            (* '<S1>:5:8' error_inf = 0; *)
                            error_inf := 0.0;
                            (* '<S1>:5:9' error_otro =0; *)
                            error_otro := 0.0;
                            (* '<S1>:5:10' modo_error = 0; *)
                            b_modo_error := 0.0;
                        END_IF;
                END_CASE;
            END_IF;
            IF temporalCounter_i1 = 50 THEN 
                temporalCounter_i1 := 0;
            END_IF;
            IF temporalCounter_i2 = 50 THEN 
                temporalCounter_i2 := 0;
            END_IF;
            IF ABS(Joy_XY[0]) < 0.1 THEN 
                IF ABS(Joy_XY[1]) < 0.1 THEN 
                    IF ABS(vt_obs) < 0.01 THEN 
                        IF ABS(vh_obs) < 0.01 THEN 
                            IF ABS(theta_l_dot) < 0.006 THEN 
                                IF ABS(tita_l) < 0.006 THEN 
                                    durationCounter_1 := durationCounter_1 + 1;
                                ELSE 
                                    durationCounter_1 := 0;
                                END_IF;
                            ELSE 
                                durationCounter_1 := 0;
                            END_IF;
                        ELSE 
                            durationCounter_1 := 0;
                        END_IF;
                    ELSE 
                        durationCounter_1 := 0;
                    END_IF;
                ELSE 
                    durationCounter_1 := 0;
                END_IF;
            ELSE 
                durationCounter_1 := 0;
            END_IF;
            IF (B = 0.0) AND (b_modo_reposo = 1.0) THEN 
                durationCounter_1_m := durationCounter_1_m + 1;
            ELSE 
                durationCounter_1_m := 0;
            END_IF;
            IF b_TLK = 0.0 THEN 
                durationCounter_2 := durationCounter_2 + 1;
            ELSE 
                durationCounter_2 := 0;
            END_IF;
            (* End of Chart: '<Root>/Nivel 1' *)
            
            (* Outport: '<Root>/BRK_h_N1' *)
            BRK_h_N1 := b_BRK_h_N1;
            (* Outport: '<Root>/BRK_t_N1' *)
            BRK_t_N1 := b_BRK_t_N1;
            (* Outport: '<Root>/TLK' *)
            TLK := b_TLK;
            (* Outport: '<Root>/yc0_vec' *)
            FOR i := 0 TO 32 DO 
                yc0_vec[i] := b_yc0_vec[i];
            END_FOR;
            (* End of Outport: '<Root>/yc0_vec' *)
            
            (* Outport: '<Root>/i_sel' *)
            i_sel := b_i_sel;
            (* Outport: '<Root>/vx_suave' *)
            vx_suave := b_vx_suave;
            (* Outport: '<Root>/vy_suave' *)
            vy_suave := b_vy_suave;
            (* Outport: '<Root>/recuperacion' *)
            recuperacion := b_recuperacion;
            (* Outport: '<Root>/modo_muerto' *)
            modo_muerto := b_modo_muerto;
            (* Outport: '<Root>/heartbeat' *)
            heartbeat := b_heartbeat;
            (* Outport: '<Root>/m_container' *)
            m_container := b_m_container;
            (* Outport: '<Root>/modo_auto' *)
            modo_auto := b_modo_auto;
            (* Outport: '<Root>/modo_manual' *)
            modo_manual := b_modo_manual;
            (* Outport: '<Root>/modo_manual_auto' *)
            modo_manual_auto := b_modo_manual_auto;
            (* Outport: '<Root>/modo_reposo' *)
            modo_reposo := b_modo_reposo;
            (* Outport: '<Root>/modo_error' *)
            modo_error := b_modo_error;
            (* Outport: '<Root>/sobrecarga' *)
            sobrecarga := b_sobrecarga;
        END_IF;
        IF plc_ts_counter1 >= 19 THEN 
            plc_ts_counter1 := 0;
        ELSE 
            plc_ts_counter1 := plc_ts_counter1 + 1;
        END_IF;
END_CASE;
END_FUNCTION_BLOCK
FUNCTION_BLOCK Suavizador_Cinematico
VAR_INPUT
    v_target: LREAL;
    v_act: LREAL;
    a_act: LREAL;
    A_MAX: LREAL;
    J_MAX: LREAL;
END_VAR
VAR_OUTPUT
    v_out: LREAL;
    a_out: LREAL;
END_VAR
VAR_TEMP
    err_v: LREAL;
    a_req: LREAL;
    jerk_req: LREAL;
    y: DINT;
    tmp: LREAL;
END_VAR
(* MATLAB Function 'Suavizador_Cinematico': '<S1>:334' *)
(* '<S1>:334:4' err_v = v_target - v_act; *)
err_v := v_target - v_act;
(* Error instantáneo de velocidad     *)
(* '<S1>:334:5' zona_lineal = 0.05; *)
(* Zona lineal cercana a cero para evitar singularidad en la raíz *)
(* Generación de aceleración deseada *)
(* '<S1>:334:8' if abs(err_v) < 1e-6 *)
tmp := ABS(err_v);
IF tmp < 1.0E-6 THEN 
    (* Evita micro-oscilaciones cuando el error es prácticamente cero. *)
    (* '<S1>:334:9' v_out = v_target; *)
    v_out := v_target;
    (* '<S1>:334:10' a_out = 0; *)
    a_out := 0.0;
ELSE 
    IF tmp > 0.05 THEN 
        (* '<S1>:334:13' elseif abs(err_v) > zona_lineal *)
        (* '<S1>:334:14' a_req = sign(err_v) * sqrt(2 * J_MAX * abs(err_v)); *)
        IF err_v < 0.0 THEN 
            y := -1;
        ELSIF err_v > 0.0 THEN 
            y := 1;
        ELSE 
            y := 0;
        END_IF;
        a_req := SQRT((2.0 * J_MAX) * tmp) * DINT_TO_LREAL(y);
        (* Región no lineal *)
    ELSE 
        (* '<S1>:334:15' else *)
        (* '<S1>:334:16' a_req = (err_v / zona_lineal) * sqrt(2 * J_MAX * zona_lineal); *)
        a_req := SQRT((2.0 * J_MAX) * 0.05) * (err_v / 0.05);
        (* Región lineal cercana a cero para evitar pendiente infinita *)
    END_IF;
    (* Saturación de aceleración *)
    (* '<S1>:334:20' if a_req > A_MAX *)
    IF a_req > A_MAX THEN 
        (* '<S1>:334:21' a_req = A_MAX; *)
        a_req := A_MAX;
    ELSIF a_req < ( -A_MAX) THEN 
        (* '<S1>:334:22' elseif a_req < -A_MAX *)
        (* '<S1>:334:23' a_req = -A_MAX; *)
        a_req :=  -A_MAX;
    END_IF;
    (* Cálculo de jerk requerido *)
    (* '<S1>:334:27' jerk_req = (a_req - a_act) / 0.02; *)
    jerk_req := (a_req - a_act) / 0.02;
    (* Saturación de jerk *)
    (* '<S1>:334:29' if jerk_req > J_MAX *)
    IF jerk_req > J_MAX THEN 
        (* '<S1>:334:30' jerk_req = J_MAX; *)
        jerk_req := J_MAX;
    ELSIF jerk_req < ( -J_MAX) THEN 
        (* '<S1>:334:31' elseif jerk_req < -J_MAX *)
        (* '<S1>:334:32' jerk_req = -J_MAX; *)
        jerk_req :=  -J_MAX;
    END_IF;
    (* Integración discreta (Euler) *)
    (* '<S1>:334:36' a_out = a_act + jerk_req * 0.02; *)
    a_out := (jerk_req * 0.02) + a_act;
    (* '<S1>:334:37' v_out = v_act + a_out * 0.02; *)
    v_out := (a_out * 0.02) + v_act;
    (* Eliminación de deriva *)
    (* Forzar a cero absoluto si el joystick está suelto *)
    (* '<S1>:334:41' if abs(v_target) < 0.001 && abs(v_out) < 0.001 *)
    IF ABS(v_target) < 0.001 THEN 
        IF ABS(v_out) < 0.001 THEN 
            (* '<S1>:334:42' v_out = 0.0; *)
            v_out := 0.0;
            (* '<S1>:334:43' a_out = 0.0; *)
            a_out := 0.0;
        END_IF;
    END_IF;
END_IF;
END_FUNCTION_BLOCK
FUNCTION Check_Container: LREAL
VAR_INPUT
    i_pos: LREAL;
    y0_vec: ARRAY [0..32] OF LREAL;
END_VAR
VAR_TEMP
    temp1: BOOL;
END_VAR
(* MATLAB Function 'Check_Container': '<S1>:47' *)
(* '<S1>:47:4' if(i_pos<13 && y0_vec(i_pos)>0) *)
temp1 := FALSE;
IF i_pos < 13.0 THEN 
    IF y0_vec[TRUNC(i_pos) - 1] > 0.0 THEN 
        (* '<S1>:47:5' hay_container = 1; *)
        Check_Container := 1.0;
    ELSE 
        temp1 := TRUE;
    END_IF;
ELSE 
    temp1 := TRUE;
END_IF;
IF temp1 THEN 
    IF (i_pos > 13.0) AND (i_pos < 33.0) THEN 
        IF y0_vec[TRUNC(i_pos) - 1] > -18.0 THEN 
            (* '<S1>:47:6' elseif(i_pos>13 && i_pos<33 && y0_vec(i_pos)>-18) *)
            (* '<S1>:47:7' hay_container = 1; *)
            Check_Container := 1.0;
        ELSE 
            (* '<S1>:47:8' else *)
            (* '<S1>:47:9' hay_container = 0; *)
            Check_Container := 0.0;
        END_IF;
    ELSE 
        (* '<S1>:47:8' else *)
        (* '<S1>:47:9' hay_container = 0; *)
        Check_Container := 0.0;
    END_IF;
END_IF;
END_FUNCTION
FUNCTION rt_floord: LREAL
VAR_INPUT
    u: LREAL;
END_VAR
rt_floord := DINT_TO_LREAL(TRUNC(u));
IF u = rt_floord THEN 
    rt_floord := u;
ELSIF u < 0.0 THEN 
    rt_floord := rt_floord - 1.0;
END_IF;
END_FUNCTION
FUNCTION_BLOCK isMember
VAR_INPUT
    a: LREAL;
END_VAR
VAR_OUTPUT
    tf: BOOL;
END_VAR
VAR
    b: ARRAY [0..2] OF SINT := 1,13,33;
END_VAR
VAR_TEMP
    k: DINT;
    exitg1: DINT;
END_VAR
tf := FALSE;
k := 0;
REPEAT 
    exitg1 := 0;
    IF k < 3 THEN 
        IF a = SINT_TO_LREAL(b[k]) THEN 
            tf := TRUE;
            exitg1 := 1;
        ELSE 
            k := k + 1;
        END_IF;
    ELSE 
        exitg1 := 1;
    END_IF;
UNTIL NOT(exitg1 = 0)
END_REPEAT;
END_FUNCTION_BLOCK
FUNCTION_BLOCK PLC_CODER_TIMER
VAR_INPUT
    timerAction: INT;
    maxTime: DINT;
END_VAR
VAR_OUTPUT
    done: BOOL;
END_VAR
VAR
    plcTimer: TON;
    plcTimerExpired: BOOL;
END_VAR
CASE timerAction OF
    1:
        (* RESET *)
        plcTimer(IN:=FALSE, PT:=T#0ms);
        plcTimerExpired := FALSE;
        done := FALSE;
    2:
        (* AFTER *)
        IF (NOT(plcTimerExpired)) THEN
            plcTimer(IN:=TRUE, PT:=DINT_TO_TIME(maxTime));
        END_IF;
        plcTimerExpired := plcTimer.Q;
        done := plcTimerExpired;
    3:
        (* BEFORE *)
        IF (NOT(plcTimerExpired)) THEN
            plcTimer(IN:=TRUE, PT:=DINT_TO_TIME(maxTime));
        END_IF;
        plcTimerExpired := plcTimer.Q;
        done := NOT(plcTimerExpired);
END_CASE;
END_FUNCTION_BLOCK
VAR_GLOBAL CONSTANT
    Nivel_IN_NO_ACTIVE_CHILD: USINT := 0;
    Nivel_IN_Automata: USINT := 1;
    Nivel_IN_Muerto: USINT := 2;
    Nivel_IN_ABRIENDO_TLK: USINT := 1;
    Nivel_IN_CARGADO: USINT := 2;
    Nivel_IN_CERRANDO_TLK: USINT := 3;
    Nivel_IN_VACIO: USINT := 4;
    Nivel_IN_PULSOS_DOWN: USINT := 1;
    Nivel_IN_PULSOS_UP: USINT := 2;
    Nivel_IN_ERROR_FC_izq_der: USINT := 1;
    Nivel_IN_ERROR_FC_sup_inf: USINT := 2;
    Nivel_IN_ERROR_OTRO: USINT := 3;
    Nivel_IN_MANUAL: USINT := 4;
    Nivel_IN_MODO_AUTO: USINT := 5;
    Nivel_IN_RECUPERACION: USINT := 6;
    Nivel_IN_REPOSO: USINT := 7;
    Nivel_IN_AUTO_INIT: USINT := 1;
    Nivel_IN_MODO_MANUAL_SIMPLE: USINT := 2;
    Nivel_IN_MOVIMIENTO_CURVO: USINT := 3;
    c_Nivel_IN_MOVIMIENTO_CURVO: USINT := 4;
    c_Nivel_IN_SELECCION_TRAYEC: USINT := 5;
    Nivel_IN_SEL_DESTINO: USINT := 6;
    Nivel_IN_SEL_ORIGEN: USINT := 7;
    SS_INITIALIZE: SINT := 0;
    SS_STEP: SINT := 1;
END_VAR
VAR_GLOBAL
    plc_ts_counter1: DINT;
END_VAR
