(*
 * COM_UDP_TX - Envía paquete UDP a Simulink (puerto 25001).
 * Serializa T_UDP_RX_TO_SIM (53 LREAL = 424 bytes) desde GVL_COMMS.udp_to_sim.
 * Usa SysSocket.library.
 *
 * Ejecutar en Task_TX cada 20 ms (después de Task_Supervisor).
 *)
FUNCTION_BLOCK COM_UDP_TX
VAR_INPUT
    xEnable    : BOOL;
END_VAR
VAR_OUTPUT
    xConnected : BOOL;
    udiCount   : UDINT;
END_VAR
VAR
    xInit       : BOOL := FALSE;
    hSocket     : RTS_IEC_HANDLE;
    sAddrDst    : SOCKADDRESS;
    diRes       : DINT;
    udiSent     : UDINT;
    abyBuffer   : ARRAY[0..511] OF BYTE;
END_VAR

(* ---- Inicialización del socket (una vez) ---- *)
IF NOT xInit AND xEnable THEN
    hSocket := SysSockCreate(SOCKET_AF_INET, SOCKET_STREAM_UDP, SOCKET_IPPROTO_UDP, ADR(diRes));
    IF diRes = 0 THEN
        // Destino: Simulink en 127.0.0.1:25001
        sAddrDst.sin_family := SOCKET_AF_INET;
        sAddrDst.sin_port := SysSockHtons(GVL_PARAMS.UDP_PORT_TX);
        SysSockInetAddr(GVL_PARAMS.UDP_REMOTE_IP, ADR(sAddrDst.sin_addr));
        xInit := TRUE;
        xConnected := TRUE;
        GVL_COMMS.udp_tx_socket := SysSockHandleToDInt(hSocket);
    ELSE
        GVL_COMMS.udp_tx_err := diRes;
    END_IF
END_IF

(* ---- Envío cada ciclo ---- *)
IF xInit AND xEnable THEN
    // Copia struct -> buffer
    SysMemCpy(ADR(abyBuffer), ADR(GVL_COMMS.udp_to_sim), GVL_PARAMS.UDP_TX_SIZE);
    udiSent := 0;
    diRes := SysSockSendTo(hSocket, ADR(abyBuffer), GVL_PARAMS.UDP_TX_SIZE, 0,
                            ADR(sAddrDst), SIZEOF(sAddrDst), ADR(udiSent));
    IF diRes = 0 AND udiSent = GVL_PARAMS.UDP_TX_SIZE THEN
        GVL_COMMS.udp_tx_ok := TRUE;
        GVL_COMMS.udp_tx_count := GVL_COMMS.udp_tx_count + 1;
        udiCount := GVL_COMMS.udp_tx_count;
    ELSE
        GVL_COMMS.udp_tx_err := diRes;
        GVL_COMMS.udp_tx_ok := FALSE;
    END_IF
END_IF
