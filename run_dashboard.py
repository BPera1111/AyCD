"""
run_dashboard.py — Entrypoint del Dashboard Grúa STS

Uso:
    python run_dashboard.py                   # solo dashboard
    python run_dashboard.py --sim-test        # inyecta datos de prueba (sin MATLAB)
    python run_dashboard.py --port 5000       # puerto HTTP (defecto: 5000)

Requisitos:
    pip install flask flask-socketio watchdog
    vgamepad (requiere ViGEm Bus Driver instalado)

Antes de correr el dashboard:
    1. En MATLAB: run('simulink/add_telemetry.m')  [una sola vez]
    2. En MATLAB: run('simulink/init_plant_parameters.m')
    3. Abrir nivel_1_full.slx y presionar Play
    4. Aquí: python run_dashboard.py
"""

import argparse
import importlib.util
import json
import math
import os
import sys
import threading
import time
import webbrowser
from pathlib import Path

# ── Agregar dashboard/ al path ───────────────────────────────────────────────
ROOT = Path(__file__).parent
DASHBOARD = ROOT / "dashboard"
sys.path.insert(0, str(DASHBOARD))

# ── Verificaciones de dependencias ───────────────────────────────────────────
def check_dep(package, pip_name=None):
    if importlib.util.find_spec(package) is None:
        pip_name = pip_name or package
        print(f"[ERROR] Paquete '{package}' no encontrado.")
        print(f"        Instalar con: pip install {pip_name}")
        return False
    return True


def check_all_deps():
    ok = True
    ok &= check_dep("flask")
    ok &= check_dep("flask_socketio", "flask-socketio")
    if not ok:
        print("\n[ERROR] Faltan dependencias. Instalar con:")
        print("  venv\\Scripts\\pip install flask flask-socketio watchdog")
        sys.exit(1)


# ── Simulador de datos de prueba (sin MATLAB) ─────────────────────────────────
def _sim_test_loop(json_file: Path):
    """Genera datos de prueba animados para verificar el dashboard sin MATLAB."""
    print("[TEST] Modo simulación de prueba activo — generando datos falsos")
    json_file.parent.mkdir(parents=True, exist_ok=True)
    t = 0.0
    estados = [0, 1, 2, 3, 6, 7, 8, 9, 10, 11, 12, 13, 14]
    while True:
        t += 0.02
        estado_idx = int(t / 5) % len(estados)
        data = {
            "xt":      10.0 * math.sin(t * 0.3) + 5.0,
            "yh":      15.0 + 10.0 * math.sin(t * 0.2),
            "vt":       4.0 * math.cos(t * 0.3),
            "vh":       3.0 * math.cos(t * 0.2),
            "freno_c": 1 if abs(math.cos(t * 0.3)) < 0.1 else 0,
            "freno_h": 1 if abs(math.cos(t * 0.2)) < 0.1 else 0,
            "estado":  estados[estado_idx],
            "modo":    min(3, int(t / 15) % 4),
            "tlk":     1 if math.sin(t) > 0.8 else 0,
            "caught":  1 if math.sin(t * 0.5) > 0.5 else 0,
        }
        try:
            # Escritura atómica: escribir a .tmp y renombrar
            tmp = json_file.parent / (json_file.stem + ".tmp")
            tmp.write_text(json.dumps(data), encoding="utf-8")
            tmp.replace(json_file)
        except OSError:
            pass
        time.sleep(0.02)


# ── Main ──────────────────────────────────────────────────────────────────────
def main():
    parser = argparse.ArgumentParser(description="Dashboard Grúa STS")
    parser.add_argument("--port",     type=int, default=5000,  help="Puerto HTTP (default: 5000)")
    parser.add_argument("--sim-test", action="store_true",      help="Datos de prueba sin MATLAB")
    parser.add_argument("--no-browser", action="store_true",   help="No abrir browser automáticamente")
    args = parser.parse_args()

    print("=" * 60)
    print("  GRÚA STS — Dashboard de Simulación")
    print("  AyCD 2025 — UNCUYO")
    print("=" * 60)

    check_all_deps()

    JSON_FILE = Path("C:/Temp/crane_state.json")

    # Modo test: inyecta datos simulados
    if args.sim_test:
        t_sim = threading.Thread(
            target=_sim_test_loop, args=(JSON_FILE,), daemon=True, name="SimTest"
        )
        t_sim.start()

    # Cambiar al directorio del dashboard para que Flask encuentre templates/static
    os.chdir(DASHBOARD)

    # Importar servidor (ya en path)
    from server import app, socketio, start_background_threads

    start_background_threads()

    # Abrir browser después de 1.5s
    if not args.no_browser:
        def _open_browser():
            time.sleep(1.5)
            webbrowser.open(f"http://localhost:{args.port}")
        threading.Thread(target=_open_browser, daemon=True).start()

    print(f"\n[INFO] Dashboard corriendo en http://localhost:{args.port}")
    if args.sim_test:
        print("[INFO] Modo test activo — datos simulados (no necesita MATLAB)")
    else:
        print(f"[INFO] Esperando datos MATLAB en: {JSON_FILE}")
        print("[INFO] En MATLAB: corre init_plant_parameters.m, luego nivel_1_full.slx")
    print("[INFO] Joystick virtual: disponible en el browser")
    print("[INFO] Ctrl+C para salir\n")

    try:
        socketio.run(
            app,
            host="0.0.0.0",
            port=args.port,
            debug=False,
            allow_unsafe_werkzeug=True,
        )
    except KeyboardInterrupt:
        print("\n[INFO] Dashboard cerrado.")


if __name__ == "__main__":
    main()
