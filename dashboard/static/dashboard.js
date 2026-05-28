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
    document.getElementById('fps-counter').textContent = `${(1 / avgDt).toFixed(1)} Hz`;
  }
  lastTelemetryTime = now;

  CraneViz.update(data);
  updateUI(data);
  updateCharts(data);
});

// ── Actualizar UI de estado ───────────────────────────────────────────────────
function updateUI(data) {
  setLabel('lbl-xt', data.xt, 2, 'm');
  setLabel('lbl-yh', data.yh, 2, 'm');
  setLabel('lbl-vt', data.vt, 2, 'm/s');
  setLabel('lbl-vh', data.vh, 2, 'm/s');
  setLabel('lbl-tita', data.tita_l, 4, 'rad');
  setLabel('lbl-m-est', data.m_container_est, 0, 'kg');

  updateConnectionBadge(data.connected);

  // Badge de modo en header
  const modoBadge = document.getElementById('modo-badge');
  if (modoBadge) modoBadge.textContent = data.modo_nombre || 'REPOSO';

  updateModeFlags(data);
  updateActuadores(data);
  updateFaults(data);
  updateFCs(data);
}

// ── Modo activo + flags booleanos ─────────────────────────────────────────────
function updateModeFlags(data) {
  const modoActivo = document.getElementById('modo-activo-badge');
  if (modoActivo) {
    modoActivo.textContent = data.modo_nombre || 'REPOSO';
    // Color según modo
    modoActivo.className = 'modo-badge-large';
    if (data.modo_error)          modoActivo.classList.add('modo-error');
    else if (data.modo_muerto)    modoActivo.classList.add('modo-muerto');
    else if (data.recuperacion)   modoActivo.classList.add('modo-recuperacion');
    else if (data.modo_auto || data.modo_manual_auto) modoActivo.classList.add('modo-auto');
    else if (data.modo_manual)    modoActivo.classList.add('modo-manual');
  }

  const flagMap = {
    'flag-reposo':   data.modo_reposo,
    'flag-manual':   data.modo_manual,
    'flag-auto':     data.modo_auto,
    'flag-man-auto': data.modo_manual_auto,
    'flag-recup':    data.recuperacion,
    'flag-muerto':   data.modo_muerto,
    'flag-error':    data.modo_error,
  };
  for (const [id, val] of Object.entries(flagMap)) {
    const el = document.getElementById(id);
    if (!el) continue;
    el.className = 'flag-item' + (val ? ' flag-on' : '');
    if (val && id === 'flag-muerto') el.classList.add('flag-danger');
    if (val && id === 'flag-error')  el.classList.add('flag-danger');
    if (val && id === 'flag-recup')  el.classList.add('flag-warn');
  }
}

// ── Actuadores ────────────────────────────────────────────────────────────────
function updateActuadores(data) {
  setIndicator('ind-freno-c',   data.freno_c,       'warning');
  setIndicator('ind-freno-h',   data.freno_h,       'warning');
  setIndicator('ind-tlk',       data.tlk,           'active');
  setIndicator('ind-container', data.hay_container, 'active');
}

// ── Fallas ────────────────────────────────────────────────────────────────────
const FALLA_MAP = {
  'ind-falla_man':       'FALLA_MAN',
  'ind-falla_wd':        'FALLA_WD',
  'ind-falla_carro_der': 'FALLA_CARRO_DER',
  'ind-falla_carro_izq': 'FALLA_CARRO_IZQ',
  'ind-falla_izaje_inf': 'FALLA_IZAJE_INF',
  'ind-falla_izaje_sup': 'FALLA_IZAJE_SUP',
  'ind-falla_izaje_sv':  'FALLA_IZAJE_SV',
  'ind-falla_carro_sv':  'FALLA_CARRO_SV',
  'ind-falla_sobrecarga':'FALLA_SOBRECARGA',
};

function updateFaults(data) {
  for (const [id, key] of Object.entries(FALLA_MAP)) {
    const el = document.getElementById(id);
    if (el) el.className = 'falla-item' + (data[key] ? ' falla-on' : '');
  }
  const banner = document.getElementById('any-falla-banner');
  if (banner) banner.className = 'falla-banner' + (data.any_falla ? '' : ' hidden');
}

// ── Fines de carrera ──────────────────────────────────────────────────────────
const FC_MAP = {
  'ind-fc_der': 'FC_der',
  'ind-fc_izq': 'FC_izq',
  'ind-fc_sup': 'FC_sup',
  'ind-fc_inf': 'FC_inf',
};

function updateFCs(data) {
  for (const [id, key] of Object.entries(FC_MAP)) {
    const el = document.getElementById(id);
    if (el) el.className = 'fc-item' + (data[key] ? ' fc-on' : '');
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────
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

// ── Charts Chart.js ───────────────────────────────────────────────────────────
function makeChart(canvasId, label1, label2, color1, color2, yMin, yMax) {
  const canvas = document.getElementById(canvasId);
  if (!canvas) return null;
  return new Chart(canvas, {
    type: 'line',
    data: {
      labels: [],
      datasets: [
        { label: label1, data: [], borderColor: color1, backgroundColor: color1 + '22',
          borderWidth: 1.5, pointRadius: 0, tension: 0.3 },
        { label: label2, data: [], borderColor: color2, backgroundColor: color2 + '22',
          borderWidth: 1.5, pointRadius: 0, tension: 0.3 },
      ],
    },
    options: {
      animation: false,
      responsive: true,
      maintainAspectRatio: false,
      interaction: { mode: 'index', intersect: false },
      plugins: { legend: { labels: { color: '#7a8aaa', font: { size: 10 }, boxWidth: 12 } } },
      scales: {
        x: { ticks: { color: '#4a5570', maxTicksLimit: 6, font: { size: 9 } }, grid: { color: '#1a2230' } },
        y: { min: yMin, max: yMax, ticks: { color: '#4a5570', maxTicksLimit: 5, font: { size: 9 } }, grid: { color: '#1a2230' } },
      },
    },
  });
}

let chartPos = null;
let chartVel = null;
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
      chart.data.datasets.forEach(ds => ds.data.shift());
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
    const cx = c.width / 2, cy = c.height / 2;
    ctx.clearRect(0, 0, c.width, c.height);
    ctx.beginPath(); ctx.arc(cx, cy, R, 0, Math.PI * 2);
    ctx.fillStyle = STICK_BG; ctx.fill();
    ctx.strokeStyle = STICK_RING; ctx.lineWidth = 2; ctx.stroke();
    ctx.strokeStyle = CROSS_CLR; ctx.lineWidth = 1;
    ctx.beginPath();
    ctx.moveTo(cx - R, cy); ctx.lineTo(cx + R, cy);
    ctx.moveTo(cx, cy - R); ctx.lineTo(cx, cy + R);
    ctx.stroke();
    const tx = cx + (axis === 'x' ? s.ax : 0) * R;
    const ty = cy + (axis === 'y' ? s.ay : 0) * R;
    const tr = 14;
    const grad = ctx.createRadialGradient(tx - 2, ty - 2, 1, tx, ty, tr);
    grad.addColorStop(0, '#80c0ff'); grad.addColorStop(1, '#3060c0');
    ctx.beginPath(); ctx.arc(tx, ty, tr, 0, Math.PI * 2);
    ctx.fillStyle = grad; ctx.fill();
    ctx.strokeStyle = '#60a0ff'; ctx.lineWidth = 2; ctx.stroke();
  }

  function getVal(e) {
    const rect = c.getBoundingClientRect();
    const clientX = e.touches ? e.touches[0].clientX : e.clientX;
    const clientY = e.touches ? e.touches[0].clientY : e.clientY;
    const cx = c.width / 2, cy = c.height / 2;
    return {
      ax: Math.max(-1, Math.min(1, (clientX - rect.left - cx) / R)),
      ay: Math.max(-1, Math.min(1, (clientY - rect.top  - cy) / R)),
    };
  }

  c.addEventListener('mousedown', (e) => { s.dragging = true; Object.assign(s, getVal(e)); emitJoystick(); });
  c.addEventListener('touchstart', (e) => { e.preventDefault(); s.dragging = true; Object.assign(s, getVal(e)); emitJoystick(); }, { passive: false });
  window.addEventListener('mousemove', (e) => { if (!s.dragging) return; Object.assign(s, getVal(e)); emitJoystick(); });
  window.addEventListener('touchmove', (e) => { if (!s.dragging) return; Object.assign(s, getVal(e)); emitJoystick(); }, { passive: false });
  window.addEventListener('mouseup',  () => { s.dragging = false; });
  window.addEventListener('touchend', () => { s.dragging = false; });

  setInterval(() => {
    if (!s.dragging) {
      let changed = false;
      ['ax', 'ay'].forEach(k => {
        if (Math.abs(s[k]) > RETURN_STEP) { s[k] -= Math.sign(s[k]) * RETURN_STEP; changed = true; }
        else if (s[k] !== 0)              { s[k] = 0; changed = true; }
      });
      if (changed) emitJoystick();
    }
    drawStick();
    const valEl = document.getElementById(stickKey === 'carro' ? 'val-carro' : 'val-izaje');
    if (valEl) valEl.textContent = (axis === 'x' ? s.ax : s.ay).toFixed(2);
    document.getElementById('gp-lx').textContent = stickState.carro.ax.toFixed(2);
    document.getElementById('gp-ry').textContent = stickState.izaje.ay.toFixed(2);
  }, 16);
}

function emitJoystick() {
  socket.emit('joystick', { lx: stickState.carro.ax, ry: stickState.izaje.ay });
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

// ── Verificar gamepad status ──────────────────────────────────────────────────
async function checkGamepadStatus() {
  try {
    const res = await fetch('/api/gamepad');
    const data = await res.json();
    const el = document.getElementById('gp-status');
    if (el) {
      el.textContent = data.ok ? 'ViGEm: OK' : 'ViGEm: no disponible';
      el.className   = 'gp-badge ' + (data.ok ? 'gp-ok' : 'gp-off');
    }
  } catch (e) {
    console.warn('[API] gamepad status error:', e);
  }
}

// ── GoldenLayout ──────────────────────────────────────────────────────────────
const GL_KEY = 'craneGL';

const GL_DEFAULT = {
  root: {
    type: 'row',
    content: [
      {
        type: 'column',
        width: 75,
        content: [
          {
            type: 'row',
            height: 80,
            content: [
              {
                type: 'column',
                width: 67,
                content: [
                  { type: 'component', componentType: 'crane',     title: 'Vista Grúa',     height: 65 },
                  { type: 'row', height: 35, content: [
                    { type: 'component', componentType: 'chart-pos', title: 'Posición (m)',    width: 50 },
                    { type: 'component', componentType: 'chart-vel', title: 'Velocidad (m/s)', width: 50 },
                  ]},
                ],
              },
            ],
          },
          { type: 'component', componentType: 'control', title: 'Control', height: 20 },
        ],
      },
      { type: 'component', componentType: 'status', title: 'Estado del Sistema', width: 25 },
    ],
  },
};

function cloneTpl(id) {
  return document.getElementById(id).content.cloneNode(true);
}

async function initGoldenLayout() {
  const ws = document.getElementById('workspace');

  let GoldenLayout, LayoutConfig;
  try {
    const mod = await import('https://esm.sh/golden-layout@2.6.0');
    GoldenLayout = mod.GoldenLayout;
    LayoutConfig = mod.LayoutConfig;
  } catch (e) {
    ws.innerHTML = `<div style="color:#ff6060;padding:2rem;font-family:monospace;font-size:1.2rem">ERROR: GoldenLayout no cargó.<br>${e.message}</div>`;
    return;
  }
  const layout = new GoldenLayout(ws);

  layout.registerComponentConstructor('crane',     class { constructor(c) { c.element.appendChild(cloneTpl('tpl-crane'));     } });
  layout.registerComponentConstructor('status',    class { constructor(c) { c.element.appendChild(cloneTpl('tpl-status'));    } });
  layout.registerComponentConstructor('chart-pos', class { constructor(c) { c.element.appendChild(cloneTpl('tpl-chart-pos')); } });
  layout.registerComponentConstructor('chart-vel', class { constructor(c) { c.element.appendChild(cloneTpl('tpl-chart-vel')); } });
  layout.registerComponentConstructor('control',   class { constructor(c) { c.element.appendChild(cloneTpl('tpl-control'));   } });

  // loadLayout es síncrono — cuando retorna, todos los elementos YA están en el DOM
  const saved = localStorage.getItem(GL_KEY);
  requestAnimationFrame(() => {
    let loaded = false;
    if (saved) {
      try {
        const resolved = JSON.parse(saved);
        layout.loadLayout(LayoutConfig.fromResolved(resolved));
        loaded = true;
      } catch (e) { console.warn('[GL] Layout guardado inválido, usando default:', e); }
    }
    if (!loaded) {
      try { layout.loadLayout(GL_DEFAULT); } catch (e2) {
        ws.innerHTML = `<div style="color:#ff6060;padding:2rem;font-family:monospace">GL Error: ${e2.message}</div>`;
        return;
      }
    }
    // Ahora sí: inicializar componentes (elementos ya en el DOM)
    if (document.getElementById('craneCanvas'))  CraneViz.init();
    if (document.getElementById('chartPos'))     chartPos = makeChart('chartPos', 'xt (m)',   'yh (m)',   COLORS.xt, COLORS.yh, -25, 55);
    if (document.getElementById('chartVel'))     chartVel = makeChart('chartVel', 'vt (m/s)', 'vh (m/s)', COLORS.vt, COLORS.vh, -5,  5);
    if (document.getElementById('stickCarro')) { initStick('stickCarro', 'carro', 'x'); initStick('stickIzaje', 'izaje', 'y'); }
  });

  // Guardar layout en cada cambio
  layout.on('stateChanged', () => {
    try { localStorage.setItem(GL_KEY, JSON.stringify(layout.saveLayout())); } catch (_) {}
  });

  // Reset layout
  document.getElementById('btn-reset-layout')?.addEventListener('click', () => {
    localStorage.removeItem(GL_KEY);
    location.reload();
  });
}

// ── Inicialización ────────────────────────────────────────────────────────────
document.addEventListener('DOMContentLoaded', () => {
  initGoldenLayout();
  checkGamepadStatus();
  setInterval(checkGamepadStatus, 10000);
});
