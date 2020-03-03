function y = satexp_fit(params, t)

    if isvector(params)
        y = params(1) - params(2) * exp(- params(3) * t);
    else
        y = params(:, 1) - params(:, 2) .* exp(- params(:, 3) .* t)
    end
end % function
