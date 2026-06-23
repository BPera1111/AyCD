"""
dashboard/server.py
Backend Flask + SocketIO para el dashboard de la Grúa STS.

Canales:
  - Escucha paquetes UDP binarios (doubles) desde MATLAB en puerto 1234
  - Emite 'telemetry' via SocketIO al browser a ~30 Hz
  - Recibe 'joystick' / 'button' del browser y actualiza vgamepad

UDP_SIGNAL_MAP: lista donde índice i = posición en el Mux de planta.slx.
  *** COMPLETAR con el orden real del archivo audit_planta_output.txt ***
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
UDP_PORT    = 1234          # Puerto del UDP Send de planta.slx
POLL_RATE   = 0.02          # 50 Hz — tasa de lectura del JSON file (fallback)
EMIT_RATE   = 0.033         # ~30 Hz — tasa de push al browser

# Mapa de señales UDP — orden real según audit_planta_output.txt (planta/Mux1, 27 señales)
# NOTA: in[1] e in[5] son ambos yh (error de cableado en planta.slx — in[5] debería ser xt)
UDP_SIGNAL_MAP = [
    'yh',              # [0]  in[1]  posición izaje [m]
    'vt',              # [1]  in[2]  velocidad carro vt_obs [m/s]
    'freno_c',         # [2]  in[3]  BRK_t_N1 — freno carro Nivel 1
    'freno_c_n0',      # [3]  in[4]  BRK_t_N0 — freno carro Nivel 0
    'xt',              # [4]  in[5]  *** CABLEADO INCORRECTO: recibe yh en vez de xt ***
    'vh',              # [5]  in[6]  velocidad izaje vh_obs [m/s]
    'tlk',             # [6]  in[7]  TLK — twistlock
    'm_container',     # [7]  in[8]  masa container [kg] (>0 = hay container)
    'FC_der',          # [8]  in[9]  fin de carrera derecho
    'FC_inf',          # [9]  in[10] fin de carrera inferior
    'FC_izq',          # [10] in[11] fin de carrera izquierdo
    'FC_sup',          # [11] in[12] fin de carrera superior
    'FALLA_CARRO_DER', # [12] in[13]
    'FALLA_CARRO_IZQ', # [13] in[14]
    'FALLA_IZAJE_INF', # [14] in[15]
    'FALLA_IZAJE_SUP', # [15] in[16]
    'FALLA_IZAJE_SV',  # [16] in[17]
    'FALLA_MAN',       # [17] in[18]
    'FALLA_WD',        # [18] in[19]
    'FALLA_CARRO_SV',  # [19] in[20]
    'i_sel',           # [20] in[21] índice perfil seleccionado
    'modo_muerto',     # [21] in[22]
    'recuperacion',    # [22] in[23]
    'modo_auto',       # [23] in[24]
    'modo_manual',     # [24] in[25]
    'modo_manual_auto',# [25] in[26]
    'modo_reposo',     # [26] in[27]
    'tita_l',          # [27] in[28] ángulo péndulo cable [rad]
]

# ── Estado global compartido ─────────────────────────────────────────────────
crane_state = {
    # Físicas
    'xt': 5.0, 'yh': 20.0, 'vt': 0.0, 'vh': 0.0, 'tita_l': 0.0,
    # Modos
    'modo_reposo': 1, 'modo_manual': 0, 'modo_auto': 0,
    'modo_manual_auto': 0, 'recuperacion': 0, 'modo_muerto': 0, 'modo_error': 0,
    # Actuadores / frenos (sentido invertido: 1=liberado, 0=activo)
    'freno_c': 1, 'freno_c_n0': 1, 'freno_h_n1': 1, 'freno_h_n0': 1,
    'tlk': 0, 'hay_container': 0, 'm_container': 0.0, 'm_container_est': 0.0, 'i_sel': 0,
    # Fallas
    'FALLA_MAN': 0, 'FALLA_WD': 0, 'FALLA_CARRO_DER': 0, 'FALLA_CARRO_IZQ': 0,
    'FALLA_IZAJE_INF': 0, 'FALLA_IZAJE_SUP': 0, 'FALLA_IZAJE_SV': 0, 'FALLA_CARRO_SV': 0,
    'FALLA_SOBRECARGA': 0,
    # Fines de carrera
    'FC_der': 0, 'FC_izq': 0, 'FC_sup': 0, 'FC_inf': 0,
    # Fines de carrera emergencia
    'FCE_der': 0, 'FCE_izq': 0, 'FCE_sup': 0, 'FCE_inf': 0,
    # Perfil de obstáculos (metros, 33 columnas de xt_min a xt_max)
    'yc0_vec':     [0.0] * 33,
    'yc0_est_vec': [0.0] * 33,
    'count_vec':   [0.0] * 33,
    'scan_h_vec':  [0.0] * 328,
    'scan': 0,
    'i_li': 0,
    'reading': 0.0,
    '_udp_n': 0,   # debug: cantidad de doubles en último paquete UDP
    't_sim': 0.0,  # tiempo de simulación [s] — Clock Mux input 39
    'ciclo_doble': 0, 'i_origen': 0, 'i_destino': 0, 'l_h': 0.0,
    # Derivados
    'modo_nombre': 'REPOSO',
    'any_falla': False,
    'connected': False,
}
crane_lock = threading.Lock()
_udp_last_rx = [0.0]   # [0] = time.time() de último paquete recibido (servidor)

_FALLA_KEYS = [
    'FALLA_MAN', 'FALLA_WD', 'FALLA_CARRO_DER', 'FALLA_CARRO_IZQ',
    'FALLA_IZAJE_INF', 'FALLA_IZAJE_SUP', 'FALLA_IZAJE_SV', 'FALLA_CARRO_SV',
    'FALLA_SOBRECARGA',
]


def _derive_mode_state():
    """Actualiza campos derivados a partir de los valores UDP. Llamar dentro del lock."""
    # Modo nombre desde flags booleanos
    if crane_state['modo_muerto']:
        crane_state['modo_nombre'] = 'MODO MUERTO'
    elif crane_state['recuperacion']:
        crane_state['modo_nombre'] = 'RECUPERACION'
    elif crane_state['modo_error']:
        crane_state['modo_nombre'] = 'ERROR'
    elif crane_state['ciclo_doble']:
        crane_state['modo_nombre'] = 'CICLO DOBLE'
    elif crane_state['modo_manual_auto']:
        crane_state['modo_nombre'] = 'MANUAL→AUTO'
    elif crane_state['modo_auto']:
        crane_state['modo_nombre'] = 'AUTO FULL'
    elif crane_state['modo_manual']:
        crane_state['modo_nombre'] = 'MANUAL'
    else:
        crane_state['modo_nombre'] = 'REPOSO'
    # hay_container derivado de masa > 0
    crane_state['hay_container'] = 1 if crane_state['m_container'] > 0 else 0
    crane_state['any_falla'] = any(crane_state[f] for f in _FALLA_KEYS)


# ── vgamepad ─────────────────────────────────────────────────────────────────
try:
    import vgamepad as vg
    gamepad = vg.VX360Gamepad()
    VGAMEPAD_OK = True
except Exception as e:
    print(f"[WARN] vgamepad no disponible: {e}")
    gamepad = None
    VGAMEPAD_OK = False

joystick_state = {"lx": 0.0, "ry": 0.0, "buttons": {}}

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
try:
    import eventlet
    eventlet.monkey_patch()
    _async_mode = "eventlet"
except ImportError:
    _async_mode = "threading"

socketio = SocketIO(app, cors_allowed_origins="*", async_mode=_async_mode)


# ── Hilo: UDP receiver — parsea doubles binarios de MATLAB ───────────────────
def _udp_receiver():
    """Escucha paquetes UDP binarios (doubles) desde planta.slx en UDP_PORT."""
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        sock.bind(("0.0.0.0", UDP_PORT))
        sock.settimeout(1.0)
        print(f"[UDP] Escuchando en 0.0.0.0:{UDP_PORT} (binario doubles)")
        while True:
            try:
                raw, _ = sock.recvfrom(65536)
                N = len(raw) // 8
                if N == 0:
                    continue
                values = struct.unpack(f'{N}d', raw[:N * 8])
                _udp_last_rx[0] = time.time()
                with crane_lock:
                    crane_state['_udp_n'] = N
                    for i, name in enumerate(UDP_SIGNAL_MAP):
                        if i < N:
                            crane_state[name] = float(values[i])
                    # yc0_vec: 33 doubles a continuación de UDP_SIGNAL_MAP
                    yc0_start = len(UDP_SIGNAL_MAP)
                    if N >= yc0_start + 33:
                        crane_state['yc0_vec'] = [float(values[yc0_start + j]) for j in range(33)]
                    # modo_error: Mux input 30, después de yc0_vec (índice 61)
                    modo_error_idx = yc0_start + 33
                    if N > modo_error_idx:
                        crane_state['modo_error'] = float(values[modo_error_idx])
                    # FALLA_SOBRECARGA: Mux input 31 (índice 62)
                    sobrecarga_idx = modo_error_idx + 1
                    if N > sobrecarga_idx:
                        crane_state['FALLA_SOBRECARGA'] = float(values[sobrecarga_idx])
                    # m_container_est: Mux input 32 (índice 63) — señal en unidades ×100, escalar a kg
                    m_est_idx = sobrecarga_idx + 1
                    if N > m_est_idx:
                        crane_state['m_container_est'] = float(values[m_est_idx]) * 100
                    # freno_h_n0: Mux input 33 (índice 64) — freno emergencia izaje nivel 0
                    freno_h_n0_idx = m_est_idx + 1
                    if N > freno_h_n0_idx:
                        crane_state['freno_h_n0'] = float(values[freno_h_n0_idx])
                    # freno_h_n1: Mux input 34 (índice 65) — freno izaje nivel 1
                    freno_h_n1_idx = freno_h_n0_idx + 1
                    if N > freno_h_n1_idx:
                        crane_state['freno_h_n1'] = float(values[freno_h_n1_idx])
                    # FCE: Mux inputs 35-38 (índices 66-69) — fines de carrera emergencia
                    for j, key in enumerate(['FCE_der', 'FCE_inf', 'FCE_izq', 'FCE_sup']):
                        idx = freno_h_n1_idx + 1 + j
                        if N > idx:
                            crane_state[key] = float(values[idx])
                    # t_sim: Clock Mux input 39 (índice 70)
                    t_sim_idx = freno_h_n1_idx + 5
                    if N > t_sim_idx:
                        crane_state['t_sim'] = float(values[t_sim_idx])
                    # ciclo_doble, i_destino, i_origen: Mux inputs 40-42 (índices 71-73)
                    for j, key in enumerate(['ciclo_doble', 'i_destino', 'i_origen']):
                        idx = t_sim_idx + 1 + j
                        if N > idx:
                            crane_state[key] = float(values[idx])
                    # l_h: longitud cable [m] — Mux input 43 (índice 74)
                    l_h_idx = t_sim_idx + 4
                    if N > l_h_idx:
                        crane_state['l_h'] = float(values[l_h_idx])
                    # i_li: índice LIDAR actual (índice 75)
                    i_li_idx = l_h_idx + 1
                    if N > i_li_idx:
                        crane_state['i_li'] = float(values[i_li_idx])
                    # reading: medición ruidosa instantánea (índice 76)
                    reading_idx = i_li_idx + 1
                    if N > reading_idx:
                        crane_state['reading'] = float(values[reading_idx])
                    # count_vec: 33 doubles (índices 77-109)
                    count_start = reading_idx + 1
                    if N > count_start:
                        n_count = min(33, N - count_start)
                        crane_state['count_vec'] = [float(values[count_start + j]) for j in range(n_count)] + [0.0] * (33 - n_count)
                    # yc0_est_vec: 33 doubles (índices 110-142)
                    est_start = count_start + 33
                    if N > est_start:
                        n_est = min(33, N - est_start)
                        crane_state['yc0_est_vec'] = [float(values[est_start + j]) for j in range(n_est)] + [0.0] * (33 - n_est)
                    # scan_h_vec: 328 doubles a 0.244m (índices 143-470)
                    scan_start = est_start + 33
                    if N > scan_start:
                        n_scan = min(328, N - scan_start)
                        crane_state['scan_h_vec'] = [float(values[scan_start + j]) for j in range(n_scan)] + [0.0] * (328 - n_scan)
                    # scan: último double del paquete — 1 cuando scan LIDAR completo
                    crane_state['scan'] = int(float(values[N - 1]))
                    crane_state['connected'] = True
                    _derive_mode_state()
            except socket.timeout:
                pass
    except OSError as e:
        print(f"[UDP] No se pudo abrir puerto {UDP_PORT}: {e}. Usando file reader.")
    finally:
        sock.close()


def _connection_watchdog():
    """Marca connected=False si no llega UDP en 2s."""
    while True:
        time.sleep(0.5)
        if _udp_last_rx[0] > 0 and (time.time() - _udp_last_rx[0]) > 2.0:
            with crane_lock:
                crane_state['connected'] = False


# ── Hilo: lectura del JSON file (fallback / modo --sim-test) ─────────────────
def _parse_and_update_json(text: str) -> bool:
    try:
        data = json.loads(text)
        if not isinstance(data, dict):
            return False
        with crane_lock:
            for k, v in data.items():
                if k in crane_state and k not in ('any_falla', 'modo_nombre'):
                    crane_state[k] = v
            _derive_mode_state()
        return True
    except (json.JSONDecodeError, ValueError, TypeError):
        return False


def _file_reader():
    """Lee crane_state.json a 50 Hz (fallback cuando UDP no disponible)."""
    last_mtime = 0.0
    no_file_warned = False

    while True:
        try:
            if JSON_FILE.exists():
                try:
                    mtime = JSON_FILE.stat().st_mtime
                except OSError:
                    time.sleep(POLL_RATE)
                    continue
                if mtime != last_mtime:
                    last_mtime = mtime
                    try:
                        text = JSON_FILE.read_text(encoding="utf-8")
                        if text.strip():
                            _parse_and_update_json(text)
                    except (OSError, UnicodeDecodeError):
                        pass
                no_file_warned = False
            else:
                if not no_file_warned:
                    print(f"[INFO] Sin archivo fallback: {JSON_FILE}")
                    no_file_warned = True
                # No tocar crane_state['connected'] — lo gestiona _udp_receiver
        except Exception:
            pass
        time.sleep(POLL_RATE)


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
        gamepad.left_joystick_float(x_value_float=float(joystick_state["lx"]), y_value_float=0.0)
        gamepad.right_joystick_float(x_value_float=0.0, y_value_float=float(joystick_state["ry"]))
        for btn_name, active in joystick_state["buttons"].items():
            if active and btn_name in BUTTON_MAP:
                gamepad.press_button(button=getattr(vg.XUSB_BUTTON, BUTTON_MAP[btn_name]))
        gamepad.update()
    except Exception as e:
        print(f"[WARN] vgamepad update: {e}")


# ── SocketIO events ───────────────────────────────────────────────────────────
@socketio.on("joystick")
def handle_joystick(data):
    joystick_state["lx"] = max(-1.0, min(1.0, float(data.get("lx", 0.0))))
    joystick_state["ry"] = max(-1.0, min(1.0, float(data.get("ry", 0.0))))
    _update_gamepad()


@socketio.on("button")
def handle_button(data):
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
    threading.Thread(target=_file_reader,        daemon=True, name="FileReader").start()
    threading.Thread(target=_udp_receiver,       daemon=True, name="UDPReceiver").start()
    threading.Thread(target=_state_emitter,      daemon=True, name="StateEmitter").start()
    threading.Thread(target=_connection_watchdog, daemon=True, name="Watchdog").start()


if __name__ == "__main__":
    print("=" * 60)
    print("  GRÚA STS — Dashboard Backend")
    print(f"  vgamepad: {'OK' if VGAMEPAD_OK else 'NO DISPONIBLE'}")
    print(f"  UDP port:  {UDP_PORT}  (binario doubles)")
    print(f"  Señales mapeadas: {len(UDP_SIGNAL_MAP)}")
    print(f"  JSON fallback: {JSON_FILE}")
    print("=" * 60)
    start_background_threads()
    kwargs = {"host": "0.0.0.0", "port": 5000, "debug": False}
    if _async_mode == "threading":
        kwargs["allow_unsafe_werkzeug"] = True
    socketio.run(app, **kwargs)
