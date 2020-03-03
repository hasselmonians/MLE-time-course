function [linear_parameters, satexp_parameters] = getParameters(data_table)

    %% Description:
    %   Extract the linear and saturating exponential fit parameters
    %   from a processed MLE-time-course data table.
    %
    %% Arguments
    %   data_table: the data table with the stats object
    %
    %% Outputs:
    %   linear_parameters: an n x 2 matrix of parameters
    %       for the linear fit: y ~ b1 + b2 * speed
    %   satexp_parameters: an n x 3 matrix of parameters
    %       for the saturating exponential fit: y ~ b1 - b2 * exp(-b3 * speed)
    %
    %% Examples:
    %   [linear_parameters, satexp_parameters] = getParameters(data_table)

    nRows = height(data_table);

    linear_parameters = NaN(nRows, 2);
    satexp_parameters = NaN(nRows, 3);

    for ii = 1:nRows
        linear_parameters(ii, :) = data_table.stats(ii).linear.Coefficients.Estimate;
        satexp_parameters(ii, :) = data_table.stats(ii).satexp.Coefficients.Estimate;
    end

end % function
