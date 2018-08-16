function [value, normalization] = hanning(x, bandwidth, notch)
  % implements the Hanning kernel (Prerau & Eden 2011)

  %% Arguments
    % x: double, the time value at which the kernel should be computed
    % bandwidth: double, the filter length (is used to compute the variance)
    % notch: boolean, if true, kernel(0) = 0, defaults to false
  %% Outputs
    % value: the actual result of computing the kernel at a point/along a vector
    % normalization: the normalization coefficient from -Inf to Inf

  if nargin < 3
    notch = false;
  end

  normalization = x / 2 + (bandwidth - 1) * sin( (2 * pi * x) / (bandwidth - 1) ) / (4 * pi);

  if notch & x == 0
    value = 0;
    return
  end

  if x > -bandwidth / 2 && x <= bandwidth / 2
    value = 0.5 * (1 + cos( (2*pi*x) / (bandwidth - 1) ) );
  else
    value = 0;
  end

end % end function
