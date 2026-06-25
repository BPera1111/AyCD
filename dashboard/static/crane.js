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
    xt_min: -30, xt_max: 50,
    yh_min: -20, yh_max: 40,
    Yt0: 45.0,
    Ysb: 5.0,
    Hc: 2.59,
    Wc: 2.44,
    xt_0: 5.0,
    yh_0: 20.0,
    alt_borde: 2.8,
    hold_depth: -7,
    h_vec: [0,0,1,0,0,1,0,0,0,0,0,0,0,
            3,5,6,3,5,6,6,4,1,1,-4,-5,-2,-1,2,6,4,2,5,0],
    // Geometría del portal de la grúa
    portal_land_x:      -33 ,    // [m] top pata tierra
    portal_sea_x:        -1  ,    // [m] top pata mar
    portal_base_spread:  0,    // [m] inclinación outward de cada pata
    // Boom
    boom_backreach: -37,       // [m] extremo contraboom
    boom_tip:        52,       // [m] extremo boom sobre barco
    // Ruedas
    wheel_r: 1.2,              // [m] radio rueda
  };

  // ── Estado interno del canvas ────────────────────────────────────────────
  let canvas, ctx;
  let W, H;
  let state = {
    xt: PHYS.xt_0,
    yh: PHYS.yh_0,
    vt: 0,
    vh: 0,
    tita_l: 0,
    hay_container: 0,
    tlk: 0,
    estado: 0,
    i_sel: 0,
    modo_auto: 0,
    modo_manual_auto: 0,
  };

  // ── Márgenes en px ───────────────────────────────────────────────────────
  const M = { top: 30, bottom: 30, left: 30, right: 30 };

  function sceneW() { return W - M.left - M.right; }
  function sceneH() { return H - M.top - M.bottom; }

  // Mundo físico
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
    return M.top + ((WORLD.yMax - y_m) / (WORLD.yMax - WORLD.yMin)) * sceneH();
  }
  function mToPx(m) {
    return m / (WORLD.xMax - WORLD.xMin) * sceneW();
  }

  // ── Colores (dos paletas: oscuro/claro) ─────────────────────────────────
  function buildColors(light) {
    return light ? {
      sky:           '#4488cc',
      water:         '#2060a0',
      dock:          '#8090a0',
      dockEdge:      '#5a6878',
      ship:          '#5a2030',
      shipEdge:      '#8a4555',
      rail:          '#8898b0',
      trolley:       '#202020',
      trolleyEdge:   '#606060',
      cable:         '#304858',
      spreader:      '#e07010',
      spreaderEdge:  '#ffa040',
      container:     '#3a7a50',
      containerEdge: '#60c080',
      containerShip: '#607890',
      containerDock: '#6a8050',
      pulley:        '#607888',
      text:          '#305070',
      grid:          '#8090a8',
      waterSurf:     '#4090c0',
      ship_hull:     '#3a1020',
      crane_col:     '#708090',
      crane_bm:      '#809090',
      skyGrad:       ['#4488cc', '#a0c8e8'],
      waterGrad:     ['#2060a0', '#102040'],
      barBg:         '#c8d4e0',
      barBorder:     '#8090a0',
    } : {
      sky:           '#0a1520',
      water:         '#0a2035',
      dock:          '#2a3040',
      dockEdge:      '#4a5560',
      ship:          '#3a1020',
      shipEdge:      '#703040',
      rail:          '#6a7a9a',
      trolley:       '#202020',
      trolleyEdge:   '#606060',
      cable:         '#c0c8d8',
      spreader:      '#e07010',
      spreaderEdge:  '#ffa040',
      container:     '#3a7a50',
      containerEdge: '#60c080',
      containerShip: '#4a5070',
      containerDock: '#5a6a40',
      pulley:        '#8090b0',
      text:          '#8090b0',
      grid:          '#1a2230',
      waterSurf:     '#0d4060',
      ship_hull:     '#250a12',
      crane_col:     '#3a4560',
      crane_bm:      '#4a5570',
      skyGrad:       ['#050e1a', '#0a1a2e'],
      waterGrad:     ['#0a2035', '#061018'],
      barBg:         '#1a2230',
      barBorder:     '#3a4858',
    };
  }
  let C = buildColors(false);

  // ── Dibujar fondo (cielo, agua) ──────────────────────────────────────────
  function drawBackground() {
    const y_water = toCanvasY(-5);
    const sky_grad = ctx.createLinearGradient(0, 0, 0, y_water);
    sky_grad.addColorStop(0, C.skyGrad[0]);
    sky_grad.addColorStop(1, C.skyGrad[1]);
    ctx.fillStyle = sky_grad;
    ctx.fillRect(0, 0, W, y_water);

    const water_grad = ctx.createLinearGradient(0, y_water, 0, H);
    water_grad.addColorStop(0, C.waterGrad[0]);
    water_grad.addColorStop(1, C.waterGrad[1]);
    ctx.fillStyle = water_grad;
    ctx.fillRect(0, y_water, W, H - y_water);

    ctx.strokeStyle = C.waterSurf;
    ctx.lineWidth = 1.5;
    ctx.beginPath();
    ctx.moveTo(0, y_water);
    ctx.lineTo(W, y_water);
    ctx.stroke();

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
  function drawDock() {
    const y_dock_top = toCanvasY(0);
    const x_dock_r   = toCanvasX(0);
    const x_dock_l   = 0;

    ctx.fillStyle = C.dock;
    ctx.fillRect(x_dock_l, y_dock_top, x_dock_r - x_dock_l, H - y_dock_top);
    ctx.strokeStyle = C.dockEdge;
    ctx.lineWidth = 1.5;
    ctx.beginPath();
    ctx.moveTo(x_dock_r, y_dock_top);
    ctx.lineTo(x_dock_l, y_dock_top);
    ctx.stroke();

    ctx.fillStyle = C.dockEdge;
    ctx.fillRect(x_dock_r - 4, toCanvasY(PHYS.alt_borde), 4, H);

    ctx.fillStyle = C.text;
    ctx.font = `${Math.max(9, mToPx(2))}px Consolas`;
    ctx.fillText('MUELLE', x_dock_l + 4, y_dock_top - 5);

    drawContainerStack(PHYS.xt_min, -0.1, 0, C.containerDock);
  }

  // ── Dibujar barco (xt > 0) ───────────────────────────────────────────────
  function drawShip() {
    const x_ship_l = toCanvasX(1);
    const x_ship_r = toCanvasX(PHYS.xt_max + 3);
    const y_deck   = toCanvasY(-2);
    const y_hull_b = toCanvasY(PHYS.hold_depth * PHYS.Hc - 2);

    ctx.fillStyle = C.ship_hull;
    ctx.beginPath();
    ctx.moveTo(x_ship_l, y_deck);
    ctx.lineTo(x_ship_l, y_hull_b);
    ctx.lineTo(x_ship_r + mToPx(2), y_hull_b);
    ctx.lineTo(x_ship_r, y_deck);
    ctx.closePath();
    ctx.fill();
    ctx.strokeStyle = C.shipEdge;
    ctx.lineWidth = 1.5;
    ctx.stroke();

    ctx.fillStyle = C.ship;
    ctx.fillRect(x_ship_l, y_deck, x_ship_r - x_ship_l, toCanvasY(-8) - y_deck);
    ctx.strokeStyle = C.shipEdge;
    ctx.lineWidth = 1;
    ctx.strokeRect(x_ship_l, y_deck, x_ship_r - x_ship_l, toCanvasY(-8) - y_deck);

    ctx.fillStyle = C.text;
    ctx.font = `${Math.max(9, mToPx(2))}px Consolas`;
    ctx.fillText('BARCO', x_ship_l + 4, y_deck - 5);

    ctx.fillStyle = C.shipEdge;
    ctx.fillRect(x_ship_l - 4, toCanvasY(PHYS.alt_borde), 4, y_hull_b - toCanvasY(PHYS.alt_borde));

    const x_ship_wall = toCanvasX(PHYS.xt_max);
    ctx.fillStyle = C.shipEdge;
    ctx.fillRect(x_ship_wall - 2, toCanvasY(PHYS.alt_borde), 5, H);

    drawContainerStack(1, PHYS.xt_max - 0.1, PHYS.hold_depth, C.containerShip);
  }

  // ── Dibujar stacks de containers ────────────────────────────────────────
  function drawContainerStack(x_start, x_end, y_min_stacks = 0, color) {
    const Wc_px = mToPx(PHYS.Wc);
    const Hc_px = toCanvasY(0) - toCanvasY(PHYS.Hc);
    const N = PHYS.h_vec.length;

    for (let i = 0; i < N; i++) {
      const x_m = PHYS.xt_min + (i + 0.5) * PHYS.Wc;
      if (x_m < x_start || x_m > x_end) continue;
      const stacks_top = Math.round(PHYS.h_vec[i]);
      if (stacks_top <= y_min_stacks) continue;
      const visW = Math.max(2, Wc_px * 0.90);
      const cx = toCanvasX(x_m) - visW / 2;
      for (let s = y_min_stacks; s < stacks_top; s++) {
        const cy = toCanvasY((s + 1) * PHYS.Hc) + 1;
        ctx.fillStyle = color;
        ctx.fillRect(cx, cy, visW, Hc_px - 1);
        ctx.strokeStyle = '#607080';
        ctx.lineWidth = 0.5;
        ctx.strokeRect(cx, cy, visW, Hc_px - 1);
      }
    }
  }

  // ── Dibujar estructura de la grúa (portal en A + boom) ──────────────────
  function drawCraneStructure() {
    const y_ground = toCanvasY(0);
    const y_top    = toCanvasY(PHYS.Yt0);

    // Columnas exteriores
    const land_top_x  = PHYS.portal_land_x;
    const sea_top_x   = PHYS.portal_sea_x;
    const land_base_x = land_top_x - PHYS.portal_base_spread;
    const sea_base_x  = sea_top_x  + PHYS.portal_base_spread;

    // Columnas interiores
    const col_sep     = 3.5;
    const land_in_top  = land_top_x  + col_sep;
    const land_in_base = land_base_x + col_sep;
    const sea_in_top   = sea_top_x   - col_sep;
    const sea_in_base  = sea_base_x  - col_sep;

    // x de una columna a altura h dada
    function colX(top_x, base_x, h) {
      return top_x + (base_x - top_x) * (1 - h / PHYS.Yt0);
    }

    const leg_w   = Math.max(3, mToPx(0.75));
    const boom_h  = Math.max(5, mToPx(0.9));
    const x_bl    = toCanvasX(PHYS.boom_backreach);
    const x_br    = toCanvasX(PHYS.boom_tip);
    const h_cross = PHYS.Yt0 * 0.55;
    const y_cross = toCanvasY(h_cross);
    const cross_h = Math.max(3, mToPx(0.75));

    // centros de cada pata (para kingpost y machine room)
    const kp_lx  = (land_top_x + land_in_top) / 2;
    const kp_sx  = (sea_top_x  + sea_in_top)  / 2;
    const kp_h   = 8;   // [m] altura del kingpost sobre el boom
    const kp_apex_lx = kp_lx;
    const kp_apex_sx = kp_sx;
    const y_kp_l = toCanvasY(PHYS.Yt0 + kp_h);
    const y_kp_s = toCanvasY(PHYS.Yt0 + kp_h);

    // ── Boom horizontal (cercha: chord superior + inferior + diagonales) ──
    const boom_grad = ctx.createLinearGradient(0, y_top - boom_h, 0, y_top + boom_h);
    boom_grad.addColorStop(0, C.crane_bm);
    boom_grad.addColorStop(0.5, C.crane_col);
    boom_grad.addColorStop(1, C.crane_col);
    ctx.fillStyle = boom_grad;
    ctx.fillRect(x_bl, y_top - boom_h / 2, x_br - x_bl, boom_h);
    ctx.strokeStyle = C.rail;
    ctx.lineWidth = 0.5;
    ctx.strokeRect(x_bl, y_top - boom_h / 2, x_br - x_bl, boom_h);

    // Diagonales de cercha sobre el boom
    ctx.strokeStyle = C.crane_bm;
    ctx.lineWidth = Math.max(0.5, mToPx(0.15));
    const truss_sp = mToPx(7);
    let dir = 1;
    for (let tx = x_bl; tx < x_br - 1; tx += truss_sp) {
      const nx = Math.min(tx + truss_sp, x_br);
      ctx.beginPath();
      if (dir > 0) {
        ctx.moveTo(tx, y_top - boom_h / 2);
        ctx.lineTo(nx, y_top + boom_h / 2);
      } else {
        ctx.moveTo(tx, y_top + boom_h / 2);
        ctx.lineTo(nx, y_top - boom_h / 2);
      }
      ctx.stroke();
      dir *= -1;
    }

    // ── Contrapeso en extremo del backreach ───────────────────────────────
    const cw_w = Math.max(6, mToPx(2.5));
    const cw_h = Math.max(5, mToPx(2.0));
    ctx.fillStyle = C.crane_col;
    ctx.fillRect(x_bl, y_top - boom_h / 2 - cw_h, cw_w, cw_h);
    ctx.strokeStyle = C.crane_bm;
    ctx.lineWidth = 0.5;
    ctx.strokeRect(x_bl, y_top - boom_h / 2 - cw_h, cw_w, cw_h);

    // ── Machine room (caja sobre portal, lado mar) ────────────────────────
    const mr_w  = Math.max(12, mToPx(6));
    const mr_h  = Math.max(10, mToPx(4));
    const mr_cx = (toCanvasX(sea_in_top) + toCanvasX(sea_top_x)) / 2;
    const mr_y  = y_top - boom_h / 2 - mr_h;
    ctx.fillStyle = C.crane_col;
    ctx.fillRect(mr_cx - mr_w / 2, mr_y, mr_w, mr_h);
    ctx.strokeStyle = C.crane_bm;
    ctx.lineWidth = 1;
    ctx.strokeRect(mr_cx - mr_w / 2, mr_y, mr_w, mr_h);
    // Ventanas machine room
    ctx.fillStyle = C.crane_bm;
    ctx.fillRect(mr_cx - mr_w * 0.35, mr_y + mr_h * 0.15, mr_w * 0.7, mr_h * 0.35);

    // ── Columnas (4 total) ────────────────────────────────────────────────
    function drawLeg(top_x, base_x) {
      const xt_c = toCanvasX(top_x);
      const xb_c = toCanvasX(base_x);
      const leg_grad = ctx.createLinearGradient(xt_c, y_top, xb_c, y_ground);
      leg_grad.addColorStop(0, C.crane_bm);
      leg_grad.addColorStop(1, C.crane_col);
      ctx.fillStyle = leg_grad;
      ctx.beginPath();
      ctx.moveTo(xt_c - leg_w / 2, y_top);
      ctx.lineTo(xt_c + leg_w / 2, y_top);
      ctx.lineTo(xb_c + leg_w / 2, y_ground);
      ctx.lineTo(xb_c - leg_w / 2, y_ground);
      ctx.closePath();
      ctx.fill();
      ctx.strokeStyle = C.rail;
      ctx.lineWidth = 0.5;
      ctx.stroke();
    }
    drawLeg(land_top_x,  land_base_x);
    drawLeg(land_in_top, land_in_base);
    drawLeg(sea_in_top,  sea_in_base);
    drawLeg(sea_top_x,   sea_base_x);

    // ── Crossbeam principal (~55% altura) ────────────────────────────────
    const land_out_cx = colX(land_top_x, land_base_x, h_cross);
    const sea_out_cx  = colX(sea_top_x,  sea_base_x,  h_cross);
    const cross_grad  = ctx.createLinearGradient(0, y_cross - cross_h, 0, y_cross + cross_h);
    cross_grad.addColorStop(0, C.crane_bm);
    cross_grad.addColorStop(1, C.crane_col);
    ctx.fillStyle = cross_grad;
    ctx.fillRect(
      toCanvasX(land_out_cx) - leg_w / 2,
      y_cross - cross_h / 2,
      toCanvasX(sea_out_cx) - toCanvasX(land_out_cx) + leg_w,
      cross_h
    );

    // ── Crossbeam inferior (~20% altura) ─────────────────────────────────
    const h_low = PHYS.Yt0 * 0.20;
    const land_low_cx = colX(land_top_x, land_base_x, h_low);
    const sea_low_cx  = colX(sea_top_x,  sea_base_x,  h_low);
    const y_low = toCanvasY(h_low);
    ctx.fillStyle = C.crane_col;
    ctx.fillRect(
      toCanvasX(land_low_cx) - leg_w / 2,
      y_low - cross_h * 0.6,
      toCanvasX(sea_low_cx) - toCanvasX(land_low_cx) + leg_w,
      cross_h * 0.6
    );

    // ── X-bracing dentro de cada pata ────────────────────────────────────
    ctx.strokeStyle = C.crane_col;
    ctx.lineWidth = Math.max(1, mToPx(0.18));

    function drawXBrace(x1, x2, y_top_m, y_bot_m) {
      const yT  = toCanvasY(y_top_m);
      const yB  = toCanvasY(y_bot_m);
      const xT1 = toCanvasX(colX(x1[0], x1[1], y_top_m));
      const xT2 = toCanvasX(colX(x2[0], x2[1], y_top_m));
      const xB1 = toCanvasX(colX(x1[0], x1[1], y_bot_m));
      const xB2 = toCanvasX(colX(x2[0], x2[1], y_bot_m));
      ctx.beginPath(); ctx.moveTo(xT1, yT); ctx.lineTo(xB2, yB); ctx.stroke();
      ctx.beginPath(); ctx.moveTo(xT2, yT); ctx.lineTo(xB1, yB); ctx.stroke();
    }

    const L_out = [land_top_x,  land_base_x];
    const L_in  = [land_in_top, land_in_base];
    const S_in  = [sea_in_top,  sea_in_base];
    const S_out = [sea_top_x,   sea_base_x];
    drawXBrace(L_out, L_in, PHYS.Yt0, h_cross);
    drawXBrace(L_out, L_in, h_cross,  0);
    drawXBrace(S_in,  S_out, PHYS.Yt0, h_cross);
    drawXBrace(S_in,  S_out, h_cross,  0);

    // ── Kingpost en A (torre triangular sobre cada pata) ──────────────────
    const kp_base_half = col_sep * 0.9;
    ctx.fillStyle = C.crane_bm;

    function drawKingpost(apex_x, y_apex, base_cx) {
      const lw = Math.max(2.5, mToPx(0.4));
      ctx.lineWidth = lw;
      ctx.strokeStyle = C.crane_bm;
      // Pata izquierda del kingpost
      ctx.beginPath();
      ctx.moveTo(toCanvasX(base_cx - kp_base_half), y_top);
      ctx.lineTo(toCanvasX(apex_x), y_apex);
      ctx.stroke();
      // Pata derecha del kingpost
      ctx.beginPath();
      ctx.moveTo(toCanvasX(base_cx + kp_base_half), y_top);
      ctx.lineTo(toCanvasX(apex_x), y_apex);
      ctx.stroke();
      // Nodo en el apex
      ctx.beginPath();
      ctx.arc(toCanvasX(apex_x), y_apex, Math.max(2, mToPx(0.3)), 0, Math.PI * 2);
      ctx.fillStyle = C.crane_bm;
      ctx.fill();
    }

    drawKingpost(kp_apex_lx, y_kp_l, kp_lx);
    drawKingpost(kp_apex_sx, y_kp_s, kp_sx);

    // ── Tirantes (múltiples por cada kingpost) ────────────────────────────
    ctx.lineWidth = Math.max(0.8, mToPx(0.1));
    ctx.strokeStyle = C.crane_bm;

    function stays(apex_x, y_apex, targets) {
      targets.forEach(([tx, ty]) => {
        ctx.beginPath();
        ctx.moveTo(toCanvasX(apex_x), y_apex);
        ctx.lineTo(toCanvasX(tx), toCanvasY(ty));
        ctx.stroke();
      });
    }

    // Kingpost tierra → puntos del boom backreach (3 tirantes)
    const bl_m = PHYS.boom_backreach;
    stays(kp_apex_lx, y_kp_l, [
      [bl_m + 1,  PHYS.Yt0 - 0.5],
      [bl_m + 7,  PHYS.Yt0 - 0.3],
      [bl_m + 14, PHYS.Yt0 - 0.1],
    ]);

    // Kingpost mar → puntos del boom forestay (3 tirantes)
    const br_m = PHYS.boom_tip;
    stays(kp_apex_sx, y_kp_s, [
      [br_m - 1,  PHYS.Yt0 - 0.5],
      [br_m - 9,  PHYS.Yt0 - 0.3],
      [br_m - 18, PHYS.Yt0 - 0.1],
    ]);

    // ── Escala X ──────────────────────────────────────────────────────────
    ctx.fillStyle = C.text;
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
    const tw      = Math.max(16, mToPx(2.8));
    const th      = Math.max(8,  mToPx(1.1));

    const L = PHYS.Yt0 - yh;
    const x_spread_m = xt + L * Math.sin(tita_l);
    const cx_spread  = toCanvasX(x_spread_m);
    const y_spreader = toCanvasY(yh);
    const Wc_px = mToPx(PHYS.Wc);
    const Hc_px = toCanvasY(0) - toCanvasY(PHYS.Hc);
    const sw = Math.max(16, Wc_px * 0.85);
    const sh = Math.max(4,  mToPx(0.3));

    // Cable
    ctx.strokeStyle = C.cable;
    ctx.lineWidth = Math.max(1, mToPx(0.05));
    ctx.beginPath();
    ctx.moveTo(cx, y_rail + th / 2);
    ctx.lineTo(cx_spread, y_spreader - sh / 2);
    ctx.stroke();

    // Container enganchado
    if (caught) {
      ctx.fillStyle = C.container;
      ctx.fillRect(cx_spread - Wc_px / 2, y_spreader + sh / 2 + 1, Wc_px, Hc_px);
      ctx.strokeStyle = C.containerEdge;
      ctx.lineWidth = 1.5;
      ctx.strokeRect(cx_spread - Wc_px / 2, y_spreader + sh / 2 + 1, Wc_px, Hc_px);
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
    sp_grad.addColorStop(0, '#ffe040');
    sp_grad.addColorStop(1, '#e0b000');
    ctx.fillStyle = sp_grad;
    ctx.fillRect(cx_spread - sw / 2, y_spreader - sh / 2, sw, sh);
    ctx.strokeStyle = '#fff080';
    ctx.lineWidth = 1.5;
    ctx.strokeRect(cx_spread - sw / 2, y_spreader - sh / 2, sw, sh);

    // Puntos de enganche
    const tlk_color = caught ? '#40ff80' : '#808090';
    [[-1, -1], [1, -1], [-1, 1], [1, 1]].forEach(([dx, dy]) => {
      ctx.beginPath();
      ctx.arc(cx_spread + dx * sw * 0.42, y_spreader + dy * sh * 0.1, 2, 0, Math.PI * 2);
      ctx.fillStyle = tlk_color;
      ctx.fill();
    });

    // Cabina del operario (cuelga del carro, lado tierra)
    const cab_w  = Math.max(9, mToPx(2.2));
    const cab_h  = Math.max(7, mToPx(2.0));
    const cab_x  = cx - tw / 2 - cab_w - mToPx(0.3);
    const cab_y  = y_rail + th;
    // Cuerpo
    ctx.fillStyle = C.trolley;
    ctx.fillRect(cab_x, cab_y, cab_w, cab_h);
    ctx.strokeStyle = C.trolleyEdge;
    ctx.lineWidth = 1.2;
    ctx.strokeRect(cab_x, cab_y, cab_w, cab_h);
    // Ventanas (banda horizontal)
    const wp = Math.max(1.5, cab_w * 0.12);
    ctx.fillStyle = '#4a9abf';
    ctx.fillRect(cab_x + wp, cab_y + wp, cab_w - wp * 2, cab_h * 0.45);
    ctx.strokeStyle = '#80c8e8';
    ctx.lineWidth = 0.5;
    ctx.strokeRect(cab_x + wp, cab_y + wp, cab_w - wp * 2, cab_h * 0.45);
    // División central ventana
    ctx.beginPath();
    ctx.moveTo(cab_x + cab_w / 2, cab_y + wp);
    ctx.lineTo(cab_x + cab_w / 2, cab_y + wp + cab_h * 0.45);
    ctx.stroke();
    // Soporte de la cabina al carro (dos pernos)
    ctx.strokeStyle = C.trolleyEdge;
    ctx.lineWidth = 1;
    [cab_x + cab_w * 0.25, cab_x + cab_w * 0.75].forEach(hx => {
      ctx.beginPath();
      ctx.moveTo(hx, cab_y);
      ctx.lineTo(hx, y_rail + th * 0.5);
      ctx.stroke();
    });

    // Polea en el carro
    ctx.beginPath();
    ctx.arc(cx, y_rail, Math.max(3, mToPx(0.25)), 0, Math.PI * 2);
    ctx.fillStyle = C.pulley;
    ctx.fill();

    // Carro (gris oscuro)
    const trolley_grad = ctx.createLinearGradient(cx - tw / 2, y_rail - th, cx + tw / 2, y_rail + th);
    trolley_grad.addColorStop(0, C.trolleyEdge);
    trolley_grad.addColorStop(1, C.trolley);
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
      ctx.strokeStyle = C.trolleyEdge;
      ctx.lineWidth = 0.5;
      ctx.stroke();
    });

    // Etiquetas
    ctx.textAlign = 'center';
    ctx.fillStyle = C.text;
    ctx.font = '9px Consolas';
    ctx.fillText(`xt=${xt.toFixed(1)}m`, cx, y_rail - th - 3);
    ctx.font = '12px Consolas';
    ctx.fillText(`yh=${yh.toFixed(1)}m`, cx_spread, y_spreader - sh - 8);
    if (Math.abs(tita_l) > 0.001) {
      ctx.fillStyle = '#e0a040';
      ctx.fillText(`θ=${(tita_l * 180 / Math.PI).toFixed(1)}°`, cx_spread, y_spreader + sh / 2 + 18);
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
      ctx.fillStyle = C.barBg;
      ctx.fillRect(x, y_mid - bar_h / 2, bar_w, bar_h);
      const fill_h = Math.abs(frac) * (bar_h / 2);
      const fill_y = frac >= 0 ? y_mid - fill_h : y_mid;
      ctx.fillStyle = frac > 0 ? '#3080d0' : '#d04030';
      ctx.fillRect(x, fill_y, bar_w, fill_h);
      ctx.strokeStyle = C.barBorder;
      ctx.lineWidth = 0.5;
      ctx.strokeRect(x, y_mid - bar_h / 2, bar_w, bar_h);
      ctx.strokeStyle = C.barBorder;
      ctx.beginPath();
      ctx.moveTo(x - 2, y_mid);
      ctx.lineTo(x + bar_w + 2, y_mid);
      ctx.stroke();
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

    if ((state.modo_auto || state.modo_manual_auto) && state.i_sel >= 1 && state.i_sel <= 33) {
      const xi   = PHYS.xt_min + (state.i_sel - 0.5) * PHYS.Wc;
      const cx1  = toCanvasX(xi - PHYS.Wc / 2);
      const cx2  = toCanvasX(xi + PHYS.Wc / 2);
      ctx.fillStyle = 'rgba(255, 220, 50, 0.15)';
      ctx.fillRect(cx1, 0, cx2 - cx1, H);
      ctx.strokeStyle = 'rgba(255, 220, 50, 0.5)';
      ctx.lineWidth = 1;
      ctx.beginPath();
      ctx.moveTo((cx1 + cx2) / 2, H - M.bottom + 2);
      ctx.lineTo((cx1 + cx2) / 2 - 4, H - M.bottom + 10);
      ctx.lineTo((cx1 + cx2) / 2 + 4, H - M.bottom + 10);
      ctx.closePath();
      ctx.fillStyle = 'rgba(255, 220, 50, 0.7)';
      ctx.fill();
    }

    drawCraneStructure();
    drawTrolleyAndHoist(state.xt, state.yh, state.hay_container, state.tita_l);
    drawVelocityBars(state.vt, state.vh);
  }

  // ── Init + loop ───────────────────────────────────────────────────────────
  function init() {
    canvas = document.getElementById('craneCanvas');
    if (!canvas) return;
    ctx = canvas.getContext('2d');
    W = canvas.offsetWidth || 800;
    H = canvas.offsetHeight || 320;
    canvas.width  = W;
    canvas.height = H;

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
    if (data.i_sel           !== undefined) state.i_sel           = parseInt(data.i_sel) || 0;
    if (data.modo_auto       !== undefined) state.modo_auto       = parseInt(data.modo_auto) || 0;
    if (data.modo_manual_auto !== undefined) state.modo_manual_auto = parseInt(data.modo_manual_auto) || 0;
    if (Array.isArray(data.yc0_vec) && data.yc0_vec.length === 33) {
      PHYS.h_vec = data.yc0_vec.map(v => v / PHYS.Hc);
      PHYS.h_vec[12] = 0;
      PHYS.h_vec[32] = 0;
    }
  }

  function setTheme(isLight) { C = buildColors(isLight); }

  return { init, update, setTheme };
})();
