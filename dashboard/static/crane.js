/**
 * crane.js — Animación 2D de la Grúa STS en Canvas
 *
 * Coordenadas físicas (del modelo):
 *   xt ∈ [-30, 50] m   → posición horizontal del carro
 *   yh ∈ [-20, 40] m   → posición vertical del izaje (positivo = arriba)
 *   Hc = 2.59 m, Wc = 2.44 m  → dimensiones del container
 *
 * El canvas escala automáticamente al tamaño de la sección.
 */

const CraneViz = (() => {
  // ── Parámetros físicos del modelo ────────────────────────────────────────
  const PHYS = {
    xt_min: -30, xt_max: 50,      // rango carro [m]
    yh_min: -20, yh_max: 40,      // rango izaje [m]
    Yt0: 45.0,                    // altura poleas en carro [m]
    Ysb: 5.0,                     // despeje mínimo viga [m]
    Hc: 2.59,                     // altura container [m]
    Wc: 2.44,                     // ancho container [m]
    xt_0: 5.0,                    // posición inicial carro
    yh_0: 20.0,                   // posición inicial izaje
    alt_borde: 2.8,               // altura borde muelle [m]
    hold_depth: -7,               // profundidad hold barco [stacks]
    // Perfil de containers (h_vec * Hc), 33 columnas de xt_min a xt_max
    // Corresponde a h_vec_inicial en init_plant_parameters.m
    h_vec: [0,0,1,0,0,1,0,0,0,0,0,0,0,   // [0-12] muelle (índice 12=muro, se dibuja aparte)
            3,5,6,3,5,6,6,4,1,1,-4,-5,-2,-1,2,6,4,2,5,0],  // [13-32] barco (índice 32=muro, aparte)
  };

  // ── Estado interno del canvas ────────────────────────────────────────────
  let canvas, ctx;
  let W, H;           // dimensiones canvas en px
  let state = {
    xt: PHYS.xt_0,
    yh: PHYS.yh_0,
    vt: 0,
    vh: 0,
    tita_l: 0,
    hay_container: 0,
    tlk: 0,
    estado: 0,
  };

  // ── Coordenadas de la escena ─────────────────────────────────────────────
  // margin en px
  const M = { top: 30, bottom: 30, left: 30, right: 30 };

  function sceneW() { return W - M.left - M.right; }
  function sceneH() { return H - M.top - M.bottom; }

  // Mundo físico: X ∈ [xt_min-5, xt_max+5], Y ∈ [-25, Yt0+10]
  const WORLD = {
    xMin: PHYS.xt_min - 5,
    xMax: PHYS.xt_max + 5,
    yMin: -25,
    yMax: PHYS.Yt0 + 10,
  };

  function toCanvasX(x_m) {
    return M.left + ((x_m - WORLD.xMin) / (WORLD.xMax - WORLD.xMin)) * sceneW();
  }
  function toCanvasY(y_m) {
    // y_m positivo = arriba → en canvas, arriba = y pequeño
    return M.top + ((WORLD.yMax - y_m) / (WORLD.yMax - WORLD.yMin)) * sceneH();
  }
  function mToPx(m) {
    return m / (WORLD.xMax - WORLD.xMin) * sceneW();
  }

  // ── Colores ──────────────────────────────────────────────────────────────
  const C = {
    sky:        '#0a1520',
    water:      '#0a2035',
    dock:       '#2a3040',
    dockEdge:   '#4a5560',
    ship:       '#1a2535',
    shipEdge:   '#3a4a60',
    rail:       '#6a7a9a',
    trolley:    '#3060c0',
    trolleyEdge:'#60a0ff',
    cable:      '#c0c8d8',
    spreader:   '#e07010',
    spreaderEdge:'#ffa040',
    container:  '#3a7a50',
    containerEdge:'#60c080',
    containerShip:'#4a5070',
    containerDock:'#5a6a40',
    pulley:     '#8090b0',
    text:       '#8090b0',
    grid:       '#1a2230',
    waterSurf:  '#0d4060',
    ship_hull:  '#243040',
    crane_col:  '#3a4560',
    crane_bm:   '#4a5570',
  };

  // ── Dibujar fondo (cielo, agua, suelo) ───────────────────────────────────
  function drawBackground() {
    // Cielo
    const y_water = toCanvasY(-5);
    const sky_grad = ctx.createLinearGradient(0, 0, 0, y_water);
    sky_grad.addColorStop(0, '#050e1a');
    sky_grad.addColorStop(1, '#0a1a2e');
    ctx.fillStyle = sky_grad;
    ctx.fillRect(0, 0, W, y_water);

    // Agua
    const water_grad = ctx.createLinearGradient(0, y_water, 0, H);
    water_grad.addColorStop(0, '#0a2035');
    water_grad.addColorStop(1, '#061018');
    ctx.fillStyle = water_grad;
    ctx.fillRect(0, y_water, W, H - y_water);

    // Línea de agua
    ctx.strokeStyle = C.waterSurf;
    ctx.lineWidth = 1.5;
    ctx.beginPath();
    ctx.moveTo(0, y_water);
    ctx.lineTo(W, y_water);
    ctx.stroke();

    // Grid de fondo (sutil)
    ctx.strokeStyle = C.grid;
    ctx.lineWidth = 0.5;
    for (let x = PHYS.xt_min; x <= PHYS.xt_max; x += 10) {
      const cx = toCanvasX(x);
      ctx.beginPath();
      ctx.moveTo(cx, M.top);
      ctx.lineTo(cx, H - M.bottom);
      ctx.stroke();
    }
  }

  // ── Dibujar dock (muelle, xt < 0) ───────────────────────────────────────
  // El muelle termina en x=0 (índice 12 del h_vec = alt_borde)
  function drawDock() {
    const y_dock_top = toCanvasY(0);
    const x_dock_r   = toCanvasX(0);   // borde derecho del muelle = x=0m
    const x_dock_l   = 0;

    ctx.fillStyle = C.dock;
    ctx.fillRect(x_dock_l, y_dock_top, x_dock_r - x_dock_l, H - y_dock_top);
    ctx.strokeStyle = C.dockEdge;
    ctx.lineWidth = 1.5;
    ctx.beginPath();
    ctx.moveTo(x_dock_r, y_dock_top);
    ctx.lineTo(x_dock_l, y_dock_top);
    ctx.stroke();

    // Muro vertical del muelle (borde al agua)
    ctx.fillStyle = C.dockEdge;
    ctx.fillRect(x_dock_r - 4, toCanvasY(PHYS.alt_borde), 4, H);

    ctx.fillStyle = C.text;
    ctx.font = `${Math.max(9, mToPx(2))}px Consolas`;
    ctx.fillText('MUELLE', x_dock_l + 4, y_dock_top - 5);

    drawContainerStack(PHYS.xt_min, -0.1, C.containerDock);  // excluye x=0 (muro)
  }

  // ── Dibujar barco (xt > 0) ───────────────────────────────────────────────
  // El barco empieza en x≈2.5m (índice 13 del h_vec), pegado al muelle
  function drawShip() {
    const x_ship_l = toCanvasX(1);
    const x_ship_r = toCanvasX(PHYS.xt_max + 3);
    const y_deck   = toCanvasY(-2);
    const y_hull_b = toCanvasY(PHYS.hold_depth * PHYS.Hc - 2);  // 2m bajo el fondo del hold

    // Casco
    ctx.fillStyle = C.ship_hull;
    ctx.beginPath();
    ctx.moveTo(x_ship_l, y_deck);
    ctx.lineTo(x_ship_l, y_hull_b);           // lado izquierdo vertical recto
    ctx.lineTo(x_ship_r + mToPx(2), y_hull_b);
    ctx.lineTo(x_ship_r, y_deck);
    ctx.closePath();
    ctx.fill();
    ctx.strokeStyle = C.shipEdge;
    ctx.lineWidth = 1.5;
    ctx.stroke();

    // Cubierta
    ctx.fillStyle = C.ship;
    ctx.fillRect(x_ship_l, y_deck, x_ship_r - x_ship_l, toCanvasY(-8) - y_deck);
    ctx.strokeStyle = C.shipEdge;
    ctx.lineWidth = 1;
    ctx.strokeRect(x_ship_l, y_deck, x_ship_r - x_ship_l, toCanvasY(-8) - y_deck);

    ctx.fillStyle = C.text;
    ctx.font = `${Math.max(9, mToPx(2))}px Consolas`;
    ctx.fillText('BARCO', x_ship_l + 4, y_deck - 5);

    // Borde izquierdo grueso del barco (lado muelle)
    ctx.fillStyle = C.shipEdge;
    ctx.fillRect(x_ship_l - 4, toCanvasY(PHYS.alt_borde), 4, y_hull_b - toCanvasY(PHYS.alt_borde));

    // Muro lateral del barco (x=50m, borde fijo)
    const x_ship_wall = toCanvasX(PHYS.xt_max);
    ctx.fillStyle = C.shipEdge;
    ctx.fillRect(x_ship_wall - 2, toCanvasY(PHYS.alt_borde), 5, H);

    drawContainerStack(1, PHYS.xt_max - 0.1, C.containerShip, PHYS.hold_depth);  // excluye x=50 (muro)
  }

  // ── Dibujar stacks de containers en el muelle o barco ───────────────────
  function drawContainerStack(x_start, x_end, color, y_min_stacks = 0) {
    const Wc_px = mToPx(PHYS.Wc);
    const Hc_px = toCanvasY(0) - toCanvasY(PHYS.Hc);  // escala Y correcta
    const N = PHYS.h_vec.length;
    const x_range = PHYS.xt_max - PHYS.xt_min;

    for (let i = 0; i < N; i++) {
      const x_m = PHYS.xt_min + (i / (N - 1)) * x_range;
      if (x_m < x_start || x_m > x_end) continue;
      const stacks_top = Math.round(PHYS.h_vec[i]);
      if (stacks_top <= y_min_stacks) continue;
      const cx = toCanvasX(x_m) - Wc_px / 2;
      for (let s = y_min_stacks; s < stacks_top; s++) {
        const cy = toCanvasY((s + 1) * PHYS.Hc) + 1;
        ctx.fillStyle = color;
        ctx.fillRect(cx, cy, Wc_px - 1, Hc_px - 1);
        ctx.strokeStyle = '#607080';
        ctx.lineWidth = 0.5;
        ctx.strokeRect(cx, cy, Wc_px - 1, Hc_px - 1);
      }
    }
  }

  // ── Dibujar estructura de la grúa (columnas + viga) ─────────────────────
  function drawCraneStructure() {
    // Viga horizontal (rail) a la altura Yt0
    const y_rail = toCanvasY(PHYS.Yt0);
    const x_l    = toCanvasX(PHYS.xt_min - 3);
    const x_r    = toCanvasX(PHYS.xt_max + 2);

    // Columna izquierda (land side)
    const y_base  = toCanvasY(0);
    ctx.fillStyle = C.crane_col;
    ctx.fillRect(toCanvasX(PHYS.xt_min - 2) - 4, y_rail, 8, y_base - y_rail);

    // Columna derecha (sea side)
    ctx.fillStyle = C.crane_col;
    ctx.fillRect(toCanvasX(PHYS.xt_max) - 4, y_rail, 8, y_base - y_rail);

    // Tirantes diagonales (decorativos)
    ctx.strokeStyle = C.crane_bm;
    ctx.lineWidth = 1.5;
    ctx.beginPath();
    ctx.moveTo(toCanvasX(PHYS.xt_min - 2), y_rail);
    ctx.lineTo(toCanvasX(PHYS.xt_min - 2) + mToPx(8), y_base);
    ctx.stroke();
    ctx.beginPath();
    ctx.moveTo(toCanvasX(PHYS.xt_max), y_rail);
    ctx.lineTo(toCanvasX(PHYS.xt_max) - mToPx(8), y_base);
    ctx.stroke();

    // Rail horizontal
    const rail_h = Math.max(3, mToPx(0.4));
    const rail_grad = ctx.createLinearGradient(0, y_rail, 0, y_rail + rail_h);
    rail_grad.addColorStop(0, '#8090b0');
    rail_grad.addColorStop(1, '#4a5570');
    ctx.fillStyle = rail_grad;
    ctx.fillRect(x_l, y_rail - rail_h / 2, x_r - x_l, rail_h);
    ctx.strokeStyle = C.rail;
    ctx.lineWidth = 0.5;
    ctx.strokeRect(x_l, y_rail - rail_h / 2, x_r - x_l, rail_h);

    // Etiquetas de escala en X
    ctx.fillStyle = '#404858';
    ctx.font = '9px Consolas';
    ctx.textAlign = 'center';
    for (let x = PHYS.xt_min; x <= PHYS.xt_max; x += 10) {
      ctx.fillText(`${x}m`, toCanvasX(x), H - 5);
    }
    ctx.textAlign = 'left';
  }

  // ── Dibujar carro, cable y spreader ──────────────────────────────────────
  function drawTrolleyAndHoist(xt, yh, caught, tita_l) {
    const cx      = toCanvasX(xt);
    const y_rail  = toCanvasY(PHYS.Yt0);
    const tw      = Math.max(12, mToPx(1.5));   // ancho carro px
    const th      = Math.max(6,  mToPx(0.6));   // alto carro px

    // Péndulo: offset horizontal del spreader por ángulo tita_l
    const L = PHYS.Yt0 - yh;                         // longitud cable [m]
    const x_spread_m = xt + L * Math.sin(tita_l);    // posición real spreader [m]
    const cx_spread  = toCanvasX(x_spread_m);
    const y_spreader = toCanvasY(yh);
    const Wc_px = mToPx(PHYS.Wc);
    const Hc_px = toCanvasY(0) - toCanvasY(PHYS.Hc);  // escala Y correcta
    const sw = Math.max(16, Wc_px * 0.85);   // ancho spreader
    const sh = Math.max(4,  mToPx(0.3));     // alto spreader

    // Cable en ángulo
    ctx.strokeStyle = C.cable;
    ctx.lineWidth = Math.max(1, mToPx(0.05));
    ctx.beginPath();
    ctx.moveTo(cx, y_rail + th / 2);
    ctx.lineTo(cx_spread, y_spreader - sh / 2);
    ctx.stroke();

    // Container enganchado (debajo del spreader)
    if (caught) {
      ctx.fillStyle = C.container;
      ctx.fillRect(cx_spread - Wc_px / 2, y_spreader + sh / 2 + 1, Wc_px, Hc_px);
      ctx.strokeStyle = C.containerEdge;
      ctx.lineWidth = 1.5;
      ctx.strokeRect(cx_spread - Wc_px / 2, y_spreader + sh / 2 + 1, Wc_px, Hc_px);
      // Stripes en el container
      ctx.strokeStyle = '#2a5a3a';
      ctx.lineWidth = 0.5;
      for (let xi = 0.25; xi < 1; xi += 0.25) {
        ctx.beginPath();
        ctx.moveTo(cx_spread - Wc_px / 2 + Wc_px * xi, y_spreader + sh / 2 + 1);
        ctx.lineTo(cx_spread - Wc_px / 2 + Wc_px * xi, y_spreader + sh / 2 + Hc_px);
        ctx.stroke();
      }
    }

    // Spreader
    const sp_grad = ctx.createLinearGradient(cx_spread - sw / 2, y_spreader - sh / 2, cx_spread + sw / 2, y_spreader + sh / 2);
    sp_grad.addColorStop(0, '#c05a10');
    sp_grad.addColorStop(1, '#e07010');
    ctx.fillStyle = sp_grad;
    ctx.fillRect(cx_spread - sw / 2, y_spreader - sh / 2, sw, sh);
    ctx.strokeStyle = C.spreaderEdge;
    ctx.lineWidth = 1.5;
    ctx.strokeRect(cx_spread - sw / 2, y_spreader - sh / 2, sw, sh);

    // Puntos de enganche (esquinas del spreader)
    const tlk_color = caught ? '#40ff80' : '#808090';
    [[-1, -1], [1, -1], [-1, 1], [1, 1]].forEach(([dx, dy]) => {
      ctx.beginPath();
      ctx.arc(cx_spread + dx * sw * 0.42, y_spreader + dy * sh * 0.1, 2, 0, Math.PI * 2);
      ctx.fillStyle = tlk_color;
      ctx.fill();
    });

    // Polea en el carro
    ctx.beginPath();
    ctx.arc(cx, y_rail, Math.max(3, mToPx(0.25)), 0, Math.PI * 2);
    ctx.fillStyle = C.pulley;
    ctx.fill();

    // Carro (trolley)
    const trolley_grad = ctx.createLinearGradient(cx - tw / 2, y_rail - th, cx + tw / 2, y_rail + th);
    trolley_grad.addColorStop(0, '#5080d0');
    trolley_grad.addColorStop(1, '#3060c0');
    ctx.fillStyle = trolley_grad;
    ctx.fillRect(cx - tw / 2, y_rail - th, tw, th);
    ctx.strokeStyle = C.trolleyEdge;
    ctx.lineWidth = 1.5;
    ctx.strokeRect(cx - tw / 2, y_rail - th, tw, th);

    // Ruedas del carro
    const wr = Math.max(2, mToPx(0.12));
    [-tw * 0.3, tw * 0.3].forEach(dx => {
      ctx.beginPath();
      ctx.arc(cx + dx, y_rail, wr, 0, Math.PI * 2);
      ctx.fillStyle = '#2a3850';
      ctx.fill();
      ctx.strokeStyle = '#6080a0';
      ctx.lineWidth = 0.5;
      ctx.stroke();
    });

    // Etiquetas
    ctx.fillStyle = '#8090b0';
    ctx.font = '9px Consolas';
    ctx.textAlign = 'center';
    ctx.fillText(`xt=${xt.toFixed(1)}m`, cx, y_rail - th - 3);
    ctx.fillText(`yh=${yh.toFixed(1)}m`, cx_spread, y_spreader - sh - 8);
    if (Math.abs(tita_l) > 0.001) {
      ctx.fillStyle = '#e0a040';
      ctx.fillText(`θ=${(tita_l * 180 / Math.PI).toFixed(1)}°`, cx_spread, y_spreader + sh / 2 + 14);
    }
    ctx.textAlign = 'left';
  }

  // ── Dibujar panel de velocidad (barras) ─────────────────────────────────
  function drawVelocityBars(vt, vh) {
    const bar_w = 10;
    const bar_h = 60;
    const x_vt = W - M.right - 30;
    const x_vh = W - M.right - 15;
    const y_mid = M.top + 80;

    const vt_frac = Math.max(-1, Math.min(1, vt / 4.0));
    const vh_frac = Math.max(-1, Math.min(1, vh / 3.0));

    function drawBar(x, frac, label) {
      // Fondo
      ctx.fillStyle = '#1a2230';
      ctx.fillRect(x, y_mid - bar_h / 2, bar_w, bar_h);
      // Relleno
      const fill_h = Math.abs(frac) * (bar_h / 2);
      const fill_y = frac >= 0 ? y_mid - fill_h : y_mid;
      ctx.fillStyle = frac > 0 ? '#3080d0' : '#d04030';
      ctx.fillRect(x, fill_y, bar_w, fill_h);
      // Borde
      ctx.strokeStyle = '#3a4858';
      ctx.lineWidth = 0.5;
      ctx.strokeRect(x, y_mid - bar_h / 2, bar_w, bar_h);
      // Línea central
      ctx.strokeStyle = '#4a5868';
      ctx.beginPath();
      ctx.moveTo(x - 2, y_mid);
      ctx.lineTo(x + bar_w + 2, y_mid);
      ctx.stroke();
      // Label
      ctx.fillStyle = C.text;
      ctx.font = '8px Consolas';
      ctx.textAlign = 'center';
      ctx.fillText(label, x + bar_w / 2, y_mid + bar_h / 2 + 10);
    }

    drawBar(x_vt, vt_frac, 'VT');
    drawBar(x_vh, vh_frac, 'VH');
  }

  // ── Render completo ───────────────────────────────────────────────────────
  function render() {
    if (!canvas || !ctx) return;

    // Sincronizar tamaño canvas
    const rect = canvas.getBoundingClientRect();
    if (canvas.width !== rect.width || canvas.height !== rect.height) {
      canvas.width  = rect.width;
      canvas.height = rect.height;
      W = canvas.width;
      H = canvas.height;
    }
    if (W < 10 || H < 10) return;

    ctx.clearRect(0, 0, W, H);

    drawBackground();
    drawDock();
    drawShip();
    drawCraneStructure();
    drawTrolleyAndHoist(state.xt, state.yh, state.hay_container, state.tita_l);
    drawVelocityBars(state.vt, state.vh);
  }

  // ── API pública ───────────────────────────────────────────────────────────
  function init() {
    canvas = document.getElementById('craneCanvas');
    if (!canvas) return;
    ctx = canvas.getContext('2d');
    W = canvas.offsetWidth || 800;
    H = canvas.offsetHeight || 320;
    canvas.width  = W;
    canvas.height = H;

    // Responder a resize
    window.addEventListener('resize', () => {
      const rect = canvas.getBoundingClientRect();
      canvas.width  = rect.width  || 800;
      canvas.height = rect.height || 320;
      W = canvas.width;
      H = canvas.height;
    });

    requestAnimationFrame(loop);
  }

  function loop() {
    render();
    requestAnimationFrame(loop);
  }

  function update(data) {
    if (data.xt    !== undefined) state.xt     = parseFloat(data.xt);
    if (data.yh    !== undefined) state.yh     = parseFloat(data.yh);
    if (data.vt    !== undefined) state.vt     = parseFloat(data.vt);
    if (data.vh    !== undefined) state.vh     = parseFloat(data.vh);
    if (data.tita_l       !== undefined) state.tita_l       = parseFloat(data.tita_l);
    if (data.hay_container !== undefined) state.hay_container = parseInt(data.hay_container);
    if (data.tlk          !== undefined) state.tlk          = parseInt(data.tlk);
    if (data.estado !== undefined) state.estado = parseInt(data.estado);
    // yc0_vec viene en metros → convertir a stack count dividiendo por Hc
    if (Array.isArray(data.yc0_vec) && data.yc0_vec.length === 33) {
      PHYS.h_vec = data.yc0_vec.map(v => v / PHYS.Hc);
      PHYS.h_vec[12] = 0;   // muro del muelle — se dibuja como estructura, no container
      PHYS.h_vec[32] = 0;   // muro del barco — idem
    }
  }

  return { init, update };
})();
