(*
 * PRG_RX - Programa llamado por Task_RX (20 ms).
 * Recibe UDP de Simulink y mapea los campos al GVL_COMMS.udp_from_sim.
 *)
PROGRAM PRG_RX
VAR
    fbUdpRx : COM_UDP_RX;
END_VAR

fbUdpRx(xEnable := TRUE);
