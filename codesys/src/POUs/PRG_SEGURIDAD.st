(*
 * PRG_SEGURIDAD - Programa llamado por Task_Seguridad (20 ms).
 * Desempaqueta entradas y ejecuta CONTROL_SEGURIDAD (L0).
 *)
PROGRAM PRG_SEGURIDAD
VAR
    fbSeguridad : CONTROL_SEGURIDAD;
END_VAR

fbSeguridad(
    BTN_Emerg     := GVL_COMMS.udp_from_sim.BTN_Emerg > 0.5,
    BTN_Reset     := GVL_COMMS.udp_from_sim.BTN_Reset > 0.5,
    FCE_der       := GVL_COMMS.udp_from_sim.FCE_der > 0.5,
    FCE_inf       := GVL_COMMS.udp_from_sim.FCE_inf > 0.5,
    FCE_izq       := GVL_COMMS.udp_from_sim.FCE_izq > 0.5,
    FCE_sup       := GVL_COMMS.udp_from_sim.FCE_sup > 0.5,
    vh_obs        := GVL_COMMS.udp_from_sim.vh_obs,
    vt_obs        := GVL_COMMS.udp_from_sim.vt_obs,
    m_container   := GVL_PROCESS.m_container_L1,
    recup_ok      := GVL_COMMS.udp_from_sim.recup_ok > 0.5,
    heartbeat_L1  := GVL_PROCESS.heartbeat_L1
);
