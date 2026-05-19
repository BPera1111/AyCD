"""
dashboard/server.py
Backend Flask + SocketIO para el dashboard de la Grúa STS.

Canales:
  - Lee crane_state.json escrito por MATLAB a 50 Hz
  - Emite 'telemetry' via SocketIO al browser
  - Recibe 'joystick' / 'button' del browser y actualiza vgamepad
"""

import json
import os
import socket
import struct
import threading
import time
from pathlib import Path

from flask import Flask, render_template, jsonify
from flask_socketio import SocketIO, emit

# ── Configuración ────────────────────────────────────────────────────────────
JSON_FILE   = Path("C:/Temp/crane_state.json")
UDP_PORT    = 5006          # Python escucha en este puerto (datos desde MATLAB)
POLL_RATE   = 0.02          # 50 Hz — tasa de lectura del JSON file
EMIT_RATE   = 0.033         # ~30 Hz — tasa de push al browser (suficiente para UI)

STATE_NAMES = {
    0: "REPOSO",
    1: "MANUAL",
    2: "MODO_AUTO",
    3: "MODO_AUTO_FULL",
    4: "RECUPERACION",
    5: "ERROR",
    6: "SUBIR_INICIAL",
    7: "IR_ORIGEN",
    8: "BAJAR_ORIGEN",
    9: "ENGANCHAR",
    10: "SUBIR_CARGADO",
    11: "IR_DESTINO",
    12: "BAJAR_DESTINO",
    13: "DESENGANCHAR",
    14: "FIN_MISION",
}

MODO_NAMES = {0: "REPOSO", 1: "MANUAL", 2: "SEMI-AUTO", 3: "AUTO FULL"}

# ── Estado global compartido ─────────────────────────────────────────────────
crane_state = {
    "xt": 5.0,
    "yh": 20.0,
    "vt": 0.0,
    "vh": 0.0,
    "freno_c": 1,
    "freno_h": 1,
    "estado": 0,
    "modo": 0,
    "tlk": 0,
    "caught": 0,
    "estado_nombre": "REPOSO",
    "modo_nombre": "REPOSO",
    "connected": False,
}
crane_lock = threading.Lock()

# ── vgamepad ─────────────────────────────────────────────────────────────────
try:
    import vgamepad as vg
    gamepad = vg.VX360Gamepad()
    VGAMEPAD_OK = True
except Exception as e:
    print(f"[WARN] vgamepad no disponible: {e}")
    gamepad = None
    VGAMEPAD_OK = False

joystick_state = {
    "lx": 0.0,
    "ry": 0.0,
    "buttons": {},
}

BUTTON_MAP = {
    "TLK":    "XUSB_GAMEPAD_A",
    "MANUAL": "XUSB_GAMEPAD_B",
    "AUTO":   "XUSB_GAMEPAD_X",
    "RESET":  "XUSB_GAMEPAD_Y",
    "EMERG":  "XUSB_GAMEPAD_BACK",
}

# ── Flask / SocketIO ─────────────────────────────────────────────────────────
app = Flask(__name__, template_folder="templates", static_folder="static")
app.config["SECRET_KEY"] = "sts-crane-secret"
socketio = SocketIO(app, cors_allowed_origins="*", async_mode="threading")


# ── Hilo: lectura del JSON file ───────────────────────────────────────────────
def _parse_and_update(text: str) -> bool:
    """Parsea JSON y actualiza crane_state. Retorna True si exitoso."""
    try:
        data = json.loads(text)
        if not isinstance(data, dict):
            return False
        with crane_lock:
            crane_state.update(data)
            crane_state["estado_nombre"] = STATE_NAMES.get(
                int(data.get("estado", 0)), f"Estado {int(data.get('estado', 0))}"
            )
            crane_state["modo_nombre"] = MODO_NAMES.get(
                int(data.get("modo", 0)), "?"
            )
            crane_state["connected"] = True
        return True
    except (json.JSONDecodeError, ValueError, TypeError):
        return False


def _file_reader():
    """Lee crane_state.json a 50 Hz y actualiza crane_state global."""
    last_mtime = 0.0
    no_file_warned = False
    # También intenta leer el archivo temporal (escritura atómica de MATLAB)
    TMP_FILE = JSON_FILE.parent / (JSON_FILE.stem + ".tmp")

    while True:
        try:
            # Preferir .tmp si es más nuevo (escritura en progreso → mejor ignorar)
            target = JSON_FILE
            if TMP_FILE.exists():
                try:
                    if TMP_FILE.stat().st_mtime > (JSON_FILE.stat().st_mtime if JSON_FILE.exists() else 0):
                        target = TMP_FILE
                except OSError:
                    pass

            if target.exists():
                try:
                    mtime = target.stat().st_mtime
                except OSError:
                    time.sleep(POLL_RATE)
                    continue

                if mtime != last_mtime:
                    last_mtime = mtime
                    try:
                        text = target.read_text(encoding="utf-8")
                        if text.strip():
                            _parse_and_update(text)
                    except (OSError, UnicodeDecodeError):
                        pass
                no_file_warned = False
            else:
                if not no_file_warned:
                    print(f"[INFO] Esperando archivo MATLAB: {JSON_FILE}")
                    no_file_warned = True
                with crane_lock:
                    crane_state["connected"] = False
        except Exception:
            pass
        time.sleep(POLL_RATE)


# ── Hilo: UDP receiver (alternativa a file reader) ────────────────────────────
def _udp_receiver():
    """Escucha paquetes UDP desde MATLAB en UDP_PORT."""
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        sock.bind(("127.0.0.1", UDP_PORT))
        sock.settimeout(1.0)
        print(f"[UDP] Escuchando en 127.0.0.1:{UDP_PORT}")
        while True:
            try:
                raw, _ = sock.recvfrom(4096)
                try:
                    data = json.loads(raw.decode("utf-8"))
                    with crane_lock:
                        crane_state.update(data)
                        crane_state["estado_nombre"] = STATE_NAMES.get(
                            int(data.get("estado", 0)), f"Estado {int(data.get('estado',0))}"
                        )
                        crane_state["modo_nombre"] = MODO_NAMES.get(
                            int(data.get("modo", 0)), "?"
                        )
                        crane_state["connected"] = True
                except (json.JSONDecodeError, UnicodeDecodeError):
                    pass
            except socket.timeout:
                pass
    except OSError as e:
        print(f"[UDP] No se pudo abrir puerto {UDP_PORT}: {e}. Usando file reader.")
    finally:
        sock.close()


# ── Hilo: emitter SocketIO ───────────────────────────────────────────────────
def _state_emitter():
    """Emite el estado de la grúa al browser a ~30 Hz."""
    while True:
        with crane_lock:
            snapshot = dict(crane_state)
        socketio.emit("telemetry", snapshot)
        time.sleep(EMIT_RATE)


# ── Actualizar vgamepad ───────────────────────────────────────────────────────
def _update_gamepad():
    if not VGAMEPAD_OK or gamepad is None:
        return
    try:
        gamepad.reset()
        gamepad.left_joystick_float(
            x_value_float=float(joystick_state["lx"]),
            y_value_float=0.0,
        )
        gamepad.right_joystick_float(
            x_value_float=0.0,
            y_value_float=float(joystick_state["ry"]),
        )
        for btn_name, active in joystick_state["buttons"].items():
            if active and btn_name in BUTTON_MAP:
                attr = BUTTON_MAP[btn_name]
                gamepad.press_button(button=getattr(vg.XUSB_BUTTON, attr))
        gamepad.update()
    except Exception as e:
        print(f"[WARN] vgamepad update: {e}")


# ── SocketIO events ───────────────────────────────────────────────────────────
@socketio.on("joystick")
def handle_joystick(data):
    """Recibe {lx: float, ry: float} desde el browser."""
    joystick_state["lx"] = max(-1.0, min(1.0, float(data.get("lx", 0.0))))
    joystick_state["ry"] = max(-1.0, min(1.0, float(data.get("ry", 0.0))))
    _update_gamepad()


@socketio.on("button")
def handle_button(data):
    """Recibe {name: str, pressed: bool} desde el browser."""
    name    = data.get("name", "")
    pressed = bool(data.get("pressed", False))
    joystick_state["buttons"][name] = pressed
    _update_gamepad()


@socketio.on("connect")
def handle_connect():
    with crane_lock:
        snapshot = dict(crane_state)
    emit("telemetry", snapshot)


# ── Rutas Flask ───────────────────────────────────────────────────────────────
@app.route("/")
def index():
    return render_template("index.html")


@app.route("/api/state")
def api_state():
    with crane_lock:
        return jsonify(crane_state)


@app.route("/api/gamepad")
def api_gamepad():
    return jsonify({"ok": VGAMEPAD_OK, "state": joystick_state})


# ── Arranque ──────────────────────────────────────────────────────────────────
def start_background_threads():
    t_file = threading.Thread(target=_file_reader, daemon=True, name="FileReader")
    t_udp  = threading.Thread(target=_udp_receiver, daemon=True, name="UDPReceiver")
    t_emit = threading.Thread(target=_state_emitter, daemon=True, name="StateEmitter")
    t_file.start()
    t_udp.start()
    t_emit.start()


if __name__ == "__main__":
    print("=" * 60)
    print("  GRÚA STS — Dashboard Backend")
    print(f"  vgamepad: {'OK' if VGAMEPAD_OK else 'NO DISPONIBLE'}")
    print(f"  JSON file: {JSON_FILE}")
    print(f"  UDP port:  {UDP_PORT}")
    print("=" * 60)
    start_background_threads()
    socketio.run(app, host="0.0.0.0", port=5000, debug=False, allow_unsafe_werkzeug=True)
