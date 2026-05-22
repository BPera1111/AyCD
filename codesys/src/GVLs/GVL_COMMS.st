(*
 * GVL_COMMS - Buffers UDP y estructuras de comunicación.
 * Las estructuras son escritas/leídas por COM_UDP_RX y COM_UDP_TX.
 *)
VAR_GLOBAL
    // Estructura recibida de Simulink (lo que el PLC lee)
    udp_from_sim       : T_UDP_TX_FROM_SIM;

    // Estructura enviada a Simulink (lo que el PLC escribe)
    udp_to_sim         : T_UDP_RX_TO_SIM;

    // Estado conexión
    udp_rx_socket      : DINT := -1;
    udp_tx_socket      : DINT := -1;
    udp_rx_ok          : BOOL := FALSE;
    udp_tx_ok          : BOOL := FALSE;
    udp_rx_count       : UDINT := 0;        // contador paquetes recibidos
    udp_tx_count       : UDINT := 0;        // contador paquetes enviados
    udp_rx_err         : DINT := 0;
    udp_tx_err         : DINT := 0;
END_VAR
