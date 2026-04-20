# CLAUDE.md — Proyecto AyCD 2025: Grúa Portacontenedores STS

## Contexto del proyecto

Control de velocidad de carro e izaje de una grúa STS para la materia **Autómatas y Control Discreto** (10mo semestre, UNCUYO). Implementado en MATLAB/Simulink con controladores PI discretos y observadores de estado Luenberger orden 3.

Modelo Simulink: `Proyecto_AyCD/controlador_torque.slx`

---

## Problemas conocidos del modelo (NO tocar sin entender)

### 1. Signal Editor hardcodeado — carro
`controlador_torque/Subsystem2/Signal Editor` genera la referencia de velocidad del carro desde `untitled.mat`, ignorando la variable `vx_cmd` del workspace.
**Fix:** llamar `bypass_signal_editor(modelName)` antes de cada `sim()`.

### 2. Step hardcodeado — izaje
`controlador_torque/Subsystem1/Step` (Time=3, After=1) genera la referencia del izaje, ignorando `vh` del workspace.
**Fix:** el mismo `bypass_signal_editor` lo resuelve también.

### 3. Manual Switches de frenos y TLK
Los 4 Manual Switches del root bypasean los estados `BRK_*_state` y `TLK_state`. Hay que forzarlos con `set_param` antes de simular:
```matlab
set_param([modelName '/Manual Switch'],  'sw','1');  % BRK_t  libre
set_param([modelName '/Manual Switch1'], 'sw','1');  % BRK_h  libre
set_param([modelName '/Manual Switch2'], 'sw','1');  % BRK_hE libre
set_param([modelName '/Manual Switch3'], 'sw','0');  % TLK    enganchado
```

### 4. Señales ToWorkspace disponibles
Solo hay dos bloques ToWorkspace en el modelo:
- `out.v_td` — velocidad del tambor del carro [m/s]
- `out.whm_t` — velocidad angular del motor de izaje [rad/s]

Para convertir whm_t a velocidad lineal del cable: `v_cable = -whm_t * rhd/(2*ih)` (signo negativo: vh>0 = descender).

### 5. Límite del mapa de obstáculos
El subsistema de perfil de obstáculos falla si el carro recorre más de ~40 m desde `xt_0=25`. No simular más de ~15 s con `vx_cmd` grande.

---

## Parámetros de controladores (vigentes)

Sintonizados con `tune_controllers.m` el 2025-04-20 (barrido 81 sims, `Mc_X=Mc_max=50000 kg`).

| Lazo | wn (rad/s) | ζ | p_obs | J | Overshoot | Settling |
|------|-----------|---|-------|---|-----------|---------|
| Carro | 0.80 | 0.70 | 2.4 | 24.4 | 1.5% | 4.7 s |
| Izaje | 5.00 | 0.70 | 40 | 1.1 | 0.2% | 0.2 s |

Las fórmulas en `init_plant_parameters.m` usan `M_carro_total = Mt+Ms+Mc_X` (carro) y `J_motor_izaje = Jhm_hb + Jhd_hEb/ih²` (izaje).

---

## Scripts principales

| Script | Uso |
|--------|-----|
| `init_plant_parameters.m` | Carga planta + ganancias. Siempre correr primero. |
| `bypass_signal_editor.m` | Fix del modelo (Signal Editor + Step hardcodeados). Llamar después de `load_system`. |
| `tune_controllers.m` | Barrido paramétrico completo (~5 min). Ver `WORKFLOW_SINTONIZACION.md`. |
| `ver_respuesta.m` | Visualiza carro e izaje, genera `respuesta_controladores.png`. |
| `metricas_respuesta.m` | Función pura: IAE, overshoot, settling. |

---

## Secuencia mínima para simular

```matlab
init_plant_parameters
load_system('controlador_torque')
bypass_signal_editor('controlador_torque')
set_param('controlador_torque/Manual Switch',  'sw','1')
set_param('controlador_torque/Manual Switch1', 'sw','1')
set_param('controlador_torque/Manual Switch2', 'sw','1')
set_param('controlador_torque/Manual Switch3', 'sw','0')
BRK_t_state=0; BRK_h_state=0; BRK_he_state=0; TLK_state=1;
anti_sway_estate=1; Mc_X=Mc_max;
vx_cmd=1.5; vh=0;
out = sim('controlador_torque','StopTime','12');
```

---

## Re-sintonizar

Ver `Proyecto_AyCD/WORKFLOW_SINTONIZACION.md`.
