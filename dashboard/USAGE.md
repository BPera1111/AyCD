# Manual de uso — Dashboard Grúa STS

## TL;DR

```bash
# Test rápido sin MATLAB (recomendado primera vez):
venv\Scripts\python run_dashboard.py --sim-test

# Flujo normal (con MATLAB):
# 1. En MATLAB:   run('simulink/init_plant_parameters.m'); open_system('simulink/nivel_1_full.slx'); sim('nivel_1_full');
# 2. En terminal: venv\Scripts\python run_dashboard.py
```

Browser abre solo en `http://localhost:5000`.

---

## 1. Primera vez — verificar que el dashboard funciona (sin MATLAB)

```bash
venv\Scripts\python run_dashboard.py --sim-test
```

Esto inyecta datos sintéticos animados. Si el browser muestra:
- Grúa moviéndose en el canvas
- Charts de posición/velocidad actualizándose
- Estado Stateflow cambiando (REPOSO → MANUAL → IR_ORIGEN → ...)
- Joystick virtual responde al mouse

→ Frontend OK. Pasar al paso 2.

---

## 2. Setup MATLAB (una sola vez)

En MATLAB, desde el directorio del proyecto:

```matlab
cd simulink

% 2.1 — Iniciar timer de telemetría externa (no modifica el modelo)
run('telemetry_timer.m')

% 2.2 — Abrir modelo y simular
open_system('nivel_1_full.slx')
% → Presionar Play. El timer detecta las señales automáticamente y escribe el JSON.
```

El script `telemetry_timer.m` **no modifica `nivel_1_full.slx`**. Busca señales por nombre en el modelo en ejecución vía `RuntimeObject`. Si alguna señal no tiene nombre en el modelo, la reporta en consola (queda en 0) y podés usar `discover_signals.m` para ver qué hay disponible.

Para detener la telemetría sin cerrar MATLAB:

```matlab
stop(crane_telemetry_timer); delete(crane_telemetry_timer)
```

> **Alternativa (invasiva):** `add_telemetry.m` agrega un bloque dentro del modelo para casos donde las señales no tienen nombre y `RuntimeObject` no alcanza. No es necesario si las señales ya están nombradas.

---

## 3. Flujo normal de prueba

**Terminal 1 — Dashboard:**
```bash
venv\Scripts\python run_dashboard.py
```
Espera datos en `C:\Temp\crane_state.json`. Browser abre en `http://localhost:5000`.

**MATLAB — Simulación:**
```matlab
cd simulink
run('telemetry_timer.m')          % inicia timer externo (una vez)
open_system('nivel_1_full.slx')
% → Presionar Play
```

Cuando MATLAB empieza a simular, dashboard muestra:
- Posición real del carro y spreader (animación 2D)
- Charts de xt, yh, vt, vh en tiempo real
- Estado actual de Stateflow (REPOSO / MANUAL / etc.)
- LEDs de frenos (rojo = engranado), TLK, container enganchado

---

## 4. Control desde el browser

| Elemento | Acción | MATLAB recibe |
|---|---|---|
| Joystick CARRO (izq) | Drag mouse horizontal | `Joy_CMD_X` (eje 1, LX) |
| Joystick IZAJE (der) | Drag mouse vertical   | `Joy_CMD_Y` (eje 5, RY * -1) |
| Botón MANUAL | Click sostenido | botón B (Demux idx 2) |
| Botón AUTO   | Click sostenido | botón X (Demux idx 3) |
| Botón TLK    | Click sostenido | botón A (Demux idx 1) |
| Botón RESET  | Click sostenido | botón Y (Demux idx 4) |
| Botón EMERG  | Click sostenido | botón Back (Demux idx 7) |

Joystick vuelve al centro cuando soltás. Botones se desactivan al soltar.

**Requisito:** ViGEm Bus Driver instalado (https://github.com/ViGEm/ViGEmBus/releases). Sin ViGEm, joystick virtual no llega a MATLAB. Dashboard sigue mostrando datos OK.

---

## 5. Opciones de línea de comandos

```bash
# Puerto alternativo (default 5000):
python run_dashboard.py --port 8080

# No abrir browser automáticamente:
python run_dashboard.py --no-browser

# Modo test sin MATLAB:
python run_dashboard.py --sim-test

# Combinaciones:
python run_dashboard.py --sim-test --port 5001 --no-browser
```

---

## 6. Verificación del estado del sistema

| Indicador en UI | Significado |
|---|---|
| Badge `MATLAB OK` (verde) | Recibiendo datos del JSON file |
| Badge `SIN DATOS` (rojo) | No hay datos — MATLAB no corre o `add_telemetry.m` no se ejecutó |
| `ViGEm: OK` | Joystick virtual funciona, MATLAB lo ve |
| `ViGEm: no disponible` | Falta driver. Instalar ViGEm |
| FPS counter (top-right) | Debería mostrar ~30 Hz cuando MATLAB envía datos |

---

## 7. Troubleshooting

### "SIN DATOS" persistente
- Verificar archivo: `dir C:\Temp\crane_state.json`. Si no existe, MATLAB no escribió. Correr `add_telemetry.m`.
- Verificar que la simulación está corriendo (no pausada) en MATLAB.
- Si bloque `UDP_Telemetry` no está conectado a señales válidas, no escribe nada.

### Charts no actualizan
- Recargar browser (F5).
- Verificar consola del browser (F12) por errores JS.
- WebSocket bloqueado por firewall? Probar `--port 8080`.

### Joystick virtual no controla MATLAB
- Verificar `ViGEm: OK` en panel.
- Si no, instalar ViGEm Bus Driver y reiniciar PC.
- En MATLAB, verificar que el bloque Joystick lee del controlador correcto (puede haber varios si hay otros gamepads conectados).

### Puerto 5000 ocupado
```bash
python run_dashboard.py --port 5001
```

### Cambios en HTML/JS no aparecen
- Hard refresh: Ctrl+Shift+R (limpia cache).
- Reiniciar `run_dashboard.py`.

---

## 8. Arquitectura (referencia rápida)

```
nivel_1_full.slx (MATLAB)
  └── bloque UDP_Telemetry escribe C:\Temp\crane_state.json (50 Hz, atómico via .tmp+rename)
       └── server.py lee el JSON (50 Hz)
            ├── SocketIO push al browser (30 Hz)
            └── recibe joystick del browser → vgamepad → MATLAB
```

Variables transmitidas en JSON: `xt, yh, vt, vh, freno_c, freno_h, estado, modo, tlk, caught`.

Estados Stateflow mapeados (en `server.py` STATE_NAMES): 0=REPOSO, 1=MANUAL, 2=MODO_AUTO, 3=MODO_AUTO_FULL, 4=RECUPERACION, 5=ERROR, 6-14=sub-estados de mision automatica.

---

## 9. Volver al control legacy (sin dashboard)

```bash
venv\Scripts\python joystick.py
```

`joystick.py` no se borró. Sigue funcionando exactamente como antes.
