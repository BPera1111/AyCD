# AyCD

Entendido. Acá van los pasos exactos para hacer vos en MATLAB/Simulink:

1. Variables nuevas en el chart (Stateflow → Edit Data)
Dentro del chart AUTOMATA_PRINCIPAL en planta.slx, agregar estas variables locales:

Nombre	Tipo	Tamaño	Scope
yc0_est_vec	double	[1 33]	Local
count_vec	double	[1 33]	Local
is_scanned_vec	double	[1 33]	Local
2. Estado ACTUALIZAR_PERFIL_ALTURAS — entry
Agregar después de yc0_vec = yc0_vec_inicial; yc0 = 0;:


yc0_est_vec = zeros(1,33);
count_vec   = zeros(1,33);
is_scanned_vec = zeros(1,33);
3. Estado ACTUALIZAR_PERFIL_ALTURAS — during
Cambio 1: En el bloque if(TLK_rise), después de yc0_vec(i_carro) = yc0_vec(i_carro) - Hc; agregar:


yc0_est_vec(i_carro) = 0;
count_vec(i_carro)   = 0;
is_scanned_vec(i_carro) = 0;
Cambio 2: Lo mismo en elseif(TLK_fall) después de + Hc.

Cambio 3: Cambiar:


yc0 = yc0_vec(i_carro);
envolvente = Generar_Envolvente(yc0_vec);
Por:


yc0 = yc0_est_vec(i_carro);
envolvente = Generar_Envolvente(yc0_est_vec, is_scanned_vec);
4. Estado Escaneo — during
Agregar al final del bloque during:


if abs(vt_obs) > 0.05
    reading = yc0_vec(i_lidar) + 0.05 * randn();
    yc0_est_vec(i_lidar) = max(yc0_est_vec(i_lidar), reading);
    count_vec(i_lidar) = count_vec(i_lidar) + 1;
    if count_vec(i_lidar) >= 3
        is_scanned_vec(i_lidar) = 1;
    end
end
5. Función Generar_Envolvente
Firma actual:


function envolvente_f = Generar_Envolvente(perfil_escaneado_vec)
...
escaneado_vec = ones(N,1);   % ← borrar esta línea
Cambiar a:


function envolvente_f = Generar_Envolvente(perfil_escaneado_vec, escaneado_vec)
% escaneado_vec viene de is_scanned_vec — ya no se hardcodea
Lógica general

yc0_vec        = verdad física (modificada por TLK, usada por modelo físico)
yc0_est_vec    = lo que el controlador "ve" (construido por LIDAR mientras el carro se mueve)
is_scanned_vec = qué celdas ya fueron escaneadas
El modo auto no puede proceder por celdas donde is_scanned_vec = 0 porque envolvente devuelve 0 ahí.

c:\Users\bruno\OneDrive - Universidad Nacional de Cuyo\Facultad\10mo Semestre\Automatas y Control Discreto\AyCD\joystick.py
ok ya lo agregue y compilo ahora como lo pruebo. como hago para ver que funciona
Pasos para verificar en MATLAB:

1. Setup inicial


cd simulink
run('init_plant_parameters.m')
open_system('planta.slx')   % o nivel_1_full.slx si lo pusiste ahí
2. Agregar señales al Scope / Workspace
En Simulink, loguear estas variables del chart para ver en tiempo real:

yc0_est_vec — debe arrancar en ceros y llenarse mientras el carro se mueve
is_scanned_vec — debe ir de 0→1 celda por celda
count_vec — debe incrementar mientras |vt_obs| > 0.05
Podés hacerlo con Simulation → Data Inspector (MATLAB loguea señales del Stateflow automáticamente si las marcás con el ícono de log).

3. Test mínimo

Simular en modo MANUAL
Mover carro de izquierda a derecha con joystick (o forzar vt_obs > 0.05 con un step)
Observar is_scanned_vec: debe pasar a 1 de izquierda a derecha con retraso (requiere ~3 pasos × 20ms = 60ms por celda a baja velocidad)
yc0_est_vec debe aproximarse a yc0_vec_inicial con pequeño ruido (±0.05 Hc ≈ ±0.13m)
4. Verificar invalidación por TLK

Mover carro a una celda ya escaneada
Activar TLK (enganchar container)
is_scanned_vec(i_carro) debe volver a 0
Al soltar TLK: lo mismo
5. Señal de alarma rápida
Si ves que yc0_est_vec nunca se actualiza → vt_obs no está llegando al chart. Verificar que el wire de vt_obs conecta con el chart (en system_1109.xml/Nivel 1).

¿Qué ves cuando simulás?

c:\Users\bruno\OneDrive - Universidad Nacional de Cuyo\Facultad\10mo Semestre\Automatas y Control Discreto\AyCD\run_dashboard.py
No entiendo cual es la idea de como deberia funcionar
Situación real (puerto real):

El LIDAR está montado en el carro, apuntando hacia abajo. Mientras el carro se mueve, el sensor dispara rayos laser continuamente y va midiendo la altura de lo que tiene abajo. Cuando termina de recorrer toda la zona, tiene un mapa completo de los containers.

Lo que había antes (irrealista):


t=0: el controlador YA SABE las 33 alturas
     → como si el carro hubiera nacido sabiendo todo
Lo que hace ahora (realista):


t=0: controlador no sabe nada → yc0_est_vec = [0,0,0,...,0]

Carro empieza a moverse →
  Celda 5 bajo LIDAR → mide yc0_vec(5) + ruido → guarda en yc0_est_vec(5)
  Celda 6 bajo LIDAR → mide yc0_vec(6) + ruido → guarda en yc0_est_vec(6)
  ...
  Después de 3 medidas en celda i → is_scanned_vec(i) = 1  ✓

Modo AUTO solo puede usar celdas donde is_scanned_vec = 1
→ Si quiere ir a una celda no escaneada, no puede
→ Operador debe hacer pasada manual primero para escanear
Flujo de operación real:


1. Arranque → todo desconocido
2. Operador mueve carro en MANUAL de extremo a extremo
3. LIDAR va "pintando" el perfil celda por celda
4. Una vez que el camino destino está escaneado → modo AUTO habilitado
5. Si mueve un container (TLK) → esa celda vuelve a desconocido → re-escanear
Por qué yc0_vec (verdad) vs yc0_est_vec (estimado):

El modelo físico necesita saber la altura REAL para calcular si el spreader choca. Eso es yc0_vec. El controlador solo puede usar lo que "vio" con el sensor. Eso es yc0_est_vec. Son dos cosas distintas igual que en la vida real.

No entiendo porque en la parte del escaneo hay que esperar v_obs>0.05
Buena pregunta. La condición |vt_obs| > 0.05 es para que el LIDAR solo tome medidas cuando el carro se está moviendo.

¿Por qué?

En un LIDAR real montado en el carro, el sensor escanea porque el carro avanza. Si el carro está quieto, el LIDAR sigue midiendo la misma celda infinitas veces → acumula miles de muestras en count_vec(i_lidar) en segundos → is_scanned_vec(i) = 1 aunque el carro nunca se movió.


Sin la condición:
  Carro quieto en celda 17 → 50 muestras/seg → celda 17 "escaneada" en 60ms
  → Todo el resto nunca escaneado
  → Situación absurda
Pero podés sacarla si querés — depende de cómo modelés el sensor:

Si el LIDAR solo mide cuando el carro se mueve → necesitás la condición
Si el LIDAR mide siempre (incluso quieto, como un sensor estático) → sin condición, pero entonces el N_min_scan = 3 pierde sentido porque las 3 muestras llegan en 60ms aunque no hayas "recorrido" nada
La condición es la que hace que el escaneo requiera recorrer físicamente el espacio, que es la esencia del sensor real.

Eso significa que esta tomando 3 medidas por conteiner ?
No exactamente. El N_min_scan = 3 es el mínimo para marcar la celda como escaneada, pero en realidad toma muchas más.

Cuántas medidas reales por celda:


Wc = 2.44 m  (ancho de celda)
Ts1 = 20 ms  (período del chart)
vt = velocidad del carro

Tiempo en cruzar una celda = Wc / vt

Medidas por celda = (Wc / vt) / Ts1
Ejemplos:


vt = 4 m/s (máxima) → 2.44/4 / 0.02 = 30 medidas
vt = 1 m/s           → 2.44/1 / 0.02 = 122 medidas
vt = 0.5 m/s         → ~244 medidas
El N_min_scan = 3 solo dice "con al menos 3 muestras ya confío en esa celda". A velocidad máxima entran 30, a velocidad baja entran cientos. Es un umbral mínimo de confianza, no el número total de muestras.

El acumulador MAX sigue actualizándose con todas las muestras mientras el carro está sobre esa celda, no solo 3.

Que tengo que armar como plot para poder ver el perfil scaneado en tiempo real ?
Opciones de más fácil a más completo:

Opción 1: Simulation Data Inspector (más rápido)

En Stateflow, click derecho en yc0_est_vec → Properties → habilitar Log signal. Mismo para is_scanned_vec. Al simular, abrís Simulation → Data Inspector y ves los 33 valores en tiempo real.

Limitación: muestra señales individuales, no un bar chart del perfil.

Opción 2: Script MATLAB con timer (recomendado)

Antes de simular, en MATLAB corrés este script en paralelo:


% Correr ANTES de darle Play al modelo
figure; h = bar(zeros(1,33)); ylim([-15 25]); grid on;
xlabel('Índice celda'); ylabel('Altura [m]');
title('Perfil LIDAR en tiempo real');

t = timer('Period', 0.1, 'ExecutionMode', 'fixedRate');
t.TimerFcn = @(~,~) update_plot(h);
start(t);

function update_plot(h)
    if evalin('base', 'exist(''yc0_est_vec'', ''var'')')
        est = evalin('base', 'yc0_est_vec');
        scanned = evalin('base', 'is_scanned_vec');
        cdata = repmat([0.3 0.5 0.8], 33, 1);
        cdata(scanned==0, :) = repmat([0.8 0.2 0.2], sum(scanned==0), 1);
        set(h, 'YData', est, 'CData', cdata);
        drawnow;
    end
end
Barras azules = escaneadas, rojas = sin escanear. Necesitás que yc0_est_vec sea OUTPUT_DATA del chart para que aparezca en workspace.

Opción 3: Dashboard Python (más completo)

yc0_vec ya se manda por UDP al dashboard. Si hacés yc0_est_vec OUTPUT_DATA del Stateflow chart y lo agregás al paquete UDP, el dashboard puede mostrar dos perfiles superpuestos: verdad vs estimado.

Para la opción 2, el paso clave en Simulink: cambiar yc0_est_vec de LOCAL_DATA a OUTPUT_DATA en el chart y conectar el puerto de salida a un bloque To Workspace con modo Array.

