"""
dashboard/udp_test.py
Envia paquetes UDP binarios (doubles) al server.py y verifica via /api/state.
Uso: venv/Scripts/python dashboard/udp_test.py
"""
import socket
import struct
import sys
import time
import json
import urllib.request

# Forzar UTF-8 en consola Windows (evita UnicodeEncodeError con caracteres como ->)
if hasattr(sys.stdout, 'reconfigure'):
    sys.stdout.reconfigure(encoding='utf-8', errors='replace')

SERVER_HOST = "127.0.0.1"
UDP_PORT    = 1234
API_URL     = "http://127.0.0.1:5000/api/state"

# Orden identico a UDP_SIGNAL_MAP en server.py
SIGNALS = [
    'yh', 'vt', 'freno_c', 'freno_c_n0', 'xt', 'vh', 'tlk', 'm_container',
    'FC_der', 'FC_inf', 'FC_izq', 'FC_sup',
    'FALLA_CARRO_DER', 'FALLA_CARRO_IZQ', 'FALLA_IZAJE_INF', 'FALLA_IZAJE_SUP',
    'FALLA_IZAJE_SV', 'FALLA_MAN', 'FALLA_WD', 'FALLA_CARRO_SV',
    'i_sel', 'modo_muerto', 'recuperacion', 'modo_auto', 'modo_manual',
    'modo_manual_auto', 'modo_reposo',
]

def make_packet(**kwargs):
    vals = [kwargs.get(s, 0.0) for s in SIGNALS]
    return struct.pack(f'{len(vals)}d', *vals)

def send_udp(data: bytes):
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.sendto(data, (SERVER_HOST, UDP_PORT))
    sock.close()

def get_state(retries=8, delay=0.12):
    for _ in range(retries):
        try:
            with urllib.request.urlopen(API_URL, timeout=2) as r:
                return json.loads(r.read())
        except Exception:
            pass
        time.sleep(delay)
    return None

def check_state(label, pkt_kwargs, expect_mode, expect_connected=True, extra_checks=None):
    send_udp(make_packet(**pkt_kwargs))
    # Retry para dar tiempo al server de procesar el paquete
    deadline = time.time() + 1.5
    state = None
    while time.time() < deadline:
        state = get_state(retries=1, delay=0.0)
        if state and state.get('modo_nombre') == expect_mode:
            if not expect_connected or state.get('connected'):
                break
        time.sleep(0.10)
    if state is None:
        print(f"[FAIL] {label} | API no responde")
        return False
    ok = True
    if state.get('modo_nombre') != expect_mode:
        print(f"[FAIL] {label} | modo={state.get('modo_nombre')!r} esperado={expect_mode!r}")
        ok = False
    if expect_connected and not state.get('connected'):
        print(f"[FAIL] {label} | connected=False (esperado True)")
        ok = False
    if extra_checks:
        for field, expected in extra_checks.items():
            actual = state.get(field)
            if abs(float(actual) - float(expected)) > 1e-9:
                print(f"[FAIL] {label} | {field}={actual} esperado={expected}")
                ok = False
    if ok:
        print(f"[PASS] {label} | modo={state['modo_nombre']} con={state['connected']}")
    return ok

def main():
    print("=== UDP integration test ===")
    print(f"UDP -> {SERVER_HOST}:{UDP_PORT}  API -> {API_URL}")
    print()

    # Verificar que el server responde
    state = get_state()
    if state is None:
        print("[ERROR] Server no responde. Iniciar con: venv\\Scripts\\python run_dashboard.py")
        return

    results = []

    results.append(check_state(
        "MANUAL + container",
        dict(modo_manual=1, m_container=25000.0, yh=10.0, xt=5.0, vt=0.1, vh=-0.2),
        "MANUAL",
        extra_checks={'m_container': 25000.0, 'hay_container': 1},
    ))

    results.append(check_state(
        "MODO MUERTO + WD + FC_sup",
        dict(modo_muerto=1, FALLA_WD=1, FC_sup=1),
        "MODO MUERTO",
        extra_checks={'any_falla': True, 'FC_sup': 1.0},
    ))

    results.append(check_state(
        "RECUPERACION",
        dict(recuperacion=1),
        "RECUPERACION",
    ))

    results.append(check_state(
        "AUTO FULL",
        dict(modo_auto=1),
        "AUTO FULL",
    ))

    results.append(check_state(
        "REPOSO + frenos",
        dict(modo_reposo=1, freno_c=1, freno_c_n0=1),
        "REPOSO",
        extra_checks={'freno_c': 1.0},
    ))

    results.append(check_state(
        "FC_DER + FC_IZQ",
        dict(modo_reposo=1, FC_der=1, FC_izq=1),
        "REPOSO",
        extra_checks={'FC_der': 1.0, 'FC_izq': 1.0},
    ))

    results.append(check_state(
        "MANUAL->AUTO (modo_manual_auto)",
        dict(modo_manual_auto=1),
        "MANUAL→AUTO",
    ))

    passed = sum(results)
    total  = len(results)
    print()
    print(f"Resultado: {passed}/{total} tests pasaron")

if __name__ == "__main__":
    main()
