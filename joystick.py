import pygame
import vgamepad as vg
import math

pygame.init()

screen = pygame.display.set_mode((820, 460), pygame.RESIZABLE)
pygame.display.set_caption("Joystick Emulator - Grúa STS")

# Xbox 360 via ViGEm → 5 ejes en MATLAB (LX, LY, Trig, RX, RY)
# Simulink Selector indices=[1,5]: eje[1]=LX → CARRO, eje[5]=RY → IZAJE (gain -1)
# Simulink Demux 10 salidas: 1=A→TLK, 2=B→MANUAL, 3=X→AUTO, 4=Y→RESET, 7=Back→EMERG
gamepad = vg.VX360Gamepad()

# ── Colores ───────────────────────────────────────────────────────────────────
BG         = (22,  26,  36)
BASE_CLR   = (48,  54,  72)
BASE_RING  = (80,  88, 115)
THUMB_CLR  = (90, 160, 255)
THUMB_RING = (160, 210, 255)
CROSS_CLR  = (80,  80, 100)
TEXT       = (220, 225, 235)
SUBLABEL   = (120, 128, 150)

# ── Botones (sin posición, se recalcula cada frame) ───────────────────────────
BUTTONS = [
    {"label": "TLK",    "sub": "A",    "btn": vg.XUSB_BUTTON.XUSB_GAMEPAD_A,    "clr_on": (80,  130, 255), "active": False},
    {"label": "MANUAL", "sub": "B",    "btn": vg.XUSB_BUTTON.XUSB_GAMEPAD_B,    "clr_on": (255,  70,  70), "active": False},
    {"label": "AUTO",   "sub": "X",    "btn": vg.XUSB_BUTTON.XUSB_GAMEPAD_X,    "clr_on": (230,  80, 180), "active": False},
    {"label": "RESET",  "sub": "Y",    "btn": vg.XUSB_BUTTON.XUSB_GAMEPAD_Y,    "clr_on": (60,  200,  90), "active": False},
    {"label": "EMERG",  "sub": "Back", "btn": vg.XUSB_BUTTON.XUSB_GAMEPAD_BACK, "clr_on": (255,  50,  50), "active": False},
]

RETURN_STEP = 0.07

axis_carro = 0.0
axis_izaje = 0.0
dragging_l = False
dragging_r = False


# ── Layout dinámico ───────────────────────────────────────────────────────────
def compute_layout(W, H):
    stick_r = max(40, min(W * 0.115, H * 0.21))
    thumb_r = max(10, int(stick_r * 0.275))
    lc = (int(W * 0.225), H // 2)
    rc = (int(W * 0.775), H // 2)

    btn_w   = max(80, min(int(W * 0.145), 130))
    btn_h   = max(36, min(int(H * 0.115), 56))
    btn_gap = max(6,  int(H * 0.022))
    total   = len(BUTTONS) * btn_h + (len(BUTTONS) - 1) * btn_gap
    bx      = W // 2 - btn_w // 2
    by0     = H // 2 - total // 2
    rects   = [pygame.Rect(bx, by0 + i * (btn_h + btn_gap), btn_w, btn_h)
               for i in range(len(BUTTONS))]
    return stick_r, thumb_r, lc, rc, btn_w, btn_h, rects


# ── Fuentes (fijas; si querés escalarlas también se puede, pero es costoso) ───
font_big   = pygame.font.SysFont("Segoe UI", 15, bold=True)
font_small = pygame.font.SysFont("Segoe UI", 12)
font_val   = pygame.font.SysFont("Consolas",  13)


# ── Helpers de dibujo ─────────────────────────────────────────────────────────
def draw_stick(surface, center, ax, ay, stick_r, thumb_r, title, subtitle, val_label, val):
    cx, cy = center
    pygame.draw.circle(surface, BASE_CLR,  center, int(stick_r))
    pygame.draw.circle(surface, BASE_RING, center, int(stick_r), 2)
    pygame.draw.line(surface, CROSS_CLR, (cx - int(stick_r), cy), (cx + int(stick_r), cy), 1)
    pygame.draw.line(surface, CROSS_CLR, (cx, cy - int(stick_r)), (cx, cy + int(stick_r)), 1)
    tx = int(cx + ax * stick_r)
    ty = int(cy + ay * stick_r)
    pygame.draw.circle(surface, THUMB_CLR,  (tx, ty), thumb_r)
    pygame.draw.circle(surface, THUMB_RING, (tx, ty), thumb_r, 3)
    lbl = font_big.render(title, True, TEXT)
    surface.blit(lbl, (cx - lbl.get_width() // 2, cy + int(stick_r) + 10))
    sub = font_small.render(subtitle, True, SUBLABEL)
    surface.blit(sub, (cx - sub.get_width() // 2, cy + int(stick_r) + 27))
    txt = font_val.render(f"{val_label} = {val:+.2f}", True, THUMB_RING)
    surface.blit(txt, (cx - txt.get_width() // 2, cy - int(stick_r) - 20))


def draw_buttons(surface, rects):
    for b, rect in zip(BUTTONS, rects):
        clr = b["clr_on"] if b["active"] else BASE_CLR
        pygame.draw.rect(surface, clr,      rect, border_radius=10)
        pygame.draw.rect(surface, BASE_RING, rect, 2, border_radius=10)
        lbl = font_big.render(b["label"], True, TEXT)
        sub = font_small.render(b["sub"],   True, SUBLABEL if not b["active"] else TEXT)
        surface.blit(lbl, (rect.centerx - lbl.get_width() // 2, rect.centery - lbl.get_height() // 2 - 7))
        surface.blit(sub, (rect.centerx - sub.get_width() // 2, rect.centery + 5))


# ── Loop principal ────────────────────────────────────────────────────────────
clock   = pygame.time.Clock()
running = True

while running:
    W, H      = screen.get_size()
    mouse_pos = pygame.mouse.get_pos()
    stick_r, thumb_r, L_CENTER, R_CENTER, _btn_w, _btn_h, btn_rects = compute_layout(W, H)

    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            running = False

        elif event.type == pygame.MOUSEBUTTONDOWN and event.button == 1:
            if math.hypot(event.pos[0] - L_CENTER[0], event.pos[1] - L_CENTER[1]) <= stick_r:
                dragging_l = True
            if math.hypot(event.pos[0] - R_CENTER[0], event.pos[1] - R_CENTER[1]) <= stick_r:
                dragging_r = True
            for b, rect in zip(BUTTONS, btn_rects):
                if rect.collidepoint(event.pos):
                    b["active"] = True

        elif event.type == pygame.MOUSEBUTTONUP and event.button == 1:
            dragging_l = False
            dragging_r = False
            for b in BUTTONS:
                b["active"] = False

    # ── Ejes ──────────────────────────────────────────────────────────────────
    if dragging_l:
        axis_carro = max(-1.0, min(1.0, (mouse_pos[0] - L_CENTER[0]) / stick_r))
    else:
        if abs(axis_carro) < RETURN_STEP:
            axis_carro = 0.0
        else:
            axis_carro -= math.copysign(RETURN_STEP, axis_carro)

    if dragging_r:
        axis_izaje = max(-1.0, min(1.0, (mouse_pos[1] - R_CENTER[1]) / stick_r))
    else:
        if abs(axis_izaje) < RETURN_STEP:
            axis_izaje = 0.0
        else:
            axis_izaje -= math.copysign(RETURN_STEP, axis_izaje)

    # ── Gamepad ───────────────────────────────────────────────────────────────
    gamepad.reset()
    gamepad.left_joystick_float(x_value_float=axis_carro, y_value_float=0.0)
    gamepad.right_joystick_float(x_value_float=0.0,       y_value_float=axis_izaje)
    for b in BUTTONS:
        if b["active"]:
            gamepad.press_button(button=b["btn"])
    gamepad.update()

    # ── Render ────────────────────────────────────────────────────────────────
    screen.fill(BG)
    draw_stick(screen, L_CENTER, axis_carro, 0.0,
               stick_r, thumb_r, "CARRO", "L-stick X  ·  eje[1]", "LX", axis_carro)
    draw_stick(screen, R_CENTER, 0.0, axis_izaje,
               stick_r, thumb_r, "IZAJE", "R-stick Y  ·  eje[5]", "RY", axis_izaje)
    draw_buttons(screen, btn_rects)
    pygame.display.flip()
    clock.tick(60)

pygame.quit()
