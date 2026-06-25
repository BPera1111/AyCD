# Proyecto CODESYS — Control PLC Grúa STS

Reemplaza los Niveles 0 y 1 del modelo Simulink `simulink/planta.slx` con un PLC CODESYS 3.5 que se comunica por UDP con `simulink/planta_codesys.slx`.

## Arquitectura

```
┌────────────────────────┐                  ┌──────────────────────────┐
│ simulink/              │   UDP 25000 →    │ codesys/control_planta   │
│ planta_codesys.slx     │ ←─ UDP 25001     │  ├─ Task_RX (20ms)       │
│                        │                  │  │  └─ PRG_RX            │
│  Plant + Joystick      │                  │  ├─ Task_Seguridad (20ms)│
│  + UDP Read/Send       │                  │  │  └─ PRG_SEGURIDAD     │
└────────────────────────┘                  │  ├─ Task_Supervisor (20ms)│
                                            │  │  └─ PRG_SUPERVISOR    │
                                            │  └─ Task_TX (20ms)       │
                                            │     └─ PRG_TX            │
                                            └──────────────────────────┘
```

## Estructura `src/`

```
src/
├─ DUTs/
│  ├─ T_UDP_TX_FROM_SIM.st    # Struct paquete Simulink → PLC (31 LREAL)
│  └─ T_UDP_RX_TO_SIM.st      # Struct paquete PLC → Simulink (53 LREAL)
├─ GVLs/
│  ├─ GVL_PARAMS.st           # Constantes físicas
│  ├─ GVL_PROCESS.st          # Señales compartidas L0 ↔ L1
│  └─ GVL_COMMS.st            # Buffers UDP
└─ POUs/
   ├─ COM_UDP_RX.st           # FB recepción UDP
   ├─ COM_UDP_TX.st           # FB envío UDP
   ├─ CONTROL_SEGURIDAD.st    # FB Nivel 0 (stub — completar lógica)
   ├─ CONTROL_SUPERVISOR.st   # FB Nivel 1 (stub — completar lógica)
   ├─ PRG_RX.st               # Programa para Task_RX
   ├─ PRG_TX.st               # Programa para Task_TX
   ├─ PRG_SEGURIDAD.st        # Programa para Task_Seguridad
   └─ PRG_SUPERVISOR.st       # Programa para Task_Supervisor
```

## Setup CODESYS IDE

### 1. Crear proyecto vacío

1. Abrir `C:\Program Files\CODESYS 3.5.21.60\CODESYS\Common\CODESYS.exe`
2. `File → New Project → Standard Project`
3. Path: `codesys/control_planta.project`
4. Device: `CODESYS Control Win V3 x64`
5. PLC_PRG: lenguaje `ST` (después se elimina, no se usa)

### 2. Agregar librerías

Library Manager → `Add Library`:
- `SysSocket` (para UDP)
- `SysMem` (para SysMemCpy)
- `Standard` (incluida por defecto)

### 3. Importar DUTs

`Application → Add Object → DUT`:
- `T_UDP_TX_FROM_SIM` → copiar contenido de `src/DUTs/T_UDP_TX_FROM_SIM.st`
- `T_UDP_RX_TO_SIM` → copiar contenido de `src/DUTs/T_UDP_RX_TO_SIM.st`

### 4. Importar GVLs

`Application → Add Object → Global Variable List`:
- `GVL_PARAMS`, `GVL_PROCESS`, `GVL_COMMS` → copiar contenido respectivo

### 5. Importar POUs

`Application → Add Object → POU`:

| Nombre | Tipo | Lenguaje | Archivo |
|--------|------|----------|---------|
| `COM_UDP_RX` | Function Block | ST | `src/POUs/COM_UDP_RX.st` |
| `COM_UDP_TX` | Function Block | ST | `src/POUs/COM_UDP_TX.st` |
| `CONTROL_SEGURIDAD` | Function Block | ST | `src/POUs/CONTROL_SEGURIDAD.st` |
| `CONTROL_SUPERVISOR` | Function Block | ST | `src/POUs/CONTROL_SUPERVISOR.st` |
| `PRG_RX` | Program | ST | `src/POUs/PRG_RX.st` |
| `PRG_TX` | Program | ST | `src/POUs/PRG_TX.st` |
| `PRG_SEGURIDAD` | Program | ST | `src/POUs/PRG_SEGURIDAD.st` |
| `PRG_SUPERVISOR` | Program | ST | `src/POUs/PRG_SUPERVISOR.st` |

Para cada uno: copiar contenido del `.st` correspondiente. Eliminar el `PLC_PRG` autogenerado (no se usa).

### 6. Configurar Task Configuration

`Application → Task Configuration → Add Object → Task`:

| Task | Tipo | Intervalo | Prioridad | POU |
|------|------|-----------|-----------|-----|
| Task_RX | Cyclic | T#20ms | 1 | PRG_RX |
| Task_Seguridad | Cyclic | T#20ms | 2 | PRG_SEGURIDAD |
| Task_Supervisor | Cyclic | T#20ms | 3 | PRG_SUPERVISOR |
| Task_TX | Cyclic | T#20ms | 4 | PRG_TX |

Orden RX → Seguridad → Supervisor → TX garantiza flujo determinístico (datos frescos cada ciclo).

### 7. Symbol Configuration (opcional, para OPC UA)

`Application → Add Object → Symbol Configuration` → tildar `Support OPC UA features`.

Exponer las variables de `GVL_PROCESS` y `GVL_COMMS` para monitoreo externo.

## Compilar y correr

1. `Build → Generate Code` (F11)
2. `Online → Login` (Alt+F8) → seleccionar `Control Win V3` (tray icon → Start PLC)
3. `Debug → Start` (F5)

## Verificación end-to-end

**Pre-requisitos**:
- `simulink/planta_codesys.slx` con UDP Read `dims=53` (corregir si está en 104)
- Bug del Selector dentro de `Control Joystick` resuelto
- Stateflow data `m_container`, `i_sel` con `Size = 1` explícito

**Tests** (ver `UDP_PACKET_SPEC.md` para detalle):

| Test | Procedimiento | Criterio |
|------|---------------|----------|
| Heartbeat | Watch `GVL_PROCESS.heartbeat_L1` | Toggle 0↔1 cada 20 ms |
| UDP loop | Correr `planta_codesys.slx` en MATLAB | `GVL_COMMS.udp_rx_count` aumenta |
| BTN_Emerg | Apretar BTN_EMERG | `FALLA_MAN_L0 = TRUE`, brakes = 0 |
| Watchdog | Detener simulación Sim | `FALLA_WD_L0 = TRUE` en < 300 ms |
| Modo manual | BTN_ON_OFF + mover joystick | `vx_suave, vy_suave` no cero |
| Auto | BTN_Auto | Estado L1 transita por sub_auto |
| TLK | BTN_TLK | `twistlock`: VACIO → CARGADO |

## Estado actual del código

| Componente | Estado |
|------------|--------|
| DUTs (paquetes UDP) | ✅ Completo según spec |
| GVL_PARAMS | ✅ Completo (espejo de init_plant_parameters.m) |
| GVL_PROCESS, GVL_COMMS | ✅ Completo |
| COM_UDP_RX, COM_UDP_TX | ✅ Funcional con SysSocket |
| CONTROL_SEGURIDAD (L0) | ⚠️ **STUB** — replicar transiciones exactas del chart Stateflow `planta/Nivel 0` |
| CONTROL_SUPERVISOR (L1) | ⚠️ **STUB** — replicar transiciones exactas del chart Stateflow `planta/Nivel 1` |
| PRG_* (orquestadores) | ✅ Completo |

## Próximos pasos

1. Importar todo en CODESYS IDE (instrucciones arriba).
2. Compilar — corregir errores de sintaxis específicos del runtime (algunos nombres de funciones SysSocket pueden variar entre versiones).
3. **Replicar lógica completa** de los charts Stateflow `Nivel 0` y `Nivel 1` dentro de `CONTROL_SEGURIDAD` y `CONTROL_SUPERVISOR`:
   - Abrir cada chart en Simulink, exportar transiciones
   - Traducir cada `state → state` con guardas a `IF` dentro del `CASE`
4. Ejecutar tests progresivos según tabla.
