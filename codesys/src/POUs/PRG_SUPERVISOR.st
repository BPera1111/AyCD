(*
 * PRG_SUPERVISOR - Programa llamado por Task_Supervisor (20 ms).
 * Desempaqueta entradas y ejecuta CONTROL_SUPERVISOR (L1).
 *)
PROGRAM PRG_SUPERVISOR
VAR
    fbSupervisor : CONTROL_SUPERVISOR;
END_VAR

fbSupervisor(
    BTN_ON_OFF    := GVL_COMMS.udp_from_sim.BTN_ON_OFF > 0.5,
    BTN_TLK       := GVL_COMMS.udp_from_sim.BTN_TLK > 0.5,
    BTN_Auto      := GVL_COMMS.udp_from_sim.BTN_Auto > 0.5,
    BTN_Reset     := GVL_COMMS.udp_from_sim.BTN_Reset > 0.5,
    Joy_XY        := GVL_COMMS.udp_from_sim.Joy_XY,
    theta_l       := GVL_COMMS.udp_from_sim.theta_l,
    theta_l_dot   := GVL_COMMS.udp_from_sim.theta_l_dot,
    vh_obs        := GVL_COMMS.udp_from_sim.vh_obs,
    vt_obs        := GVL_COMMS.udp_from_sim.vt_obs,
    Fhw           := GVL_COMMS.udp_from_sim.Fhw,
    yh_enc        := GVL_COMMS.udp_from_sim.yh_enc,
    xt_enc        := GVL_COMMS.udp_from_sim.xt_enc,
    FC_der        := GVL_COMMS.udp_from_sim.FC_der > 0.5,
    FC_inf        := GVL_COMMS.udp_from_sim.FC_inf > 0.5,
    FC_izq        := GVL_COMMS.udp_from_sim.FC_izq > 0.5,
    FC_sup        := GVL_COMMS.udp_from_sim.FC_sup > 0.5,
    T_hm          := GVL_COMMS.udp_from_sim.T_hm,
    T_tm          := GVL_COMMS.udp_from_sim.T_tm,
    FALLA_GLOBAL  := GVL_PROCESS.FALLA_GLOBAL,
    RECUPERAR_L0  := GVL_PROCESS.RECUPERAR_L0
);
