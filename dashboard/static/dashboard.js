/**
 * dashboard.js — Lógica principal del dashboard: SocketIO, charts, joystick virtual
 */

// ── Configuración de charts ───────────────────────────────────────────────────
const MAX_POINTS = 600;   // ~20s a 30Hz
const COLORS = {
  xt: '#4a90e2',
  yh: '#5bc4a0',
  vt: '#e2884a',
  vh: '#c05bc4',
};

// ── Estado del joystick virtual ──────────────────────────────────────────────
const stickState = {
  carro: { ax: 0, ay: 0, dragging: false },
  izaje: { ax: 0, ay: 0, dragging: false },
};
const RETURN_STEP = 0.06;
const STICK_BG    = '#1e2a3e';
const STICK_RING  = '#2e3e5e';
const THUMB_CLR   = '#4a90e2';
const CROSS_CLR   = '#2e3a50';

// ── FPS counter ───────────────────────────────────────────────────────────────
let lastTelemetryTime = 0;
let fpsAccum = [];

// ── Socket.IO ─────────────────────────────────────────────────────────────────
const socket = io({ transports: ['websocket', 'polling'] });

socket.on('connect', () => {
  console.log('[WS] Conectado al servidor');
});

socket.on('disconnect', () => {
  updateConnectionBadge(false);
});

socket.on('telemetry', (data) => {
  const now = performance.now();
  if (lastTelemetryTime > 0) {
    const dt = (now - lastTelemetryTime) / 1000;
    fpsAccum.push(dt);
    if (fpsAccum.length > 30) fpsAccum.shift();
    const avgDt = fpsAccum.reduce((a, b) => a + b, 0) / fpsAccum.length;
    const fps = 1 / avgDt;
    document.getElementById('fps-counter').textContent = `${fps.toFixed(1)} Hz`;
  }
  lastTelemetryTime = now;

  CraneViz.update(data);
  updateUI(data);
  updateCharts(data);
});

// ── Actualizar UI de estado ───────────────────────────────────────────────────
function updateUI(data) {
  // Labels numéricos
  setLabel('lbl-xt', data.xt,  2, 'm');
  setLabel('lbl-yh', data.yh,  2, 'm');
  setLabel('lbl-vt', data.vt,  2, 'm/s');
  setLabel('lbl-vh', data.vh,  2, 'm/s');

  // Badge conexión y modo
  updateConnectionBadge(data.connected);
  const modoBadge = document.getElementById('modo-badge');
  if (modoBadge) modoBadge.textContent = data.modo_nombre || 'REPOSO';

  // Estado Stateflow
  const stateEl = document.getElementById('state-name');
  if (stateEl) stateEl.textContent = data.estado_nombre || '---';

  // Árbol Stateflow
  updateStateflowTree(data);

  // Indicadores
  setIndicator('ind-freno-c', data.freno_c, 'warning');
  setIndicator('ind-freno-h', data.freno_h, 'warning');
  setIndicator('ind-tlk',     data.tlk,     'active');
  setIndicator('ind-caught',  data.caught,  'active');
}

function setLabel(id, val, dec, unit) {
  const el = document.getElementById(id);
  if (!el) return;
  if (val === undefined || val === null) { el.textContent = '---'; return; }
  el.textContent = `${parseFloat(val).toFixed(dec)} ${unit}`;
}

function updateConnectionBadge(connected) {
  const el = document.getElementById('connection-badge');
  if (!el) return;
  if (connected) {
    el.textContent = 'MATLAB OK';
    el.className = 'badge badge-on';
  } else {
    el.textContent = 'SIN DATOS';
    el.className = 'badge badge-off';
  }
}

function setIndicator(id, value, cls) {
  const el = document.getElementById(id);
  if (!el) return;
  el.className = 'indicator' + (value ? ` ${cls}` : '');
}

// Mapeo estado → nivel y sub-estado
const ESTADO_TREE = {
  0:  { n1: 'REPOSO',       sub: null },
  1:  { n1: 'MANUAL',       sub: null },
  2:  { n1: 'MODO_AUTO',    sub: 'Esperando' },
  3:  { n1: 'MODO_AUTO_FULL', sub: null },
  4:  { n1: 'RECUPERACION', sub: null },
  5:  { n1: 'ERROR',        sub: null },
  6:  { n1: 'MODO_AUTO_FULL', sub: 'SUBIR_INICIAL' },
  7:  { n1: 'MODO_AUTO_FULL', sub: 'IR_ORIGEN' },
  8:  { n1: 'MODO_AUTO_FULL', sub: 'BAJAR_ORIGEN' },
  9:  { n1: 'MODO_AUTO_FULL', sub: 'ENGANCHAR' },
  10: { n1: 'MODO_AUTO_FULL', sub: 'SUBIR_CARGADO' },
  11: { n1: 'MODO_AUTO_FULL', sub: 'IR_DESTINO' },
  12: { n1: 'MODO_AUTO_FULL', sub: 'BAJAR_DESTINO' },
  13: { n1: 'MODO_AUTO_FULL', sub: 'DESENGANCHAR' },
  14: { n1: 'MODO_AUTO_FULL', sub: 'FIN_MISION' },
};

function updateStateflowTree(data) {
  const estado = parseInt(data.estado || 0);
  const tree = ESTADO_TREE[estado] || { n1: `Estado ${estado}`, sub: null };

  const sf1  = document.getElementById('sf1-state');
  const sfSub = document.getElementById('sf-sub-state');
  const sfSubRow = document.getElementById('sf-subestado');

  if (sf1)  sf1.textContent = tree.n1;
  if (sfSub) sfSub.textContent = tree.sub || '---';
  if (sfSubRow) sfSubRow.style.opacity = tree.sub ? '1' : '0.4';
}

// ── Charts Chart.js ───────────────────────────────────────────────────────────
function makeChart(canvasId, label1, label2, color1, color2, yMin, yMax) {
  const canvas = document.getElementById(canvasId);
  if (!canvas) return null;
  return new Chart(canvas, {
    type: 'line',
    data: {
      labels: [],
      datasets: [
        {
          label: label1,
          data: [],
          borderColor: color1,
          backgroundColor: color1 + '22',
          borderWidth: 1.5,
          pointRadius: 0,
          tension: 0.3,
        },
        {
          label: label2,
          data: [],
          borderColor: color2,
          backgroundColor: color2 + '22',
          borderWidth: 1.5,
          pointRadius: 0,
          tension: 0.3,
        },
      ],
    },
    options: {
      animation: false,
      responsive: true,
      maintainAspectRatio: false,
      interaction: { mode: 'index', intersect: false },
      plugins: {
        legend: {
          labels: { color: '#7a8aaa', font: { size: 10 }, boxWidth: 12 },
        },
      },
      scales: {
        x: {
          ticks: { color: '#4a5570', maxTicksLimit: 6, font: { size: 9 } },
          grid: { color: '#1a2230' },
        },
        y: {
          min: yMin,
          max: yMax,
          ticks: { color: '#4a5570', maxTicksLimit: 5, font: { size: 9 } },
          grid: { color: '#1a2230' },
        },
      },
    },
  });
}

const chartPos = makeChart('chartPos', 'xt (m)', 'yh (m)', COLORS.xt, COLORS.yh, -25, 55);
const chartVel = makeChart('chartVel', 'vt (m/s)', 'vh (m/s)', COLORS.vt, COLORS.vh, -5, 5);

let t_start = null;

function updateCharts(data) {
  if (!chartPos || !chartVel) return;
  const now = Date.now();
  if (t_start === null) t_start = now;
  const t_s = ((now - t_start) / 1000).toFixed(1);

  function pushData(chart, v1, v2) {
    chart.data.labels.push(t_s + 's');
    chart.data.datasets[0].data.push(parseFloat(v1) || 0);
    chart.data.datasets[1].data.push(parseFloat(v2) || 0);
    if (chart.data.labels.length > MAX_POINTS) {
      chart.data.labels.shift();
      chart.data.datasets[0].data.shift();
      chart.data.datasets[1].data.shift();
    }
    chart.update('none');
  }

  pushData(chartPos, data.xt, data.yh);
  pushData(chartVel, data.vt, data.vh);
}

// ── Joystick virtual ──────────────────────────────────────────────────────────
function initStick(canvasId, stickKey, axis) {
  const c = document.getElementById(canvasId);
  if (!c) return;
  const s = stickState[stickKey];
  const ctx = c.getContext('2d');
  const R = c.width / 2 - 4;

  function drawStick() {
    const cx = c.width / 2;
    const cy = c.height / 2;
    ctx.clearRect(0, 0, c.width, c.height);

    // Fondo
    ctx.beginPath();
    ctx.arc(cx, cy, R, 0, Math.PI * 2);
    ctx.fillStyle = STICK_BG;
    ctx.fill();
    ctx.strokeStyle = STICK_RING;
    ctx.lineWidth = 2;
    ctx.stroke();

    // Cruces
    ctx.strokeStyle = CROSS_CLR;
    ctx.lineWidth = 1;
    ctx.beginPath();
    ctx.moveTo(cx - R, cy); ctx.lineTo(cx + R, cy);
    ctx.moveTo(cx, cy - R); ctx.lineTo(cx, cy + R);
    ctx.stroke();

    // Pulgar
    const tx = cx + (axis === 'x' ? s.ax : 0) * R;
    const ty = cy + (axis === 'y' ? s.ay : 0) * R;
    const tr = 14;
    const grad = ctx.createRadialGradient(tx - 2, ty - 2, 1, tx, ty, tr);
    grad.addColorStop(0, '#80c0ff');
    grad.addColorStop(1, '#3060c0');
    ctx.beginPath();
    ctx.arc(tx, ty, tr, 0, Math.PI * 2);
    ctx.fillStyle = grad;
    ctx.fill();
    ctx.strokeStyle = '#60a0ff';
    ctx.lineWidth = 2;
    ctx.stroke();
  }

  function getVal(e) {
    const rect = c.getBoundingClientRect();
    const clientX = e.touches ? e.touches[0].clientX : e.clientX;
    const clientY = e.touches ? e.touches[0].clientY : e.clientY;
    const cx = c.width / 2, cy = c.height / 2;
    const rx = (clientX - rect.left) - cx;
    const ry = (clientY - rect.top) - cy;
    return {
      ax: Math.max(-1, Math.min(1, rx / R)),
      ay: Math.max(-1, Math.min(1, ry / R)),
    };
  }

  c.addEventListener('mousedown', (e) => { s.dragging = true; const v = getVal(e); s.ax = v.ax; s.ay = v.ay; emitJoystick(); });
  c.addEventListener('touchstart', (e) => { e.preventDefault(); s.dragging = true; const v = getVal(e); s.ax = v.ax; s.ay = v.ay; emitJoystick(); }, { passive: false });
  window.addEventListener('mousemove', (e) => { if (!s.dragging) return; const v = getVal(e); s.ax = v.ax; s.ay = v.ay; emitJoystick(); });
  window.addEventListener('touchmove', (e) => { if (!s.dragging) return; const v = getVal(e); s.ax = v.ax; s.ay = v.ay; emitJoystick(); }, { passive: false });
  window.addEventListener('mouseup',   () => { s.dragging = false; });
  window.addEventListener('touchend',  () => { s.dragging = false; });

  // Return animation
  setInterval(() => {
    if (!s.dragging) {
      let changed = false;
      if (Math.abs(s.ax) > RETURN_STEP) { s.ax -= Math.sign(s.ax) * RETURN_STEP; changed = true; }
      else if (s.ax !== 0) { s.ax = 0; changed = true; }
      if (Math.abs(s.ay) > RETURN_STEP) { s.ay -= Math.sign(s.ay) * RETURN_STEP; changed = true; }
      else if (s.ay !== 0) { s.ay = 0; changed = true; }
      if (changed) emitJoystick();
    }
    drawStick();
    // Update labels
    const valEl = document.getElementById(stickKey === 'carro' ? 'val-carro' : 'val-izaje');
    if (valEl) valEl.textContent = (axis === 'x' ? s.ax : s.ay).toFixed(2);
    // Update gamepad display
    document.getElementById('gp-lx').textContent = stickState.carro.ax.toFixed(2);
    document.getElementById('gp-ry').textContent = stickState.izaje.ay.toFixed(2);
  }, 16);
}

function emitJoystick() {
  socket.emit('joystick', {
    lx: stickState.carro.ax,
    ry: stickState.izaje.ay,
  });
}

// ── Botones de control ────────────────────────────────────────────────────────
function btnDown(el) {
  el.classList.add('pressed');
  socket.emit('button', { name: el.dataset.name, pressed: true });
}
function btnUp(el) {
  el.classList.remove('pressed');
  socket.emit('button', { name: el.dataset.name, pressed: false });
}

// ── Verificar gamepad status desde API ───────────────────────────────────────
async function checkGamepadStatus() {
  try {
    const res = await fetch('/api/gamepad');
    const data = await res.json();
    const el = document.getElementById('gp-status');
    if (el) {
      if (data.ok) {
        el.textContent = 'ViGEm: OK';
        el.className = 'gp-badge gp-ok';
      } else {
        el.textContent = 'ViGEm: no disponible';
        el.className = 'gp-badge gp-off';
      }
    }
  } catch (e) {
    console.warn('[API] gamepad status error:', e);
  }
}

// ── Inicialización ────────────────────────────────────────────────────────────
document.addEventListener('DOMContentLoaded', () => {
  CraneViz.init();

  initStick('stickCarro', 'carro', 'x');
  initStick('stickIzaje', 'izaje', 'y');

  checkGamepadStatus();
  setInterval(checkGamepadStatus, 10000);
});
