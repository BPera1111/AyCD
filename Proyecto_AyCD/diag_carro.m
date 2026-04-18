%% Diagnóstico: por qué el carro no se mueve
% Agrega ToWorkspace programáticamente a señales clave, corre una sim,
% imprime resumen. NO guarda el modelo.

load_system('controlador_torque');

targets = {'vt_ref','T_tm','vt_cmd','e_v','F_tw','a_td'};
for k = 1:numel(targets)
    nm = targets{k};
    lines = find_system('controlador_torque','FindAll','on','Type','Line','Name',nm);
    for i = 1:numel(lines)
        l  = lines(i);
        pp = get_param(l,'Parent');
        sb = get_param(l,'SrcBlockHandle');
        sp = get_param(l,'SrcPortHandle');
        if sp == -1 || sb == -1, continue; end
        var = sprintf('%s_L%d', nm, i);
        tblk = [pp '/TWK_' var];
        try
            add_block('simulink/Sinks/To Workspace', tblk);
            set_param(tblk,'VariableName',var,'SaveFormat','Timeseries');
            add_line(pp, sprintf('%s/%d', get_param(sb,'Name'), get_param(sp,'PortNumber')), ...
                     [get_param(tblk,'Name') '/1'], 'autorouting','on');
        catch ME
            fprintf('  skip %s: %s\n', var, ME.message);
        end
    end
end

init_plant_parameters;
vx_cmd = 1.5; vh = 0;
anti_sway_estate = 0;
BRK_t_state = 0;  BRK_h_state = 1;  BRK_he_state = 1;  TLK_state = 0;
Mc_X = Mc_max;

set_param('controlador_torque','ReturnWorkspaceOutputs','on','SaveOutput','on');
out = sim('controlador_torque','StopTime','4');

fprintf('\n== Fields in out ==\n');
fn = fieldnames(out);
for i = 1:numel(fn)
    val = out.(fn{i});
    if isa(val,'timeseries')
        d = val.Data(:);
        fprintf('  %-20s  min=%9.4f  max=%9.4f  final=%9.4f\n', fn{i}, min(d), max(d), d(end));
    else
        fprintf('  %-20s  (type %s)\n', fn{i}, class(val));
    end
end

close_system('controlador_torque',0);
