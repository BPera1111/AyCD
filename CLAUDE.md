# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Proyecto

Simulación de Grúa STS (Ship-to-Shore) para la materia Autómatas y Control Discreto — UNCUYO 2025. Combina modelos MATLAB/Simulink/Stateflow con un dashboard Python para visualización y control en tiempo real.

---

## Comandos principales

### Dashboard de simulación (reemplaza joystick.py)

```bash
# Modo con MATLAB corriendo (flujo normal):
venv\Scripts\python run_dashboard.py

# Modo de prueba sin MATLAB (verifica que el dashboard funcione):
venv\Scripts\python run_dashboard.py --sim-test

# Puerto alternativo:
venv\Scripts\python run_dashboard.py --port 8080
```

### Joystick legacy (solo control, sin visualización)

```bash
venv\Scripts\python joystick.py
```

### Instalar dependencias Python

```bash
venv\Scripts\pip install flask flask-socketio watchdog vgamepad pygame
```

### Setup MATLAB (ejecutar en orden en MATLAB)

```matlab
% 1. Parámetros (SIEMPRE primero)
cd simulink
run('init_plant_parameters.m')

% 2. Iniciar telemetría externa (no modifica el modelo)
run('telemetry_timer.m')

% 3. Abrir modelo y simular
open_system('nivel_1_full.slx')
% → Presionar Play (el timer detecta señales automáticamente)

% Para detener telemetría:
stop(crane_telemetry_timer); delete(crane_telemetry_timer)

% Explorar señales del modelo (debugging, si telemetría muestra 0s):
run('discover_signals.m')
```

---

## Modelos Simulink

| Archivo | Propósito |
|---|---|
| `simulink/planta.slx` | **Planta física completa**: dinámica de carro, izaje, spreader, contacto, LIDAR virtual — sin controlador |
| `simulink/nivel_1_full.slx` | **Modelo principal de prueba**: planta + L0 + L1 + L2 completos |
| `simulink/nivel_2.slx` | Solo capa de torque (Level 2 aislado) |
| `simulink/planta_codesys.slx` | Planta para integración con PLC CODESYS vía UDP |
| `simulink/planta_codesys_opc.slx` | Variante con OPC-UA |
| `simulink/planta_rots.slx` | Variante con rotaciones adicionales |

Al modificar `.slx` directamente, abrirlos como ZIP y editar los XML internos en `simulink/systems/` y `simulink/stateflow/`.

---

## Arquitectura de control

El sistema tiene 3 niveles de control en cascada:

| Nivel | Ts | Responsabilidad |
|---|---|---|
| **0** | 20 ms | Seguridad: watchdog, límites de posición/velocidad, freno de emergencia |
| **1** | 20 ms | Supervisión: Stateflow principal + generación de referencias de velocidad |
| **2** | 1 ms | Torque: observador Luenberger + PI trapezoidal (carro e izaje) |

### Scripts de Nivel 2

| Script | Función |
|---|---|
| `simulink/nivel2_carro.m` | MATLAB Function Block: anti-sway por ángulo de carga, observador Luenberger, PI trapezoidal con anti-windup para velocidad del carro |
| `simulink/nivel2_izaje.m` | Ídem para izaje: compensación gravitacional por masa del container, observador, PI con anti-windup |

Ganancias del observador (`k_tita`, `k_omega`, `k_i`) y del PI (`Kp`, `Ki`) definidas en `init_plant_parameters.m`.

---

## Stateflow — Estados principales (nivel 1)

La máquina de estados principal (`AUTOMATA_PRINCIPAL`, `chart_487.xml`) tiene estos estados:

```
REPOSO → MANUAL
       → MODO_AUTO → [SELECCION] → ENGANCHAR → MISION
       → MODO_AUTO_FULL → SUBIR_INICIAL → IR_ORIGEN → BAJAR_ORIGEN
                        → ENGANCHAR → SUBIR_CARGADO → IR_DESTINO
                        → BAJAR_DESTINO → DESENGANCHAR → FIN_MISION
       → RECUPERACION
       → ERROR
```

Estados paralelos: `TWISTLOCKS`, `INDICES_PERFIL`.

---

## Falso Sensor LIDAR

El LIDAR es un escáner láser 1D **simulado** (no hardware real) montado 3 m adelante del carro. A medida que el carro se mueve, escanea el perfil de obstáculos debajo (containers en el barco o en el muelle).

### Variables clave (`init_plant_parameters.m`)

| Variable | Valor | Descripción |
|---|---|---|
| `x_LIDAR` | 3 m | Offset del sensor adelante del centro del carro |
| `N_xt` | 33 | Cantidad de celdas del perfil de obstáculos |
| `Wc` | 2.44 m | Ancho de container ISO = resolución espacial del perfil |
| `yc0_vec` | vector 33×1 | Altura de obstáculo medida en cada celda [m] |
| `is_scanned_vec` | vector 33×1 binario | `1` = celda ya escaneada por el LIDAR |
| `i_lidar` | entero [1,33] | Índice de celda activa (calculado en Stateflow) |

### Fórmula de índice (Stateflow `chart_487.xml`)

```matlab
i_lidar = floor((xt_enc + x_LIDAR - xt_min) / Wc) + 1;
% Clamped a [1, N_xt]
```

En cada paso de simulación: `yc0_vec(i_lidar)` ← lectura actual; `is_scanned_vec(i_lidar) = 1`.

### Integración con modo automático

El modo automático (`MODO_AUTO_FULL`) **no puede ejecutar** una trayectoria hasta verificar que todos los índices del camino tengan `is_scanned_vec = 1`. Si alguna celda no fue escaneada, requiere pasada previa manual o semi-automática. `yc0_vec` completo se transmite por UDP al dashboard y se visualiza como perfil de obstáculos en tiempo real.

---

## Comunicación Python ↔ MATLAB

### MATLAB → Python (UDP binario, puerto 1234)

`planta.slx` y `nivel_1_full.slx` envían paquetes UDP binarios (doubles de 64 bits) a 50 Hz:
- 28 señales de telemetría de planta (posiciones, velocidades, frenos, estado)
- 33 doubles del perfil `yc0_vec`

`dashboard/server.py` los parsea en `udp_receiver_thread()` y los emite al browser vía SocketIO a 30 Hz.

Fallback: `crane_state.json` en `C:\Temp\` con campos `xt, yh, vt, vh, freno_c, freno_h, estado, modo, tlk, caught`.

### Python → MATLAB (gamepad virtual)

`vgamepad.VX360Gamepad()` emula Xbox 360. Simulink lee:
- Eje [1] (LX): joystick izquierdo X → `Joy_CMD_X` → velocidad carro
- Eje [5] (RY, gain -1): joystick derecho Y → `Joy_CMD_Y` → velocidad izaje
- Botones: A=TLK, B=MANUAL, X=AUTO, Y=RESET, Back=EMERG

---

## Variables físicas clave

| Variable | Descripción | Valor/Rango |
|---|---|---|
| `xt` | Posición carro [m] | [-30, 50] |
| `yh` | Posición izaje [m] | [-20, 40] |
| `Yt0` | Altura poleas [m] | 45 (fijo) |
| `Ms` | Masa spreader [kg] | 15 000 (fijo) |
| `Mc_max / Mc_min` | Masa container [kg] | 50 000 / 2 000 |
| `Mt` | Masa equivalente carro [kg] | 30 000 |
| `Hc` | Altura container ISO [m] | 2.59 (fijo) |
| `Wc` | Ancho container ISO [m] | 2.44 (fijo) |
| `vt_max / vh_max` | Velocidades máx. [m/s] | 4 / 3 |
| `at_max / ah_max` | Aceleraciones máx. [m/s²] | 0.80 / 0.75 |

---

## Integración CODESYS

`codesys/` contiene proyecto CODESYS 3.5 con PLC virtual que recibe la planta vía UDP:
- `CONTROL_SEGURIDAD` (L0) y `CONTROL_SUPERVISOR` (L1) son stubs por ahora
- Usar `planta_codesys.slx` como planta en MATLAB, no `nivel_1_full.slx`
- Ver `codesys/README.md` para setup completo (DUT structs, GVL, task config)

---

## Invariantes críticos de Stateflow XML

Al modificar `.slx` directamente como ZIP+XML:

1. En `<Children>` de un estado: primero `<state>`, luego `<transition>`, luego `<junction>`.
2. Las transiciones van dentro del `<Children>` del estado padre.
3. Variables de datos van al final del `<Children>` del chart raíz.
4. El atributo `<P Name="subviewer">` apunta al ID del Chart (ej. `180`), no al estado padre.

---

## Estructura de archivos relevante

```
simulink/
  planta.slx                ← planta física completa (sin controlador)
  nivel_1_full.slx          ← modelo principal de prueba (planta + L0+L1+L2)
  init_plant_parameters.m   ← SIEMPRE correr antes de simular
  nivel2_carro.m            ← MATLAB Function Block: control L2 carro
  nivel2_izaje.m            ← MATLAB Function Block: control L2 izaje
  add_telemetry.m           ← setup one-shot: agrega bloque UDP writer
  discover_signals.m        ← lista señales disponibles en el modelo
  build_auto_full.m         ← construye el modo automático completo
  agregar_modo_auto.m       ← agrega modo semi-automático

dashboard/
  server.py                 ← backend Flask + SocketIO + UDP receiver
  templates/index.html      ← UI web
  static/crane.js           ← canvas 2D animación grúa
  static/dashboard.js       ← charts + joystick virtual
  static/style.css          ← estilos dark mode

codesys/                    ← proyecto CODESYS 3.5 (PLC virtual)
run_dashboard.py            ← entrypoint dashboard
joystick.py                 ← control legacy (solo vgamepad, sin visualización)
```

---

## ViGEm (vgamepad)

`vgamepad` requiere el **ViGEm Bus Driver** instalado en Windows. Si no está instalado, el dashboard funciona igual pero el joystick virtual no llega a MATLAB. Descargar desde: https://github.com/ViGEm/ViGEmBus/releases
