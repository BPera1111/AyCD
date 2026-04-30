"""
crear_nivel1_claude.py
Crea nivel_1_claude.slx modificando el XML interno de nivel_1.slx.
No requiere MATLAB corriendo. Ejecutar desde la carpeta simulink/.

ESTRUCTURA Stateflow XML (verificada contra nivel_1.slx original):
  - Transiciones van DENTRO del <Children> de su estado padre
  - Data va al nivel del chart <Children>, después de todos los estados
  - Subviewer = ID del chart (180), no del estado padre
"""
import zipfile, io, re

SLX_IN  = 'nivel_1.slx'
SLX_OUT = 'nivel_1_claude.slx'
CHART   = 'simulink/stateflow/chart_180.xml'
SYS_ROOT = 'simulink/systems/system_root.xml'

# ─── Leer ZIP original ────────────────────────────────────────────────────────
files = {}
compress_types = {}
with zipfile.ZipFile(SLX_IN, 'r') as z:
    for info in z.infolist():
        files[info.filename] = z.read(info.filename)
        compress_types[info.filename] = info.compress_type

# ─── Helper: data XML ─────────────────────────────────────────────────────────
def data_xml(ssid, name, scope, param_idx=None):
    dtype = ('Inherit: From definition in chart'
             if scope == 'LOCAL_DATA'
             else 'Inherit: Same as Simulink')
    param_line = (f'\n      <P Name="paramIndexForInitFromWorkspace">{param_idx}</P>'
                  if param_idx is not None else '')
    return (f'    <data SSID="{ssid}" name="{name}">\n'
            f'      <P Name="scope">{scope}</P>{param_line}\n'
            f'      <props>\n'
            f'        <array>\n'
            f'          <P Name="size">-1</P>\n'
            f'        </array>\n'
            f'        <type>\n'
            f'          <P Name="method">SF_INHERITED_TYPE</P>\n'
            f'          <P Name="primitive">SF_DOUBLE_TYPE</P>\n'
            f'          <P Name="isSigned">1</P>\n'
            f'          <P Name="wordLength">16</P>\n'
            f'        </type>\n'
            f'        <P Name="frame">SF_FRAME_INHERITED</P>\n'
            f'        <unit>\n'
            f'          <P Name="name">inherit</P>\n'
            f'        </unit>\n'
            f'      </props>\n'
            f'      <P Name="dataType">{dtype}</P>\n'
            f'    </data>')

# ─── Helper: OR_STATE sin hijos ───────────────────────────────────────────────
def state_or(ssid, label, pos, indent=8):
    ind  = ' ' * indent
    ind2 = ' ' * (indent + 2)
    p = f'[{pos[0]} {pos[1]} {pos[2]} {pos[3]}]'
    return (f'{ind}<state SSID="{ssid}">\n'
            f'{ind2}<P Name="labelString">{label}</P>\n'
            f'{ind2}<P Name="position">{p}</P>\n'
            f'{ind2}<P Name="fontSize">12</P>\n'
            f'{ind2}<P Name="subviewer">180</P>\n'
            f'{ind2}<P Name="type">OR_STATE</P>\n'
            f'{ind2}<P Name="decomposition">CLUSTER_STATE</P>\n'
            f'{ind}</state>')

# ─── Helper: OR_STATE con hijos (hijos = estados + transiciones) ──────────────
def state_or_with_children(ssid, label, pos, children_xml, indent=8):
    ind  = ' ' * indent
    ind2 = ' ' * (indent + 2)
    p = f'[{pos[0]} {pos[1]} {pos[2]} {pos[3]}]'
    return (f'{ind}<state SSID="{ssid}">\n'
            f'{ind2}<P Name="labelString">{label}</P>\n'
            f'{ind2}<P Name="position">{p}</P>\n'
            f'{ind2}<P Name="fontSize">12</P>\n'
            f'{ind2}<P Name="subviewer">180</P>\n'
            f'{ind2}<P Name="type">OR_STATE</P>\n'
            f'{ind2}<P Name="decomposition">CLUSTER_STATE</P>\n'
            f'{ind2}<Children>\n'
            f'{children_xml}\n'
            f'{ind2}</Children>\n'
            f'{ind}</state>')

# ─── Helper: transición ───────────────────────────────────────────────────────
def trans(ssid, label, src_ssid, dst_ssid,
          src_x, src_y, dst_x, dst_y,
          src_edge, dst_edge,
          mid_x, mid_y, exec_order=1, indent=8):
    """
    Las transiciones van dentro del <Children> de su estado padre.
    indent=8 para hijos de AUTOMATA_PRINCIPAL, indent=10 para hijos de MODO_AUTO.
    edge: 'top'=1, 'right'=2, 'bottom'=3, 'left'=4, 'free'=0 (default)
    """
    edge_map = {'free': 0, 'top': 1, 'right': 2, 'bottom': 3, 'left': 4}
    se = edge_map[src_edge]
    de = edge_map[dst_edge]

    if src_edge == 'free':
        src_int = f'[0 0 1 0 {src_x} {src_y} 0 0]'
        src_body = ''
    else:
        s = 1 if src_edge == 'right' else (-1 if src_edge == 'left' else 0)
        src_int = f'[{se} {s} 0 0.5 {src_x} {src_y} 0 0]'
        src_body = f'\n{" "*(indent+4)}<P Name="SSID">{src_ssid}</P>'

    d = -1 if dst_edge in ('top', 'left') else 1
    dst_int = f'[{de} {d} 0 0.5 {dst_x} {dst_y} 0 0]'

    ind  = ' ' * indent
    ind2 = ' ' * (indent + 2)
    lbl_xml = f'\n{ind2}<P Name="labelString">{label}</P>' if label else ''

    return (f'{ind}<transition SSID="{ssid}">{lbl_xml}\n'
            f'{ind2}<P Name="fontSize">12</P>\n'
            f'{ind2}<src>{src_body}\n'
            f'{ind2}  <P Name="intersection">{src_int}</P>\n'
            f'{ind2}</src>\n'
            f'{ind2}<dst>\n'
            f'{ind2}  <P Name="SSID">{dst_ssid}</P>\n'
            f'{ind2}  <P Name="intersection">{dst_int}</P>\n'
            f'{ind2}</dst>\n'
            f'{ind2}<P Name="midPoint">[{mid_x} {mid_y}]</P>\n'
            f'{ind2}<P Name="subviewer">180</P>\n'
            f'{ind2}<P Name="drawStyle">SMART</P>\n'
            f'{ind2}<slide>\n'
            f'{ind2}  <P Name="sticky">BOTH_STICK</P>\n'
            f'{ind2}</slide>\n'
            f'{ind2}<P Name="executionOrder">{exec_order}</P>\n'
            f'{ind}</transition>')

# ═══════════════════════════════════════════════════════════════════════════════
xml = files[CHART].decode('utf-8')

# ── 1. ssIdHighWaterMark: 170 → 192 ──────────────────────────────────────────
xml = xml.replace('<P Name="ssIdHighWaterMark">170</P>',
                   '<P Name="ssIdHighWaterMark">192</P>', 1)

# ── 2. Corregir SSID=170 (i_lista): LOCAL_DATA → PARAMETER_DATA ───────────────
# El script MATLAB (agregar_modo_auto.m) creó i_lista con scope incorrecto antes de fallar.
# Contamos PARAMETER_DATA existentes ANTES de SSID=170 para el paramIndex.
ssid170_start = xml.find('<data SSID="170"')
assert ssid170_start >= 0, 'SSID=170 no encontrado'
xml_before_170 = xml[:ssid170_start]
n_params_before = len(re.findall(r'<P Name="scope">PARAMETER_DATA</P>', xml_before_170))
i_lista_param_idx = n_params_before + 1  # 1-based
ssid170_end = xml.find('</data>', ssid170_start) + len('</data>')
xml = xml[:ssid170_start] + data_xml(170, 'i_lista', 'PARAMETER_DATA',
                                      param_idx=i_lista_param_idx) + xml[ssid170_end:]

# ── 3. Guard VACIO→CERRANDO: agrega && modo_seleccion==0 ─────────────────────
old_lbl = ('[BTN_TLK == 1 &amp;&amp;...\n'
           ' Fhw &lt; (Ms*g/2 * 0.8) &amp;&amp;...\n'
           ' hay_cont == 1]')
new_lbl = ('[BTN_TLK == 1 &amp;&amp;...\n'
           ' Fhw &lt; (Ms*g/2 * 0.8) &amp;&amp;...\n'
           ' hay_cont == 1 &amp;&amp;...\n'
           ' modo_seleccion == 0]')
if old_lbl in xml:
    xml = xml.replace(old_lbl, new_lbl, 1)
    print('OK: VACIO->CERRANDO guard actualizado')
else:
    print('AVISO: label VACIO->CERRANDO no encontrado — verificar manualmente')

# ── 4. Nuevos datos (BTN_Auto + locales) al final del chart Children ──────────
# SSID=170 (i_lista) ya es el último dato. Insertamos después de su </data>.
# El rfind('</Children>') da el chart-level Children close (último </Children> del XML).
new_data = '\n'.join([
    data_xml(171, 'BTN_Auto',       'INPUT_DATA'),
    data_xml(172, 'i_sel',          'LOCAL_DATA'),
    data_xml(173, 'i_obj',          'LOCAL_DATA'),
    data_xml(174, 'x_obj',          'LOCAL_DATA'),
    data_xml(175, 'modo_auto',      'LOCAL_DATA'),
    data_xml(176, 'modo_seleccion', 'LOCAL_DATA'),
    data_xml(177, 'debounce',       'LOCAL_DATA'),
    data_xml(178, 'y_max_ruta',     'LOCAL_DATA'),
    data_xml(179, 'y_segura',       'LOCAL_DATA'),
    data_xml(180, 'err_x',          'LOCAL_DATA'),
]) + '\n'

chart_cc = xml.rfind('</Children>')  # cierre del chart Children
xml = xml[:chart_cc] + new_data + xml[chart_cc:]

# ── 5. Encontrar </Children> de AUTOMATA_PRINCIPAL ────────────────────────────
ap_idx = xml.find('<state SSID="1">')
ap_children_open = xml.find('<Children>', ap_idx)
pos = ap_children_open + len('<Children>')
depth = 1
ap_children_close = -1
while depth > 0:
    no = xml.find('<Children>', pos)
    nc = xml.find('</Children>', pos)
    assert nc >= 0, 'XML malformado'
    if no != -1 and no < nc:
        depth += 1; pos = no + len('<Children>')
    else:
        depth -= 1
        if depth == 0: ap_children_close = nc
        pos = nc + len('</Children>')
assert ap_children_close >= 0

# ── 6. Labels (XML-escaped) ───────────────────────────────────────────────────
lbl_sel = (
    'SELECCION\n'
    'entry:\n'
    '  i_sel = 1; debounce = 0;\n'
    '  modo_seleccion = 1;\n'
    '  BRK_t_N1 = 0; BRK_h_N1 = 0;\n'
    '  x_obj = xt_min + (i_lista(1)-1)*Wc + Wc/2;\n'
    'during:\n'
    '  debounce = debounce + 1;\n'
    '  if (debounce &gt; 25)\n'
    '    if (Joy_CMD_X &gt; dead_zone)\n'
    '      i_sel = mod(i_sel, length(i_lista)) + 1;\n'
    '      debounce = 0;\n'
    '    elseif (Joy_CMD_X &lt; -dead_zone)\n'
    '      i_sel = mod(i_sel-2, length(i_lista)) + 1;\n'
    '      debounce = 0;\n'
    '    end\n'
    '  end\n'
    '  x_obj = xt_min + (i_lista(i_sel)-1)*Wc + Wc/2;\n'
    'exit:\n'
    '  i_obj = i_lista(i_sel);\n'
    '  modo_seleccion = 0;'
)
lbl_auto = (
    'MODO_AUTO\n'
    'entry:\n'
    '  modo_auto = 1;\n'
    '  BRK_t_N1 = 1; BRK_h_N1 = 1;\n'
    'exit:\n'
    '  modo_auto = 0;'
)
lbl_subir = (
    'SUBIR\n'
    'entry:\n'
    '  y_max_ruta = 0;\n'
    '  for k = min(i_carro,i_obj):max(i_carro,i_obj)\n'
    '    if yc0_vec(k) &gt; y_max_ruta\n'
    '      y_max_ruta = yc0_vec(k);\n'
    '    end\n'
    '  end\n'
    '  y_segura = min(y_max_ruta + Hc + 1.0, yh_max - 1.0);\n'
    'during:\n'
    '  vx_target = 0;\n'
    '  vy_target = vh_lim;'
)
lbl_mover = (
    'MOVER\n'
    'entry:\n'
    '  x_obj = xt_min + (i_obj-1)*Wc + Wc/2;\n'
    'during:\n'
    '  err_x = x_obj - xt_enc;\n'
    '  vx_target = max(-vt_max, min(vt_max, 3.0*err_x));\n'
    '  vy_target = 0;'
)
lbl_pos = (
    'POSICION_MANUAL\n'
    'entry: modo_auto = 0;\n'
    'during:\n'
    '  if (abs(Joy_CMD_X) &lt; dead_zone)\n'
    '    vx_target = 0;\n'
    '  else\n'
    '    vx_target = Joy_CMD_X * vt_max * 0.05;\n'
    '  end\n'
    '  if (abs(Joy_CMD_Y) &lt; dead_zone)\n'
    '    vy_target = 0;\n'
    '  else\n'
    '    vy_target = Joy_CMD_Y * vh_lim;\n'
    '  end'
)

# ── 7. Posiciones (coordenadas absolutas del chart) ───────────────────────────
# AUTOMATA_PRINCIPAL: [20, 124, 1401, 1380] → right=1421, bottom=1504
# REPOSO: [859.3, 177.7, 306.8, 230.4] → right=1166, center=(1012.7, 293)
# SELECCION: a la izquierda de REPOSO
pos_sel  = [50,  148, 720, 240]   # center=(410,268), right=770, bottom=388
pos_auto = [50, 1020, 1370, 450]  # center=(785,1245), top=1020
pos_sub  = [70,  1110, 360, 320]  # center=(250,1270), right=430
pos_mov  = [470, 1110, 360, 320]  # center=(650,1270), right=830
pos_posm = [870, 1110, 360, 320]  # center=(1050,1270), right=1230

# ── 8. XML de estados ─────────────────────────────────────────────────────────
s_sub_xml = state_or(183, lbl_subir, pos_sub,  indent=10)
s_mov_xml = state_or(184, lbl_mover, pos_mov,  indent=10)
s_pos_xml = state_or(185, lbl_pos,   pos_posm, indent=10)

# Transiciones DENTRO de MODO_AUTO (entre sus sub-estados)
# Default → SUBIR (flecha sin fuente)
t186 = trans(186, '', None, 183,
             250, 1095, 250, 1110,
             'free', 'top', 250, 1097, exec_order=1, indent=10)
# SUBIR → MOVER
t187 = trans(187,
             '[yh_enc &gt;= y_segura &amp;&amp; abs(vh_obs) &lt; 0.1]',
             183, 184,
             430, 1270, 470, 1270,
             'right', 'left', 450, 1270, exec_order=1, indent=10)
# MOVER → POSICION_MANUAL
t188 = trans(188,
             '[abs(xt_enc - x_obj) &lt; 0.15 &amp;&amp; abs(vt_obs) &lt; 0.1]',
             184, 185,
             830, 1270, 870, 1270,
             'right', 'left', 850, 1270, exec_order=1, indent=10)

children_auto = '\n'.join([s_sub_xml, s_mov_xml, s_pos_xml, t186, t187, t188])
sel_xml  = state_or(181, lbl_sel,  pos_sel,  indent=8)
auto_xml = state_or_with_children(182, lbl_auto, pos_auto, children_auto, indent=8)

# Transiciones DENTRO de AUTOMATA_PRINCIPAL (entre sus sub-estados directos)
# REPOSO(5) left(x=859.3, cy=293) → SELECCION(181) right(x=770, cy=268)
t189 = trans(189, '[BTN_Auto == 1]',
             5, 181,
             859.3, 293, 770, 268,
             'left', 'right', 815, 280, exec_order=5, indent=8)
# SELECCION(181) bottom(cx=410, y=388) → MODO_AUTO(182) top(cx=785, y=1020)
t190 = trans(190, '[BTN_TLK == 1]',
             181, 182,
             410, 388, 785, 1020,
             'bottom', 'top', 410, 704, exec_order=1, indent=8)
# SELECCION(181) top(cx=410, y=148) → REPOSO(5) left(x=859.3, cy=293)
t191 = trans(191, '[BTN_Reset == 1]',
             181, 5,
             410, 148, 859.3, 200,
             'top', 'left', 635, 148, exec_order=2, indent=8)
# POSICION_MANUAL(185) right(x=1230, cy=1270) → SELECCION(181) right(x=770, cy=268)
t192 = trans(192, '[BTN_Auto == 1]',
             185, 181,
             1230, 1270, 770, 268,
             'right', 'right', 1350, 600, exec_order=1, indent=8)

# ── 9. Insertar en AUTOMATA_PRINCIPAL Children ────────────────────────────────
# REGLA STATEFLOW: dentro de <Children>, estados SIEMPRE antes de transiciones/junctions.
# Si insertamos al final (ap_children_close), los nuevos estados quedan DESPUÉS
# de las transiciones existentes → SF::get_all_substates_of falla con abort().
# Fix: insertar estados nuevos ANTES del primer <transition o <junction en AP Children.
# Insertar transiciones nuevas al final (antes de </Children>).

# Encontrar primer <transition o <junction dentro de AP Children
pos_first_trans = xml.find('<transition', ap_children_open, ap_children_close)
pos_first_junc  = xml.find('<junction',   ap_children_open, ap_children_close)
candidates = [p for p in [pos_first_trans, pos_first_junc] if p > 0]
insert_states_at = min(candidates) if candidates else ap_children_close

# Insertar nuevos ESTADOS antes del primer transition/junction
new_states_xml = '\n' + sel_xml + '\n' + auto_xml + '\n'
xml = xml[:insert_states_at] + new_states_xml + xml[insert_states_at:]

# Recomputar ap_children_close (desplazado por la inserción anterior)
ap_children_close += len(new_states_xml)

# Insertar nuevas TRANSICIONES al final de AP Children (después de todo)
new_trans_xml = '\n' + t189 + '\n' + t190 + '\n' + t191 + '\n' + t192 + '\n      '
xml = xml[:ap_children_close] + new_trans_xml + xml[ap_children_close:]

# ── 10. Verificación rápida ───────────────────────────────────────────────────
import xml.etree.ElementTree as ET
try:
    ET.fromstring(xml)
    print('OK: XML válido')
except Exception as e:
    print(f'ERROR XML: {e}')
    raise

# ─── system_root.xml: cable BTN_Auto (Control Joystick port5 → Chart port15) ──
root_xml = files[SYS_ROOT].decode('utf-8')
new_line = ('  <Line>\n'
            '    <P Name="ZOrder">14100</P>\n'
            '    <P Name="Src">1112#out:5</P>\n'
            '    <P Name="Dst">1109#in:15</P>\n'
            '  </Line>\n')
if '1109#in:15' not in root_xml:
    root_xml = root_xml.replace('</System>', new_line + '</System>', 1)
    print('OK: línea BTN_Auto agregada en system_root')
else:
    print('INFO: línea BTN_Auto ya existe en system_root')

# ─── Escribir ZIP nuevo ───────────────────────────────────────────────────────
buf = io.BytesIO()
with zipfile.ZipFile(buf, 'w') as z_out:
    for fname, data in files.items():
        if fname == CHART:
            z_out.writestr(fname, xml.encode('utf-8'),
                           compress_type=compress_types[fname])
        elif fname == SYS_ROOT:
            z_out.writestr(fname, root_xml.encode('utf-8'),
                           compress_type=compress_types[fname])
        else:
            z_out.writestr(fname, data,
                           compress_type=compress_types[fname])

with open(SLX_OUT, 'wb') as f:
    f.write(buf.getvalue())

# ─── Resumen ──────────────────────────────────────────────────────────────────
print(f'\nCreado: {SLX_OUT}')
print(f'  i_lista (SSID=170) paramIndex: {i_lista_param_idx}')
n_inputs  = xml.count('<P Name="scope">INPUT_DATA</P>')
n_params  = xml.count('<P Name="scope">PARAMETER_DATA</P>')
n_locals  = xml.count('<P Name="scope">LOCAL_DATA</P>')
print(f'  INPUT_DATA: {n_inputs}  (BTN_Auto = puerto {n_inputs})')
print(f'  PARAMETER_DATA: {n_params}  LOCAL_DATA: {n_locals}')
print()
print('Próximo paso:')
print('  1. Abrir nivel_1_claude.slx en MATLAB/Simulink')
print('  2. Ejecutar init_plant_parameters.m')
print('  3. Verificar chart: SELECCION y MODO_AUTO visibles')
