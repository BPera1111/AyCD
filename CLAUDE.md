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
% 1. Iniciar telemetría externa (no modifica el modelo)
cd simulink
run('telemetry_timer.m')

% 2. Abrir modelo y simular
open_system('nivel_1_full.slx')
% → Presionar Play (el timer detecta señales automáticamente)

% Para detener telemetría:
stop(crane_telemetry_timer); delete(crane_telemetry_timer)

% Explorar señales del modelo (debugging, si telemetría muestra 0s):
run('discover_signals.m')
```

---

## Arquitectura de control

El sistema tiene 3 niveles de control en cascada:

| Nivel | Ts | Responsabilidad |
|---|---|---|
| **0** | 20 ms | Seguridad: watchdog, límites de posición/velocidad, freno de emergencia |
| **1** | 20 ms | Supervisión: Stateflow principal + control PI de velocidad |
| **2** | 1 ms | Torque: modulación del torque del motor (carro e izaje) |

Los modelos son:
- `simulink/nivel_1_full.slx` → modelo principal usado para pruebas (L1 + L2 + L0)
- `simulink/nivel_2.slx` → solo capa de torque
- `simulink/planta_completa.slx` → planta física sin controlador

---

## Stateflow — Estados principales (nivel 1)

La máquina de estados principal (`AUTOMATA_PRINCIPAL`) tiene estos estados:

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

## Comunicación Python ↔ MATLAB

```
MATLAB (nivel_1_full.slx)
  └── MATLAB Function block "UDP_Telemetry"
       └── Escribe C:\Temp\crane_state.json a 50 Hz
           └── dashboard/server.py  (lee JSON, 50 Hz)
               ├── SocketIO → Browser (30 Hz)
               └── vgamepad → MATLAB Joystick block
```

**Python → MATLAB**: `vgamepad.VX360Gamepad()` emula un Xbox 360. Simulink lee:
- Eje [1] (LX): posición joystick izquierdo X → `Joy_CMD_X` → velocidad carro
- Eje [5] (RY, gain -1): joystick derecho Y → `Joy_CMD_Y` → velocidad izaje
- Botones: A=TLK, B=MANUAL, X=AUTO, Y=RESET, Back=EMERG

**MATLAB → Python**: `crane_state.json` con campos `xt, yh, vt, vh, freno_c, freno_h, estado, modo, tlk, caught`.

---

## Variables físicas clave

| Variable | Descripción | Rango |
|---|---|---|
| `xt` | Posición carro [m] | [-30, 50] |
| `yh` | Posición izaje [m] | [-20, 40] |
| `Yt0 = 45` | Altura poleas [m] | fijo |
| `Ms = 15000` | Masa spreader [kg] | fijo |
| `Mc_max = 50000` | Masa container máx. [kg] | variable |
| `Hc = 2.59` | Altura container ISO [m] | fijo |
| `Wc = 2.44` | Ancho container ISO [m] | fijo |

---

## Invariantes críticos de Stateflow XML

Al modificar `.slx` directamente como ZIP+XML (ver `crear_nivel1_claude.py`):

1. En `<Children>` de un estado: primero `<state>`, luego `<transition>`, luego `<junction>`.
2. Las transiciones van dentro del `<Children>` del estado padre.
3. Variables de datos van al final del `<Children>` del chart raíz.
4. El atributo `<P Name="subviewer">` apunta al ID del Chart (ej. `180`), no al estado padre.

---

## Estructura de archivos relevante

```
simulink/
  nivel_1_full.slx          ← modelo principal de prueba
  init_plant_parameters.m   ← SIEMPRE correr antes de simular
  add_telemetry.m           ← setup one-shot: agrega bloque JSON writer
  discover_signals.m        ← lista señales disponibles en el modelo
  build_auto_full.m         ← construye el modo automático completo
  agregar_modo_auto.m       ← agrega modo semi-automático

dashboard/
  server.py                 ← backend Flask + SocketIO
  templates/index.html      ← UI web
  static/crane.js           ← canvas 2D animación grúa
  static/dashboard.js       ← charts + joystick virtual
  static/style.css          ← estilos dark mode

run_dashboard.py            ← entrypoint (reemplaza joystick.py)
joystick.py                 ← control legacy (solo vgamepad, sin visualización)
```

---

## ViGEm (vgamepad)

`vgamepad` requiere el **ViGEm Bus Driver** instalado en Windows. Si no está instalado, el dashboard funciona igual pero el joystick virtual no llega a MATLAB. Descargar desde: https://github.com/ViGEm/ViGEmBus/releases
