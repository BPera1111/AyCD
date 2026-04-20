function bypass_signal_editor(modelName)
%BYPASS_SIGNAL_EDITOR  Reemplaza el Signal Editor "Controlador de Velocidad"
% del subsistema Subsystem2 por un Constant que lee vx_cmd del workspace.
% Idempotente: si ya hay un Constant 'VxCmd_WS', sólo se asegura el cableado.
%
% El modelo debe estar ya cargado. Los cambios se pueden descartar con
% close_system(modelName, 0).

parent = [modelName '/Subsystem2'];
sePath = [parent '/Signal Editor'];
constName = 'VxCmd_WS';
constPath = [parent '/' constName];

if isempty(find_system(parent, 'SearchDepth', 1, 'Name', 'Signal Editor'))
    % Ya bypassado antes — no hacer nada
    if ~isempty(find_system(parent, 'SearchDepth', 1, 'Name', constName))
        return;
    end
end

% Si el Signal Editor existe, obtener sus conexiones y removerlo
if ~isempty(find_system(parent, 'SearchDepth', 1, 'Name', 'Signal Editor'))
    lh = get_param(sePath, 'LineHandles');
    outLine = lh.Outport(1);
    if outLine ~= -1
        dstHandles = get_param(outLine, 'DstBlockHandle');
        dstPorts   = get_param(outLine, 'DstPortHandle');
        if ~iscell(dstHandles)
            dstHandles = {dstHandles};
            dstPorts   = {dstPorts};
        end
        delete_line(outLine);
    else
        dstHandles = {};
        dstPorts   = {};
    end
    pos = get_param(sePath, 'Position');
    delete_block(sePath);
else
    dstHandles = {};
    dstPorts   = {};
    pos = [165 440 250 480];
end

% Crear Constant si no existe
if isempty(find_system(parent, 'SearchDepth', 1, 'Name', constName))
    add_block('simulink/Sources/Constant', constPath, 'Position', pos);
    set_param(constPath, 'Value', 'vx_cmd');
end

% Reconectar líneas al Constant
for k = 1:numel(dstHandles)
    dstBlk = get_param(dstHandles{k}, 'Name');
    dstPortNum = get_param(dstPorts{k}, 'PortNumber');
    try
        add_line(parent, [constName '/1'], sprintf('%s/%d', dstBlk, dstPortNum), ...
                 'autorouting', 'on');
    catch ME
        fprintf('bypass_signal_editor: aviso reconectando %s: %s\n', dstBlk, ME.message);
    end
end

fprintf('bypass_signal_editor: reemplazado %s por Constant(vx_cmd)\n', sePath);
end
