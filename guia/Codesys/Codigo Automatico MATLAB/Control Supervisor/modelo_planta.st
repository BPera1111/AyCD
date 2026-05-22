(*
 *
 * File: modelo_planta.st
 *
 * IEC 61131-3 Structured Text (ST) code generated for subsystem "modelo_planta/Control Nivel 1"
 *
 * Model name                      : modelo_planta
 * Model version                   : 5.74
 * Model creator                   : Nahuel
 * Model last modified by          : nahue
 * Model last modified on          : Thu Mar 12 16:33:08 2026
 * Model sample time               : 0.001s
 * Subsystem name                  : modelo_planta/Control Nivel 1
 * Subsystem sample time           : 0.02s
 * Simulink PLC Coder version      : 25.2 (R2025b) 28-Jul-2025
 * ST code generated on            : Thu Mar 12 16:51:46 2026
 *
 * Target IDE selection            : CODESYS 3.5
 * Test Bench included             : No
 *
 *)
FUNCTION_BLOCK Control
VAR_INPUT
    ssMethodType: SINT;
    theta_l_dot: LREAL;
    vt_obs: LREAL;
    Fhw: LREAL;
    BTN_TLK: BOOL;
    Joy_XY: ARRAY [0..1] OF LREAL;
    BTN_Manual: BOOL;
    BTN_Auto: BOOL;
    BTN_Reset: BOOL;
    FC_der: BOOL;
    FC_sup: BOOL;
    FC_izq: BOOL;
    FC_inf: BOOL;
    yh_enc: LREAL;
    vh_obs: LREAL;
    FALLA: LREAL;
    RECUPERAR: LREAL;
    theta_l: LREAL;
    xt_enc: LREAL;
END_VAR
VAR_OUTPUT
    m_est: LREAL;
    vh_lim: LREAL;
    x_ref: LREAL;
    y_ref: LREAL;
    BRK_h_N1: LREAL;
    BRK_t_N1: LREAL;
    TLK: LREAL;
    h_vec_output: ARRAY [0..32] OF LREAL;
    modo_manual: LREAL;
    modo_auto: LREAL;
    seleccionando_i: ARRAY [0..1] OF LREAL;
    i_obj_vec: ARRAY [0..1] OF LREAL;
    x_cruz_unity: LREAL;
    y_cruz_unity: LREAL;
    modo_posicion_segura: LREAL;
    modo_error: LREAL;
    modo_manual_auto: LREAL;
    modo_standby: LREAL;
    ejec_mov: LREAL;
    sobrecarga: LREAL;
    m_container: LREAL;
    heartbeat: LREAL;
    recup_ok: LREAL;
    vx_cmd: LREAL;
    envolvente: ARRAY [0..32] OF LREAL;
    vy_cmd: LREAL;
END_VAR
VAR
    durationCounter_1: UDINT;
    durationCounter_1_d: UDINT;
    is_active_c6_Control: USINT;
    is_MAQUINA_ESTADOS: USINT;
    is_TWISTLOCKS: USINT;
    is_WATCHDOG_HEARTBEAT: USINT;
    dead_zone: LREAL;
    x_cruz: LREAL;
    y_cruz: LREAL;
    is_MODO_AUTO: USINT;
    estado: LREAL;
    seleccionando: LREAL;
    is_cont: LREAL;
    hay_cont: LREAL;
    i_carro: LREAL;
    trans_TLK: LREAL;
    ax_act: LREAL;
    jerk_max: LREAL;
    ay_act: LREAL;
    i_x_cruz: LREAL;
    TLK_anterior: LREAL;
    K_acc: LREAL;
    temporalCounter_i1: PLC_CODER_TIMER;
    y_start: LREAL;
    v_max_ref: LREAL;
    invalido: LREAL;
    i_fin: LREAL;
    i_ini: LREAL;
    manual_ok: LREAL;
    i_usado: LREAL;
    safe_trajectory: LREAL;
    last_i_ref_not_empty: BOOL;
    x_prev: LREAL;
    y_prev: LREAL;
    last_i_ref: LREAL;
    bloqueado: BOOL;
    bloq_cnt: LREAL;
    dir_fija: LREAL;
    fase_not_empty: BOOL;
    x_prev_p: LREAL;
    y_prev_d: LREAL;
    last_i_ref_o: LREAL;
    fase: USINT;
    is_scanned_vec: ARRAY [0..32] OF LREAL;
    yc0_vec: ARRAY [0..32] OF LREAL;
    c_ControlNivel1_yc0_vec_ini: ARRAY [0..32] OF LREAL := 0.0,0.0,2.59,0.0,0.0,2.59,0.0,0.0,0.0,0.0,0.0,0.0,0.0,
        0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0;
    ControlNivel1_h_vec_inicial: ARRAY [0..32] OF LREAL := 0.0,0.0,2.59,0.0,0.0,2.59,0.0,0.0,0.0,0.0,0.0,0.0,
        7.2519999999999989,7.77,12.95,15.54,7.77,12.95,23.31,20.72,10.36,2.59,-2.59,-10.36,-12.95,-5.18,-2.59,5.18,
        15.54,20.72,20.72,12.95,7.2519999999999989;
    c_ControlNivel1_is_scanned_: ARRAY [0..32] OF LREAL := 1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,0.0,0.0,
        0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0;
    i0_Suavizador_Cinematico: Suavizador_Cinematico;
    i0_isMember: isMember;
END_VAR
VAR_TEMP
    out: BOOL;
    TLK_fall: BOOL;
    H_extra: LREAL;
    i_obj: LREAL;
    i_act: DINT;
    x_dest: LREAL;
    dist_dest: LREAL;
    k_vent_fin: LREAL;
    h_local_max: LREAL;
    lookahead: LREAL;
    xc: LREAL;
    dist_xc: LREAL;
    i_eff: DINT;
    x_seg: LREAL;
    bloq: BOOL;
    d_bloq: LREAL;
    i_min_ruta: LREAL;
    h_max_ruta: LREAL;
    y_base: LREAL;
    y_prop: LREAL;
    b_i_obj: LREAL;
    b_i_act: DINT;
    b_x_dest: LREAL;
    b_H_extra: LREAL;
    b_y_base: LREAL;
    b_i_min_ruta: LREAL;
    i_max_ruta: LREAL;
    b_h_max_ruta: LREAL;
    y_crucero: LREAL;
    stepY_crucero: LREAL;
    perfil_seguro: ARRAY [0..32] OF LREAL;
    b_i: DINT;
    c_i: DINT;
    d_i: DINT;
    g_k: DINT;
    dist_efectiva: LREAL;
    c_x_cmd: LREAL;
    h_k: LREAL;
    i: DINT;
    tmp: DINT;
    temp1: BOOL;
    temp2: BOOL;
    temp3: BOOL;
    temp4: BOOL;
    temp5: BOOL;
    temp6: BOOL;
    temp7: BOOL;
    exitg1: DINT;
    b_temp2: LREAL;
    b_temp3: LREAL;
    b_temp4: LREAL;
    b_temp5: LREAL;
    b_temp6: LREAL;
    b_temp7: LREAL;
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
    temp18: LREAL;
    temp19: LREAL;
    temp20: LREAL;
    temp21: LREAL;
    temp22: LREAL;
    temp23: LREAL;
    temp24: LREAL;
    temp25: LREAL;
    temp26: LREAL;
    temp27: LREAL;
END_VAR
CASE ssMethodType OF
    SS_INITIALIZE: 
        (* SystemInitialize for Chart: '<Root>/Control Nivel 1' incorporates:
         *  Outport: '<Root>/BRK_h_N1'
         *  Outport: '<Root>/BRK_t_N1'
         *  Outport: '<Root>/TLK'
         *  Outport: '<Root>/ejec_mov'
         *  Outport: '<Root>/i_obj_vec'
         *  Outport: '<Root>/m_container'
         *  Outport: '<Root>/m_est'
         *  Outport: '<Root>/modo_auto'
         *  Outport: '<Root>/modo_error'
         *  Outport: '<Root>/modo_manual'
         *  Outport: '<Root>/modo_manual_auto'
         *  Outport: '<Root>/modo_posicion_segura'
         *  Outport: '<Root>/modo_standby'
         *  Outport: '<Root>/recup_ok'
         *  Outport: '<Root>/seleccionando_i'
         *  Outport: '<Root>/sobrecarga'
         *  Outport: '<Root>/vh_lim'
         *  Outport: '<Root>/vx_cmd'
         *  Outport: '<Root>/vy_cmd'
         *  Outport: '<Root>/x_ref'
         *  Outport: '<Root>/y_ref' *)
        last_i_ref_not_empty := FALSE;
        fase_not_empty := FALSE;
        temporalCounter_i1(timerAction := 1, maxTime := 0);
        last_i_ref := -1.0;
        bloqueado := FALSE;
        bloq_cnt := 0.0;
        dir_fija := 1.0;
        fase := 1;
        last_i_ref_o := -1.0;
        m_est := 0.0;
        vh_lim := 0.0;
        x_ref := 0.0;
        y_ref := 0.0;
        BRK_h_N1 := 0.0;
        BRK_t_N1 := 0.0;
        TLK := 0.0;
        modo_manual := 0.0;
        modo_auto := 0.0;
        seleccionando_i[0] := 0.0;
        i_obj_vec[0] := 0.0;
        seleccionando_i[1] := 0.0;
        i_obj_vec[1] := 0.0;
        modo_posicion_segura := 0.0;
        modo_error := 0.0;
        modo_manual_auto := 0.0;
        modo_standby := 0.0;
        ejec_mov := 0.0;
        sobrecarga := 0.0;
        m_container := 0.0;
        recup_ok := 0.0;
        vx_cmd := 0.0;
        vy_cmd := 0.0;
        dead_zone := 0.0;
        seleccionando := 0.0;
        manual_ok := 0.0;
        safe_trajectory := 0.0;
        v_max_ref := 0.0;
        trans_TLK := 0.0;
        TLK_anterior := 0.0;
        estado := 0.0;
        i_ini := 0.0;
        is_cont := 0.0;
        i_x_cruz := 0.0;
        (* SystemInitialize for Chart: '<Root>/Control Nivel 1' incorporates:
         *  Outport: '<Root>/envolvente'
         *  Outport: '<Root>/h_vec_output' *)
        FOR i := 0 TO 32 DO 
            h_vec_output[i] := 0.0;
            envolvente[i] := 0.0;
            is_scanned_vec[i] := 0.0;
            yc0_vec[i] := 0.0;
        END_FOR;
        invalido := 0.0;
        i_fin := 0.0;
        x_cruz := 0.0;
        y_cruz := 0.0;
        i_usado := 0.0;
        i_carro := 0.0;
        ax_act := 0.0;
        ay_act := 0.0;
        jerk_max := 0.0;
        K_acc := 0.0;
        y_start := 0.0;
        hay_cont := 0.0;
        is_active_c6_Control := 0;
        is_MAQUINA_ESTADOS := Control_IN_NO_ACTIVE_CHILD;
        is_MODO_AUTO := Control_IN_NO_ACTIVE_CHILD;
        is_TWISTLOCKS := Control_IN_NO_ACTIVE_CHILD;
        is_WATCHDOG_HEARTBEAT := Control_IN_NO_ACTIVE_CHILD;
    SS_STEP: 
        (* Chart: '<Root>/Control Nivel 1' incorporates:
         *  Outport: '<Root>/BRK_h_N1'
         *  Outport: '<Root>/BRK_t_N1'
         *  Outport: '<Root>/TLK'
         *  Outport: '<Root>/ejec_mov'
         *  Outport: '<Root>/envolvente'
         *  Outport: '<Root>/h_vec_output'
         *  Outport: '<Root>/i_obj_vec'
         *  Outport: '<Root>/m_container'
         *  Outport: '<Root>/m_est'
         *  Outport: '<Root>/modo_auto'
         *  Outport: '<Root>/modo_error'
         *  Outport: '<Root>/modo_manual'
         *  Outport: '<Root>/modo_manual_auto'
         *  Outport: '<Root>/modo_posicion_segura'
         *  Outport: '<Root>/modo_standby'
         *  Outport: '<Root>/recup_ok'
         *  Outport: '<Root>/seleccionando_i'
         *  Outport: '<Root>/sobrecarga'
         *  Outport: '<Root>/vh_lim'
         *  Outport: '<Root>/vx_cmd'
         *  Outport: '<Root>/vy_cmd'
         *  Outport: '<Root>/x_ref'
         *  Outport: '<Root>/y_ref' *)
        (* Gateway: Control Nivel 1 *)
        (* During: Control Nivel 1 *)
        IF is_active_c6_Control = 0 THEN 
            (* Entry: Control Nivel 1 *)
            is_active_c6_Control := 1;
            (* Entry Internal: Control Nivel 1 *)
            (* Entry 'MAQUINA_ESTADOS': '<S1>:54' *)
            (* heartbeat = 0; % COMENTAR SI ACTIVAS WATCHDOG *)
            (* '<S1>:54:4' dead_zone = 0.1; *)
            dead_zone := 0.1;
            (* Zona muerta joystick *)
            (* '<S1>:54:5' modo_posicion_segura = 0; *)
            modo_posicion_segura := 0.0;
            (* '<S1>:54:6' modo_manual_auto = 0; *)
            modo_manual_auto := 0.0;
            (* '<S1>:54:7' seleccionando = 0; *)
            seleccionando := 0.0;
            (* '<S1>:54:8' vx_cmd = 0; *)
            vx_cmd := 0.0;
            (* '<S1>:54:9' vy_cmd = 0; *)
            vy_cmd := 0.0;
            (* '<S1>:54:10' ejec_mov = 0; *)
            ejec_mov := 0.0;
            (* '<S1>:54:11' is_cont = 0; *)
            is_cont := 0.0;
            (* Entry Internal 'MAQUINA_ESTADOS': '<S1>:54' *)
            (* Transition: '<S1>:61' *)
            is_MAQUINA_ESTADOS := Control_IN_STAND_BY;
            (* Entry 'STAND_BY': '<S1>:60' *)
            (* '<S1>:60:3' x_ref = xt_enc; *)
            x_ref := xt_enc;
            (* '<S1>:60:3' y_ref = yh_enc; *)
            y_ref := yh_enc;
            (* Outport: '<Root>/x_cruz_unity' incorporates:
             *  Outport: '<Root>/ejec_mov'
             *  Outport: '<Root>/modo_manual_auto'
             *  Outport: '<Root>/modo_posicion_segura'
             *  Outport: '<Root>/vx_cmd'
             *  Outport: '<Root>/vy_cmd'
             *  Outport: '<Root>/x_ref'
             *  Outport: '<Root>/y_ref' *)
            (* '<S1>:60:4' x_cruz_unity = x_ref; *)
            x_cruz_unity := xt_enc;
            (* Outport: '<Root>/y_cruz_unity' *)
            (* '<S1>:60:4' y_cruz_unity = y_ref; *)
            y_cruz_unity := yh_enc;
            (* '<S1>:60:5' modo_standby = 1; *)
            modo_standby := 1.0;
            (* Frenos Cerrados *)
            (* '<S1>:60:7' BRK_t_N1 = 0; *)
            BRK_t_N1 := 0.0;
            (* '<S1>:60:7' BRK_h_N1 = 0; *)
            BRK_h_N1 := 0.0;
            (* '<S1>:60:8' modo_manual = 0; *)
            modo_manual := 0.0;
            (* '<S1>:60:8' modo_auto = 0; *)
            modo_auto := 0.0;
            (* '<S1>:60:9' modo_error = 0; *)
            modo_error := 0.0;
            (* Entry Internal 'TWISTLOCKS': '<S1>:165' *)
            (* Transition: '<S1>:167' *)
            is_TWISTLOCKS := Control_IN_VACIO;
            (* Entry 'VACIO': '<S1>:166' *)
            (* '<S1>:166:3' TLK = 0; *)
            TLK := 0.0;
            (* '<S1>:166:4' m_est = Ms; *)
            m_est := 15000.0;
            (* '<S1>:166:5' sobrecarga = 0; *)
            sobrecarga := 0.0;
            (* '<S1>:166:6' trans_TLK = 0; *)
            trans_TLK := 0.0;
            (* Entry Internal 'MANEJO_CRUCETA': '<S1>:638' *)
            (* Entry 'INPUT_JOYSTICK': '<S1>:852' *)
            (* '<S1>:852:3' ax_act = 0; *)
            ax_act := 0.0;
            (* '<S1>:852:3' ay_act = 0; *)
            ay_act := 0.0;
            (* '<S1>:852:4' jerk_max = 1.5; *)
            jerk_max := 1.5;
            (* '<S1>:852:5' v_max_ref = 12; *)
            v_max_ref := 12.0;
            (* Entry Internal 'INDICES_Y_PERFIL': '<S1>:361' *)
            (* Entry 'CALCULO_INDICES': '<S1>:231' *)
            (* '<S1>:231:3' i_carro = 1; *)
            i_carro := 1.0;
            (* '<S1>:231:3' i_lidar = 1; *)
            (* '<S1>:231:4' i_xt_ref = 1; *)
            (* '<S1>:231:4' i_x_cruz = 1; *)
            i_x_cruz := 1.0;
            (* Entry 'ACTUALIZAR_PERFIL_ALTURAS': '<S1>:238' *)
            (* '<S1>:238:3' yc0_xtref = 0; *)
            (* '<S1>:238:3' yc0_vec = yc0_vec_inicial; *)
            (* '<S1>:238:3' yc0 = 0; *)
            (* '<S1>:238:4' h_vec_output = h_vec_inicial; *)
            (* '<S1>:238:4' TLK_anterior = 0; *)
            TLK_anterior := 0.0;
            (* '<S1>:238:5' is_scanned_vec = is_scanned_vec_inicial; *)
            FOR i := 0 TO 32 DO 
                yc0_vec[i] := c_ControlNivel1_yc0_vec_ini[i];
                h_vec_output[i] := ControlNivel1_h_vec_inicial[i];
                is_scanned_vec[i] := c_ControlNivel1_is_scanned_[i];
            END_FOR;
            (* Entry 'LIMITES_SUAVES': '<S1>:1022' *)
            (* '<S1>:1022:2' K_acc = 0.65; *)
            K_acc := 0.65;
            (* Entry Internal 'WATCHDOG_HEARTBEAT': '<S1>:724' *)
            (* Transition: '<S1>:726' *)
            temporalCounter_i1(timerAction := 1, maxTime := 0);
            is_WATCHDOG_HEARTBEAT := Control_IN_PULSOS_UP;
            (* Outport: '<Root>/heartbeat' incorporates:
             *  Outport: '<Root>/BRK_h_N1'
             *  Outport: '<Root>/BRK_t_N1'
             *  Outport: '<Root>/TLK'
             *  Outport: '<Root>/h_vec_output'
             *  Outport: '<Root>/m_est'
             *  Outport: '<Root>/modo_auto'
             *  Outport: '<Root>/modo_error'
             *  Outport: '<Root>/modo_manual'
             *  Outport: '<Root>/modo_standby'
             *  Outport: '<Root>/sobrecarga' *)
            (* Entry 'PULSOS_UP': '<S1>:725' *)
            (* '<S1>:725:3' heartbeat = 0; *)
            heartbeat := 0.0;
        ELSE 
            (* During 'MAQUINA_ESTADOS': '<S1>:54' *)
            temp1 := FALSE;
            temp2 := FALSE;
            temp3 := FALSE;
            temp4 := FALSE;
            temp5 := FALSE;
            CASE is_MAQUINA_ESTADOS OF
                Control_IN_MODO_AUTO: 
                    (* During 'MODO_AUTO': '<S1>:88' *)
                    (* '<S1>:1177:1' sf_internal_predicateOutput = 0 | (ejec_mov == 1 &&... *)
                    (* '<S1>:1177:2'  (abs(Joy_XY(1)) > dead_zone ||... *)
                    (* '<S1>:1177:3'  abs(Joy_XY(2)) > dead_zone)); *)
                    IF ejec_mov = 1.0 THEN 
                        IF ABS(Joy_XY[0]) > dead_zone THEN 
                            (* Transition: '<S1>:1177' *)
                            temp2 := TRUE;
                        ELSIF ABS(Joy_XY[1]) > dead_zone THEN 
                            (* Transition: '<S1>:1177' *)
                            temp2 := TRUE;
                        ELSE 
                            out := FALSE;
                            temp5 := TRUE;
                        END_IF;
                    ELSE 
                        out := FALSE;
                        temp5 := TRUE;
                    END_IF;
                Control_IN_MODO_ERROR: 
                    BRK_t_N1 := 0.0;
                    BRK_h_N1 := 0.0;
                    (* During 'MODO_ERROR': '<S1>:91' *)
                    (* '<S1>:740:1' sf_internal_predicateOutput = 0 | (RECUPERAR == 1 ||... *)
                    (* '<S1>:740:2'  BTN_Reset == 1); *)
                    IF (RECUPERAR = 1.0) OR BTN_Reset THEN 
                        (* Transition: '<S1>:740' *)
                        (* Exit 'MODO_ERROR': '<S1>:91' *)
                        (* '<S1>:91:9' modo_error = 0; *)
                        modo_error := 0.0;
                        is_MAQUINA_ESTADOS := d_Control_IN_POSICION_SEGUR;
                        (* Entry 'POSICION_SEGURA_Y': '<S1>:739' *)
                        (* '<S1>:739:3' BRK_t_N1 = 0; *)
                        (* '<S1>:739:3' BRK_h_N1 = 1; *)
                        BRK_h_N1 := 1.0;
                        (* '<S1>:739:4' modo_posicion_segura = 1; *)
                        modo_posicion_segura := 1.0;
                        (* '<S1>:739:5' y_ref = yh_0; *)
                        y_ref := 39.0;
                        (* '<S1>:739:5' y_cruz = y_ref; *)
                        y_cruz := 39.0;
                    ELSE 
                        (* '<S1>:91:7' x_cruz = xt_enc; *)
                        x_cruz := xt_enc;
                        (* '<S1>:91:7' y_cruz = yh_enc; *)
                        y_cruz := yh_enc;
                    END_IF;
                Control_IN_MODO_MANUAL: 
                    BRK_t_N1 := 1.0;
                    BRK_h_N1 := 1.0;
                    (* During 'MODO_MANUAL': '<S1>:86' *)
                    (* Transition: '<S1>:95' *)
                    (* '<S1>:1094:1' sf_internal_predicateOutput = 0 | (FALLA ==1 ||... *)
                    (* '<S1>:1094:2'  FC_der == 1 || FC_izq == 1 ||... *)
                    (* '<S1>:1094:3'  FC_sup == 1 || FC_inf == 1); *)
                    IF ((((FALLA = 1.0) OR FC_der) OR FC_izq) OR FC_sup) OR FC_inf THEN 
                        (* Transition: '<S1>:1094' *)
                        (* Exit 'MODO_MANUAL': '<S1>:86' *)
                        (* '<S1>:86:12' modo_manual = 0; *)
                        modo_manual := 0.0;
                        is_MAQUINA_ESTADOS := Control_IN_MODO_ERROR;
                        (* Entry 'MODO_ERROR': '<S1>:91' *)
                        (* '<S1>:91:3' BRK_t_N1 = 0; *)
                        BRK_t_N1 := 0.0;
                        (* '<S1>:91:3' BRK_h_N1 = 0; *)
                        BRK_h_N1 := 0.0;
                        (* '<S1>:91:4' modo_error = 1; *)
                        modo_error := 1.0;
                        (* '<S1>:91:5' recup_ok = 0; *)
                        recup_ok := 0.0;
                    ELSE 
                        (* '<S1>:671:1' sf_internal_predicateOutput = 0 | (BTN_Reset); *)
                        IF BTN_Reset THEN 
                            (* Transition: '<S1>:671' *)
                            (* Exit 'MODO_MANUAL': '<S1>:86' *)
                            (* '<S1>:86:12' modo_manual = 0; *)
                            modo_manual := 0.0;
                            is_MAQUINA_ESTADOS := Control_IN_PASO_STANDBY;
                            (* Entry 'PASO_STANDBY': '<S1>:787' *)
                            (* '<S1>:787:3' modo_standby = 1; *)
                            modo_standby := 1.0;
                        ELSE 
                            (* '<S1>:961:1' sf_internal_predicateOutput = 0 | (duration((abs(Joy_XY(1)) < 0.1 &&... *)
                            (* '<S1>:961:2'  abs(Joy_XY(2)) < 0.1 &&... *)
                            (* '<S1>:961:3'  abs(vt_obs) < 0.01) &&... *)
                            (* '<S1>:961:4'  abs(vh_obs) < 0.01, sec) > 5); *)
                            IF ABS(Joy_XY[0]) < 0.1 THEN 
                                IF ABS(Joy_XY[1]) < 0.1 THEN 
                                    IF ABS(vt_obs) < 0.01 THEN 
                                        IF ABS(vh_obs) < 0.01 THEN 
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
                            IF durationCounter_1 > 250 THEN 
                                (* Transition: '<S1>:961' *)
                                (* Exit 'MODO_MANUAL': '<S1>:86' *)
                                (* '<S1>:86:12' modo_manual = 0; *)
                                is_MAQUINA_ESTADOS := Control_IN_STAND_BY;
                                (* Entry 'STAND_BY': '<S1>:60' *)
                                (* '<S1>:60:3' x_ref = xt_enc; *)
                                x_ref := xt_enc;
                                (* '<S1>:60:3' y_ref = yh_enc; *)
                                y_ref := yh_enc;
                                (* '<S1>:60:4' x_cruz_unity = x_ref; *)
                                (* '<S1>:60:4' y_cruz_unity = y_ref; *)
                                (* '<S1>:60:5' modo_standby = 1; *)
                                modo_standby := 1.0;
                                (* Frenos Cerrados *)
                                (* '<S1>:60:7' BRK_t_N1 = 0; *)
                                BRK_t_N1 := 0.0;
                                (* '<S1>:60:7' BRK_h_N1 = 0; *)
                                BRK_h_N1 := 0.0;
                                (* '<S1>:60:8' modo_manual = 0; *)
                                modo_manual := 0.0;
                                (* '<S1>:60:8' modo_auto = 0; *)
                                modo_auto := 0.0;
                                (* '<S1>:60:9' modo_error = 0; *)
                                modo_error := 0.0;
                            ELSE 
                                (* '<S1>:86:7' x_cruz = xt_enc; *)
                                x_cruz := xt_enc;
                                (* '<S1>:86:8' y_cruz = yh_enc; *)
                                y_cruz := yh_enc;
                                (* '<S1>:86:9' x_ref = x_cruz; *)
                                x_ref := x_cruz;
                                (* '<S1>:86:10' y_ref = y_cruz; *)
                                y_ref := y_cruz;
                            END_IF;
                        END_IF;
                    END_IF;
                Control_IN_PASO_STANDBY: 
                    (* During 'PASO_STANDBY': '<S1>:787' *)
                    (* '<S1>:788:1' sf_internal_predicateOutput = 0 | (abs(theta_l) < 0.0175/2 &&... *)
                    (* '<S1>:788:2'  abs(theta_l_dot) < 0.01 &&... *)
                    (* '<S1>:788:3'  abs(vt_obs) < 0.01 &&... *)
                    (* '<S1>:788:4'  abs(vh_obs) < 0.01); *)
                    temp6 := FALSE;
                    IF ABS(theta_l) < 0.00875 THEN 
                        IF ABS(theta_l_dot) < 0.01 THEN 
                            IF ABS(vt_obs) < 0.01 THEN 
                                IF ABS(vh_obs) < 0.01 THEN 
                                    (* Transition: '<S1>:788' *)
                                    is_MAQUINA_ESTADOS := Control_IN_STAND_BY;
                                    (* Entry 'STAND_BY': '<S1>:60' *)
                                    (* '<S1>:60:3' x_ref = xt_enc; *)
                                    x_ref := xt_enc;
                                    (* '<S1>:60:3' y_ref = yh_enc; *)
                                    y_ref := yh_enc;
                                    (* '<S1>:60:4' x_cruz_unity = x_ref; *)
                                    (* '<S1>:60:4' y_cruz_unity = y_ref; *)
                                    (* '<S1>:60:5' modo_standby = 1; *)
                                    modo_standby := 1.0;
                                    (* Frenos Cerrados *)
                                    (* '<S1>:60:7' BRK_t_N1 = 0; *)
                                    BRK_t_N1 := 0.0;
                                    (* '<S1>:60:7' BRK_h_N1 = 0; *)
                                    BRK_h_N1 := 0.0;
                                    (* '<S1>:60:8' modo_manual = 0; *)
                                    modo_manual := 0.0;
                                    (* '<S1>:60:8' modo_auto = 0; *)
                                    modo_auto := 0.0;
                                    (* '<S1>:60:9' modo_error = 0; *)
                                    modo_error := 0.0;
                                ELSE 
                                    temp6 := TRUE;
                                END_IF;
                            ELSE 
                                temp6 := TRUE;
                            END_IF;
                        ELSE 
                            temp6 := TRUE;
                        END_IF;
                    ELSE 
                        temp6 := TRUE;
                    END_IF;
                    IF temp6 THEN 
                        (* '<S1>:787:5' x_cruz = xt_enc; *)
                        x_cruz := xt_enc;
                        (* '<S1>:787:6' y_cruz = yh_enc; *)
                        y_cruz := yh_enc;
                        (* '<S1>:787:7' x_ref = x_cruz; *)
                        x_ref := x_cruz;
                        (* '<S1>:787:8' y_ref = y_cruz; *)
                        y_ref := y_cruz;
                    END_IF;
                c_Control_IN_POSICION_SEGUR: 
                    BRK_t_N1 := 1.0;
                    BRK_h_N1 := 0.0;
                    (* During 'POSICION_SEGURA_X': '<S1>:939' *)
                    (* '<S1>:941:1' sf_internal_predicateOutput = 0 | (abs(theta_l) < 0.0175/2 &&... *)
                    (* '<S1>:941:2'  abs(theta_l_dot) < 0.01 &&... *)
                    (* '<S1>:941:3'  abs(xt_enc - x_ref) <= 0.1 &&... *)
                    (* '<S1>:941:4'  abs(vt_obs) < 0.01); *)
                    temp6 := FALSE;
                    IF ABS(theta_l) < 0.00875 THEN 
                        IF ABS(theta_l_dot) < 0.01 THEN 
                            IF ABS(xt_enc - x_ref) <= 0.1 THEN 
                                IF ABS(vt_obs) < 0.01 THEN 
                                    (* Transition: '<S1>:941' *)
                                    (* Exit 'POSICION_SEGURA_X': '<S1>:939' *)
                                    (* '<S1>:939:13' modo_posicion_segura = 0; *)
                                    modo_posicion_segura := 0.0;
                                    (* '<S1>:939:14' recup_ok = 1; *)
                                    recup_ok := 1.0;
                                    is_MAQUINA_ESTADOS := Control_IN_STAND_BY;
                                    (* Entry 'STAND_BY': '<S1>:60' *)
                                    (* '<S1>:60:3' x_ref = xt_enc; *)
                                    x_ref := xt_enc;
                                    (* '<S1>:60:3' y_ref = yh_enc; *)
                                    y_ref := yh_enc;
                                    (* '<S1>:60:4' x_cruz_unity = x_ref; *)
                                    (* '<S1>:60:4' y_cruz_unity = y_ref; *)
                                    (* '<S1>:60:5' modo_standby = 1; *)
                                    modo_standby := 1.0;
                                    (* Frenos Cerrados *)
                                    (* '<S1>:60:7' BRK_t_N1 = 0; *)
                                    BRK_t_N1 := 0.0;
                                    (* '<S1>:60:7' BRK_h_N1 = 0; *)
                                    (* '<S1>:60:8' modo_manual = 0; *)
                                    modo_manual := 0.0;
                                    (* '<S1>:60:8' modo_auto = 0; *)
                                    modo_auto := 0.0;
                                    (* '<S1>:60:9' modo_error = 0; *)
                                    modo_error := 0.0;
                                ELSE 
                                    temp6 := TRUE;
                                END_IF;
                            ELSE 
                                temp6 := TRUE;
                            END_IF;
                        ELSE 
                            temp6 := TRUE;
                        END_IF;
                    ELSE 
                        temp6 := TRUE;
                    END_IF;
                    IF temp6 THEN 
                        (* '<S1>:939:11' x_cruz = x_ref; *)
                        x_cruz := x_ref;
                        (* '<S1>:939:11' y_cruz = yh_enc; *)
                        y_cruz := yh_enc;
                    END_IF;
                d_Control_IN_POSICION_SEGUR: 
                    BRK_t_N1 := 0.0;
                    BRK_h_N1 := 1.0;
                    (* During 'POSICION_SEGURA_Y': '<S1>:739' *)
                    (* '<S1>:1090:1' sf_internal_predicateOutput = 0 | (abs(yh_enc - y_ref) <= 0.1); *)
                    IF ABS(yh_enc - y_ref) <= 0.1 THEN 
                        (* Transition: '<S1>:1090' *)
                        is_MAQUINA_ESTADOS := c_Control_IN_POSICION_SEGUR;
                        (* Entry 'POSICION_SEGURA_X': '<S1>:939' *)
                        (* '<S1>:939:3' BRK_t_N1 = 1; *)
                        BRK_t_N1 := 1.0;
                        (* '<S1>:939:3' BRK_h_N1 = 0; *)
                        BRK_h_N1 := 0.0;
                        (* '<S1>:939:4' if (xt_enc > xt_max - 2) *)
                        IF xt_enc > 48.0 THEN 
                            (* '<S1>:939:5' x_ref = xt_max - 2; *)
                            x_ref := 48.0;
                        ELSIF xt_enc < -28.0 THEN 
                            (* '<S1>:939:6' elseif (xt_enc < xt_min + 2) *)
                            (* '<S1>:939:7' x_ref = xt_min + 2; *)
                            x_ref := -28.0;
                        ELSE 
                            (* '<S1>:939:8' else *)
                            (* '<S1>:939:8' x_ref = xt_enc; *)
                            x_ref := xt_enc;
                        END_IF;
                    ELSE 
                        (* '<S1>:739:7' x_cruz = xt_enc; *)
                        x_cruz := xt_enc;
                        (* '<S1>:739:7' y_cruz = y_ref; *)
                        y_cruz := y_ref;
                    END_IF;
                ELSE
                    BRK_t_N1 := 0.0;
                    BRK_h_N1 := 0.0;
                    (* During 'STAND_BY': '<S1>:60' *)
                    (* '<S1>:90:1' sf_internal_predicateOutput = 0 | (BTN_Auto &&... *)
                    (* '<S1>:90:2'  FALLA == 0 &&... *)
                    (* '<S1>:90:3'  yh_enc >= envolvente(i_carro)); *)
                    temp6 := FALSE;
                    IF BTN_Auto AND (FALLA = 0.0) THEN 
                        IF yh_enc >= envolvente[TRUNC(i_carro) - 1] THEN 
                            (* Transition: '<S1>:90' *)
                            (* Exit 'STAND_BY': '<S1>:60' *)
                            (* '<S1>:60:13' modo_standby = 0; *)
                            modo_standby := 0.0;
                            durationCounter_1_d := 0;
                            is_MAQUINA_ESTADOS := Control_IN_MODO_AUTO;
                            (* Entry Internal 'MODO_AUTO': '<S1>:88' *)
                            (* Transition: '<S1>:222' *)
                            is_MODO_AUTO := Control_IN_AUTO_INIT;
                            (* Entry 'AUTO_INIT': '<S1>:221' *)
                            (* '<S1>:221:3' modo_auto = 1; *)
                            modo_auto := 1.0;
                            (* '<S1>:221:4' BRK_t_N1 = 1; *)
                            BRK_t_N1 := 1.0;
                            (* '<S1>:221:4' BRK_h_N1 = 1; *)
                            BRK_h_N1 := 1.0;
                            (* '<S1>:221:5' x_cmd = 0; *)
                            (* '<S1>:221:5' y_cmd = 0; *)
                            (* '<S1>:221:6' estado = 1; *)
                            estado := 1.0;
                            (* Etapa de movimiento *)
                            (* '<S1>:221:7' if (TLK == 1) *)
                            IF TLK = 1.0 THEN 
                                (* '<S1>:221:8' estado = 2; *)
                                estado := 2.0;
                                (* '<S1>:221:9' i_ini = 0; *)
                                i_ini := 0.0;
                            END_IF;
                            (* '<S1>:221:11' i_obj_vec = [0,0]; *)
                            (* '<S1>:221:12' seleccionando_i = [0,0]; *)
                            i_obj_vec[0] := 0.0;
                            seleccionando_i[0] := 0.0;
                            i_obj_vec[1] := 0.0;
                            seleccionando_i[1] := 0.0;
                        ELSE 
                            temp6 := TRUE;
                        END_IF;
                    ELSE 
                        temp6 := TRUE;
                    END_IF;
                    IF temp6 THEN 
                        (* '<S1>:96:1' sf_internal_predicateOutput = 0 | (FALLA == 1); *)
                        IF FALLA = 1.0 THEN 
                            (* Transition: '<S1>:96' *)
                            (* Exit 'STAND_BY': '<S1>:60' *)
                            (* '<S1>:60:13' modo_standby = 0; *)
                            modo_standby := 0.0;
                            is_MAQUINA_ESTADOS := Control_IN_MODO_ERROR;
                            (* Entry 'MODO_ERROR': '<S1>:91' *)
                            (* '<S1>:91:3' BRK_t_N1 = 0; *)
                            (* '<S1>:91:3' BRK_h_N1 = 0; *)
                            (* '<S1>:91:4' modo_error = 1; *)
                            modo_error := 1.0;
                            (* '<S1>:91:5' recup_ok = 0; *)
                            recup_ok := 0.0;
                        ELSE 
                            (* '<S1>:87:1' sf_internal_predicateOutput = 0 | ((abs(Joy_XY(1)) > dead_zone ||... *)
                            (* '<S1>:87:2'  abs(Joy_XY(2)) > dead_zone ||... *)
                            (* '<S1>:87:3'  BTN_Manual) && FALLA == 0); *)
                            temp6 := FALSE;
                            temp7 := FALSE;
                            IF ABS(Joy_XY[0]) > dead_zone THEN 
                                temp7 := TRUE;
                            ELSIF ABS(Joy_XY[1]) > dead_zone THEN 
                                temp7 := TRUE;
                            ELSIF BTN_Manual THEN 
                                temp7 := TRUE;
                            ELSE 
                                temp6 := TRUE;
                            END_IF;
                            IF temp7 THEN 
                                IF FALLA = 0.0 THEN 
                                    (* Transition: '<S1>:87' *)
                                    (* Exit 'STAND_BY': '<S1>:60' *)
                                    (* '<S1>:60:13' modo_standby = 0; *)
                                    modo_standby := 0.0;
                                    durationCounter_1 := 0;
                                    is_MAQUINA_ESTADOS := Control_IN_MODO_MANUAL;
                                    (* Entry 'MODO_MANUAL': '<S1>:86' *)
                                    (* Frenos abiertos *)
                                    (* '<S1>:86:4' BRK_t_N1 = 1; *)
                                    BRK_t_N1 := 1.0;
                                    (* '<S1>:86:4' BRK_h_N1 = 1; *)
                                    BRK_h_N1 := 1.0;
                                    (* '<S1>:86:5' modo_manual = 1; *)
                                    modo_manual := 1.0;
                                ELSE 
                                    temp6 := TRUE;
                                END_IF;
                            END_IF;
                            IF temp6 THEN 
                                (* '<S1>:60:11' x_cruz = x_ref; *)
                                x_cruz := x_ref;
                                (* '<S1>:60:11' y_cruz = y_ref; *)
                                y_cruz := y_ref;
                            END_IF;
                        END_IF;
                    END_IF;
            END_CASE;
            IF temp5 THEN 
                (* '<S1>:1073:1' sf_internal_predicateOutput = 0 | (modo_manual == 1 &&... *)
                (* '<S1>:1073:2' sobrecarga == 0); *)
                IF (modo_manual = 1.0) AND (sobrecarga = 0.0) THEN 
                    (* Transition: '<S1>:1073' *)
                    temp3 := TRUE;
                ELSE 
                    (* '<S1>:427:1' sf_internal_predicateOutput = 0 | (modo_manual_auto == 1 &&... *)
                    (* '<S1>:427:2'  (TLK == 0 &&... *)
                    (* '<S1>:427:3'  yh_enc > envolvente(i_usado) &&... *)
                    (* '<S1>:427:4'  abs(vh_obs) < 0.1 && estado == 2)); *)
                    IF (modo_manual_auto = 1.0) AND (TLK = 0.0) THEN 
                        IF yh_enc > envolvente[TRUNC(i_usado) - 1] THEN 
                            IF ABS(vh_obs) < 0.1 THEN 
                                IF estado = 2.0 THEN 
                                    (* Transition: '<S1>:427' *)
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
                END_IF;
            END_IF;
            IF temp4 THEN 
                (* '<S1>:379:1' sf_internal_predicateOutput = 0 | (BTN_Manual); *)
                IF BTN_Manual THEN 
                    (* Transition: '<S1>:379' *)
                    temp2 := TRUE;
                ELSE 
                    (* Transition: '<S1>:92' *)
                    (* '<S1>:1094:1' sf_internal_predicateOutput = 0 | (FALLA ==1 ||... *)
                    (* '<S1>:1094:2'  FC_der == 1 || FC_izq == 1 ||... *)
                    (* '<S1>:1094:3'  FC_sup == 1 || FC_inf == 1); *)
                    IF ((((FALLA = 1.0) OR FC_der) OR FC_izq) OR FC_sup) OR FC_inf THEN 
                        (* Transition: '<S1>:1094' *)
                        (* Exit Internal 'MODO_AUTO': '<S1>:88' *)
                        CASE is_MODO_AUTO OF
                            c_Control_IN_ESPERA_SOBRECA: 
                                (* Exit 'ESPERA_SOBRECARGA': '<S1>:1071' *)
                                (* '<S1>:1071:6' modo_manual = 0; *)
                                modo_manual := 0.0;
                                is_MODO_AUTO := Control_IN_NO_ACTIVE_CHILD;
                            c_Control_IN_MODO_MANUAL_SI: 
                                (* Exit 'MODO_MANUAL_SIMPLE': '<S1>:408' *)
                                (* '<S1>:408:9' estado = estado + 1; *)
                                estado := estado + 1.0;
                                (* '<S1>:408:10' modo_manual_auto = 0; *)
                                is_MODO_AUTO := Control_IN_NO_ACTIVE_CHILD;
                            Control_IN_MOVIMIENTO_CURVO: 
                                (* Exit 'MOVIMIENTO_CURVO': '<S1>:457' *)
                                (* '<S1>:457:8' ejec_mov = 0; *)
                                is_MODO_AUTO := Control_IN_NO_ACTIVE_CHILD;
                            c_Control_IN_MOVIMIENTO_SEG: 
                                (* Exit 'MOVIMIENTO_SEGURO': '<S1>:701' *)
                                (* '<S1>:701:8' ejec_mov = 0; *)
                                is_MODO_AUTO := Control_IN_NO_ACTIVE_CHILD;
                            c_Control_IN_SELECCION_INDI: 
                                (* Exit 'SELECCION_INDICE_FIN': '<S1>:377' *)
                                (* '<S1>:377:12' i_obj_vec(2) = i_fin; *)
                                (* '<S1>:377:13' seleccionando_i(2) = 0; *)
                                is_MODO_AUTO := Control_IN_NO_ACTIVE_CHILD;
                            d_Control_IN_SELECCION_INDI: 
                                (* Exit 'SELECCION_INDICE_INI': '<S1>:541' *)
                                (* '<S1>:541:9' i_obj_vec(1) = i_ini; *)
                                (* '<S1>:541:10' seleccionando_i(1) = 0; *)
                                is_MODO_AUTO := Control_IN_NO_ACTIVE_CHILD;
                            ELSE
                                is_MODO_AUTO := Control_IN_NO_ACTIVE_CHILD;
                        END_CASE;
                        (* Exit 'MODO_AUTO': '<S1>:88' *)
                        (* '<S1>:88:3' seleccionando_i = [0,0]; *)
                        (* '<S1>:88:4' i_obj_vec = [0,0]; *)
                        seleccionando_i[0] := 0.0;
                        i_obj_vec[0] := 0.0;
                        seleccionando_i[1] := 0.0;
                        i_obj_vec[1] := 0.0;
                        (* '<S1>:88:5' modo_auto = 0; *)
                        modo_auto := 0.0;
                        (* '<S1>:88:6' modo_manual_auto = 0; *)
                        modo_manual_auto := 0.0;
                        (* '<S1>:88:7' seleccionando = 0; *)
                        seleccionando := 0.0;
                        (* '<S1>:88:8' ejec_mov = 0; *)
                        ejec_mov := 0.0;
                        is_MAQUINA_ESTADOS := Control_IN_MODO_ERROR;
                        (* Entry 'MODO_ERROR': '<S1>:91' *)
                        (* '<S1>:91:3' BRK_t_N1 = 0; *)
                        BRK_t_N1 := 0.0;
                        (* '<S1>:91:3' BRK_h_N1 = 0; *)
                        BRK_h_N1 := 0.0;
                        (* '<S1>:91:4' modo_error = 1; *)
                        modo_error := 1.0;
                        (* '<S1>:91:5' recup_ok = 0; *)
                        recup_ok := 0.0;
                    ELSE 
                        (* '<S1>:980:1' sf_internal_predicateOutput = 0 | (modo_manual_auto == 1 &&... *)
                        (* '<S1>:980:2'  duration(abs(Joy_XY(1)) > 0.1, sec) > 3); *)
                        IF modo_manual_auto = 1.0 THEN 
                            IF ABS(Joy_XY[0]) <= 0.1 THEN 
                                durationCounter_1_d := 0;
                            END_IF;
                            IF durationCounter_1_d > 150 THEN 
                                (* Transition: '<S1>:980' *)
                                temp2 := TRUE;
                            ELSE 
                                temp1 := TRUE;
                            END_IF;
                        ELSE 
                            temp1 := TRUE;
                        END_IF;
                    END_IF;
                END_IF;
            END_IF;
            IF temp3 THEN 
                (* Exit Internal 'MODO_AUTO': '<S1>:88' *)
                CASE is_MODO_AUTO OF
                    c_Control_IN_ESPERA_SOBRECA: 
                        (* Exit 'ESPERA_SOBRECARGA': '<S1>:1071' *)
                        (* '<S1>:1071:6' modo_manual = 0; *)
                        is_MODO_AUTO := Control_IN_NO_ACTIVE_CHILD;
                    c_Control_IN_MODO_MANUAL_SI: 
                        (* Exit 'MODO_MANUAL_SIMPLE': '<S1>:408' *)
                        (* '<S1>:408:9' estado = estado + 1; *)
                        estado := estado + 1.0;
                        (* '<S1>:408:10' modo_manual_auto = 0; *)
                        is_MODO_AUTO := Control_IN_NO_ACTIVE_CHILD;
                    Control_IN_MOVIMIENTO_CURVO: 
                        (* Exit 'MOVIMIENTO_CURVO': '<S1>:457' *)
                        (* '<S1>:457:8' ejec_mov = 0; *)
                        is_MODO_AUTO := Control_IN_NO_ACTIVE_CHILD;
                    c_Control_IN_MOVIMIENTO_SEG: 
                        (* Exit 'MOVIMIENTO_SEGURO': '<S1>:701' *)
                        (* '<S1>:701:8' ejec_mov = 0; *)
                        is_MODO_AUTO := Control_IN_NO_ACTIVE_CHILD;
                    c_Control_IN_SELECCION_INDI: 
                        (* Exit 'SELECCION_INDICE_FIN': '<S1>:377' *)
                        (* '<S1>:377:12' i_obj_vec(2) = i_fin; *)
                        (* '<S1>:377:13' seleccionando_i(2) = 0; *)
                        is_MODO_AUTO := Control_IN_NO_ACTIVE_CHILD;
                    d_Control_IN_SELECCION_INDI: 
                        (* Exit 'SELECCION_INDICE_INI': '<S1>:541' *)
                        (* '<S1>:541:9' i_obj_vec(1) = i_ini; *)
                        (* '<S1>:541:10' seleccionando_i(1) = 0; *)
                        is_MODO_AUTO := Control_IN_NO_ACTIVE_CHILD;
                    ELSE
                        is_MODO_AUTO := Control_IN_NO_ACTIVE_CHILD;
                END_CASE;
                (* Exit 'MODO_AUTO': '<S1>:88' *)
                (* '<S1>:88:3' seleccionando_i = [0,0]; *)
                (* '<S1>:88:4' i_obj_vec = [0,0]; *)
                seleccionando_i[0] := 0.0;
                i_obj_vec[0] := 0.0;
                seleccionando_i[1] := 0.0;
                i_obj_vec[1] := 0.0;
                (* '<S1>:88:5' modo_auto = 0; *)
                (* '<S1>:88:6' modo_manual_auto = 0; *)
                modo_manual_auto := 0.0;
                (* '<S1>:88:7' seleccionando = 0; *)
                seleccionando := 0.0;
                (* '<S1>:88:8' ejec_mov = 0; *)
                ejec_mov := 0.0;
                is_MAQUINA_ESTADOS := Control_IN_STAND_BY;
                (* Entry 'STAND_BY': '<S1>:60' *)
                (* '<S1>:60:3' x_ref = xt_enc; *)
                x_ref := xt_enc;
                (* '<S1>:60:3' y_ref = yh_enc; *)
                y_ref := yh_enc;
                (* '<S1>:60:4' x_cruz_unity = x_ref; *)
                (* '<S1>:60:4' y_cruz_unity = y_ref; *)
                (* '<S1>:60:5' modo_standby = 1; *)
                modo_standby := 1.0;
                (* Frenos Cerrados *)
                (* '<S1>:60:7' BRK_t_N1 = 0; *)
                BRK_t_N1 := 0.0;
                (* '<S1>:60:7' BRK_h_N1 = 0; *)
                BRK_h_N1 := 0.0;
                (* '<S1>:60:8' modo_manual = 0; *)
                modo_manual := 0.0;
                (* '<S1>:60:8' modo_auto = 0; *)
                modo_auto := 0.0;
                (* '<S1>:60:9' modo_error = 0; *)
                modo_error := 0.0;
            END_IF;
            IF temp2 THEN 
                (* Exit Internal 'MODO_AUTO': '<S1>:88' *)
                CASE is_MODO_AUTO OF
                    c_Control_IN_ESPERA_SOBRECA: 
                        (* Exit 'ESPERA_SOBRECARGA': '<S1>:1071' *)
                        (* '<S1>:1071:6' modo_manual = 0; *)
                        is_MODO_AUTO := Control_IN_NO_ACTIVE_CHILD;
                    c_Control_IN_MODO_MANUAL_SI: 
                        (* Exit 'MODO_MANUAL_SIMPLE': '<S1>:408' *)
                        (* '<S1>:408:9' estado = estado + 1; *)
                        estado := estado + 1.0;
                        (* '<S1>:408:10' modo_manual_auto = 0; *)
                        is_MODO_AUTO := Control_IN_NO_ACTIVE_CHILD;
                    Control_IN_MOVIMIENTO_CURVO: 
                        (* Exit 'MOVIMIENTO_CURVO': '<S1>:457' *)
                        (* '<S1>:457:8' ejec_mov = 0; *)
                        is_MODO_AUTO := Control_IN_NO_ACTIVE_CHILD;
                    c_Control_IN_MOVIMIENTO_SEG: 
                        (* Exit 'MOVIMIENTO_SEGURO': '<S1>:701' *)
                        (* '<S1>:701:8' ejec_mov = 0; *)
                        is_MODO_AUTO := Control_IN_NO_ACTIVE_CHILD;
                    c_Control_IN_SELECCION_INDI: 
                        (* Exit 'SELECCION_INDICE_FIN': '<S1>:377' *)
                        (* '<S1>:377:12' i_obj_vec(2) = i_fin; *)
                        (* '<S1>:377:13' seleccionando_i(2) = 0; *)
                        is_MODO_AUTO := Control_IN_NO_ACTIVE_CHILD;
                    d_Control_IN_SELECCION_INDI: 
                        (* Exit 'SELECCION_INDICE_INI': '<S1>:541' *)
                        (* '<S1>:541:9' i_obj_vec(1) = i_ini; *)
                        (* '<S1>:541:10' seleccionando_i(1) = 0; *)
                        is_MODO_AUTO := Control_IN_NO_ACTIVE_CHILD;
                    ELSE
                        is_MODO_AUTO := Control_IN_NO_ACTIVE_CHILD;
                END_CASE;
                (* Exit 'MODO_AUTO': '<S1>:88' *)
                (* '<S1>:88:3' seleccionando_i = [0,0]; *)
                (* '<S1>:88:4' i_obj_vec = [0,0]; *)
                seleccionando_i[0] := 0.0;
                i_obj_vec[0] := 0.0;
                seleccionando_i[1] := 0.0;
                i_obj_vec[1] := 0.0;
                (* '<S1>:88:5' modo_auto = 0; *)
                modo_auto := 0.0;
                (* '<S1>:88:6' modo_manual_auto = 0; *)
                modo_manual_auto := 0.0;
                (* '<S1>:88:7' seleccionando = 0; *)
                seleccionando := 0.0;
                (* '<S1>:88:8' ejec_mov = 0; *)
                ejec_mov := 0.0;
                durationCounter_1 := 0;
                is_MAQUINA_ESTADOS := Control_IN_MODO_MANUAL;
                (* Entry 'MODO_MANUAL': '<S1>:86' *)
                (* Frenos abiertos *)
                (* '<S1>:86:4' BRK_t_N1 = 1; *)
                BRK_t_N1 := 1.0;
                (* '<S1>:86:4' BRK_h_N1 = 1; *)
                BRK_h_N1 := 1.0;
                (* '<S1>:86:5' modo_manual = 1; *)
                modo_manual := 1.0;
            END_IF;
            IF temp1 THEN 
                (* '<S1>:672:1' sf_internal_predicateOutput = 0 | (BTN_Reset); *)
                IF BTN_Reset THEN 
                    (* Transition: '<S1>:672' *)
                    (* Exit Internal 'MODO_AUTO': '<S1>:88' *)
                    CASE is_MODO_AUTO OF
                        c_Control_IN_ESPERA_SOBRECA: 
                            (* Exit 'ESPERA_SOBRECARGA': '<S1>:1071' *)
                            (* '<S1>:1071:6' modo_manual = 0; *)
                            modo_manual := 0.0;
                            is_MODO_AUTO := Control_IN_NO_ACTIVE_CHILD;
                        c_Control_IN_MODO_MANUAL_SI: 
                            (* Exit 'MODO_MANUAL_SIMPLE': '<S1>:408' *)
                            (* '<S1>:408:9' estado = estado + 1; *)
                            estado := estado + 1.0;
                            (* '<S1>:408:10' modo_manual_auto = 0; *)
                            is_MODO_AUTO := Control_IN_NO_ACTIVE_CHILD;
                        Control_IN_MOVIMIENTO_CURVO: 
                            (* Exit 'MOVIMIENTO_CURVO': '<S1>:457' *)
                            (* '<S1>:457:8' ejec_mov = 0; *)
                            is_MODO_AUTO := Control_IN_NO_ACTIVE_CHILD;
                        c_Control_IN_MOVIMIENTO_SEG: 
                            (* Exit 'MOVIMIENTO_SEGURO': '<S1>:701' *)
                            (* '<S1>:701:8' ejec_mov = 0; *)
                            is_MODO_AUTO := Control_IN_NO_ACTIVE_CHILD;
                        c_Control_IN_SELECCION_INDI: 
                            (* Exit 'SELECCION_INDICE_FIN': '<S1>:377' *)
                            (* '<S1>:377:12' i_obj_vec(2) = i_fin; *)
                            (* '<S1>:377:13' seleccionando_i(2) = 0; *)
                            is_MODO_AUTO := Control_IN_NO_ACTIVE_CHILD;
                        d_Control_IN_SELECCION_INDI: 
                            (* Exit 'SELECCION_INDICE_INI': '<S1>:541' *)
                            (* '<S1>:541:9' i_obj_vec(1) = i_ini; *)
                            (* '<S1>:541:10' seleccionando_i(1) = 0; *)
                            is_MODO_AUTO := Control_IN_NO_ACTIVE_CHILD;
                        ELSE
                            is_MODO_AUTO := Control_IN_NO_ACTIVE_CHILD;
                    END_CASE;
                    (* Exit 'MODO_AUTO': '<S1>:88' *)
                    (* '<S1>:88:3' seleccionando_i = [0,0]; *)
                    (* '<S1>:88:4' i_obj_vec = [0,0]; *)
                    seleccionando_i[0] := 0.0;
                    i_obj_vec[0] := 0.0;
                    seleccionando_i[1] := 0.0;
                    i_obj_vec[1] := 0.0;
                    (* '<S1>:88:5' modo_auto = 0; *)
                    modo_auto := 0.0;
                    (* '<S1>:88:6' modo_manual_auto = 0; *)
                    modo_manual_auto := 0.0;
                    (* '<S1>:88:7' seleccionando = 0; *)
                    seleccionando := 0.0;
                    (* '<S1>:88:8' ejec_mov = 0; *)
                    ejec_mov := 0.0;
                    is_MAQUINA_ESTADOS := Control_IN_PASO_STANDBY;
                    (* Entry 'PASO_STANDBY': '<S1>:787' *)
                    (* '<S1>:787:3' modo_standby = 1; *)
                    modo_standby := 1.0;
                ELSE 
                    CASE is_MODO_AUTO OF
                        Control_IN_AUTO_INIT: 
                            BRK_t_N1 := 1.0;
                            BRK_h_N1 := 1.0;
                            (* During 'AUTO_INIT': '<S1>:221' *)
                            (* Transition: '<S1>:378' *)
                            (* '<S1>:654:1' sf_internal_predicateOutput = 0 | (TLK == 0); *)
                            IF TLK = 0.0 THEN 
                                (* Transition: '<S1>:654' *)
                                is_MODO_AUTO := d_Control_IN_SELECCION_INDI;
                                (* Entry 'SELECCION_INDICE_INI': '<S1>:541' *)
                                (* '<S1>:541:3' seleccionando_i(1) = 1; *)
                                seleccionando_i[0] := 1.0;
                                (* '<S1>:541:4' seleccionando = 1; *)
                                seleccionando := 1.0;
                            ELSE 
                                (* '<S1>:745:1' sf_internal_predicateOutput = 0 | (TLK == 1); *)
                                IF TLK = 1.0 THEN 
                                    (* Transition: '<S1>:745' *)
                                    is_MODO_AUTO := c_Control_IN_SELECCION_INDI;
                                    (* Entry 'SELECCION_INDICE_FIN': '<S1>:377' *)
                                    (* '<S1>:377:3' seleccionando_i(2) = 1; *)
                                    seleccionando_i[1] := 1.0;
                                    (* '<S1>:377:4' seleccionando = 1; *)
                                    seleccionando := 1.0;
                                    (* '<S1>:377:5' invalido = 0; *)
                                    invalido := 0.0;
                                END_IF;
                            END_IF;
                        c_Control_IN_ESPERA_SOBRECA: 
                            (* During 'ESPERA_SOBRECARGA': '<S1>:1071' *)
                            (* '<S1>:1071:4' x_cruz = xt_enc; *)
                            x_cruz := xt_enc;
                            (* '<S1>:1071:4' y_cruz = yh_enc; *)
                            y_cruz := yh_enc;
                            (* '<S1>:1071:5' x_ref = x_cruz; *)
                            x_ref := x_cruz;
                            (* '<S1>:1071:5' y_ref = y_cruz; *)
                            y_ref := y_cruz;
                        c_Control_IN_MODO_MANUAL_SI: 
                            (* During 'MODO_MANUAL_SIMPLE': '<S1>:408' *)
                            (* '<S1>:497:1' sf_internal_predicateOutput = 0 | (TLK == 1 && yh_enc > (envolvente(i_usado) + Hc) && abs(vh_obs) < 0.1 && estado == 1); *)
                            temp6 := FALSE;
                            IF TLK = 1.0 THEN 
                                IF yh_enc > (envolvente[TRUNC(i_usado) - 1] + 2.59) THEN 
                                    IF ABS(vh_obs) < 0.1 THEN 
                                        IF estado = 1.0 THEN 
                                            (* Transition: '<S1>:497' *)
                                            (* Exit 'MODO_MANUAL_SIMPLE': '<S1>:408' *)
                                            (* '<S1>:408:9' estado = estado + 1; *)
                                            estado := 2.0;
                                            (* '<S1>:408:10' modo_manual_auto = 0; *)
                                            modo_manual_auto := 0.0;
                                            is_MODO_AUTO := c_Contro_IN_SELECCION_TRAYE;
                                            (* Entry 'SELECCION_TRAYECTORIA': '<S1>:697' *)
                                            (* '<S1>:697:3' modo_auto = 1; *)
                                            modo_auto := 1.0;
                                            (* '<S1>:697:4' manual_ok = 0; *)
                                            manual_ok := 0.0;
                                            (* '<S1>:697:5' i_usado = 1; *)
                                            (* '<S1>:697:6' seleccionando = 0; *)
                                            seleccionando := 0.0;
                                            (* '<S1>:697:7' if (estado == 1) *)
                                            (* '<S1>:697:9' elseif (estado == 2) *)
                                            (* '<S1>:697:10' i_usado = i_fin; *)
                                            i_usado := i_fin;
                                            (* '<S1>:697:12' safe_trajectory = 0; *)
                                            safe_trajectory := 0.0;
                                            (* Asumimos segura *)
                                            (* '<S1>:697:13' for k = i_carro:i_usado *)
                                            i := TRUNC((1.0 - i_carro) + i_usado);
                                            g_k := 0;
                                            WHILE g_k <= (i - 1) DO
                                                (* '<S1>:697:14' if is_scanned_vec(k) == 0 *)
                                                IF is_scanned_vec[TRUNC(i_carro + DINT_TO_LREAL(g_k)) - 1] = 0.0 THEN 
                                                    (* '<S1>:697:15' safe_trajectory = 1; *)
                                                    safe_trajectory := 1.0;
                                                    (* Insegura *)
                                                END_IF;
                                                g_k := g_k + 1;
                                            END_WHILE;
                                        ELSE 
                                            temp6 := TRUE;
                                        END_IF;
                                    ELSE 
                                        temp6 := TRUE;
                                    END_IF;
                                ELSE 
                                    temp6 := TRUE;
                                END_IF;
                            ELSE 
                                temp6 := TRUE;
                            END_IF;
                            IF temp6 THEN 
                                (* '<S1>:1072:1' sf_internal_predicateOutput = 0 | (sobrecarga == 1); *)
                                IF sobrecarga = 1.0 THEN 
                                    (* Transition: '<S1>:1072' *)
                                    (* Exit 'MODO_MANUAL_SIMPLE': '<S1>:408' *)
                                    (* '<S1>:408:9' estado = estado + 1; *)
                                    estado := estado + 1.0;
                                    (* '<S1>:408:10' modo_manual_auto = 0; *)
                                    modo_manual_auto := 0.0;
                                    is_MODO_AUTO := c_Control_IN_ESPERA_SOBRECA;
                                    (* Entry 'ESPERA_SOBRECARGA': '<S1>:1071' *)
                                    (* '<S1>:1071:2' modo_manual = 1; *)
                                    modo_manual := 1.0;
                                ELSE 
                                    (* '<S1>:408:6' x_cruz = xt_enc; *)
                                    x_cruz := xt_enc;
                                    (* '<S1>:408:6' y_cruz = yh_enc; *)
                                    y_cruz := yh_enc;
                                    (* '<S1>:408:7' x_ref = x_cruz; *)
                                    x_ref := x_cruz;
                                    (* '<S1>:408:7' y_ref = y_cruz; *)
                                    y_ref := y_cruz;
                                END_IF;
                            END_IF;
                        Control_IN_MOVIMIENTO_CURVO: 
                            (* During 'MOVIMIENTO_CURVO': '<S1>:457' *)
                            (* Transition: '<S1>:496' *)
                            (* '<S1>:869:1' sf_internal_predicateOutput = 0 | (manual_ok == 1); *)
                            IF manual_ok = 1.0 THEN 
                                (* Transition: '<S1>:869' *)
                                (* Exit 'MOVIMIENTO_CURVO': '<S1>:457' *)
                                (* '<S1>:457:8' ejec_mov = 0; *)
                                ejec_mov := 0.0;
                                is_MODO_AUTO := c_Control_IN_MODO_MANUAL_SI;
                                (* Entry 'MODO_MANUAL_SIMPLE': '<S1>:408' *)
                                (* '<S1>:408:3' modo_auto = 0; *)
                                modo_auto := 0.0;
                                (* '<S1>:408:4' modo_manual_auto = 1; *)
                                modo_manual_auto := 1.0;
                            ELSE 
                                (* '<S1>:457:4' [x_cmd, y_cmd, manual_ok] = Planificador_Trayectoria... *)
                                (* '<S1>:457:5'        (xt_enc, yh_enc, vt_obs, i_usado, envolvente, TLK, theta_l); *)
                                (* MEMORIA *)
                                (* MATLAB Function 'Planificador_Trayectoria': '<S1>:1055' *)
                                (* '<S1>:1055:5' if isempty(last_i_ref) *)
                                IF  NOT last_i_ref_not_empty THEN 
                                    (* '<S1>:1055:6' last_i_ref = -1; *)
                                    last_i_ref_not_empty := TRUE;
                                    (* '<S1>:1055:7' x_prev     = x_real; *)
                                    x_prev := xt_enc;
                                    (* '<S1>:1055:8' y_prev     = y_real; *)
                                    y_prev := yh_enc;
                                    (* '<S1>:1055:9' bloqueado  = false; *)
                                    (* '<S1>:1055:10' bloq_cnt   = 0; *)
                                    (* '<S1>:1055:11' dir_fija   = 1; *)
                                END_IF;
                                (* '<S1>:1055:14' if i_ref ~= last_i_ref *)
                                IF i_usado <> last_i_ref THEN 
                                    (* '<S1>:1055:15' last_i_ref   = i_ref; *)
                                    last_i_ref := i_usado;
                                    (* '<S1>:1055:16' x_prev       = x_real; *)
                                    x_prev := xt_enc;
                                    (* '<S1>:1055:17' bloqueado    = false; *)
                                    bloqueado := FALSE;
                                    (* '<S1>:1055:18' bloq_cnt     = 0; *)
                                    bloq_cnt := 0.0;
                                    (* '<S1>:1055:19' i_obj_nuevo  = min(max(i_ref, 1), N_xt); *)
                                    (* '<S1>:1055:20' x_dest_nuevo = xt_min + (i_obj_nuevo - 0.5) * Wc; *)
                                    (* '<S1>:1055:21' d_ini        = x_dest_nuevo - x_real; *)
                                    b_temp2 := MAX(i_usado, 1.0);
                                    dir_fija := (((MIN(b_temp2, 33.0) - 0.5) * 2.44) - 30.0) - xt_enc;
                                    (* '<S1>:1055:22' dir_fija     = sign(d_ini); *)
                                    IF dir_fija < 0.0 THEN 
                                        dir_fija := -1.0;
                                    ELSIF dir_fija > 0.0 THEN 
                                        dir_fija := 1.0;
                                    ELSE 
                                        dir_fija := 0.0;
                                    END_IF;
                                    (* '<S1>:1055:23' if dir_fija == 0 *)
                                    IF dir_fija = 0.0 THEN 
                                        (* '<S1>:1055:23' , *)
                                        (* '<S1>:1055:23' dir_fija = 1; *)
                                        dir_fija := 1.0;
                                    END_IF;
                                END_IF;
                                (* PARÁMETROS *)
                                (* '<S1>:1055:27' PEND        = 0.25; *)
                                (* '<S1>:1055:28' UMBRAL_IN   = 0.0174; *)
                                (* '<S1>:1055:29' DY_MAX      = 0.10; *)
                                (* '<S1>:1055:30' LA_MIN      = 2.5; *)
                                (* [m] lookahead mínimo (zona tipo pozo) *)
                                (* '<S1>:1055:31' LA_MAX      = 35.0; *)
                                (* [m] lookahead máximo (espacio libre) *)
                                (* '<S1>:1055:32' MARGEN_LA   = 0.20; *)
                                (* [m] colchón de seguridad sobre el obstáculo detectado *)
                                (* '<S1>:1055:33' H_extra     = double(twistlock == 1) * Hc; *)
                                H_extra := BOOL_TO_LREAL(TLK = 1.0) * 2.59;
                                (* ÍNDICES Y DESTINO *)
                                (* '<S1>:1055:36' i_obj  = min(max(i_ref, 1), N_xt); *)
                                b_temp3 := MAX(i_usado, 1.0);
                                i_obj := MIN(b_temp3, 33.0);
                                (* '<S1>:1055:37' i_act  = min(max(floor((x_real - xt_min) / Wc) + 1, 1), N_xt); *)
                                b_temp4 := rt_floord(u := (xt_enc - -30.0) / 2.44);
                                b_temp5 := MAX(b_temp4 + 1.0, 1.0);
                                i_act := TRUNC(MIN(b_temp5, 33.0));
                                (* '<S1>:1055:38' x_dest = xt_min + (i_obj - 0.5) * Wc; *)
                                x_dest := ((i_obj - 0.5) * 2.44) - 30.0;
                                (* '<S1>:1055:39' dir    = dir_fija; *)
                                (* '<S1>:1055:40' dist_dest = abs(x_dest - x_real); *)
                                dist_dest := ABS(x_dest - xt_enc);
                                (* ── LOOKAHEAD DINÁMICO ────────────────────────────────────────────────── *)
                                (* '<S1>:1055:43' local_window = 4; *)
                                (* celdas, cuántas adelante revisar para pared *)
                                (* Máxima envolvente en la ventana local adelante (en dirección de avance) *)
                                (* '<S1>:1055:46' k_vent_ini = i_act; *)
                                (* '<S1>:1055:47' k_vent_fin = i_act + dir * local_window; *)
                                (* '<S1>:1055:48' k_vent_fin = min(max(k_vent_fin, 1), N_xt); *)
                                b_temp6 := MAX((dir_fija * 4.0) + DINT_TO_LREAL(i_act), 1.0);
                                k_vent_fin := MIN(b_temp6, 33.0);
                                (* '<S1>:1055:50' h_local_max = 0.0; *)
                                h_local_max := 0.0;
                                (* '<S1>:1055:51' for k = min(k_vent_ini, k_vent_fin) : max(k_vent_ini, k_vent_fin) *)
                                c_x_cmd := MIN(DINT_TO_LREAL(i_act), k_vent_fin);
                                i := TRUNC((1.0 - c_x_cmd) + MAX(DINT_TO_LREAL(i_act), k_vent_fin));
                                g_k := 0;
                                WHILE g_k <= (i - 1) DO
                                    (* '<S1>:1055:52' if envolvente_vec(k) + H_extra > h_local_max *)
                                    dist_efectiva := envolvente[TRUNC(c_x_cmd + DINT_TO_LREAL(g_k)) - 1] + H_extra;
                                    IF dist_efectiva > h_local_max THEN 
                                        (* '<S1>:1055:53' h_local_max = envolvente_vec(k) + H_extra; *)
                                        h_local_max := dist_efectiva;
                                    END_IF;
                                    g_k := g_k + 1;
                                END_WHILE;
                                (* Estoy en zona peligrosa si mi altura actual no supera el máximo local. *)
                                (* '<S1>:1055:58' en_pozo = y_real < h_local_max - 2.5; *)
                                (* '<S1>:1055:60' if ~en_pozo *)
                                IF yh_enc >= (h_local_max - 2.5) THEN 
                                    (* '<S1>:1055:61' lookahead = min(LA_MAX, dist_dest); *)
                                    lookahead := MIN(35.0, dist_dest);
                                ELSE 
                                    (* '<S1>:1055:62' else *)
                                    (* '<S1>:1055:63' dist_libre = dist_dest; *)
                                    c_x_cmd := dist_dest;
                                    (* '<S1>:1055:64' k = i_act; *)
                                    h_k := DINT_TO_LREAL(i_act);
                                    (* '<S1>:1055:65' while (dir > 0 && k <= i_obj) || (dir < 0 && k >= i_obj) *)
                                    REPEAT 
                                        exitg1 := 0;
                                        IF ((dir_fija > 0.0) AND (h_k <= i_obj)) OR ((dir_fija < 0.0) AND (h_k >= i_obj)) THEN 
                                            (* '<S1>:1055:66' xc      = xt_min + (k - 0.5) * Wc; *)
                                            (* '<S1>:1055:67' dist_xc = (xc - x_real) * dir; *)
                                            dist_xc := ((((h_k - 0.5) * 2.44) - 30.0) - xt_enc) * dir_fija;
                                            (* '<S1>:1055:68' if dist_xc >= 0 *)
                                            IF dist_xc >= 0.0 THEN 
                                                (* '<S1>:1055:69' techo = envolvente_vec(k) + H_extra; *)
                                                (* '<S1>:1055:70' if y_real < techo *)
                                                IF yh_enc < (envolvente[TRUNC(h_k) - 1] + H_extra) THEN 
                                                    (* '<S1>:1055:71' dist_libre = max(0.0, dist_xc - Wc/2 - MARGEN_LA); *)
                                                    c_x_cmd := MAX(0.0, (dist_xc - 1.22) - 0.2);
                                                    exitg1 := 1;
                                                ELSE 
                                                    (* '<S1>:1055:75' k = k + dir; *)
                                                    h_k := h_k + dir_fija;
                                                END_IF;
                                            ELSE 
                                                (* '<S1>:1055:75' k = k + dir; *)
                                                h_k := h_k + dir_fija;
                                            END_IF;
                                        ELSE 
                                            exitg1 := 1;
                                        END_IF;
                                    UNTIL NOT(exitg1 = 0)
                                    END_REPEAT;
                                    (* '<S1>:1055:77' lookahead = min(max(dist_libre, LA_MIN), LA_MAX); *)
                                    (* '<S1>:1055:78' lookahead = min(lookahead, dist_dest); *)
                                    b_temp7 := MAX(c_x_cmd, 2.5);
                                    temp8 := MIN(b_temp7, 35.0);
                                    lookahead := MIN(temp8, dist_dest);
                                END_IF;
                                (* PLANIFICACIÓN HORIZONTAL: LOOKAHEAD DINÁMICO + RATCHET *)
                                (* '<S1>:1055:82' if dir > 0 *)
                                IF dir_fija > 0.0 THEN 
                                    (* '<S1>:1055:83' x_look = min(x_real + lookahead, x_dest); *)
                                    (* '<S1>:1055:84' x_cmd  = max(x_look, x_prev); *)
                                    temp10 := MIN(xt_enc + lookahead, x_dest);
                                    c_x_cmd := MAX(temp10, x_prev);
                                ELSE 
                                    (* '<S1>:1055:85' else *)
                                    (* '<S1>:1055:86' x_look = max(x_real - lookahead, x_dest); *)
                                    (* '<S1>:1055:87' x_cmd  = min(x_look, x_prev); *)
                                    temp9 := MAX(xt_enc - lookahead, x_dest);
                                    c_x_cmd := MIN(temp9, x_prev);
                                END_IF;
                                (* DETECCIÓN Y EVASIÓN DE COLISIONES (con pendiente, igual que antes) *)
                                (* '<S1>:1055:91' i_eff = min(max(floor((x_cmd - xt_min) / Wc) + 1, 1), N_xt); *)
                                temp11 := rt_floord(u := (c_x_cmd - -30.0) / 2.44);
                                temp12 := MAX(temp11 + 1.0, 1.0);
                                i_eff := TRUNC(MIN(temp12, 33.0));
                                (* '<S1>:1055:92' x_seg = x_cmd; *)
                                x_seg := c_x_cmd;
                                (* '<S1>:1055:93' bloq  = false; *)
                                bloq := FALSE;
                                (* '<S1>:1055:95' for k = min(i_act, i_eff) : max(i_act, i_eff) *)
                                dist_efectiva := MIN(DINT_TO_LREAL(i_act), DINT_TO_LREAL(i_eff));
                                i := TRUNC((1.0 - dist_efectiva) + MAX(DINT_TO_LREAL(i_act), DINT_TO_LREAL(i_eff)));
                                g_k := 0;
                                REPEAT 
                                    exitg1 := 0;
                                    IF g_k <= (i - 1) THEN 
                                        h_k := dist_efectiva + DINT_TO_LREAL(g_k);
                                        (* '<S1>:1055:96' xc     = xt_min + (k - 0.5) * Wc; *)
                                        xc := ((h_k - 0.5) * 2.44) - 30.0;
                                        (* '<S1>:1055:97' h_proj = y_real + abs(xc - x_real) * PEND; *)
                                        (* '<S1>:1055:98' techo  = envolvente_vec(k) + H_extra; *)
                                        (* '<S1>:1055:99' if h_proj < techo *)
                                        IF ((ABS(xc - xt_enc) * 0.25) + yh_enc) < (envolvente[TRUNC(h_k) - 1] + H_extra) THEN 
                                            (* '<S1>:1055:100' bloq = true; *)
                                            bloq := TRUE;
                                            (* '<S1>:1055:101' if dir > 0 *)
                                            IF dir_fija > 0.0 THEN 
                                                (* '<S1>:1055:102' x_seg = max(x_real, xc - Wc/2); *)
                                                x_seg := MAX(xt_enc, xc - 1.22);
                                            ELSE 
                                                (* '<S1>:1055:103' else *)
                                                (* '<S1>:1055:104' x_seg = min(x_real, xc + Wc/2); *)
                                                x_seg := MIN(xt_enc, xc + 1.22);
                                            END_IF;
                                            exitg1 := 1;
                                        ELSE 
                                            g_k := g_k + 1;
                                        END_IF;
                                    ELSE 
                                        exitg1 := 1;
                                    END_IF;
                                UNTIL NOT(exitg1 = 0)
                                END_REPEAT;
                                (* '<S1>:1055:110' if dir > 0 *)
                                IF dir_fija > 0.0 THEN 
                                    (* '<S1>:1055:111' x_ref_out = min(x_cmd, x_seg); *)
                                    (* '<S1>:1055:112' x_ref_out = max(x_ref_out, x_prev); *)
                                    temp14 := MIN(c_x_cmd, x_seg);
                                    x_ref := MAX(temp14, x_prev);
                                    (* ratchet *)
                                ELSE 
                                    (* '<S1>:1055:113' else *)
                                    (* '<S1>:1055:114' x_ref_out = max(x_cmd, x_seg); *)
                                    (* '<S1>:1055:115' x_ref_out = min(x_ref_out, x_prev); *)
                                    temp13 := MAX(c_x_cmd, x_seg);
                                    x_ref := MIN(temp13, x_prev);
                                    (* ratchet *)
                                END_IF;
                                (* HISTÉRESIS DE BLOQUEO *)
                                (* '<S1>:1055:119' d_bloq = abs(x_ref_out - x_cmd); *)
                                d_bloq := ABS(x_ref - c_x_cmd);
                                (* '<S1>:1055:120' if bloqueado *)
                                IF bloqueado THEN 
                                    (* '<S1>:1055:121' if bloq && d_bloq > 0.03 *)
                                    IF bloq AND (d_bloq > 0.03) THEN 
                                        (* '<S1>:1055:122' bloq_cnt = bloq_cnt + 1; *)
                                        bloq_cnt := bloq_cnt + 1.0;
                                    ELSE 
                                        (* '<S1>:1055:123' else *)
                                        (* '<S1>:1055:124' bloq_cnt = bloq_cnt - 1; *)
                                        bloq_cnt := bloq_cnt - 1.0;
                                        (* '<S1>:1055:125' if bloq_cnt <= -5 *)
                                        IF bloq_cnt <= -5.0 THEN 
                                            (* '<S1>:1055:126' bloqueado = false; *)
                                            bloqueado := FALSE;
                                            (* '<S1>:1055:127' bloq_cnt  = 0; *)
                                            bloq_cnt := 0.0;
                                        END_IF;
                                    END_IF;
                                ELSE 
                                    (* '<S1>:1055:130' else *)
                                    (* '<S1>:1055:131' if bloq && d_bloq > 0.15 *)
                                    IF bloq AND (d_bloq > 0.15) THEN 
                                        (* '<S1>:1055:132' bloqueado = true; *)
                                        bloqueado := TRUE;
                                        (* '<S1>:1055:133' bloq_cnt  = 1; *)
                                        bloq_cnt := 1.0;
                                    END_IF;
                                END_IF;
                                (* PLANIFICACIÓN VERTICAL *)
                                (* '<S1>:1055:138' h_dest = envolvente_vec(i_obj); *)
                                (* '<S1>:1055:140' i_min_ruta = min(i_act, i_obj); *)
                                i_min_ruta := MIN(DINT_TO_LREAL(i_act), i_obj);
                                (* '<S1>:1055:141' i_max_ruta = max(i_act, i_obj); *)
                                (* '<S1>:1055:142' h_max_ruta = 0.0; *)
                                h_max_ruta := 0.0;
                                (* '<S1>:1055:143' for k = i_min_ruta : i_max_ruta *)
                                i := TRUNC((1.0 - i_min_ruta) + MAX(DINT_TO_LREAL(i_act), i_obj));
                                g_k := 0;
                                WHILE g_k <= (i - 1) DO
                                    (* '<S1>:1055:144' if envolvente_vec(k) > h_max_ruta *)
                                    dist_efectiva := envolvente[TRUNC(i_min_ruta + DINT_TO_LREAL(g_k)) - 1];
                                    IF dist_efectiva > h_max_ruta THEN 
                                        (* '<S1>:1055:145' h_max_ruta = envolvente_vec(k); *)
                                        h_max_ruta := dist_efectiva;
                                    END_IF;
                                    g_k := g_k + 1;
                                END_WHILE;
                                (* '<S1>:1055:148' y_techo_viaje = h_max_ruta + H_extra; *)
                                (* '<S1>:1055:149' y_base        = h_dest + H_extra; *)
                                y_base := envolvente[TRUNC(i_obj) - 1] + H_extra;
                                (* '<S1>:1055:151' ya_en_destino_x = abs(x_real - x_dest) < Wc/2; *)
                                (* '<S1>:1055:152' if ya_en_destino_x *)
                                dist_efectiva := ABS(xt_enc - x_dest);
                                IF dist_efectiva < 1.22 THEN 
                                    (* '<S1>:1055:153' y_prop = y_base; *)
                                    y_prop := y_base;
                                ELSE 
                                    (* '<S1>:1055:154' else *)
                                    (* '<S1>:1055:155' y_prop = max(y_base, y_techo_viaje); *)
                                    y_prop := MAX(y_base, h_max_ruta + H_extra);
                                END_IF;
                                (* '<S1>:1055:158' dy        = min(max(y_prop - y_prev, -DY_MAX), DY_MAX); *)
                                (* '<S1>:1055:159' y_ref_out = y_prev + dy; *)
                                temp15 := MAX(y_prop - y_prev, -0.1);
                                y_ref := MIN(temp15, 0.1) + y_prev;
                                (* SEÑAL DE POSICIONAMIENTO COMPLETO *)
                                (* '<S1>:1055:162' listo_para_manual = double( ... *)
                                (* '<S1>:1055:163'     abs(x_real - x_dest) < 0.05 && ... *)
                                (* '<S1>:1055:164'     abs(y_real - y_base)  < 0.1  && ... *)
                                (* '<S1>:1055:165'     abs(tita_l)           < UMBRAL_IN && ... *)
                                (* '<S1>:1055:166'     abs(vx_carro)         < 0.05); *)
                                IF dist_efectiva < 0.05 THEN 
                                    IF ABS(yh_enc - y_base) < 0.1 THEN 
                                        IF ABS(theta_l) < 0.0174 THEN 
                                            IF ABS(vt_obs) < 0.05 THEN 
                                                out := TRUE;
                                            END_IF;
                                        END_IF;
                                    END_IF;
                                END_IF;
                                manual_ok := BOOL_TO_LREAL(out);
                                (* ACTUALIZAR MEMORIA *)
                                (* '<S1>:1055:169' x_prev = x_ref_out; *)
                                x_prev := x_ref;
                                (* '<S1>:1055:170' y_prev = y_ref_out; *)
                                y_prev := y_ref;
                                (* '<S1>:457:6' x_ref = x_cmd; *)
                                (* '<S1>:457:6' y_ref = y_cmd; *)
                                (* '<S1>:457:7' x_cruz = x_ref; *)
                                x_cruz := x_ref;
                                (* '<S1>:457:7' y_cruz = y_ref; *)
                                y_cruz := y_ref;
                            END_IF;
                        c_Control_IN_MOVIMIENTO_SEG: 
                            (* During 'MOVIMIENTO_SEGURO': '<S1>:701' *)
                            (* Transition: '<S1>:717' *)
                            (* '<S1>:869:1' sf_internal_predicateOutput = 0 | (manual_ok == 1); *)
                            IF manual_ok = 1.0 THEN 
                                (* Transition: '<S1>:869' *)
                                (* Exit 'MOVIMIENTO_SEGURO': '<S1>:701' *)
                                (* '<S1>:701:8' ejec_mov = 0; *)
                                ejec_mov := 0.0;
                                is_MODO_AUTO := c_Control_IN_MODO_MANUAL_SI;
                                (* Entry 'MODO_MANUAL_SIMPLE': '<S1>:408' *)
                                (* '<S1>:408:3' modo_auto = 0; *)
                                modo_auto := 0.0;
                                (* '<S1>:408:4' modo_manual_auto = 1; *)
                                modo_manual_auto := 1.0;
                            ELSE 
                                (* '<S1>:701:4' [x_cmd, y_cmd, manual_ok] = Planificador_Trayectoria_Segura... *)
                                (* '<S1>:701:5'        (xt_enc, yh_enc, i_usado, envolvente, TLK, theta_l); *)
                                (* MEMORIA *)
                                (* MATLAB Function 'Planificador_Trayectoria_Segura': '<S1>:714' *)
                                (* '<S1>:714:6' if isempty(fase) *)
                                IF  NOT fase_not_empty THEN 
                                    (* '<S1>:714:7' fase = uint8(1); *)
                                    fase_not_empty := TRUE;
                                    (* '<S1>:714:8' last_i_ref = -1; *)
                                    (* '<S1>:714:9' x_prev = x_real; *)
                                    x_prev_p := xt_enc;
                                    (* '<S1>:714:10' y_prev = y_real; *)
                                    y_prev_d := yh_enc;
                                END_IF;
                                (* '<S1>:714:13' if i_ref ~= last_i_ref *)
                                IF i_usado <> last_i_ref_o THEN 
                                    (* '<S1>:714:14' fase = uint8(1); *)
                                    fase := 1;
                                    (* '<S1>:714:15' last_i_ref = i_ref; *)
                                    last_i_ref_o := i_usado;
                                    (* '<S1>:714:16' x_prev = x_real; *)
                                    x_prev_p := xt_enc;
                                END_IF;
                                (* PARÁMETROS *)
                                (* '<S1>:714:20' DX_MAX = 0.1; *)
                                (* '<S1>:714:21' DY_MAX = 0.1; *)
                                (* '<S1>:714:22' DIST_X = 1; *)
                                (* Distancia aceptable para bajar *)
                                (* '<S1>:714:23' DIST_Y = 10; *)
                                (* '<S1>:714:24' UMBRAL_IN = 0.0175; *)
                                (* 1° [rad] *)
                                (* '<S1>:714:25' Y_CRUCERO_MIN = 39.0; *)
                                (* ÍNDICES Y DESTINO *)
                                (* '<S1>:714:28' i_obj = min(max(i_ref, 1), N_xt); *)
                                temp16 := MAX(i_usado, 1.0);
                                b_i_obj := MIN(temp16, 33.0);
                                (* '<S1>:714:29' i_act = min(max(floor((x_real - xt_min) / Wc) + 1, 1), N_xt); *)
                                temp17 := rt_floord(u := (xt_enc - -30.0) / 2.44);
                                temp18 := MAX(temp17 + 1.0, 1.0);
                                b_i_act := TRUNC(MIN(temp18, 33.0));
                                (* '<S1>:714:30' x_dest = xt_min + (i_obj - 0.5) * Wc; *)
                                b_x_dest := ((b_i_obj - 0.5) * 2.44) - 30.0;
                                (* '<S1>:714:31' h_dest = envolvente_vec(i_obj); *)
                                (* '<S1>:714:33' H_extra = double(twistlock == 1) * Hc; *)
                                b_H_extra := BOOL_TO_LREAL(TLK = 1.0) * 2.59;
                                (* '<S1>:714:35' y_base = h_dest + H_extra; *)
                                b_y_base := envolvente[TRUNC(b_i_obj) - 1] + b_H_extra;
                                (* Techo de viaje *)
                                (* '<S1>:714:38' i_min_ruta = min(i_act, i_obj); *)
                                b_i_min_ruta := MIN(DINT_TO_LREAL(b_i_act), b_i_obj);
                                (* '<S1>:714:39' i_max_ruta = max(i_act, i_obj); *)
                                i_max_ruta := MAX(DINT_TO_LREAL(b_i_act), b_i_obj);
                                (* '<S1>:714:40' h_max_ruta = max(envolvente_vec(i_min_ruta:i_max_ruta)); *)
                                IF b_i_min_ruta > i_max_ruta THEN 
                                    i := 0;
                                    g_k := -1;
                                ELSE 
                                    i := TRUNC(b_i_min_ruta) - 1;
                                    g_k := TRUNC(i_max_ruta) - 1;
                                END_IF;
                                tmp := g_k - i;
                                IF (USINT_TO_DINT(DINT_TO_USINT(tmp)) + 1) <= 2 THEN 
                                    IF DINT_TO_USINT(tmp) = 0 THEN 
                                        b_h_max_ruta := envolvente[i];
                                    ELSIF envolvente[i] < envolvente[g_k] THEN 
                                        b_h_max_ruta := envolvente[g_k];
                                    ELSE 
                                        b_h_max_ruta := envolvente[i];
                                    END_IF;
                                ELSE 
                                    h_k := envolvente[i];
                                    g_k := 1;
                                    WHILE (g_k + 1) <= (tmp + 1) DO
                                        dist_efectiva := envolvente[i + g_k];
                                        IF h_k < dist_efectiva THEN 
                                            h_k := dist_efectiva;
                                        END_IF;
                                        g_k := g_k + 1;
                                    END_WHILE;
                                    b_h_max_ruta := h_k;
                                END_IF;
                                (* '<S1>:714:42' y_crucero = max(Y_CRUCERO_MIN, h_max_ruta + H_extra); *)
                                y_crucero := MAX(39.0, b_h_max_ruta + b_H_extra);
                                (* PASOS (Interpolación suave ciclo a ciclo) *)
                                (* '<S1>:714:45' stepX = min(max(x_dest - x_prev, -DX_MAX), DX_MAX); *)
                                (* '<S1>:714:46' stepY_crucero = min(max(y_crucero - y_prev, -DY_MAX), DY_MAX); *)
                                temp19 := MAX(y_crucero - y_prev_d, -0.1);
                                stepY_crucero := MIN(temp19, 0.1);
                                (* '<S1>:714:47' stepY_base = min(max(y_base - y_prev, -DY_MAX), DY_MAX); *)
                                (* '<S1>:714:49' listo_para_manual = 0; *)
                                manual_ok := 0.0;
                                (* '<S1>:714:51' switch fase *)
                                CASE fase OF
                                    1: 
                                        (* '<S1>:714:52' case 1 *)
                                        (* Subir a crucero *)
                                        (* '<S1>:714:53' x_ref_out = x_prev; *)
                                        x_ref := x_prev_p;
                                        (* '<S1>:714:54' y_ref_out = y_prev + stepY_crucero; *)
                                        y_ref := y_prev_d + stepY_crucero;
                                        (* '<S1>:714:55' if abs(y_real - y_crucero) < DIST_Y *)
                                        IF ABS(yh_enc - y_crucero) < 10.0 THEN 
                                            (* '<S1>:714:56' fase = uint8(2); *)
                                            fase := 2;
                                        END_IF;
                                    2: 
                                        (* '<S1>:714:59' case 2 *)
                                        (* Mover en X *)
                                        (* Mantenemos la referencia Y persiguiendo al crucero suavemente *)
                                        (* '<S1>:714:61' y_ref_out = y_prev + stepY_crucero; *)
                                        y_ref := y_prev_d + stepY_crucero;
                                        (* '<S1>:714:62' x_ref_out = x_prev + stepX; *)
                                        temp20 := MAX(b_x_dest - x_prev_p, -0.1);
                                        x_ref := MIN(temp20, 0.1) + x_prev_p;
                                        (* '<S1>:714:63' if abs(x_real - x_dest) < DIST_X && abs(tita_l) < UMBRAL_IN *)
                                        IF ABS(xt_enc - b_x_dest) < 1.0 THEN 
                                            IF ABS(theta_l) < 0.0175 THEN 
                                                (* '<S1>:714:64' fase = uint8(3); *)
                                                fase := 3;
                                            END_IF;
                                        END_IF;
                                    3: 
                                        (* '<S1>:714:67' case 3 *)
                                        (* Bajar hasta y_base *)
                                        (* '<S1>:714:68' x_ref_out = x_dest; *)
                                        x_ref := b_x_dest;
                                        (* '<S1>:714:69' y_ref_out = y_prev + stepY_base; *)
                                        temp21 := MAX(b_y_base - y_prev_d, -0.1);
                                        y_ref := MIN(temp21, 0.1) + y_prev_d;
                                        (* '<S1>:714:70' if abs(y_real - y_base) < 0.1 && abs(tita_l) < UMBRAL_IN *)
                                        IF ABS(yh_enc - b_y_base) < 0.1 THEN 
                                            IF ABS(theta_l) < 0.0175 THEN 
                                                (* '<S1>:714:71' fase = uint8(4); *)
                                                fase := 4;
                                            END_IF;
                                        END_IF;
                                    ELSE
                                        (* '<S1>:714:74' otherwise *)
                                        (* '<S1>:714:75' x_ref_out = x_dest; *)
                                        x_ref := b_x_dest;
                                        (* '<S1>:714:76' y_ref_out = y_base; *)
                                        y_ref := b_y_base;
                                        (* '<S1>:714:77' listo_para_manual = double( ... *)
                                        (* '<S1>:714:78'             abs(x_real - x_dest) < 0.1 && ... *)
                                        (* '<S1>:714:79'             abs(y_real - y_base) < 0.1); *)
                                        IF ABS(xt_enc - b_x_dest) < 0.1 THEN 
                                            IF ABS(yh_enc - b_y_base) < 0.1 THEN 
                                                out := TRUE;
                                            END_IF;
                                        END_IF;
                                        manual_ok := BOOL_TO_LREAL(out);
                                END_CASE;
                                (* ACTUALIZAR MEMORIA *)
                                (* '<S1>:714:83' x_prev = x_ref_out; *)
                                x_prev_p := x_ref;
                                (* '<S1>:714:84' y_prev = y_ref_out; *)
                                y_prev_d := y_ref;
                                (* '<S1>:701:6' x_ref = x_cmd; *)
                                (* '<S1>:701:6' y_ref = y_cmd; *)
                                (* '<S1>:701:7' x_cruz = x_ref; *)
                                x_cruz := x_ref;
                                (* '<S1>:701:7' y_cruz = y_ref; *)
                                y_cruz := y_ref;
                            END_IF;
                        c_Control_IN_SELECCION_INDI: 
                            (* During 'SELECCION_INDICE_FIN': '<S1>:377' *)
                            (* '<S1>:382:1' sf_internal_predicateOutput = 0 | (BTN_TLK &&... *)
                            (* '<S1>:382:2'  invalido == 0); *)
                            IF BTN_TLK AND (invalido = 0.0) THEN 
                                (* Transition: '<S1>:382' *)
                                (* Exit 'SELECCION_INDICE_FIN': '<S1>:377' *)
                                (* '<S1>:377:12' i_obj_vec(2) = i_fin; *)
                                i_obj_vec[1] := i_fin;
                                (* '<S1>:377:13' seleccionando_i(2) = 0; *)
                                seleccionando_i[1] := 0.0;
                                is_MODO_AUTO := c_Contro_IN_SELECCION_TRAYE;
                                (* Entry 'SELECCION_TRAYECTORIA': '<S1>:697' *)
                                (* '<S1>:697:3' modo_auto = 1; *)
                                modo_auto := 1.0;
                                (* '<S1>:697:4' manual_ok = 0; *)
                                manual_ok := 0.0;
                                (* '<S1>:697:5' i_usado = 1; *)
                                i_usado := 1.0;
                                (* '<S1>:697:6' seleccionando = 0; *)
                                seleccionando := 0.0;
                                (* '<S1>:697:7' if (estado == 1) *)
                                IF estado = 1.0 THEN 
                                    (* '<S1>:697:8' i_usado = i_ini; *)
                                    i_usado := i_ini;
                                ELSIF estado = 2.0 THEN 
                                    (* '<S1>:697:9' elseif (estado == 2) *)
                                    (* '<S1>:697:10' i_usado = i_fin; *)
                                    i_usado := i_fin;
                                END_IF;
                                (* '<S1>:697:12' safe_trajectory = 0; *)
                                safe_trajectory := 0.0;
                                (* Asumimos segura *)
                                (* '<S1>:697:13' for k = i_carro:i_usado *)
                                i := TRUNC((1.0 - i_carro) + i_usado);
                                g_k := 0;
                                WHILE g_k <= (i - 1) DO
                                    (* '<S1>:697:14' if is_scanned_vec(k) == 0 *)
                                    IF is_scanned_vec[TRUNC(i_carro + DINT_TO_LREAL(g_k)) - 1] = 0.0 THEN 
                                        (* '<S1>:697:15' safe_trajectory = 1; *)
                                        safe_trajectory := 1.0;
                                        (* Insegura *)
                                    END_IF;
                                    g_k := g_k + 1;
                                END_WHILE;
                            ELSE 
                                (* '<S1>:377:7' i_fin = i_x_cruz; *)
                                i_fin := i_x_cruz;
                                (* '<S1>:377:8' if (i_fin == 33 || i_fin == 13 || i_fin == 1) *)
                                IF ((i_fin = 33.0) OR (i_fin = 13.0)) OR (i_fin = 1.0) THEN 
                                    (* '<S1>:377:9' invalido = 1; *)
                                    invalido := 1.0;
                                ELSE 
                                    (* '<S1>:377:10' else *)
                                    (* '<S1>:377:10' invalido = 0; *)
                                    invalido := 0.0;
                                END_IF;
                            END_IF;
                        d_Control_IN_SELECCION_INDI: 
                            (* During 'SELECCION_INDICE_INI': '<S1>:541' *)
                            (* '<S1>:543:1' sf_internal_predicateOutput = 0 | (BTN_TLK &&... *)
                            (* '<S1>:543:2'  is_cont == 1); *)
                            IF BTN_TLK AND (is_cont = 1.0) THEN 
                                (* Transition: '<S1>:543' *)
                                (* Exit 'SELECCION_INDICE_INI': '<S1>:541' *)
                                (* '<S1>:541:9' i_obj_vec(1) = i_ini; *)
                                i_obj_vec[0] := i_ini;
                                (* '<S1>:541:10' seleccionando_i(1) = 0; *)
                                seleccionando_i[0] := 0.0;
                                is_MODO_AUTO := c_Control_IN_SELECCION_INDI;
                                (* Entry 'SELECCION_INDICE_FIN': '<S1>:377' *)
                                (* '<S1>:377:3' seleccionando_i(2) = 1; *)
                                seleccionando_i[1] := 1.0;
                                (* '<S1>:377:4' seleccionando = 1; *)
                                seleccionando := 1.0;
                                (* '<S1>:377:5' invalido = 0; *)
                                invalido := 0.0;
                            ELSE 
                                (* '<S1>:541:6' i_ini = i_x_cruz; *)
                                i_ini := i_x_cruz;
                                (* '<S1>:541:7' is_cont = Check_Container(i_ini, yc0_vec); *)
                                is_cont := Check_Container(i_pos := i_ini, y0_vec := yc0_vec);
                            END_IF;
                        ELSE
                            (* During 'SELECCION_TRAYECTORIA': '<S1>:697' *)
                            (* '<S1>:699:1' sf_internal_predicateOutput = 0 | (safe_trajectory == 0); *)
                            IF safe_trajectory = 0.0 THEN 
                                (* Transition: '<S1>:699' *)
                                is_MODO_AUTO := Control_IN_MOVIMIENTO_CURVO;
                                (* Entry 'MOVIMIENTO_CURVO': '<S1>:457' *)
                                (* '<S1>:457:2' ejec_mov = 1; *)
                                ejec_mov := 1.0;
                            ELSE 
                                (* '<S1>:703:1' sf_internal_predicateOutput = 0 | (safe_trajectory == 1); *)
                                IF safe_trajectory = 1.0 THEN 
                                    (* Transition: '<S1>:703' *)
                                    is_MODO_AUTO := c_Control_IN_MOVIMIENTO_SEG;
                                    (* Entry 'MOVIMIENTO_SEGURO': '<S1>:701' *)
                                    (* '<S1>:701:2' ejec_mov = 1; *)
                                    ejec_mov := 1.0;
                                END_IF;
                            END_IF;
                    END_CASE;
                END_IF;
            END_IF;
            (* During 'TWISTLOCKS': '<S1>:165' *)
            CASE is_TWISTLOCKS OF
                Control_IN_ABRIENDO_TLK: 
                    (* During 'ABRIENDO_TLK': '<S1>:294' *)
                    (* '<S1>:292:1' sf_internal_predicateOutput = 0 | (Fhw > (Ms*g/2*0.8) && abs(yh_enc - y_start) > 0.3 && abs(vt_obs) < 0.01); *)
                    temp1 := FALSE;
                    IF Fhw > 58839.9 THEN 
                        IF ABS(yh_enc - y_start) > 0.3 THEN 
                            IF ABS(vt_obs) < 0.01 THEN 
                                (* Transition: '<S1>:292' *)
                                is_TWISTLOCKS := Control_IN_VACIO;
                                (* Entry 'VACIO': '<S1>:166' *)
                                (* '<S1>:166:3' TLK = 0; *)
                                TLK := 0.0;
                                (* '<S1>:166:4' m_est = Ms; *)
                                m_est := 15000.0;
                                (* '<S1>:166:5' sobrecarga = 0; *)
                                sobrecarga := 0.0;
                                (* '<S1>:166:6' trans_TLK = 0; *)
                                trans_TLK := 0.0;
                            ELSE 
                                temp1 := TRUE;
                            END_IF;
                        ELSE 
                            temp1 := TRUE;
                        END_IF;
                    ELSE 
                        temp1 := TRUE;
                    END_IF;
                    IF temp1 THEN 
                        (* '<S1>:294:9' m_est = max(Ms, Fhw * 2 / g); *)
                        m_est := MAX(15000.0, (Fhw * 2.0) / 9.80665);
                        (* '<S1>:294:10' vh_lim = 0.1; *)
                        vh_lim := 0.1;
                    END_IF;
                Control_IN_CARGADO: 
                    (* During 'CARGADO': '<S1>:177' *)
                    (* '<S1>:180:1' sf_internal_predicateOutput = 0 | (BTN_TLK == 1 &&... *)
                    (* '<S1>:180:2'  Fhw < ((m_est*g/2)*0.8) &&... *)
                    (* '<S1>:180:3' ~ismember(i_carro, [1, 13, 33])); *)
                    temp1 := FALSE;
                    IF BTN_TLK THEN 
                        IF Fhw < (((m_est * 9.80665) / 2.0) * 0.8) THEN 
                            i0_isMember(a := i_carro);
                            IF  NOT i0_isMember.tf THEN 
                                (* Transition: '<S1>:180' *)
                                is_TWISTLOCKS := Control_IN_ABRIENDO_TLK;
                                (* Entry 'ABRIENDO_TLK': '<S1>:294' *)
                                (* '<S1>:294:3' TLK = 0; *)
                                TLK := 0.0;
                                (* '<S1>:294:4' y_start = yh_enc; *)
                                y_start := yh_enc;
                                (* '<S1>:294:5' trans_TLK = 1; *)
                                trans_TLK := 1.0;
                                (* '<S1>:294:6' m_container = 0; *)
                                m_container := 0.0;
                                (* '<S1>:294:7' sobrecarga = 0; *)
                                sobrecarga := 0.0;
                            ELSE 
                                temp1 := TRUE;
                            END_IF;
                        ELSE 
                            temp1 := TRUE;
                        END_IF;
                    ELSE 
                        temp1 := TRUE;
                    END_IF;
                    IF temp1 THEN 
                        (* '<S1>:177:9' m_est = max(Ms, (Fhw * 2 / g)); *)
                        m_est := MAX(15000.0, (Fhw * 2.0) / 9.80665);
                        (* '<S1>:177:10' vh_lim = min(vh_max_unloaded,... *)
                        (* '<S1>:177:11'        max(vh_nom, P_nom / ((m_container + Ms) * g))); *)
                        temp22 := MAX(1.5, 956150.0 / ((m_container + 15000.0) * 9.80665));
                        vh_lim := MIN(3.0, temp22);
                    END_IF;
                Control_IN_CERRANDO_TLK: 
                    (* During 'CERRANDO_TLK': '<S1>:168' *)
                    (* '<S1>:288:1' sf_internal_predicateOutput = 0 | (Fhw > (Ms*g/2 * 1.2) &&... *)
                    (* '<S1>:288:2'  abs(yh_enc - y_start) > 0.3 &&... *)
                    (* '<S1>:288:3'  abs(vt_obs) < 0.01); *)
                    temp1 := FALSE;
                    IF Fhw > 88259.849999999991 THEN 
                        IF ABS(yh_enc - y_start) > 0.3 THEN 
                            IF ABS(vt_obs) < 0.01 THEN 
                                (* Transition: '<S1>:288' *)
                                is_TWISTLOCKS := Control_IN_CARGADO;
                                (* Entry 'CARGADO': '<S1>:177' *)
                                (* '<S1>:177:3' m_container = m_est - Ms; *)
                                m_container := m_est - 15000.0;
                                (* Masa estimada container *)
                                (* '<S1>:177:4' if (m_container > (Mc_max + 100)) *)
                                IF (m_est - 15000.0) > 50100.0 THEN 
                                    (* Margen de 100kg *)
                                    (* '<S1>:177:5' trans_TLK = 1; *)
                                    trans_TLK := 1.0;
                                    (* '<S1>:177:5' sobrecarga = 1; *)
                                    sobrecarga := 1.0;
                                ELSE 
                                    (* '<S1>:177:6' else *)
                                    (* '<S1>:177:6' trans_TLK = 0; *)
                                    trans_TLK := 0.0;
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
                    IF temp1 THEN 
                        (* '<S1>:168:7' vh_lim = 0.1; *)
                        vh_lim := 0.1;
                        (* Filtro simple *)
                        (* '<S1>:168:9' m_est = m_est + 0.1 * (max(Ms, (Fhw * 2 / g)) - m_est); *)
                        m_est := ((MAX(15000.0, (Fhw * 2.0) / 9.80665) - m_est) * 0.1) + m_est;
                    END_IF;
                ELSE
                    (* During 'VACIO': '<S1>:166' *)
                    (* '<S1>:171:1' sf_internal_predicateOutput = 0 | (BTN_TLK == 1 &&... *)
                    (* '<S1>:171:2'  Fhw < (Ms*g/2 * 0.8) &&... *)
                    (* '<S1>:171:3'  hay_cont == 1); *)
                    temp1 := FALSE;
                    IF BTN_TLK THEN 
                        IF Fhw < 58839.9 THEN 
                            IF hay_cont = 1.0 THEN 
                                (* Transition: '<S1>:171' *)
                                is_TWISTLOCKS := Control_IN_CERRANDO_TLK;
                                (* Entry 'CERRANDO_TLK': '<S1>:168' *)
                                (* '<S1>:168:3' TLK = 1; *)
                                TLK := 1.0;
                                (* '<S1>:168:3' trans_TLK = 1; *)
                                trans_TLK := 1.0;
                                (* '<S1>:168:4' y_start = yh_enc; *)
                                y_start := yh_enc;
                                (* '<S1>:168:5' m_est = max(Ms, (Fhw * 2 / g)); *)
                                m_est := 15000.0;
                            ELSE 
                                temp1 := TRUE;
                            END_IF;
                        ELSE 
                            temp1 := TRUE;
                        END_IF;
                    ELSE 
                        temp1 := TRUE;
                    END_IF;
                    IF temp1 THEN 
                        (* '<S1>:166:8' hay_cont = Check_Container... *)
                        (* '<S1>:166:9'        (i_carro, yc0_vec); *)
                        hay_cont := Check_Container(i_pos := i_carro, y0_vec := yc0_vec);
                        (* '<S1>:166:10' vh_lim = vh_max_unloaded; *)
                        vh_lim := 3.0;
                    END_IF;
            END_CASE;
            (* During 'MANEJO_CRUCETA': '<S1>:638' *)
            (* During 'INPUT_JOYSTICK': '<S1>:852' *)
            (* '<S1>:852:7' Joy_CMD_X = Joy_XY(1); *)
            (* '<S1>:852:7' Joy_CMD_Y = Joy_XY(2); *)
            (* '<S1>:852:8' if abs(Joy_CMD_X) < dead_zone *)
            IF ABS(Joy_XY[0]) < dead_zone THEN 
                (* '<S1>:852:9' vx_target = 0; *)
                h_k := 0.0;
            ELSE 
                (* '<S1>:852:10' else *)
                (* '<S1>:852:11' vx_target = Joy_CMD_X * vt_max; *)
                h_k := Joy_XY[0] * 4.0;
            END_IF;
            (* '<S1>:852:13' if abs(Joy_CMD_Y) < dead_zone *)
            IF ABS(Joy_XY[1]) < dead_zone THEN 
                (* '<S1>:852:14' vy_target = 0; *)
                c_x_cmd := 0.0;
            ELSE 
                (* '<S1>:852:15' else *)
                (* '<S1>:852:16' vy_target = Joy_CMD_Y * vh_lim; *)
                c_x_cmd := Joy_XY[1] * vh_lim;
            END_IF;
            (* '<S1>:852:18' if (trans_TLK == 1 || modo_manual_auto == 1) *)
            IF (trans_TLK = 1.0) OR (modo_manual_auto = 1.0) THEN 
                (* '<S1>:852:19' vx_target = 0; *)
                h_k := 0.0;
                (* '<S1>:852:20' if (sobrecarga == 1) *)
                IF sobrecarga = 1.0 THEN 
                    (* '<S1>:852:21' vh_lim = 0.1; *)
                    vh_lim := 0.1;
                    (* '<S1>:852:22' if (vy_target > 0) *)
                    IF c_x_cmd > 0.0 THEN 
                        (* '<S1>:852:22' vy_target = 0; *)
                        c_x_cmd := 0.0;
                    END_IF;
                END_IF;
            END_IF;
            (* '<S1>:852:25' if (modo_posicion_segura == 1) *)
            IF modo_posicion_segura = 1.0 THEN 
                (* '<S1>:852:25' vh_lim = 0.5; *)
                vh_lim := 0.5;
            END_IF;
            (* '<S1>:852:26' if seleccionando == 1 *)
            IF seleccionando = 1.0 THEN 
                (* '<S1>:852:27' vx_target = Joy_CMD_X * v_max_ref; *)
                (* '<S1>:852:28' vx_cmd = vx_target; *)
                vx_cmd := Joy_XY[0] * v_max_ref;
            ELSE 
                (* '<S1>:852:29' else *)
                (* '<S1>:852:30' [vx_cmd, ax_act] = Suavizador_Cinematico... *)
                (* '<S1>:852:31'            (vx_target, vx_cmd, ax_act, at_max, jerk_max, Ts1); *)
                i0_Suavizador_Cinematico(v_target := h_k, v_act := vx_cmd, a_act := ax_act, A_MAX := 0.8, J_MAX := jerk_max, Ts := 0.02);
                vx_cmd := i0_Suavizador_Cinematico.v_out;
                ax_act := i0_Suavizador_Cinematico.a_out;
                (* '<S1>:852:32' [vy_cmd, ay_act] = Suavizador_Cinematico... *)
                (* '<S1>:852:33'            (vy_target, vy_cmd, ay_act, ah_max, jerk_max, Ts1); *)
                i0_Suavizador_Cinematico(v_target := c_x_cmd, v_act := vy_cmd, a_act := ay_act, A_MAX := 0.75, J_MAX := jerk_max, Ts := 0.02);
                vy_cmd := i0_Suavizador_Cinematico.v_out;
                ay_act := i0_Suavizador_Cinematico.a_out;
            END_IF;
            (* During 'ACTUALIZAR_CRUCETA': '<S1>:639' *)
            (* '<S1>:639:3' x_cruz = x_cruz + vx_cmd * Ts1; *)
            x_cruz := (vx_cmd * 0.02) + x_cruz;
            (* Actualizar X cruceta *)
            (* '<S1>:639:4' y_cruz = y_cruz + vy_cmd * Ts1; *)
            y_cruz := (vy_cmd * 0.02) + y_cruz;
            (* Actualizar Y cruceta *)
            (* Limitar en X *)
            (* '<S1>:639:6' x_cruz = max(xt_min, min(xt_max, x_cruz)); *)
            temp23 := MIN(50.0, x_cruz);
            x_cruz := MAX(-30.0, temp23);
            (* Limitar en Y *)
            (* '<S1>:639:8' y_cruz = max(yh_min, min(yh_max, y_cruz)); *)
            temp24 := MIN(40.0, y_cruz);
            y_cruz := MAX(-20.0, temp24);
            (* '<S1>:639:9' if seleccionando == 0 *)
            IF seleccionando = 0.0 THEN 
                (* Outport: '<Root>/x_cruz_unity' *)
                (* '<S1>:639:10' x_cruz_unity = x_cruz; *)
                x_cruz_unity := x_cruz;
                (* Outport: '<Root>/y_cruz_unity' *)
                (* '<S1>:639:11' y_cruz_unity = y_cruz; *)
                y_cruz_unity := y_cruz;
            ELSE 
                (* Outport: '<Root>/x_cruz_unity' *)
                (* '<S1>:639:12' else *)
                (* '<S1>:639:13' x_cruz_unity = xt_min + i_x_cruz * Wc - Wc/2; *)
                x_cruz_unity := ((i_x_cruz * 2.44) - 30.0) - 1.22;
                (* Outport: '<Root>/y_cruz_unity' *)
                (* '<S1>:639:14' y_cruz_unity = yh_min; *)
                y_cruz_unity := -20.0;
            END_IF;
            (* During 'INDICES_Y_PERFIL': '<S1>:361' *)
            (* During 'CALCULO_INDICES': '<S1>:231' *)
            (* '<S1>:231:6' i_carro = floor((xt_enc - xt_min)/Wc) + 1; *)
            i_carro := rt_floord(u := (xt_enc - -30.0) / 2.44) + 1.0;
            (* '<S1>:231:7' i_carro = min(max(i_carro, 1), 33); *)
            temp25 := MAX(i_carro, 1.0);
            i_carro := MIN(temp25, 33.0);
            (* '<S1>:231:8' i_lidar = floor((xt_enc+x_LIDAR-xt_min)/Wc)+1; *)
            (* '<S1>:231:9' i_lidar = min(max(i_lidar,1),33); *)
            temp26 := rt_floord(u := ((xt_enc + 3.0) - -30.0) / 2.44);
            temp27 := MAX(temp26 + 1.0, 1.0);
            i := TRUNC(MIN(temp27, 33.0)) - 1;
            (* '<S1>:231:10' i_xt_ref = floor((x_ref - xt_min)/Wc) + 1; *)
            (* '<S1>:231:11' i_xt_ref = min(max(i_xt_ref, 1), 33); *)
            (* '<S1>:231:12' i_x_cruz = floor((x_cruz - xt_min)/Wc) + 1; *)
            i_x_cruz := rt_floord(u := (x_cruz - -30.0) / 2.44) + 1.0;
            (* '<S1>:231:13' i_x_cruz = min(max(i_x_cruz, 1), 33); *)
            (* During 'ACTUALIZAR_PERFIL_ALTURAS': '<S1>:238' *)
            (* '<S1>:238:7' yc0_xtref = yc0_vec(i_xt_ref); *)
            (* Obtengo altura de referencia *)
            (* '<S1>:238:8' yc0_vec(i_lidar) = h_vec_output(i_lidar); *)
            yc0_vec[i] := h_vec_output[i];
            (* Actualizo perfil *)
            (* '<S1>:238:9' is_scanned_vec(i_lidar) = 1; *)
            is_scanned_vec[i] := 1.0;
            (* Detecto si se ha abierto o cerrado TLK *)
            (* '<S1>:238:11' TLK_rise  = (TLK_anterior == 0) && (TLK == 1); *)
            IF (TLK_anterior = 0.0) AND (TLK = 1.0) THEN 
                out := TRUE;
            ELSE 
                out := FALSE;
            END_IF;
            (* '<S1>:238:12' TLK_fall  = (TLK_anterior == 1) && (TLK == 0); *)
            IF (TLK_anterior = 1.0) AND (TLK = 0.0) THEN 
                TLK_fall := TRUE;
            ELSE 
                TLK_fall := FALSE;
            END_IF;
            (* '<S1>:238:13' if(TLK_rise) *)
            IF out THEN 
                (* Si agarré un container, hay que bajar el perfil *)
                (* '<S1>:238:14' h_vec_output(i_carro) = h_vec_output(i_carro) - Hc; *)
                h_vec_output[TRUNC(i_carro) - 1] := h_vec_output[TRUNC(i_carro) - 1] - 2.59;
                (* '<S1>:238:15' yc0_vec(i_carro) = yc0_vec(i_carro) - Hc; *)
                yc0_vec[TRUNC(i_carro) - 1] := yc0_vec[TRUNC(i_carro) - 1] - 2.59;
            ELSIF TLK_fall THEN 
                (* '<S1>:238:16' elseif(TLK_fall) *)
                (* Si solté un container, hay que subir el perfil *)
                (* '<S1>:238:17' h_vec_output(i_carro) = h_vec_output(i_carro) + Hc; *)
                h_vec_output[TRUNC(i_carro) - 1] := h_vec_output[TRUNC(i_carro) - 1] + 2.59;
                (* '<S1>:238:18' yc0_vec(i_carro) = yc0_vec(i_carro) + Hc; *)
                yc0_vec[TRUNC(i_carro) - 1] := yc0_vec[TRUNC(i_carro) - 1] + 2.59;
            END_IF;
            (* '<S1>:238:20' TLK_anterior = TLK; *)
            TLK_anterior := TLK;
            (* '<S1>:238:20' yc0 = yc0_vec(i_carro); *)
            (* '<S1>:238:21' envolvente = Generar_Envolvente(yc0_vec, is_scanned_vec); *)
            (* MATLAB Function 'Generar_Envolvente': '<S1>:1075' *)
            (* '<S1>:1075:4' N = 33; *)
            (* No puedo usar N_xt, da error *)
            (* '<S1>:1075:5' h_seguridad = Hc/2; *)
            (* Margen fijo (ajustable) *)
            (* '<S1>:1075:7' perfil_seguro = zeros(N,1); *)
            (* '<S1>:1075:8' for i = 1:N *)
            (* '<S1>:1075:16' envolvente_f = perfil_seguro; *)
            FOR b_i := 0 TO 32 DO 
                (* '<S1>:1075:9' if escaneado_vec(i) == 1 *)
                IF is_scanned_vec[b_i] = 1.0 THEN 
                    (* '<S1>:1075:10' perfil_seguro(i) = perfil_escaneado_vec(i) + h_seguridad; *)
                    h_k := yc0_vec[b_i] + 1.295;
                    perfil_seguro[b_i] := h_k;
                ELSE 
                    (* '<S1>:1075:11' else *)
                    (* '<S1>:1075:12' perfil_seguro(i) = 0; *)
                    h_k := 0.0;
                    perfil_seguro[b_i] := 0.0;
                END_IF;
                envolvente[b_i] := h_k;
            END_FOR;
            (* '<S1>:1075:18' for i = 1:N *)
            FOR c_i := 0 TO 32 DO 
                (* '<S1>:1075:19' if escaneado_vec(i) == 0 *)
                IF is_scanned_vec[c_i] <> 0.0 THEN 
                    (* '<S1>:1075:23' e_i = perfil_seguro(i); *)
                    (* vecino izquierdo *)
                    (* '<S1>:1075:25' if i > 1 && escaneado_vec(i-1) == 1 *)
                    IF c_i > 0 THEN 
                        IF is_scanned_vec[c_i - 1] = 1.0 THEN 
                            (* '<S1>:1075:26' if e_i > perfil_seguro(i-1) *)
                            h_k := perfil_seguro[c_i];
                            IF h_k > perfil_seguro[c_i - 1] THEN 
                                (* '<S1>:1075:27' envolvente_f(i-1) = max(envolvente_f(i-1), e_i); *)
                                envolvente[c_i - 1] := MAX(envolvente[c_i - 1], h_k);
                            END_IF;
                        END_IF;
                    END_IF;
                    (* vecino derecho *)
                    (* '<S1>:1075:31' if i < N && escaneado_vec(i+1) == 1 *)
                    IF (c_i + 1) < 33 THEN 
                        IF is_scanned_vec[c_i + 1] = 1.0 THEN 
                            (* '<S1>:1075:32' if e_i > perfil_seguro(i+1) *)
                            h_k := perfil_seguro[c_i];
                            IF h_k > perfil_seguro[c_i + 1] THEN 
                                (* '<S1>:1075:33' envolvente_f(i+1) = max(envolvente_f(i+1), e_i); *)
                                envolvente[c_i + 1] := MAX(envolvente[c_i + 1], h_k);
                            END_IF;
                        END_IF;
                    END_IF;
                END_IF;
            END_FOR;
            (* '<S1>:1075:38' for i = 1:N *)
            FOR d_i := 0 TO 32 DO 
                (* '<S1>:1075:39' if escaneado_vec(i) == 0 *)
                IF is_scanned_vec[d_i] = 0.0 THEN 
                    (* '<S1>:1075:40' envolvente_f(i) = 0; *)
                    envolvente[d_i] := 0.0;
                END_IF;
            END_FOR;
            (* During 'LIMITES_SUAVES': '<S1>:1022' *)
            (* LÍMITE INFERIOR DE IZAJE *)
            (* '<S1>:1022:5' if (TLK == 1) *)
            IF TLK = 1.0 THEN 
                (* '<S1>:1022:6' dist = yh_enc - (yc0 + 0.5 + Hc); *)
                c_x_cmd := yh_enc - ((yc0_vec[TRUNC(i_carro) - 1] + 0.5) + 2.59);
                (* '<S1>:1022:6' T_retardo = 0.8; *)
                h_k := 0.8;
            ELSE 
                (* '<S1>:1022:7' else *)
                (* '<S1>:1022:8' dist = yh_enc - (yc0 + 0.5); *)
                c_x_cmd := yh_enc - (yc0_vec[TRUNC(i_carro) - 1] + 0.5);
                (* '<S1>:1022:8' T_retardo = 0.4; *)
                h_k := 0.4;
            END_IF;
            (* Compensación con retardo dinámico *)
            (* '<S1>:1022:11' dist_efectiva = dist - (abs(vy_cmd) * T_retardo); *)
            dist_efectiva := c_x_cmd - (ABS(vy_cmd) * h_k);
            (* '<S1>:1022:12' if (dist_efectiva < 0) *)
            IF dist_efectiva < 0.0 THEN 
                (* '<S1>:1022:13' dist_efectiva = 0; *)
                dist_efectiva := 0.0;
            END_IF;
            (* '<S1>:1022:15' acc_plan = ah_max * K_acc; *)
            (* '<S1>:1022:16' v_segura = sqrt(0.01 + 2 * acc_plan * dist_efectiva); *)
            c_x_cmd := 2.0 * (0.75 * K_acc);
            dist_efectiva := SQRT((c_x_cmd * dist_efectiva) + 0.01);
            (* '<S1>:1022:17' if (v_segura > vh_lim) *)
            IF dist_efectiva > vh_lim THEN 
                (* '<S1>:1022:18' v_segura = vh_lim; *)
                dist_efectiva := vh_lim;
            END_IF;
            (* Si pide moverse más rápido, se recorta *)
            (* '<S1>:1022:21' if (vy_cmd < -v_segura) *)
            IF vy_cmd < ( -dist_efectiva) THEN 
                (* '<S1>:1022:22' vy_cmd = -v_segura; *)
                vy_cmd :=  -dist_efectiva;
            END_IF;
            (* LÍMITE SUPERIOR DE IZAJE *)
            (* '<S1>:1022:25' dist = (yh_max - 2) - yh_enc; *)
            (* '<S1>:1022:26' dist_efectiva = dist - (abs(vy_cmd) * T_retardo); *)
            dist_efectiva := (38.0 - yh_enc) - (ABS(vy_cmd) * h_k);
            (* '<S1>:1022:27' if (dist_efectiva < 0) *)
            IF dist_efectiva < 0.0 THEN 
                (* '<S1>:1022:28' dist_efectiva = 0; *)
                dist_efectiva := 0.0;
            END_IF;
            (* '<S1>:1022:30' v_segura = sqrt(0.01 + 2 * acc_plan * dist_efectiva); *)
            dist_efectiva := SQRT((c_x_cmd * dist_efectiva) + 0.01);
            (* '<S1>:1022:31' if (v_segura > vh_lim) *)
            IF dist_efectiva > vh_lim THEN 
                (* '<S1>:1022:32' v_segura = vh_lim; *)
                dist_efectiva := vh_lim;
            END_IF;
            (* '<S1>:1022:34' if (vy_cmd > v_segura) *)
            IF vy_cmd > dist_efectiva THEN 
                (* '<S1>:1022:35' vy_cmd = v_segura; *)
                vy_cmd := dist_efectiva;
            END_IF;
            (* LÍMITE DERECHO DEL CARRO *)
            (* '<S1>:1022:38' T_retardo = 5; *)
            (* Retardo mayor para el carro *)
            (* '<S1>:1022:39' dist = (xt_max - 2) - xt_enc; *)
            (* '<S1>:1022:40' dist_efectiva = dist - (abs(vx_cmd) * T_retardo); *)
            dist_efectiva := (48.0 - xt_enc) - (ABS(vx_cmd) * 5.0);
            (* '<S1>:1022:41' if (dist_efectiva < 0) *)
            IF dist_efectiva < 0.0 THEN 
                (* '<S1>:1022:42' dist_efectiva = 0; *)
                dist_efectiva := 0.0;
            END_IF;
            (* '<S1>:1022:44' acc_plan = at_max * K_acc; *)
            (* '<S1>:1022:45' v_segura = sqrt(0.01 + 2 * acc_plan * dist_efectiva); *)
            c_x_cmd := 2.0 * (0.8 * K_acc);
            dist_efectiva := SQRT((c_x_cmd * dist_efectiva) + 0.01);
            (* '<S1>:1022:46' if (vx_cmd > v_segura) *)
            IF vx_cmd > dist_efectiva THEN 
                (* '<S1>:1022:47' vx_cmd = v_segura; *)
                vx_cmd := dist_efectiva;
            END_IF;
            (* LÍMITE IZQUIERDO DEL CARRO *)
            (* '<S1>:1022:50' dist = xt_enc - (xt_min + 2); *)
            (* '<S1>:1022:51' dist_efectiva = dist - (abs(vx_cmd) * T_retardo); *)
            dist_efectiva := (xt_enc - -28.0) - (ABS(vx_cmd) * 5.0);
            (* '<S1>:1022:52' if (dist_efectiva < 0) *)
            IF dist_efectiva < 0.0 THEN 
                (* '<S1>:1022:53' dist_efectiva = 0; *)
                dist_efectiva := 0.0;
            END_IF;
            (* '<S1>:1022:55' v_segura = sqrt(0.01 + 2 * acc_plan * dist_efectiva); *)
            dist_efectiva := SQRT((c_x_cmd * dist_efectiva) + 0.01);
            (* '<S1>:1022:56' if (vx_cmd < -v_segura) *)
            IF vx_cmd < ( -dist_efectiva) THEN 
                (* '<S1>:1022:57' vx_cmd = -v_segura; *)
                vx_cmd :=  -dist_efectiva;
            END_IF;
            (* During 'WATCHDOG_HEARTBEAT': '<S1>:724' *)
            CASE is_WATCHDOG_HEARTBEAT OF
                Control_IN_PULSOS_DOWN: 
                    (* Outport: '<Root>/heartbeat' *)
                    heartbeat := 1.0;
                    (* During 'PULSOS_DOWN': '<S1>:728' *)
                    (* '<S1>:730:1' sf_internal_predicateOutput = 0 | (after(periodo_pulsos, msec)); *)
                    temporalCounter_i1(timerAction := 2, maxTime := 100);
                    out := temporalCounter_i1.done;
                    IF out THEN 
                        (* Transition: '<S1>:730' *)
                        temporalCounter_i1(timerAction := 1, maxTime := 0);
                        is_WATCHDOG_HEARTBEAT := Control_IN_PULSOS_UP;
                        (* Outport: '<Root>/heartbeat' *)
                        (* Entry 'PULSOS_UP': '<S1>:725' *)
                        (* '<S1>:725:3' heartbeat = 0; *)
                        heartbeat := 0.0;
                    END_IF;
                ELSE
                    (* Outport: '<Root>/heartbeat' *)
                    heartbeat := 0.0;
                    (* During 'PULSOS_UP': '<S1>:725' *)
                    (* '<S1>:729:1' sf_internal_predicateOutput = 0 | (after(periodo_pulsos, msec)); *)
                    temporalCounter_i1(timerAction := 2, maxTime := 100);
                    out := temporalCounter_i1.done;
                    IF out THEN 
                        (* Transition: '<S1>:729' *)
                        temporalCounter_i1(timerAction := 1, maxTime := 0);
                        is_WATCHDOG_HEARTBEAT := Control_IN_PULSOS_DOWN;
                        (* Outport: '<Root>/heartbeat' *)
                        (* Entry 'PULSOS_DOWN': '<S1>:728' *)
                        (* '<S1>:728:3' heartbeat = 1; *)
                        heartbeat := 1.0;
                    END_IF;
            END_CASE;
        END_IF;
        dist_efectiva := ABS(Joy_XY[0]);
        IF dist_efectiva < 0.1 THEN 
            IF ABS(Joy_XY[1]) < 0.1 THEN 
                IF ABS(vt_obs) < 0.01 THEN 
                    IF ABS(vh_obs) < 0.01 THEN 
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
        IF dist_efectiva > 0.1 THEN 
            durationCounter_1_d := durationCounter_1_d + 1;
        ELSE 
            durationCounter_1_d := 0;
        END_IF;
        (* End of Chart: '<Root>/Control Nivel 1' *)
END_CASE;
END_FUNCTION_BLOCK
FUNCTION_BLOCK Suavizador_Cinematico
VAR_INPUT
    v_target: LREAL;
    v_act: LREAL;
    a_act: LREAL;
    A_MAX: LREAL;
    J_MAX: LREAL;
    Ts: LREAL;
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
(* MATLAB Function 'Suavizador_Cinematico': '<S1>:853' *)
(* '<S1>:853:4' err_v = v_target - v_act; *)
err_v := v_target - v_act;
(* Error instantáneo de velocidad     *)
(* '<S1>:853:5' zona_lineal = 0.05; *)
(* Zona lineal cercana a cero para evitar singularidad en la raíz *)
(* Generación de aceleración deseada *)
(* '<S1>:853:8' if abs(err_v) < 1e-6 *)
tmp := ABS(err_v);
IF tmp < 1.0E-6 THEN 
    (* Evita micro-oscilaciones cuando el error es prácticamente cero. *)
    (* '<S1>:853:9' v_out = v_target; *)
    v_out := v_target;
    (* '<S1>:853:10' a_out = 0; *)
    a_out := 0.0;
ELSE 
    IF tmp > 0.05 THEN 
        (* '<S1>:853:13' elseif abs(err_v) > zona_lineal *)
        (* '<S1>:853:14' a_req = sign(err_v) * sqrt(2 * J_MAX * abs(err_v)); *)
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
        (* '<S1>:853:15' else *)
        (* '<S1>:853:16' a_req = (err_v / zona_lineal) * sqrt(2 * J_MAX * zona_lineal); *)
        a_req := SQRT((2.0 * J_MAX) * 0.05) * (err_v / 0.05);
        (* Región lineal cercana a cero para evitar pendiente infinita *)
    END_IF;
    (* Saturación de aceleración *)
    (* '<S1>:853:20' if a_req > A_MAX *)
    IF a_req > A_MAX THEN 
        (* '<S1>:853:21' a_req = A_MAX; *)
        a_req := A_MAX;
    ELSIF a_req < ( -A_MAX) THEN 
        (* '<S1>:853:22' elseif a_req < -A_MAX *)
        (* '<S1>:853:23' a_req = -A_MAX; *)
        a_req :=  -A_MAX;
    END_IF;
    (* Cálculo de jerk requerido *)
    (* '<S1>:853:27' jerk_req = (a_req - a_act) / Ts; *)
    jerk_req := (a_req - a_act) / Ts;
    (* Saturación de jerk *)
    (* '<S1>:853:29' if jerk_req > J_MAX *)
    IF jerk_req > J_MAX THEN 
        (* '<S1>:853:30' jerk_req = J_MAX; *)
        jerk_req := J_MAX;
    ELSIF jerk_req < ( -J_MAX) THEN 
        (* '<S1>:853:31' elseif jerk_req < -J_MAX *)
        (* '<S1>:853:32' jerk_req = -J_MAX; *)
        jerk_req :=  -J_MAX;
    END_IF;
    (* Integración discreta (Euler) *)
    (* '<S1>:853:36' a_out = a_act + jerk_req * Ts; *)
    a_out := (jerk_req * Ts) + a_act;
    (* '<S1>:853:37' v_out = v_act + a_out * Ts; *)
    v_out := (a_out * Ts) + v_act;
    (* Eliminación de deriva *)
    (* Forzar a cero absoluto si el joystick está suelto *)
    (* '<S1>:853:41' if abs(v_target) < 0.001 && abs(v_out) < 0.001 *)
    IF ABS(v_target) < 0.001 THEN 
        IF ABS(v_out) < 0.001 THEN 
            (* '<S1>:853:42' v_out = 0.0; *)
            v_out := 0.0;
            (* '<S1>:853:43' a_out = 0.0; *)
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
(* MATLAB Function 'Check_Container': '<S1>:369' *)
(* '<S1>:369:4' if(i_pos<13 && y0_vec(i_pos)>0) *)
temp1 := FALSE;
IF i_pos < 13.0 THEN 
    IF y0_vec[TRUNC(i_pos) - 1] > 0.0 THEN 
        (* '<S1>:369:5' hay_container = 1; *)
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
            (* '<S1>:369:6' elseif(i_pos>13 && i_pos<33 && y0_vec(i_pos)>-18) *)
            (* '<S1>:369:7' hay_container = 1; *)
            Check_Container := 1.0;
        ELSE 
            (* '<S1>:369:8' else *)
            (* '<S1>:369:9' hay_container = 0; *)
            Check_Container := 0.0;
        END_IF;
    ELSE 
        (* '<S1>:369:8' else *)
        (* '<S1>:369:9' hay_container = 0; *)
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
    Control_IN_NO_ACTIVE_CHILD: USINT := 0;
    Control_IN_MODO_AUTO: USINT := 1;
    Control_IN_MODO_ERROR: USINT := 2;
    Control_IN_MODO_MANUAL: USINT := 3;
    Control_IN_PASO_STANDBY: USINT := 4;
    c_Control_IN_POSICION_SEGUR: USINT := 5;
    d_Control_IN_POSICION_SEGUR: USINT := 6;
    Control_IN_STAND_BY: USINT := 7;
    Control_IN_AUTO_INIT: USINT := 1;
    c_Control_IN_ESPERA_SOBRECA: USINT := 2;
    c_Control_IN_MODO_MANUAL_SI: USINT := 3;
    Control_IN_MOVIMIENTO_CURVO: USINT := 4;
    c_Control_IN_MOVIMIENTO_SEG: USINT := 5;
    c_Control_IN_SELECCION_INDI: USINT := 6;
    d_Control_IN_SELECCION_INDI: USINT := 7;
    c_Contro_IN_SELECCION_TRAYE: USINT := 8;
    Control_IN_ABRIENDO_TLK: USINT := 1;
    Control_IN_CARGADO: USINT := 2;
    Control_IN_CERRANDO_TLK: USINT := 3;
    Control_IN_VACIO: USINT := 4;
    Control_IN_PULSOS_DOWN: USINT := 1;
    Control_IN_PULSOS_UP: USINT := 2;
    SS_INITIALIZE: SINT := 0;
    SS_STEP: SINT := 1;
END_VAR
