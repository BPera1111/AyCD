# UDP Packet Specification — Simulink ↔ CODESYS

## Conexión

| Canal | Origen | Destino | Puerto | LREAL | Bytes |
|---|---|---|---|---|---|
| **TX** | Simulink (`UDP Send2`) | PLC (`COM_UDP_RX`) | 127.0.0.1:25000 | 31 | 248 |
| **RX** | PLC (`COM_UDP_TX`) | Simulink (`UDP Read`) | 127.0.0.1:25001 | 53 | 424 |

Sample time: 20 ms ambos. Endianness: little-endian (x64 Windows).

---

## RX (PLC → Simulink) — 53 LREAL

Genera el PLC. Demux 21 lanes en `planta_codesys.slx`.

| # | GotoTag | Size | Origen PLC | Tipo CODESYS |
|---|---------|------|------------|--------------|
| 1 | `BRK_h_N1` | 1 | CONTROL_SUPERVISOR.BRK_h_N1 | LREAL |
| 2 | `BRK_t_N1` | 1 | CONTROL_SUPERVISOR.BRK_t_N1 | LREAL |
| 3 | `TLK` | 1 | CONTROL_SUPERVISOR.TLK | LREAL |
| 4 | `yc0_vec` | **33** | CONTROL_SUPERVISOR.yc0_vec | ARRAY[1..33] OF LREAL |
| 5 | `i_sel` | 1 | CONTROL_SUPERVISOR.i_sel | LREAL |
| 6 | `vx_suave` | 1 | CONTROL_SUPERVISOR.vx_suave | LREAL |
| 7 | `vy_suave` | 1 | CONTROL_SUPERVISOR.vy_suave | LREAL |
| 8 | `recuperacion` | 1 | CONTROL_SUPERVISOR.recuperacion | LREAL |
| 9 | `modo_muerto` | 1 | CONTROL_SUPERVISOR.modo_muerto | LREAL |
| 10 | `heartbeat` | 1 | CONTROL_SUPERVISOR.heartbeat | LREAL |
| 11 | `m_container` | 1 | CONTROL_SUPERVISOR.m_container | LREAL |
| 12 | `BRK_hE_N0` | 1 | CONTROL_SEGURIDAD.BRK_hE_N0 | LREAL |
| 13 | `BRK_t_N0` | 1 | CONTROL_SEGURIDAD.BRK_t_N0 | LREAL |
| 14 | `FALLA_IZAJE_SV` | 1 | CONTROL_SEGURIDAD.FALLA_IZAJE_SV | LREAL |
| 15 | `FALLA_MAN` | 1 | CONTROL_SEGURIDAD.FALLA_MAN | LREAL |
| 16 | `FALLA_WD` | 1 | CONTROL_SEGURIDAD.FALLA_WD | LREAL |
| 17 | `FALLA_CARRO_DER` | 1 | CONTROL_SEGURIDAD.FALLA_CARRO_DER | LREAL |
| 18 | `FALLA_CARRO_IZQ` | 1 | CONTROL_SEGURIDAD.FALLA_CARRO_IZQ | LREAL |
| 19 | `FALLA_IZAJE_INF` | 1 | CONTROL_SEGURIDAD.FALLA_IZAJE_INF | LREAL |
| 20 | `FALLA_IZAJE_SUP` | 1 | CONTROL_SEGURIDAD.FALLA_IZAJE_SUP | LREAL |
| 21 | `FALLA_CARRO_SV` | 1 | CONTROL_SEGURIDAD.FALLA_CARRO_SV | LREAL |

**Total**: 20×1 + 33 = **53 LREAL = 424 bytes**

---

## TX (Simulink → PLC) — 31 LREAL

Mux 30 lanes en `planta_codesys.slx`. Lane 13 (`Joy_XY`) es [1×2] → 2 LREAL.

| # | Mux in | Tag | Size | Destino PLC | Notas |
|---|--------|-----|------|-------------|-------|
| 1 | 1 | `BTN_EMERG` | 1 | CONTROL_SEGURIDAD.BTN_Emerg | BOOL via > 0.5 |
| 2 | 2 | `BTN_RESET` | 1 | ambos.BTN_Reset | BOOL |
| 3 | 3 | `FCE_DER` | 1 | CONTROL_SEGURIDAD.FCE_der | BOOL |
| 4 | 4 | `FCE_INF` | 1 | CONTROL_SEGURIDAD.FCE_inf | BOOL |
| 5 | 5 | `FCE_IZQ` | 1 | CONTROL_SEGURIDAD.FCE_izq | BOOL |
| 6 | 6 | `FCE_SUP` | 1 | CONTROL_SEGURIDAD.FCE_sup | BOOL |
| 7 | 7 | `recuperacion` | 1 | CONTROL_SEGURIDAD.recup_ok | feedback de L1 |
| 8 | 8 | `yh` | 1 | CONTROL_SUPERVISOR.yh_enc | posición izaje (m) |
| 9 | 9 | `modo_muerto` | 1 | ambos | feedback |
| 10 | 10 | `heartbeat` | 1 | feedback | echo |
| 11 | 11 | `m_container` | 1 | feedback | echo |
| 12 | 12 | `BTN_ON_OFF` | 1 | CONTROL_SUPERVISOR.BTN_ON_OFF | BOOL |
| 13 | 13 | `Joy_XY` | **2** | CONTROL_SUPERVISOR.Joy_XY | ARRAY[1..2] OF LREAL |
| 14 | 14 | `tita_l` | 1 | CONTROL_SUPERVISOR.theta_l | rad |
| 15 | 15 | `w_l` | 1 | CONTROL_SUPERVISOR.theta_l_dot | rad/s (derivada de tita_l) |
| 16 | 16 | `vh_obs` | 1 | ambos | m/s |
| 17 | 17 | `vt_obs` | 1 | ambos | m/s |
| 18 | 18 | `F_hw` | 1 | CONTROL_SUPERVISOR.Fhw | N (fuerza horizontal cable) |
| 19 | 19 | `BTN_TLK` | 1 | CONTROL_SUPERVISOR.BTN_TLK | BOOL |
| 20 | 20 | `xt` | 1 | CONTROL_SUPERVISOR.xt_enc | posición carro (m) |
| 21 | 21 | `FC_DER` | 1 | CONTROL_SUPERVISOR.FC_der | BOOL |
| 22 | 22 | `FC_INF` | 1 | CONTROL_SUPERVISOR.FC_inf | BOOL |
| 23 | 23 | `FC_IZQ` | 1 | CONTROL_SUPERVISOR.FC_izq | BOOL |
| 24 | 24 | `FC_SUP` | 1 | CONTROL_SUPERVISOR.FC_sup | BOOL |
| 25 | 25 | `BTN_AUTO` | 1 | CONTROL_SUPERVISOR.BTN_Auto | BOOL |
| 26 | 26 | `FALLA_MAN` | 1 | CONTROL_SUPERVISOR.FALLA_MAN | feedback |
| 27 | 27 | `FALLA_WD` | 1 | CONTROL_SUPERVISOR.FALLA_WD | feedback |
| 28 | 28 | `FALLA_IZAJE_SV` | 1 | CONTROL_SUPERVISOR.FALLA_SV | feedback |
| 29 | 29 | `T_hm*` | 1 | CONTROL_SUPERVISOR.T_hm | Nm (torque motor izaje) |
| 30 | 30 | `T_tm*` | 1 | CONTROL_SUPERVISOR.T_tm | Nm (torque motor carro) |

**Total**: 29 + 2 (Joy_XY) = **31 LREAL = 248 bytes**

---

## Estructuras CODESYS

### `T_UDP_TX_FROM_SIM` (recibe el PLC, 248 bytes)

```iecst
TYPE T_UDP_TX_FROM_SIM :
STRUCT
    BTN_Emerg          : LREAL;
    BTN_Reset          : LREAL;
    FCE_der            : LREAL;
    FCE_inf            : LREAL;
    FCE_izq            : LREAL;
    FCE_sup            : LREAL;
    recup_ok           : LREAL;
    yh_enc             : LREAL;
    modo_muerto        : LREAL;
    heartbeat_echo     : LREAL;
    m_container_echo   : LREAL;
    BTN_ON_OFF         : LREAL;
    Joy_XY             : ARRAY[1..2] OF LREAL;
    theta_l            : LREAL;
    theta_l_dot        : LREAL;
    vh_obs             : LREAL;
    vt_obs             : LREAL;
    Fhw                : LREAL;
    BTN_TLK            : LREAL;
    xt_enc             : LREAL;
    FC_der             : LREAL;
    FC_inf             : LREAL;
    FC_izq             : LREAL;
    FC_sup             : LREAL;
    BTN_Auto           : LREAL;
    FALLA_MAN_fb       : LREAL;
    FALLA_WD_fb        : LREAL;
    FALLA_SV_fb        : LREAL;
    T_hm               : LREAL;
    T_tm               : LREAL;
END_STRUCT
END_TYPE
```

### `T_UDP_RX_TO_SIM` (envía el PLC, 424 bytes)

```iecst
TYPE T_UDP_RX_TO_SIM :
STRUCT
    BRK_h_N1           : LREAL;
    BRK_t_N1           : LREAL;
    TLK                : LREAL;
    yc0_vec            : ARRAY[1..33] OF LREAL;
    i_sel              : LREAL;
    vx_suave           : LREAL;
    vy_suave           : LREAL;
    recuperacion       : LREAL;
    modo_muerto        : LREAL;
    heartbeat          : LREAL;
    m_container        : LREAL;
    BRK_hE_N0          : LREAL;
    BRK_t_N0           : LREAL;
    FALLA_IZAJE_SV     : LREAL;
    FALLA_MAN          : LREAL;
    FALLA_WD           : LREAL;
    FALLA_CARRO_DER    : LREAL;
    FALLA_CARRO_IZQ    : LREAL;
    FALLA_IZAJE_INF    : LREAL;
    FALLA_IZAJE_SUP    : LREAL;
    FALLA_CARRO_SV     : LREAL;
END_STRUCT
END_TYPE
```

---

## Verificaciones críticas pre-test

- [ ] `UDP Read` block en `planta_codesys.slx` → `dims = 53` (no 104)
- [ ] Bug del Selector dentro de `Control Joystick` (output size 5 → 8)
- [ ] Stateflow data `m_container`, `i_sel` → declarar `Size = 1` explícito en chart Nivel 1
- [ ] Fix `From44` → `AND1` (dim mismatch en planta_codesys.slx)
- [ ] Confirmar que modelo compila (`set_param('planta_codesys','SimulationCommand','update')`)
