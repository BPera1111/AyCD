function m = metricas_respuesta(y, r, t, opts)
% METRICAS_RESPUESTA  Calcula métricas de calidad de una respuesta al escalón.
%
%   m = metricas_respuesta(y, r, t)
%   m = metricas_respuesta(y, r, t, opts)
%
% Entradas:
%   y    [vector] señal medida
%   r    [vector] referencia (misma longitud que y)
%   t    [vector] tiempo correspondiente
%   opts (struct, opcional):
%     .banda       [default 0.02]  banda ±2% para settling time
%     .t_inicio    [default 0]     ignora datos antes de t_inicio
%
% Salida (struct m):
%   .ISE         integral del error cuadrático
%   .IAE         integral del valor absoluto del error
%   .overshoot   overshoot relativo al valor final de la referencia [0..inf]
%   .settling    tiempo de establecimiento (desde t_inicio) [s] (Inf si no entra a la banda)
%   .err_final   error promedio en el último 10% del tiempo
%   .rise_time   tiempo entre 10% y 90% del salto final [s]

    if nargin < 4, opts = struct(); end
    if ~isfield(opts,'banda'),    opts.banda = 0.02;   end
    if ~isfield(opts,'t_inicio'), opts.t_inicio = 0;   end

    y = y(:); r = r(:); t = t(:);

    idx = t >= opts.t_inicio;
    t = t(idx); y = y(idx); r = r(idx);

    err = r - y;

    m.ISE = trapz(t, err.^2);
    m.IAE = trapz(t, abs(err));

    r_final = mean(r(end-max(1,round(0.05*numel(r))):end));
    y_final = mean(y(end-max(1,round(0.05*numel(y))):end));
    amp_ref = max(abs(r_final), eps);

    if r_final >= 0
        m.overshoot = max(0, (max(y) - r_final)/amp_ref);
    else
        m.overshoot = max(0, (r_final - min(y))/amp_ref);
    end

    m.err_final = r_final - y_final;

    banda_abs = opts.banda * amp_ref;
    fuera = abs(err) > banda_abs;
    idx_last = find(fuera, 1, 'last');
    if isempty(idx_last) || idx_last == numel(t)
        if isempty(idx_last)
            m.settling = t(1);
        else
            m.settling = Inf;
        end
    else
        m.settling = t(idx_last+1) - opts.t_inicio;
    end

    r0 = r(1);
    salto = r_final - r0;
    if abs(salto) < eps
        m.rise_time = 0;
    else
        y10 = r0 + 0.10*salto;
        y90 = r0 + 0.90*salto;
        if salto > 0
            i10 = find(y >= y10, 1, 'first');
            i90 = find(y >= y90, 1, 'first');
        else
            i10 = find(y <= y10, 1, 'first');
            i90 = find(y <= y90, 1, 'first');
        end
        if isempty(i10) || isempty(i90)
            m.rise_time = Inf;
        else
            m.rise_time = t(i90) - t(i10);
        end
    end
end
