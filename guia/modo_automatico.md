# Modo Automático — Control Nivel 1

**Archivo:** `guia/Simulink/planta_controlador.slx`  
**Chart:** `Control Nivel 1` (chart_1366, Ts1 = 20 ms)  
**Estado:** `MODO_AUTO` dentro de `AUTOMATA_PRINCIPAL`

---

## 1. Contexto general

El chart `Control Nivel 1` está compuesto por varios estados paralelos (AND_STATEs) que corren simultáneamente a 20 ms:

| Estado paralelo | Responsabilidad |
|---|---|
| `AUTOMATA_PRINCIPAL` | Máquina principal: modos, errores, misión |
| `TWISTLOCKS` | Gestión de twistlocks y estimación de masa |
| `SUAVIZADO_VELOCIDAD` | Suavizador cinemático de velocidades |
| `LIMITES_SUAVES` | Límite dinámico de velocidad de bajada |
| `CRUCETA_INDICES_PERFIL` | Cruceta, índices de grilla y perfil de alturas |
| `WATCHDOG_HEARTBEAT` | Señal de vida del supervisor |

El Modo Automático es el estado `MODO_AUTO` dentro de `AUTOMATA_PRINCIPAL`. Mientras está activo, los demás AND_STATEs continúan ejecutándose normalmente.

---

## 2. Condición de entrada

Desde `STAND_BY`, la transición a `MODO_AUTO` requiere:

```
BTN_Auto == 1  &&  yh_enc >= envolvente(i_carro)
```

- `BTN_Auto`: pulsador físico/virtual de modo automático.
- `yh_enc >= envolvente(i_carro)`: el gancho debe estar **por encima de la envolvente** en la columna donde se encuentra el carro. Esto garantiza que hay suficiente clearance antes de iniciar cualquier movimiento horizontal.

Al entrar a `MODO_AUTO`:
- Se abren los frenos: `BRK_t_N1 = 1`, `BRK_h_N1 = 1`.
- Se activa `modo_auto = 1`.

---

## 3. Sub-autómata de MODO_AUTO

`MODO_AUTO` es un OR_STATE con su propio autómata secuencial interno. Los estados son:

```
AUTO_INIT
    │
    ├─(TLK == 0)──► SELECCION_INDICE_INI ──► SELECCION_INDICE_FIN
    │                                               │
    └─(TLK == 1)──────────────────────────────────►┘
                                                    │
                                         SELECCION_TRAYECTORIA
                                          │              │
                              safe=0      │              │ safe=1
                                          ▼              ▼
                                  MOVIMIENTO_CURVO  MOVIMIENTO_SEGURO
                                          │              │
                                  manual_ok=1    manual_ok=1
                                          └──────┬───────┘
                                                 ▼
                                       MODO_MANUAL_SIMPLE
                                                 │
                              (TLK==1 && alto && quieto && estado==1)
                                                 │
                                                 └──► SELECCION_TRAYECTORIA
                                                        (segunda etapa: depositar)
```

### Variable `estado`

`estado` representa la **etapa de la misión** actual:

| Valor | Significado |
|---|---|
| `1` | Etapa de **recolección**: ir a buscar el container |
| `2` | Etapa de **depósito**: llevar el container al destino |

Avanza: `estado++` al salir de `MODO_MANUAL_SIMPLE` (cuando el operador confirma posición fina).

---

## 4. Estados internos de MODO_AUTO

### 4.1 AUTO_INIT

Estado de inicialización al entrar al modo automático.

```matlab
entry:
   modo_auto = 1;
   BRK_t_N1 = 1; BRK_h_N1 = 1;   % Frenos abiertos
   estado = 1;                      % Comienza en etapa de recolección
   if (TLK == 1)
       estado = 2;                  % Ya tiene container: va directo a depositar
       i_ini = 0;
   end
   i_obj_vec = [0,0];
   seleccionando_i = [0,0];
```

- Si los twistlocks ya estaban cerrados (`TLK=1`), el operador ya tenía un container cargado. El autómata salta directamente a `SELECCION_INDICE_FIN` para definir el destino.
- Si `TLK=0`, comienza desde la selección de origen (`SELECCION_INDICE_INI`).

Transiciones desde AUTO_INIT:
- → `SELECCION_INDICE_INI` si `TLK == 0`
- → `SELECCION_INDICE_FIN` si `TLK == 1`

---

### 4.2 SELECCION_INDICE_INI

El operador mueve la cruceta para indicar **dónde está el container a levantar**.

```matlab
entry:
   seleccionando_i(1) = 1;
   seleccionando = 1;          % Activa snap de cruceta a grilla
during:
   i_ini = i_x_cruz;           % Lee índice de columna de la cruceta
   is_cont = Check_Container(i_ini, yc0_vec);  % ¿Hay container ahí?
exit:
   i_obj_vec(1) = i_ini;       % Guarda índice de origen
   seleccionando_i(1) = 0;
```

**Nota:** Durante `seleccionando=1`, el estado `ACTUALIZAR_CRUCETA` hace que `x_cruz_unity` se "enganche" a la posición discreta del bin seleccionado (snap a grilla), en lugar de la posición continua.

**Transición de salida:**
```
[BTN_TLK && is_cont == 1]  →  SELECCION_INDICE_FIN
```
El operador confirma pulsando `BTN_TLK` solo si hay un container en la posición seleccionada. Si la columna está vacía, la transición no ocurre.

---

### 4.3 SELECCION_INDICE_FIN

El operador mueve la cruceta para indicar **dónde depositar el container**.

```matlab
entry:
   seleccionando_i(2) = 1;
   seleccionando = 1;
   invalido = 0;
during:
   i_fin = i_x_cruz;
   if (i_fin == 33 || i_fin == 13 || i_fin == 1)
       invalido = 1;    % Posiciones de borde/esquina prohibidas
   else
       invalido = 0;
   end
exit:
   i_obj_vec(2) = i_fin;   % Guarda índice de destino
   seleccionando_i(2) = 0;
```

**Posiciones inválidas:** Los índices 1, 13 y 33 corresponden a posiciones de borde de la grilla (primeras y últimas columnas), donde no se puede depositar.

**Transición de salida:**
```
[BTN_TLK && invalido == 0]  →  SELECCION_TRAYECTORIA
```

---

### 4.4 SELECCION_TRAYECTORIA

Determina si el camino hacia el objetivo es **seguro** o requiere trayectoria especial.

```matlab
entry:
   modo_auto = 1;
   manual_ok = 0;
   i_usado = 1;
   seleccionando = 0;
   % Selecciona índice objetivo según etapa
   if (estado == 1)
       i_usado = i_ini;    % Etapa 1: ir a origen del container
   elseif (estado == 2)
       i_usado = i_fin;    % Etapa 2: ir al destino
   end
   % Verifica si toda la trayectoria está escaneada
   safe_trajectory = 0;
   for k = i_carro:i_usado
       if is_scanned_vec(k) == 0
           safe_trajectory = 1;   % Hay posiciones no escaneadas → inseguro
       end
   end
```

- `is_scanned_vec(k)`: indica si la posición `k` fue escaneada por el LIDAR. Si alguna posición entre el carro y el destino **no fue escaneada**, no se puede garantizar que no haya obstáculos.
- `i_carro`: índice actual del carro en la grilla (calculado continuamente en `CALCULO_INDICES`).

**Transiciones:**
```
[safe_trajectory == 0]  →  MOVIMIENTO_CURVO    % Camino libre y conocido
[safe_trajectory == 1]  →  MOVIMIENTO_SEGURO   % Hay zonas no escaneadas
```

---

### 4.5 MOVIMIENTO_CURVO

Ejecuta la trayectoria óptima cuando el camino está completamente escaneado y libre.

```matlab
entry: ejec_mov = 1;
during:
   [vx_target, vy_target, manual_ok] = Planificador_Trayectoria_Vel(
       xt_enc,    % Posición actual del carro
       yh_enc,    % Posición actual del gancho
       vt_obs,    % Velocidad carro (observador)
       vh_obs,    % Velocidad izaje (observador)
       i_usado,   % Índice de columna objetivo
       envolvente,% Vector de alturas máximas permitidas
       TLK,       % Estado de twistlocks
       theta_l,   % Ángulo del péndulo
       vh_lim);   % Velocidad máxima de izaje (función de la masa)
   x_cruz = xt_enc; y_cruz = yh_enc;
exit: ejec_mov = 0;
```

El planificador genera referencias de velocidad para carro (`vx_target`) e izaje (`vy_target`) coordinadas, siguiendo una **trayectoria curva** que respeta la envolvente de obstáculos. Devuelve `manual_ok=1` cuando el movimiento automático termina y se requiere posicionamiento fino manual.

**Transición de salida:**
```
[manual_ok == 1]  →  MODO_MANUAL_SIMPLE
```

---

### 4.6 MOVIMIENTO_SEGURO

Ejecuta una trayectoria conservadora cuando hay zonas no escaneadas en el camino.

```matlab
entry: ejec_mov = 1;
during:
   [vx_target, vy_target, manual_ok] = Planificador_Trayectoria_Segura_Vel(
       xt_enc, yh_enc, vt_obs,
       i_usado, envolvente, TLK, theta_l, vh_lim);
   x_cruz = xt_enc; y_cruz = yh_enc;
exit: ejec_mov = 0;
```

A diferencia de `MOVIMIENTO_CURVO`, esta versión no usa `vh_obs` como entrada, lo que implica una estrategia de movimiento más cautelosa (posiblemente priorizando el eje vertical antes que el horizontal). Se usa cuando no toda la trayectoria fue escaneada por el LIDAR.

**Transición de salida:**
```
[manual_ok == 1]  →  MODO_MANUAL_SIMPLE
```

---

### 4.7 MODO_MANUAL_SIMPLE

Estado de **posicionamiento fino** dentro del ciclo automático. El operador ajusta manualmente la posición final (sobre el container o sobre el slot de destino) antes de confirmar.

```matlab
entry:
   modo_auto = 0;
   modo_manual_auto = 1;            % Señal: estamos en manual dentro de auto
during:
   if (abs(Joy_CMD_X) < dead_zone)
       vx_target = 0;
   else
       vx_target = Joy_CMD_X * 0.05;   % Velocidad horizontal muy reducida (5%)
   end
   if (abs(Joy_CMD_Y) < dead_zone)
       vy_target = 0;
   else
       vy_target = Joy_CMD_Y * vh_lim; % Velocidad vertical normal
   end
   x_cruz = xt_enc; y_cruz = yh_enc;
exit:
   estado = estado + 1;    % Avanza la etapa de misión
   modo_manual_auto = 0;
```

**Velocidad horizontal limitada al 5%** de `vt_max` para permitir ajuste fino sin riesgo de colisión.

**Transición de salida** (solo válida en `estado==1`, es decir, tras posicionar para levantar):
```
[TLK==1 && yh_enc > (envolvente(i_usado) + Hc) && abs(vh_obs) < 0.1 && estado==1]
→  SELECCION_TRAYECTORIA
```
- `TLK==1`: el operador cerró los twistlocks (container enganchado).
- `yh_enc > envolvente(i_usado) + Hc`: el gancho subió al menos la altura de un container por encima de la envolvente (clearance mínimo).
- `abs(vh_obs) < 0.1`: el movimiento de izaje está prácticamente detenido.
- Al salir, `estado` pasa de 1 a 2: ahora el autómata irá a `SELECCION_TRAYECTORIA` para planificar el depósito.

---

## 5. Flujo completo de una misión

```
Condición inicial: TLK=0 (vacío), crane en alguna posición

1. Operador presiona BTN_Auto  →  entra a MODO_AUTO
2. AUTO_INIT: estado=1, abre frenos, va a SELECCION_INDICE_INI
3. SELECCION_INDICE_INI:
   - Operador mueve cruceta sobre container deseado
   - Sistema confirma que hay container (Check_Container)
   - Operador presiona BTN_TLK  →  SELECCION_INDICE_FIN
4. SELECCION_INDICE_FIN:
   - Operador mueve cruceta al slot de destino
   - Sistema valida que no sea posición de borde
   - Operador presiona BTN_TLK  →  SELECCION_TRAYECTORIA
5. SELECCION_TRAYECTORIA:
   - Verifica si toda la ruta está escaneada
   - Elige planificador (curvo o seguro)
6. MOVIMIENTO_CURVO o MOVIMIENTO_SEGURO:
   - Movimiento automático coordinado (carro + izaje)
   - Cuando manual_ok=1  →  MODO_MANUAL_SIMPLE
7. MODO_MANUAL_SIMPLE (posicionamiento sobre container):
   - Operador baja gancho y cierra twistlocks (BTN_TLK)
   - TWISTLOCKS: VACIO → CERRANDO_TLK → CARGADO
   - Operador sube gancho hasta yh_enc > envolvente+Hc
   - estado pasa de 1 a 2  →  vuelve a SELECCION_TRAYECTORIA
8. SELECCION_TRAYECTORIA (segunda vuelta, estado=2):
   - i_usado = i_fin (índice de destino)
   - Planifica trayectoria al destino
9. MOVIMIENTO_CURVO o MOVIMIENTO_SEGURO (hacia destino)
   - Cuando manual_ok=1  →  MODO_MANUAL_SIMPLE
10. MODO_MANUAL_SIMPLE (posicionamiento sobre destino):
    - Operador baja y abre twistlocks (BTN_TLK)
    - TWISTLOCKS: CARGADO → ABRIENDO_TLK → VACIO
    - Operador sube gancho
    - estado pasa de 2 a 3  →  no hay más condiciones: misión completada
11. MODO_AUTO sale por condición externa o BTN_Manual/BTN_Reset
```

---

## 6. Condiciones de salida de MODO_AUTO

| Condición | Destino | Descripción |
|---|---|---|
| `BTN_Manual` | `MODO_MANUAL` | Operador interrumpe para tomar control total |
| `ejec_mov==1 && Joy movido` | `MODO_MANUAL` | Operador interviene durante movimiento automático |
| `modo_manual_auto==1 && sobrecarga==1` | `STAND_BY` | Sobrecarga detectada en posicionamiento fino |
| `modo_manual_auto==1 && TLK==0 && yh_enc>envolvente` | `STAND_BY` | Container depositado correctamente, gancho libre |
| `BTN_Reset` | `PASO_STANDBY` | Abandona modo auto, espera que crane frene |

---

## 7. Interacción con TWISTLOCKS (estado paralelo)

El estado `TWISTLOCKS` corre en paralelo y gestiona de forma independiente el cierre/apertura de twistlocks. El modo automático **no controla directamente** los twistlocks: el operador usa `BTN_TLK` y el estado `TWISTLOCKS` responde. Sin embargo, el modo automático **lee** el estado `TLK` para tomar decisiones.

| Estado TWISTLOCKS | TLK | Efecto en MODO_AUTO |
|---|---|---|
| `VACIO` | 0 | Permite ir a buscar container |
| `CERRANDO_TLK` | 1 | Bloquea movimiento: `vh_lim=0.1`, `vx_target=0` |
| `CARGADO` | 1 | Limita `vh_lim` en función de masa, bloquea si sobrecarga |
| `ABRIENDO_TLK` | 0 → 0 | Bloquea movimiento durante apertura |

La condición `yh_enc > envolvente(i_usado) + Hc` en `MODO_MANUAL_SIMPLE` asegura que el container fue levantado al menos `Hc` metros por encima de los containers vecinos antes de que el autómata planifique el movimiento horizontal.

---

## 8. Función de envolvente

La **envolvente** es un vector de 33 elementos que representa la **altura máxima de containers en cada columna de la grilla**, más un margen de seguridad. Se genera mediante:

```
envolvente = Generar_Envolvente(perfil_escaneado_vec, escaneado_vec)
```

El planificador la usa para determinar la altura mínima a la que debe estar el gancho (o container) al trasladarse horizontalmente sobre cada columna. Garantiza clearance vertical durante el movimiento horizontal.

El vector `h_vec_output` (perfil de alturas) se actualiza en `ACTUALIZAR_PERFIL_ALTURAS` cada vez que:
- El LIDAR escanea una nueva posición: `h_vec(i_lidar) = lectura_LIDAR`
- Se cierran los twistlocks (TLK rise): `h_vec(i_carro) -= Hc` (se levantó un container)
- Se abren los twistlocks (TLK fall): `h_vec(i_carro) += Hc` (se depositó un container)

---

## 9. Función de suavizado de velocidad

Las velocidades que genera el modo automático (`vx_target`, `vy_target`) no van directamente a los controladores. Pasan por `SUAVIZADO_VELOCIDAD`:

```
[vx_cmd, ax_act] = Suavizador_Cinematico(vx_target, vx_cmd, ax_act, at_max, jerk_max)
[vy_cmd, ay_act] = Suavizador_Cinematico(vy_target, vy_cmd, ay_act, ah_max, jerk_max)
```

- `jerk_max = 1.5 m/s³`
- Limita aceleración a `at_max` (carro) y `ah_max` (izaje)
- Garantiza transiciones suaves cuando el planificador cambia de objetivo

**Excepción:** Durante `seleccionando==1` (selección de índices), `vx_cmd = Joy_CMD_X * 12` (movimiento rápido de cruceta sin suavizado, ya que es solo visual).

---

## 10. Límite suave de bajada (LIMITES_SUAVES)

Previene colisión del gancho/container con los containers de abajo al descender:

```matlab
% Distancia al obstáculo más cercano debajo
if (TLK == 1)
    dist = yh_enc - (yc0 + 0.5 + Hc);   % Con container: margen mayor
    T_retardo = 0.8;
else
    dist = yh_enc - (yc0 + 0.5);         % Sin container
    T_retardo = 0.4;
end
% Compensa retardo dinámico del sistema
dist_efectiva = dist - abs(vy_cmd) * T_retardo;
% Velocidad máxima de bajada segura
v_segura = sqrt(0.01 + 2 * ah_max * 0.65 * dist_efectiva)
% Recorta vy_cmd si baja demasiado rápido
if vy_cmd < -v_segura:
    vy_cmd = -v_segura
```

Este límite actúa **incluso en modo automático**: si el planificador genera una referencia de bajada demasiado rápida, `LIMITES_SUAVES` la recorta antes de que llegue al controlador.

---

## 11. Señales de entrada relevantes para MODO_AUTO

| Señal | Descripción |
|---|---|
| `BTN_Auto` | Activa modo automático |
| `BTN_Manual` | Fuerza salida a modo manual |
| `BTN_Reset` | Abandona modo, va a PASO_STANDBY |
| `BTN_TLK` | Confirma selección de índice / opera twistlocks |
| `Joy_XY` | Joystick [X, Y], usado en MODO_MANUAL_SIMPLE |
| `xt_enc` | Posición del carro (encoder) |
| `yh_enc` | Posición del gancho (encoder) |
| `vt_obs`, `vh_obs` | Velocidades estimadas (observador) |
| `theta_l`, `theta_l_dot` | Ángulo y velocidad angular del péndulo |
| `Fhw` | Fuerza en el cable (célula de carga) |
| `FC_der/izq/sup/inf` | Fines de carrera (seguridad, interrumpen MODO_AUTO) |

## 12. Señales de salida relevantes de MODO_AUTO

| Señal | Descripción |
|---|---|
| `vx_cmd`, `vy_cmd` | Comandos de velocidad (suavizados) para controladores |
| `modo_auto` | 1 mientras ejecuta trayectoria automática |
| `modo_manual_auto` | 1 durante MODO_MANUAL_SIMPLE |
| `ejec_mov` | 1 durante MOVIMIENTO_CURVO o MOVIMIENTO_SEGURO |
| `seleccionando` | 1 durante selección de índices (snap de cruceta) |
| `seleccionando_i` | [ini, fin]: indica cuál índice se está seleccionando |
| `i_obj_vec` | [i_ini, i_fin]: índices de origen y destino confirmados |
| `x_cruz_unity`, `y_cruz_unity` | Posición de la cruceta para visualización (Unity) |
| `BRK_t_N1`, `BRK_h_N1` | Control de frenos (1=abierto, 0=cerrado) |
| `TLK` | Estado twistlocks (gestionado por TWISTLOCKS paralelo) |
| `m_est` | Masa estimada total (spreader + container) |
| `m_container` | Masa estimada del container solo |
| `vh_lim` | Velocidad máxima de izaje (función de masa y potencia) |
| `sobrecarga` | 1 si m_container > Mc_max |
| `envolvente` | Vector 33×1 de alturas máximas por columna |
| `h_vec_output` | Perfil de alturas actualizado |

---

## 13. Parámetros del workspace relevantes

| Parámetro | Descripción |
|---|---|
| `Ts1` | Período de muestreo del supervisor (20 ms) |
| `Hc` | Altura de un container |
| `Wc` | Ancho de una columna de la grilla |
| `xt_min`, `xt_max` | Límites horizontales del recorrido |
| `yh_min`, `yh_max` | Límites verticales del recorrido |
| `vt_max` | Velocidad máxima del carro |
| `vh_nom`, `vh_max_unloaded` | Velocidades nominales de izaje |
| `ah_max`, `at_max` | Aceleraciones máximas |
| `P_nom` | Potencia nominal del motor de izaje |
| `Mc_max` | Masa máxima de container (umbral de sobrecarga) |
| `Ms` | Masa del spreader (sin container) |
| `g` | Gravedad (9.81 m/s²) |
| `N_xt` | Número de columnas en la grilla (33) |
| `x_LIDAR` | Offset del LIDAR respecto al carro |
| `h_vec_inicial` | Perfil de alturas inicial |
| `is_scanned_vec_inicial` | Vector inicial de posiciones escaneadas |
