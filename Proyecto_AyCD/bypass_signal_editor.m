function bypass_signal_editor(modelName)
%BYPASS_SIGNAL_EDITOR  Reemplaza fuentes hardcodeadas de referencia por
% Constants que leen del workspace, para que vx_cmd y vh sean efectivos.
%
%  CARRO: Signal Editor "Signal Editor" en Subsystem2 → Constant(vx_cmd)
%  IZAJE: Step "Step" en Subsystem1 → Constant(vh)
%
% Idempotente. El modelo debe estar cargado. Descarte con close_system(modelName,0).

bypass_block(modelName, [modelName '/Subsystem2'], 'Signal Editor', 'VxCmd_WS', 'vx_cmd');
bypass_block(modelName, [modelName '/Subsystem1'], 'Step',          'Vh_WS',    'vh');

end

function bypass_block(modelName, parent, srcName, constName, wsVar)
% Reemplaza srcName en parent por un Constant que lee wsVar del workspace.
srcPath   = [parent '/' srcName];
constPath = [parent '/' constName];

% Idempotente: si ya existe el Constant, no hacer nada
if ~isempty(find_system(parent, 'SearchDepth', 1, 'Name', constName))
    return;
end

if isempty(find_system(parent, 'SearchDepth', 1, 'Name', srcName))
    fprintf('bypass_signal_editor: %s no encontrado en %s, skip\n', srcName, parent);
    return;
end

% Capturar destinos de la línea de salida
lh = get_param(srcPath, 'LineHandles');
outLine = lh.Outport(1);
dstHandles = {};  dstPorts = {};
if outLine ~= -1
    h = get_param(outLine, 'DstBlockHandle');
    p = get_param(outLine, 'DstPortHandle');
    if ~iscell(h), h = {h}; p = {p}; end
    dstHandles = h;  dstPorts = p;
    delete_line(outLine);
end
pos = get_param(srcPath, 'Position');
delete_block(srcPath);

% Crear Constant
add_block('simulink/Sources/Constant', constPath, 'Position', pos);
set_param(constPath, 'Value', wsVar);

% Reconectar
for k = 1:numel(dstHandles)
    dstBlk    = get_param(dstHandles{k}, 'Name');
    dstPortNum = get_param(dstPorts{k},  'PortNumber');
    try
        add_line(parent, [constName '/1'], sprintf('%s/%d', dstBlk, dstPortNum), ...
                 'autorouting', 'on');
    catch ME
        fprintf('bypass_signal_editor: aviso reconectando %s/%s: %s\n', ...
                parent, dstBlk, ME.message);
    end
end
fprintf('bypass_signal_editor: %s/%s → Constant(%s)\n', parent, srcName, wsVar);
end
