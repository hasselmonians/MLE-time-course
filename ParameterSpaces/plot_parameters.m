%% Load the raw data

processed_data_filepath = fullfile(pathlib.strip(mfilename('fullpath'), 2), ...
    'data', 'data-Caitlin-BandwidthEstimator-processed.mat');
load(processed_data_filepath) % contains a 'dataTable' object

%% Classify cell fits

% determine which cells are putatively speed-modulated
fs = 30; % Hz
isModulated = dataTable.kmax / fs < 30 & [dataTable.stats.R]' .^2 > 0.25;

% determine which cells are linear
isLinear = [dataTable.stats.p]' >= 0.05;

%% Scatter plots of parameters

% get the parameters from all modulated cells
[params_linear, params_satexp] = getParameters(dataTable(isModulated & ~isLinear, :));

% generate figures
count = 0;
for ii = 1:3 % over satexp parameters
    for qq = 1:2 % over linear parameters
        count = count + 1;

        h(count) = figure;
        scatter(params_linear(:, qq), params_satexp(:, ii), ...
            'MarkerEdgeColor', 'k', ...
            'MarkerFaceColor', 'k', ...
            'MarkerEdgeAlpha', 0.2, ...
            'MarkerFaceAlpha', 0.2);
        xlabel(['linear parameter ' num2str(qq)])
        ylabel(['satexp parameter ' num2str(ii)])
        title('satexp speed-modulated cells')
        axis square
        figlib.pretty('PlotBuffer', 0.1);
    end
end

% save figures
for ii = 1:length(h)
    save_path = fullfile(pathlib.strip(mfilename('fullpath'), 2), ...
        'data', 'figures', ...
        ['figure-parameters-satexp-' num2str(ii) '.fig']);
    saveas(h(ii), save_path)
end
