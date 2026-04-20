# Workflow de Re-sintonización de Controladores

## Cuándo re-sintonizar

- Cambiaste masas, inercias, radios o transmisiones en `init_plant_parameters.m`
- Cambiaste la topología del modelo Simulink
- Querés probar una grilla de parámetros más fina o más amplia

---

## Pasos

### 1. Modificar la planta

Editá `init_plant_parameters.m` con los nuevos valores físicos.

### 2. Correr el barrido

```matlab
cd Proyecto_AyCD
tune_controllers
```

Tarda ~5 min (81 simulaciones). Al terminar muestra:

```
>>> Mejor carro: wn_t=X.XXX  zitta_t=X.XXX  p_obs_c=X.XXX  J=XX.XX
>>> Mejor izaje: wn_h=X.XXX  zitta_h=X.XXX  p_obs_h=XX.XX  J=X.XX
Resultados guardados en tune_results.mat
```

### 3. Aplicar los óptimos a `init_plant_parameters.m`

Editá las 4 líneas de la sección **CN2**:

```matlab
%% CN2 - Controlador de movimiento - Carro
zitta_t = <best_c.zitta_t>;
wn_t    = <best_c.wn_t>;

%% CN2 - Controlador de movimiento - Izaje
zitta_h = <best_h.zitta_h>;
wn_h    = <best_h.wn_h>;
```

Los observadores se recalculan solos a partir de `wn_t` y `wn_h` — no hace falta tocarlos.

### 4. Verificar visualmente

```matlab
ver_respuesta
```

Genera `respuesta_controladores.png` con los 4 paneles de entrada/salida.

---

## Ajustar la grilla del barrido

Si el óptimo quedó en el borde de la grilla, ampliá el rango en `tune_controllers.m`:

```matlab
% Carro
grid_c.wn   = [0.5 0.8 1.2 1.6 2.2];   % agregar valores límite
grid_c.zit  = [0.6 0.7 0.85 1.0];
grid_c.kobs = [3 5 8];

% Izaje
grid_h.wn   = [3 5 8 10];
grid_h.zit  = [0.6 0.7 0.85 1.0];
grid_h.kobs = [5 8 12];
```

---

## Re-sintonizar solo un lazo

Si solo cambiaste algo del carro o del izaje, comentá el bloque que no necesitás en `tune_controllers.m`:

```matlab
%% 2) Barrido CARRO  ← comentar esta sección si no cambiaste el carro
```

Y en la sección 3 (izaje) reemplazá la línea que carga `best_c` por los valores actuales:

```matlab
wn_t    = 0.80;   % valor vigente
zitta_t = 0.70;
p_obs_c = 3 * wn_t;
```

---

## Archivos involucrados

| Archivo | Rol |
|---|---|
| `init_plant_parameters.m` | Parámetros de la planta + ganancias activas |
| `tune_controllers.m` | Barrido paramétrico — editar grilla aquí |
| `bypass_signal_editor.m` | Fix del modelo (no tocar) |
| `metricas_respuesta.m` | Función de métricas (no tocar) |
| `ver_respuesta.m` | Visualización post-sintonía |
| `tune_results.mat` | Resultado del último barrido (ignorado por git) |
