(*
 * PRG_TX - Programa llamado por Task_TX (20 ms).
 * Empaqueta señales del PLC en GVL_COMMS.udp_to_sim y las envía.
 *)
PROGRAM PRG_TX
VAR
    fbUdpTx : COM_UDP_TX;
END_VAR

(* Empaquetar valores actuales del PLC en el struct de salida *)
GVL_COMMS.udp_to_sim.BRK_h_N1        := INT_TO_LREAL(GVL_PROCESS.BRK_h_N1);
GVL_COMMS.udp_to_sim.BRK_t_N1        := INT_TO_LREAL(GVL_PROCESS.BRK_t_N1);
GVL_COMMS.udp_to_sim.TLK             := INT_TO_LREAL(GVL_PROCESS.TLK_OUT);
GVL_COMMS.udp_to_sim.yc0_vec         := GVL_PROCESS.yc0_vec_OUT;
GVL_COMMS.udp_to_sim.i_sel           := INT_TO_LREAL(GVL_PROCESS.i_sel_OUT);
GVL_COMMS.udp_to_sim.vx_suave        := GVL_PROCESS.vx_suave;
GVL_COMMS.udp_to_sim.vy_suave        := GVL_PROCESS.vy_suave;
GVL_COMMS.udp_to_sim.recuperacion    := BOOL_TO_LREAL(GVL_PROCESS.recuperacion_OUT);
GVL_COMMS.udp_to_sim.modo_muerto     := BOOL_TO_LREAL(GVL_PROCESS.modo_muerto_L1);
GVL_COMMS.udp_to_sim.heartbeat       := INT_TO_LREAL(GVL_PROCESS.heartbeat_L1);
GVL_COMMS.udp_to_sim.m_container     := GVL_PROCESS.m_container_L1;
GVL_COMMS.udp_to_sim.BRK_hE_N0       := INT_TO_LREAL(GVL_PROCESS.BRK_h_N0);
GVL_COMMS.udp_to_sim.BRK_t_N0        := INT_TO_LREAL(GVL_PROCESS.BRK_t_N0);
GVL_COMMS.udp_to_sim.FALLA_IZAJE_SV  := BOOL_TO_LREAL(GVL_PROCESS.FALLA_IZAJE_SV_L0);
GVL_COMMS.udp_to_sim.FALLA_MAN       := BOOL_TO_LREAL(GVL_PROCESS.FALLA_MAN_L0);
GVL_COMMS.udp_to_sim.FALLA_WD        := BOOL_TO_LREAL(GVL_PROCESS.FALLA_WD_L0);
GVL_COMMS.udp_to_sim.FALLA_CARRO_DER := BOOL_TO_LREAL(GVL_PROCESS.FALLA_CARRO_DER_L0);
GVL_COMMS.udp_to_sim.FALLA_CARRO_IZQ := BOOL_TO_LREAL(GVL_PROCESS.FALLA_CARRO_IZQ_L0);
GVL_COMMS.udp_to_sim.FALLA_IZAJE_INF := BOOL_TO_LREAL(GVL_PROCESS.FALLA_IZAJE_INF_L0);
GVL_COMMS.udp_to_sim.FALLA_IZAJE_SUP := BOOL_TO_LREAL(GVL_PROCESS.FALLA_IZAJE_SUP_L0);
GVL_COMMS.udp_to_sim.FALLA_CARRO_SV  := BOOL_TO_LREAL(GVL_PROCESS.FALLA_CARRO_SV_L0);

fbUdpTx(xEnable := TRUE);
