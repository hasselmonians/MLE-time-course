function y = linear_fit(params, t)

    if isvector(params)
        y = params(1) + params(2) * t;
    else
        y = params(:, 1) + params(:, 2) .* t;
    end
end % function
