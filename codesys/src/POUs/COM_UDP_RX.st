(*
 * COM_UDP_RX - Recibe paquete UDP de Simulink (puerto 25000).
 * Deserializa T_UDP_TX_FROM_SIM (31 LREAL = 248 bytes).
 * Usa SysSocket.library (incluida en CODESYS estándar).
 *
 * Ejecutar en Task_RX cada 20 ms.
 *)
FUNCTION_BLOCK COM_UDP_RX
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
    sAddr       : SOCKADDRESS;
    udiRecv     : UDINT;
    diRes       : DINT;
    abyBuffer   : ARRAY[0..255] OF BYTE;
END_VAR

(* ---- Inicialización del socket (una vez) ---- *)
IF NOT xInit AND xEnable THEN
    hSocket := SysSockCreate(SOCKET_AF_INET, SOCKET_STREAM_UDP, SOCKET_IPPROTO_UDP, ADR(diRes));
    IF diRes = 0 THEN
        // Modo no bloqueante para que Task_RX no se quede esperando
        SysSockIoctl(hSocket, SOCKET_FIONBIO, ADR(1));
        // Bind a localhost:25000
        sAddr.sin_family := SOCKET_AF_INET;
        sAddr.sin_port := SysSockHtons(GVL_PARAMS.UDP_PORT_RX);
        SysSockInetAddr('0.0.0.0', ADR(sAddr.sin_addr));
        diRes := SysSockBind(hSocket, ADR(sAddr), SIZEOF(sAddr));
        IF diRes = 0 THEN
            xInit := TRUE;
            xConnected := TRUE;
            GVL_COMMS.udp_rx_socket := SysSockHandleToDInt(hSocket);
        ELSE
            GVL_COMMS.udp_rx_err := diRes;
            SysSockClose(hSocket);
        END_IF
    ELSE
        GVL_COMMS.udp_rx_err := diRes;
    END_IF
END_IF

(* ---- Recepción no bloqueante ---- *)
IF xInit AND xEnable THEN
    udiRecv := 0;
    diRes := SysSockRecv(hSocket, ADR(abyBuffer), SIZEOF(abyBuffer), 0, ADR(udiRecv));
    IF diRes = 0 AND udiRecv = GVL_PARAMS.UDP_RX_SIZE THEN
        // Copia directa al struct (little-endian, x64)
        SysMemCpy(ADR(GVL_COMMS.udp_from_sim), ADR(abyBuffer), GVL_PARAMS.UDP_RX_SIZE);
        GVL_COMMS.udp_rx_ok := TRUE;
        GVL_COMMS.udp_rx_count := GVL_COMMS.udp_rx_count + 1;
        udiCount := GVL_COMMS.udp_rx_count;
    ELSIF diRes <> 0 AND diRes <> SOCKET_EAGAIN THEN
        GVL_COMMS.udp_rx_err := diRes;
        GVL_COMMS.udp_rx_ok := FALSE;
    END_IF
END_IF
