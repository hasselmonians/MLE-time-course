function y = satexp_fit(params, t)
    y = params(1) - params(2) * exp(- params(3) * t);
end % function
