/**
 * selector.js — Panel de selección de posición (i_sel)
 * Muestra el perfil de 33 columnas con alturas de containers y el cursor i_sel.
 */

const SelectorViz = (() => {
  const N      = 33;
  const XT_MIN = -30;
  const XT_MAX =  50;
  const HC     =  2.59;
  const INVALID = new Set([1, 13, 33]);   // 1-indexed

  let canvas, ctx, infoEl;
  let _data = { yc0_vec: Array(N).fill(0), i_sel: 0 };

  function xFromIndex(i) {
    return XT_MIN + (i / (N - 1)) * (XT_MAX - XT_MIN);
  }

  let SC = buildSC(false);

  function buildSC(light) {
    return light ? {
      bg:       '#d4dfe8',
      invalid:  '#b8c4cc',
      muelle:   '#4070a0',
      barco:    '#407858',
      hold:     '#a8b8c8',
      baseline: '#8090a8',
      divider:  '#90a0b8',
      lblMuelle:'#305080',
      lblBarco: '#306050',
      lblAxis:  '#506878',
    } : {
      bg:       '#0f1520',
      invalid:  '#1e2430',
      muelle:   '#2a5070',
      barco:    '#2a6050',
      hold:     '#0a1e2e',
      baseline: '#2a3448',
      divider:  '#3a4458',
      lblMuelle:'#2d5070',
      lblBarco: '#2d6050',
      lblAxis:  '#363f50',
    };
  }

  function baseColor(i0) {
    const i1 = i0 + 1;
    if (INVALID.has(i1))   return SC.invalid;
    if (i1 <= 12)          return SC.muelle;
    return SC.barco;
  }

  function draw() {
    if (!canvas || !ctx) return;

    const rect = canvas.getBoundingClientRect();
    if (rect.width < 1 || rect.height < 1) return;
    if (canvas.width !== Math.floor(rect.width) || canvas.height !== Math.floor(rect.height)) {
      canvas.width  = Math.floor(rect.width);
      canvas.height = Math.floor(rect.height);
    }
    const W = canvas.width;
    const H = canvas.height;

    ctx.clearRect(0, 0, W, H);

    // Layout
    const ML = 26, MR = 4, MT = 16, MB = 16;
    const chartW = W - ML - MR;
    const chartH = H - MT - MB;
    const colW   = chartW / N;
    const BASE_Y = H - MB;        // y=0 line on canvas
    const MAX_STACKS = 8;

    // Fondo
    ctx.fillStyle = SC.bg;
    ctx.fillRect(0, 0, W, H);

    const yc0_vec = _data.yc0_vec || Array(N).fill(0);
    const i_sel   = Math.round(_data.i_sel) || 0;

    // Divisor muelle/barco (entre col i=12 y i=13)
    const divX = ML + (13 / N) * chartW;

    // Columnas
    for (let i = 0; i < N; i++) {
      const barL  = ML + (i / N) * chartW;
      const barW  = Math.max(1, colW - 1);
      const h_m   = yc0_vec[i] || 0;
      const stacks = h_m / HC;
      const isSel  = (i + 1 === i_sel);

      if (stacks > 0) {
        const barH = Math.min((stacks / MAX_STACKS) * chartH, chartH);
        ctx.fillStyle = baseColor(i);
        ctx.fillRect(barL, BASE_Y - barH, barW, barH);
        ctx.strokeStyle = 'rgba(96,120,128,0.5)';
        ctx.lineWidth = 0.5;
        ctx.strokeRect(barL, BASE_Y - barH, barW, barH);
      } else if (stacks < 0) {
        // hold por debajo de la línea base
        const barH = Math.min((-stacks / MAX_STACKS) * chartH * 0.4, chartH * 0.25);
        ctx.fillStyle = SC.hold;
        ctx.fillRect(barL, BASE_Y, barW, barH);
      }

      if (isSel) {
        ctx.fillStyle = 'rgba(255, 208, 50, 0.2)';
        ctx.fillRect(barL, MT, barW, BASE_Y - MT + MB * 0.4);
        ctx.strokeStyle = '#ffd032';
        ctx.lineWidth = 1.5;
        ctx.strokeRect(barL + 0.75, MT, barW - 1.5, BASE_Y - MT + MB * 0.4);
      }
    }

    // Línea base
    ctx.strokeStyle = SC.baseline;
    ctx.lineWidth = 1;
    ctx.beginPath();
    ctx.moveTo(ML, BASE_Y);
    ctx.lineTo(W - MR, BASE_Y);
    ctx.stroke();

    // Divisor muelle / barco
    ctx.setLineDash([3, 3]);
    ctx.strokeStyle = SC.divider;
    ctx.lineWidth = 1;
    ctx.beginPath();
    ctx.moveTo(divX, MT);
    ctx.lineTo(divX, BASE_Y);
    ctx.stroke();
    ctx.setLineDash([]);

    // Etiquetas de zona
    ctx.font = '7px Consolas';
    ctx.textAlign = 'left';
    ctx.fillStyle = SC.lblMuelle;
    ctx.fillText('MUELLE', ML + 2, MT - 3);
    ctx.fillStyle = SC.lblBarco;
    ctx.fillText('BARCO', divX + 3, MT - 3);

    // Eje X (cada 20m)
    ctx.fillStyle = SC.lblAxis;
    ctx.font = '8px Consolas';
    ctx.textAlign = 'center';
    for (let x = XT_MIN; x <= XT_MAX; x += 20) {
      const i_f  = (x - XT_MIN) / (XT_MAX - XT_MIN) * (N - 1);
      const cx   = ML + (i_f / N) * chartW + colW / 2;
      ctx.fillText(`${x}`, cx, BASE_Y + 11);
    }
    ctx.textAlign = 'left';

    // Info strip
    if (infoEl) {
      if (i_sel >= 1 && i_sel <= N) {
        const i0    = i_sel - 1;
        const xt_m  = xFromIndex(i0);
        const h_m   = yc0_vec[i0] || 0;
        const nCont = h_m > 0 ? Math.max(0, Math.round(h_m / HC)) : 0;
        const valid = !INVALID.has(i_sel);
        infoEl.textContent = `Col: ${i_sel}  |  xt: ${xt_m.toFixed(1)} m  |  ${nCont} cont.  |  ${valid ? 'VÁLIDO' : 'INVÁLIDO'}`;
        infoEl.style.color  = valid ? '' : '#e04040';
      } else {
        infoEl.textContent = 'Col: --  |  xt: -- m  |  -- cont.';
        infoEl.style.color  = '';
      }
    }
  }

  function loop() {
    draw();
    requestAnimationFrame(loop);
  }

  function init() {
    canvas  = document.getElementById('selectorCanvas');
    if (!canvas) return;
    ctx     = canvas.getContext('2d');
    infoEl  = document.getElementById('selector-info');
    requestAnimationFrame(loop);
  }

  function update(data) {
    _data = data;
  }

  function setTheme(isLight) { SC = buildSC(isLight); }

  return { init, update, setTheme };
})();
