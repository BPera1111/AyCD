%% Parámetros de escenario (editables por script externo o barrido)
% --- Control Carro (escalón de velocidad) ---
time_vx_cmdi = 0;
paso_vx_cmd  = 0.05;
time_vx_cmdf = 15;

% --- Control Izaje (escalón de velocidad) ---
time_vhi = 0;
paso_vh  = 0.05;
time_vhf = 15;

% --- Estados discretos (constantes durante la simulación) ---
anti_sway_estate = 0;
BRK_t_state  = 0;
BRK_h_state  = 0;
BRK_he_state = 0;
TLK_state    = 0;

%% Construcción de señales [t, valor] para los bloques From Workspace
vx_cmd            = build_step(time_vx_cmdi, time_vx_cmdf, paso_vx_cmd);
vh                = build_step(time_vhi,     time_vhf,     paso_vh);
anti_sway_estate  = build_const(anti_sway_estate);
BRK_t_state       = build_const(BRK_t_state);
BRK_h_state       = build_const(BRK_h_state);
BRK_he_state      = build_const(BRK_he_state);
TLK_state         = build_const(TLK_state);

function M = build_step(t_on, t_off, amp)
    eps_t = 1e-6;
    if t_on <= 0 && t_off <= 0
        M = [0 0; 1e6 0];
        return
    end
    M = [0            0; ...
         t_on-eps_t   0; ...
         t_on         amp; ...
         t_off-eps_t  amp; ...
         t_off        0; ...
         1e6          0];
end

function M = build_const(v)
    M = [0 v; 1e6 v];
end
