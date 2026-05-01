# Modo Automático Full (MODO_AUTO_FULL) — Documentación

**Archivo:** `simulink/nivel_1_full.slx` (basado en `nivel_1.slx`)  
**Chart:** `Chart` dentro de `nivel_1_full`  
**Estado:** `MODO_AUTO_FULL` dentro de `AUTOMATA_PRINCIPAL`  
**Generador:** `simulink/build_auto_full.m` (script MATLAB con API de Stateflow)  
**Fecha:** Abril 2025

---

## 1. Resumen

El **Modo Automático Full** (100% automático) es una nueva máquina de estados que automatiza completamente el ciclo de trabajo de la grúa STS: seleccionar origen, recoger un container, trasladarlo a destino, depositarlo y volver a la posición inicial. A diferencia del `MODO_AUTO` existente (que requiere intervención del operador en cada paso), este modo **no requiere joystick** durante la misión completa.

### Diferencia clave: MODO_AUTO vs MODO_AUTO_FULL

| Característica | MODO_AUTO (existente) | MODO_AUTO_FULL (nuevo) |
|---|---|---|
| Selección de origen/destino | Operador mueve cruceta | Operador navega lista con joystick X |
| Planificación | Usa `Planificador_Trayectoria_Vel()` | Usa control proporcional directo |
| Envolvente de seguridad | Vector `envolvente()` | Vector `yc0_vec()` (perfil escaneado) |
| Posicionamiento fino | Manual (`MODO_MANUAL_SIMPLE`) | Automático (`BAJAR_ORIGEN`, `BAJAR_DESTINO`) |
| Twistlocks | Operador pulsa BTN_TLK | Automático (`cmd_auto_tlk`) |
| Intervención humana | Requerida en cada etapa | Solo al inicio (selección) y al final |

---

## 2. Estructura del modelo

### Estados paralelos del Chart (AND_STATEs)

| Estado | Responsabilidad |
|---|---|
| `AUTOMATA_PRINCIPAL` | Máquina principal: modos, selección, misión automática |
| `TWISTLOCKS` | Gestión de twistlocks (VACIO ↔ CARGADO) |
| `INDICES_PERFIL` | Cruceta, índices de grilla y perfil de alturas |
| `VELOCIDAD_LIMITES` | Límites de velocidad |

### Estructura interna de AUTOMATA_PRINCIPAL

```
AUTOMATA_PRINCIPAL
├── REPOSO              (estado existente, standby)
├── RECUPERACION        (estado existente)
├── ERROR_FC_sup_inf    (estado existente)
├── MANUAL              (estado existente)
├── ERROR_FC_izq_der    (estado existente)
├── SEL_ORIGEN          (NUEVO: selección de container origen)
├── SEL_DESTINO         (NUEVO: selección de slot destino)
└── MODO_AUTO_FULL      (NUEVO: superestado con la misión completa)
    ├── SUBIR_INICIAL
    ├── IR_ORIGEN
    ├── BAJAR_ORIGEN
    ├── ENGANCHAR
    ├── SUBIR_CARGADO
    ├── IR_DESTINO
    ├── BAJAR_DESTINO
    ├── DESENGANCHAR
    ├── SUBIR_VACIO
    ├── VOLVER_INICIO
    └── FIN_MISION
```

---

## 3. Diagrama de transiciones (AUTOMATA_PRINCIPAL)

```
REPOSO ──[BTN_Auto==1]──► SEL_ORIGEN ──[BTN_TLK==1]──► SEL_DESTINO
   ▲                           │                              │
   │                           │    [BTN_Reset==1]            │
   │                           └──────────────────────────────┤
   │                                                          │
   │    [BTN_Reset==1]                                        │
   └──────────────────────────────────────────────────────────┘
                                                             │
                          [BTN_TLK==1]                       ▼
                                                       MODO_AUTO_FULL
                                                             │
                                                 (misión completa)
                                                             │
                                        [default]            ▼
                                                       ──► REPOSO
```

---

## 4. Estados de Selección

### 4.1 SEL_ORIGEN — Selección del container a recoger

El operador selecciona de qué columna de la grilla se debe tomar el container.

```matlab
entry:
  i_sel = 1; debounce = 0;        % Iniciar en primer índice de la lista
  x_inicio = xt_enc;              % Guardar posición actual del carro
  x_origen = xt_min + (i_lista(1)-1)*Wc + Wc/2;  % Posición del primer container

during:
  debounce = debounce + 1;
  if (debounce > 25)              % Anti-rebote: solo cambia cada 25 ticks (~500ms)
    if (Joy_CMD_X > dead_zone)
      i_sel = mod(i_sel, length(i_lista)) + 1; debounce = 0;  % Avanzar en lista
    elseif (Joy_CMD_X < -dead_zone)
      i_sel = mod(i_sel-2, length(i_lista)) + 1; debounce = 0;  % Retroceder
    end
  end
  x_origen = xt_min + (i_lista(i_sel)-1)*Wc + Wc/2;  % Posición del seleccionado

exit:
  i_origen = i_lista(i_sel);      % Confirmar índice de origen
```

**Funcionamiento:**
- `i_lista` es un parámetro que contiene los índices de columnas que tienen containers disponibles.
- El operador usa el joystick X (izquierda/derecha) para navegar por la lista.
- El debounce de 25 ticks (~500ms a 20ms/tick) evita que el índice cambie demasiado rápido.
- La posición `x_origen` se actualiza continuamente para que la cruceta muestre la selección.

**Transición de salida:** `[BTN_TLK == 1]` → `SEL_DESTINO` (el operador confirma con BTN_TLK)

---

### 4.2 SEL_DESTINO — Selección del slot de destino

El operador selecciona dónde depositar el container, similar a SEL_ORIGEN.

```matlab
entry:
  i_sel = 1; debounce = 0;
  x_destino = xt_min + (i_lista(1)-1)*Wc + Wc/2;

during:
  debounce = debounce + 1;
  if (debounce > 25)
    if (Joy_CMD_X > dead_zone)
      i_sel = mod(i_sel, length(i_lista)) + 1; debounce = 0;
    elseif (Joy_CMD_X < -dead_zone)
      i_sel = mod(i_sel-2, length(i_lista)) + 1; debounce = 0;
    end
  end
  x_destino = xt_min + (i_lista(i_sel)-1)*Wc + Wc/2;

exit:
  i_destino = i_lista(i_sel);     % Confirmar índice de destino
```

**Transición de salida:** `[BTN_TLK == 1]` → `MODO_AUTO_FULL` (el operador confirma e inicia la misión)

**Cancelación:** `[BTN_Reset == 1]` desde SEL_ORIGEN o SEL_DESTINO → `REPOSO`

---

## 5. MODO_AUTO_FULL — Misión automática completa

Al entrar:
```matlab
entry:
  modo_auto = 1; BRK_t_N1 = 1; BRK_h_N1 = 1;  % Abrir frenos, activar flag
exit:
  modo_auto = 0;  % Al salir, desactivar modo auto
```

### Flujo de la misión (10 estados secuenciales)

```
FASE 1: BUSCAR CONTAINER
┌─────────────────┐     ┌─────────────┐     ┌───────────────┐     ┌─────────────┐
│  SUBIR_INICIAL  │────►│  IR_ORIGEN  │────►│ BAJAR_ORIGEN  │────►│ ENGANCHAR   │
│  Subir gancho   │     │ Mover carro │     │ Bajar gancho  │     │ Cerrar TLK  │
│  a altura segura│     │ al origen   │     │ sobre container│    │ (auto)      │
└─────────────────┘     └─────────────┘     └───────────────┘     └──────┬──────┘
                                                                          │ [TLK==1]
                                                                          ▼
FASE 2: TRASLADAR A DESTINO                                          (SUBIR_CARGADO)
┌──────────────────┐    ┌──────────────┐    ┌────────────────┐    ┌─────────────────┐
│ DESENGANCHAR     │◄───│ BAJAR_DESTINO│◄───│  IR_DESTINO    │◄───│  SUBIR_CARGADO  │
│ Abrir TLK (auto) │    │ Bajar sobre  │    │  Mover carro   │    │  Subir gancho   │
│                  │    │ slot destino │    │  al destino    │    │  altura segura  │
└───┬──────────────┘    └──────────────┘    └────────────────┘    └─────────────────┘
    │ [TLK==0]
    ▼
FASE 3: VOLVER A INICIO
┌────────────────┐    ┌──────────────────┐    ┌─────────────┐
│ SUBIR_VACIO    │───►│ VOLVER_INICIO    │───►│ FIN_MISION  │
│ Subir gancho   │    │ Mover carro a    │    │ vx=0, vy=0  │
│ altura segura  │    │ posición inicial │    │ ──► REPOSO  │
└────────────────┘    └──────────────────┘    └─────────────┘
```

---

### 5.1 FASE 1 — Ir a buscar el container

#### SUBIR_INICIAL
Eleva el gancho hasta una altura segura sobre todos los containers de la ruta hacia el origen.

```matlab
entry:
  y_max_ruta = 0;
  for k = min(i_carro,i_origen):max(i_carro,i_origen)
    if yc0_vec(k) > y_max_ruta, y_max_ruta = yc0_vec(k); end
  end
  y_segura_origen = min(y_max_ruta + Hc + 1.0, yh_max - 1.0);
during:
  vx_target = 0;             % No mover carro mientras sube
  vy_target = vh_lim;        % Subir a velocidad máxima
```

**Lógica de seguridad:** Recorre el perfil de alturas (`yc0_vec`) desde la posición actual del carro hasta el destino. Encuentra el container más alto en esa trayectoria y calcula `y_segura_origen` = altura máxima + altura de container + 1m de margen. Esto garantiza que el gancho pase **por encima** de cualquier obstáculo.

**Transición:** `[yh_enc >= y_segura_origen]` → `IR_ORIGEN`

---

#### IR_ORIGEN
Traslada el carro horizontalmente hasta la columna de origen.

```matlab
during:
  err_x = x_origen - xt_enc;  % Error de posición
  vx_target = max(-vt_max, min(vt_max, 3.0*err_x));  % Control P saturado
  vy_target = 0;             % Mantener altura del gancho
```

Usa un **controlador proporcional** con ganancia 3.0, saturado a `±vt_max`. El gancho permanece a la altura segura mientras el carro se desplaza.

**Transición:** `[abs(xt_enc - x_origen) < 0.15 && abs(vt_obs) < 0.1]` → `BAJAR_ORIGEN`
(El carro llegó a ±15cm del destino y está prácticamente detenido)

---

#### BAJAR_ORIGEN
Desciende el gancho hasta la altura del container a recoger.

```matlab
entry:
  y_obj = yc0_vec(i_origen) + 0.5;  % Altura del container + 0.5m de margen
during:
  err_y = y_obj - yh_enc;
  vy_target = max(-vh_lim, min(vh_lim, 3.0*err_y));  % Control P saturado
  vx_target = 0;             % No mover carro mientras baja
```

El gancho baja hasta 50cm por encima del container (`yc0_vec(i_origen) + 0.5`).

**Transición:** `[hay_cont == 1]` → `ENGANCHAR`
(La función `hay_cont` confirma que hay un container en la posición del gancho)

---

#### ENGANCHAR
Cierra los twistlocks automáticamente para sujetar el container.

```matlab
entry:
  vy_target = 0; cmd_auto_tlk = 1;  % Parar izaje, enviar comando auto
exit:
  cmd_auto_tlk = 0;
```

**Mecanismo:** `cmd_auto_tlk = 1` activa la misma transición que `BTN_TLK == 1` en el estado paralelo `TWISTLOCKS`. El estado TWISTLOCKS pasa de `VACIO` → `CERRANDO_TLK` → `CARGADO`.

**Transición:** `[TLK == 1]` → `SUBIR_CARGADO`
(Se confirma que los twistlocks cerraron correctamente)

---

### 5.2 FASE 2 — Trasladar container al destino

#### SUBIR_CARGADO
Eleva el container por encima de la envolvente de la ruta hacia el destino.

```matlab
entry:
  y_max_ruta = 0;
  for k = min(i_origen,i_destino):max(i_origen,i_destino)
    if yc0_vec(k) > y_max_ruta, y_max_ruta = yc0_vec(k); end
  end
  y_segura_destino = min(y_max_ruta + Hc + 1.0, yh_max - 1.0);
during:
  vx_target = 0;
  vy_target = vh_lim;
```

Igual que `SUBIR_INICIAL`, pero ahora calcula la altura segura para la ruta **desde el origen hasta el destino** (no desde la posición actual del carro).

**Transición:** `[yh_enc >= y_segura_destino]` → `IR_DESTINO`

---

#### IR_DESTINO
Traslada el carro (con container cargado) hasta la columna de destino.

```matlab
during:
  err_x = x_destino - xt_enc;
  vx_target = max(-vt_max, min(vt_max, 3.0*err_x));
  vy_target = 0;
```

**Transición:** `[abs(xt_enc - x_destino) < 0.15 && abs(vt_obs) < 0.1]` → `BAJAR_DESTINO`

---

#### BAJAR_DESTINO
Desciende el container hasta la altura del slot de destino.

```matlab
entry:
  altura_apoyo = yc0_vec(i_destino) + Hc + 0.5;  % Altura del slot + container + 0.5m
during:
  err_y = altura_apoyo - yh_enc;
  vy_target = max(-vh_lim, min(vh_lim, 3.0*err_y));
  vx_target = 0;
```

El gancho baja hasta una posición donde el container quede apoyado sobre los containers debajo (o el chasis). La condición `altura_apoyo = yc0_vec(i_destino) + Hc + 0.5` posiciona el gancho justo por encima del punto de apoyo.

**Transición:** `[yh_enc <= altura_apoyo || Fhw < (Ms*g/2 * 0.8)]` → `DESENGANCHAR`

Esta transición tiene **dos condiciones alternativas**:
1. `yh_enc <= altura_apoyo`: el gancho llegó a la posición de apoyo.
2. `Fhw < (Ms*g/2 * 0.8)`: la fuerza en el cable cayó por debajo del 80% del peso del spreader solo (sin container). Esto indica que **el container ya está apoyado** y el cable se descargó. Esta condición de seguridad previene que el gancho siga bajando y aplaste el container.

---

#### DESENGANCHAR
Abre los twistlocks automáticamente para soltar el container.

```matlab
entry:
  vy_target = 0; cmd_auto_tlk = 1;  % Parar izaje, enviar comando auto
exit:
  cmd_auto_tlk = 0;
```

Igual que `ENGANCHAR`, pero `cmd_auto_tlk` activa la transición `CARGADO` → `ABRIENDO_TLK` → `VACIO` en TWISTLOCKS.

**Transición:** `[TLK == 0]` → `SUBIR_VACIO`
(Se confirma que los twistlocks abrieron correctamente)

---

### 5.3 FASE 3 — Volver a posición inicial

#### SUBIR_VACIO
Eleva el gancho vacío hasta altura segura para la ruta de regreso.

```matlab
entry:
  y_max_ruta = 0;
  for k = min(i_destino,i_carro):max(i_destino,i_carro)
    if yc0_vec(k) > y_max_ruta, y_max_ruta = yc0_vec(k); end
  end
  y_segura_inicio = min(y_max_ruta + Hc + 1.0, yh_max - 1.0);
during:
  vx_target = 0;
  vy_target = vh_lim;
```

**Transición:** `[yh_enc >= y_segura_inicio]` → `VOLVER_INICIO`

---

#### VOLVER_INICIO
Traslada el carro vacío de vuelta a la posición donde estaba al inicio de la misión.

```matlab
during:
  err_x = x_inicio - xt_enc;  % x_inicio se guardó en SEL_ORIGEN
  vx_target = max(-vt_max, min(vt_max, 3.0*err_x));
  vy_target = 0;
```

**Transición:** `[abs(xt_enc - x_inicio) < 0.15]` → `FIN_MISION`

---

#### FIN_MISION
Misión completada. Detiene todos los movimientos.

```matlab
entry:
  vx_target = 0; vy_target = 0;
```

**Transición:** (default) → `REPOSO`

---

## 6. Variables locales y parámetros

### Variables agregadas por el script

| Variable | Scope | Tipo | Valor inicial | Descripción |
|---|---|---|---|---|
| `BTN_Auto` | Input | uint8 | — | Pulsador de modo automático (puerto 15 del chart) |
| `modo_auto` | Local | uint8 | 0 | Flag: 1 mientras ejecuta misión automática |
| `modo_seleccion` | Local | uint8 | 0 | Flag: 1 mientras selecciona origen/destino |
| `i_sel` | Local | int32 | 1 | Índice de selección actual en la lista |
| `i_origen` | Local | int32 | 1 | Índice de columna confirmado como origen |
| `i_destino` | Local | int32 | 1 | Índice de columna confirmado como destino |
| `x_origen` | Local | double | 0 | Posición X absoluta del container origen |
| `x_destino` | Local | double | 0 | Posición X absoluta del slot destino |
| `x_inicio` | Local | double | 0 | Posición X del carro al iniciar misión |
| `cmd_auto_tlk` | Local | uint8 | 0 | Comando automático de twistlocks (simula BTN_TLK) |
| `y_obj` | Local | double | 0 | Altura objetivo de bajada en origen |
| `altura_apoyo` | Local | double | 0 | Altura de apoyo del container en destino |
| `debounce` | Local | int32 | 0 | Contador anti-rebote para selección |
| `y_max_ruta` | Local | double | 0 | Altura máxima encontrada en la ruta |
| `y_segura_origen` | Local | double | 0 | Altura segura para ruta hacia origen |
| `y_segura_destino` | Local | double | 0 | Altura segura para ruta hacia destino |
| `y_segura_inicio` | Local | double | 0 | Altura segura para ruta de regreso |
| `err_x` | Local | double | 0 | Error de posición del carro |
| `err_y` | Local | double | 0 | Error de posición del gancho |

### Parámetros existentes utilizados

| Parámetro | Descripción |
|---|---|
| `i_lista` | Vector con índices de columnas que tienen containers |
| `yc0_vec` | Vector [33×1] con alturas de containers en cada columna |
| `xt_enc` | Posición actual del carro (encoder) |
| `yh_enc` | Posición actual del gancho (encoder) |
| `vt_obs` | Velocidad observada del carro |
| `vh_lim` | Velocidad máxima de izaje |
| `vt_max` | Velocidad máxima del carro |
| `Wc` | Ancho de una columna de la grilla |
| `xt_min` | Posición X mínima de la grilla |
| `yh_max` | Altura máxima del gancho |
| `Hc` | Altura de un container |
| `Ms` | Masa del spreader |
| `g` | Gravedad (9.81) |
| `dead_zone` | Zona muerta del joystick |
| `i_carro` | Índice actual del carro en la grilla |
| `hay_cont` | Flag: hay container en posición del gancho |

---

## 7. Integración con TWISTLOCKS

El estado `TWISTLOCKS` corre en paralelo a `AUTOMATA_PRINCIPAL`. El modo automático **inyecta** el comando `cmd_auto_tlk` para cerrar/abrir twistlocks sin intervención del operador.

### Modificación en las transiciones de TWISTLOCKS

**Antes (solo manual):**
```
VACIO → CERRANDO_TLK:  [BTN_TLK == 1 && ...]
CARGADO → ABRIENDO_TLK: [BTN_TLK == 1 && ...]
```

**Después (manual + automático):**
```
VACIO → CERRANDO_TLK:  [(BTN_TLK == 1 || cmd_auto_tlk == 1) && ...]
CARGADO → ABRIENDO_TLK: [(BTN_TLK == 1 || cmd_auto_tlk == 1) && ...]
```

Esto permite que tanto el operador (BTN_TLK) como el autómata (cmd_auto_tlk) operen los twistlocks.

---

## 8. Flujo completo de una misión

```
Estado inicial: Grúa en REPOSO, gancho arriba, sin container (TLK=0)

1. Operador presiona BTN_Auto → entra a SEL_ORIGEN

2. SEL_ORIGEN:
   - Operador mueve joystick X para navegar por i_lista
   - Visualiza x_origen en la cruceta
   - Presiona BTN_TLK para confirmar → SEL_DESTINO
   - Si presiona BTN_Reset → vuelve a REPOSO

3. SEL_DESTINO:
   - Operador mueve joystick X para navegar por i_lista
   - Visualiza x_destino en la cruceta
   - Presiona BTN_TLK para confirmar → MODO_AUTO_FULL

4. MODO_AUTO_FULL comienza:
   a. SUBIR_INICIAL: calcula altura segura, sube gancho
   b. IR_ORIGEN: mueve carro horizontalmente al origen
   c. BAJAR_ORIGEN: baja gancho sobre el container
   d. ENGANCHAR: cierra twistlocks automáticamente
   e. SUBIR_CARGADO: sube container sobre la envolvente
   f. IR_DESTINO: mueve carro al destino
   g. BAJAR_DESTINO: baja container al slot de destino
   h. DESENGANCHAR: abre twistlocks automáticamente
   i. SUBIR_VACIO: sube gancho sobre la envolvente
   j. VOLVER_INICIO: mueve carro a posición inicial
   k. FIN_MISION: detiene todo → REPOSO

Misión completada. La grúa está de vuelta en REPOSO, lista para otra misión.
```

---

## 9. Trabajo realizado

### 9.1 Archivos creados/modificados

| Archivo | Acción | Descripción |
|---|---|---|
| `simulink/build_auto_full.m` | **Creado** | Script MATLAB que genera `nivel_1_full.slx` desde `nivel_1.slx` |
| `simulink/nivel_1_full.slx` | **Generado** | Modelo con modo automático full (requiere edición manual) |
| `simulink/modo_automatico_impl.html` | Creado | Diagrama visual del autómata (documento previo) |
| `AGENTS.md` | Creado | Instrucciones para agentes sobre el proyecto |
| `guia/modo_automatico_full.md` | **Este documento** | Documentación completa del modo |

### 9.2 Lo que el script logra automáticamente

- Copia `nivel_1.slx` → `nivel_1_full.slx`
- Limpia estados viejos (SELECCION, MODO_AUTO, etc.)
- Calcula la coordenada Y inicial sin colisiones
- Expande `AUTOMATA_PRINCIPAL` verticalmente
- Agrega todas las variables locales y de entrada
- Corrige el tamaño de `yc0_vec` a [33]
- Crea los estados SEL_ORIGEN, SEL_DESTINO y MODO_AUTO_FULL con su LabelString
- Crea los 10 sub-estados de MODO_AUTO_FULL
- Crea todas las transiciones internas y externas
- Modifica las transiciones de TWISTLOCKS para aceptar `cmd_auto_tlk`
- Corrige `InputPortWidth` del Selector a 8
- Conecta el cable de `BTN_Auto` (puerto 5 del Joystick → puerto 15 del Chart)

### 9.3 Limitación encontrada: sub-estados en la API de Stateflow

La API de Stateflow en MATLAB no proporciona un método `.move()` funcional para cambiar el contenedor padre de un estado. Cuando se crea un estado con `Stateflow.State(automata)`, el estado se crea al **nivel del chart** en lugar de como sub-estado del estado padre. Esto causa el error:

```
State 'AUTOMATA_PRINCIPAL' must not intersect another state or junction.
```

El script genera el modelo correctamente pero los estados nuevos (`SEL_ORIGEN`, `SEL_DESTINO`, `MODO_AUTO_FULL` y sus sub-estados) quedan al nivel del chart en lugar de dentro de `AUTOMATA_PRINCIPAL` / `MODO_AUTO_FULL`.

### 9.4 Edición manual requerida en MATLAB/Simulink GUI

Para que el modelo funcione, se debe abrir `nivel_1_full.slx` y:

1. **Mover SEL_ORIGEN y SEL_DESTINO** dentro de `AUTOMATA_PRINCIPAL` (cortar y pegar)
2. **Mover MODO_AUTO_FULL** dentro de `AUTOMATA_PRINCIPAL`
3. **Mover los 10 sub-estados** dentro de `MODO_AUTO_FULL`:
   - SUBIR_INICIAL, IR_ORIGEN, BAJAR_ORIGEN, ENGANCHAR
   - SUBIR_CARGADO, IR_DESTINO, BAJAR_DESTINO, DESENGANCHAR
   - SUBIR_VACIO, VOLVER_INICIO, FIN_MISION
4. **Verificar las transiciones** después de mover los estados (Stateflow puede desconectarlas)
5. **Guardar** el modelo

### 9.5 Alternativa: inyección XML con Python

El proyecto ya tiene un script Python (`simulink/crear_nivel1_claude.py`) que inyecta XML directamente en el `.slx` (que es un archivo ZIP). Este método **sí funciona** para crear sub-estados, ya que manipula el XML de Stateflow directamente. Se podría crear un script similar para el modo Full Auto si la edición manual es impráctica.

---

## 10. Ejecución del modelo

### 10.1 Requisitos previos

```matlab
% Desde la carpeta simulink/
addpath('simulink');
run('simulink/init_plant_parameters.m');  % Cargar variables de planta
open_system('nivel_1_full');
```

### 10.2 Simulación

1. Abrir `nivel_1_full.slx` en MATLAB/Simulink
2. Ejecutar `init_plant_parameters.m` para cargar el workspace
3. Ejecutar la simulación (botón Run o `Ctrl+T`)
4. Usar el joystick virtual (`joystick.py`) para interactuar:
   - Presionar el botón de modo automático (BTN_Auto)
   - Navegar la lista de containers con Joy_X
   - Confirmar selecciones con BTN_TLK

### 10.3 Señales de monitoreo

Para verificar el funcionamiento, agregar al Scope:
- `modo_auto` (1 durante la misión)
- `i_sel`, `i_origen`, `i_destino` (índices seleccionados)
- `x_origen`, `x_destino` (posiciones objetivo)
- `y_segura_origen`, `y_segura_destino` (alturas de seguridad)
- `vx_target`, `vy_target` (comandos de velocidad)
- `TLK` (estado de twistlocks)
- `cmd_auto_tlk` (comando automático)

---

## 11. Diagrama de referencia

Ver `simulink/modo_automatico_impl.html` para el diagrama visual del autómata con posiciones y conexiones.
