% process the data and save it in data-Caitlin-BandwidthEstimator-2

% This scripts requires the following packages:
%   * srinivas.gs_mtools
%   * CMBHOME
%   * RatCatcher
%   * BandwidthEstimator

% This script assumes that you have the cluster mounted to your drive at /mnt/hasselmogrp.

data_filepath               = fullfile(pathlib.strip(2), 'data', 'data-Caitlin-BandwidthEstimator.mat');
processed_data_filepath     = fullfile(pathlib.strip(2), 'data', 'data-Caitlin-BandwidthEstimator-processed.mat');

% load the bandwidth data
try
  load(processed_data_filepath);
  disp('[INFO] loaded the bandwidth data')
catch
  % if the bandwidth data can't be loaded, it will be computed instead
  load(data_filepath);
  disp('[INFO] bandwidth data couldn''t be loaded, computing instead')

  % containers
  Pearson       = zeros(height(dataTable), 1);
  delay         = zeros(height(dataTable), 1);
  delay_uncorrected = zeros(height(dataTable), 1);
  meanFiringRate= zeros(height(dataTable), 1);
  speed         = cell(height(dataTable), 1); % time series of animal speed
  frequency     = cell(height(dataTable), 1); % time series of firing rate

  % loop over all filename/filecode pairs
  for ii = 1:height(dataTable)
    corelib.textbar(ii, height(dataTable))

    % load the data
    [best, root] = RatCatcher.extract(dataTable, ii, 'BandwidthEstimator', @(x) preprocess_fcn(x), true)
    speed{ii}     = root.svel; % spatially-scaled speed in cm/s
    best.kernel   = 'alpha';

    % force bandwidth to be odd (it should already be, but to be sure...)
    if mod(dataTable.kmax(ii), 2) == 0
      bandwidth   = dataTable.kmax(ii) + 1;
    else
      bandwidth   = dataTable.kmax(ii);
    end

    % compute the mean firing rate
    meanFiringRate(ii) = length(best.spikeTimes)/length(best.timestamps)*best.Fs; % Hz

    % find the Pearson correlation and time delay between the signals in seconds
    % this method uses the cross-correlation

    % (1) compute the firing rate estimate using the best bandwidth parameter
    signal        = best.kconv(bandwidth);

    % (2) compute the delay between the spike train (real data) and the firing rate estimate
    D             = finddelay(best.spikeTrain, signal, 30);
    delay_uncorrected(ii) = D;

    % (3) pre-process the firing rate estimate to align with the spike train
    % this cannot be done with alignsignals because the function can shift the spike train
    if D > 0
      % prepend the firing rate estimate with zeros
      signal2     = [signal(D:end)'; zeros(D-1, 1)];
    elseif D < 0
      % append the firing rate estimate with zeros
      signal2     = [zeros(abs(D), 1); signal(1:end-abs(D))'];
    else
      signal2     = signal;
    end

    % define the frequency (firing rate estimate)
    % as the filtered spike train with delay correction
    frequency{ii} = signal2;

    % (4) compute the delay between the animal speed and the firing rate
    D             = finddelay(speed{ii}, frequency{ii}, 30);
    % if delay is positive, frequency lags behind speed
    delay(ii)     = D / best.Fs; % seconds

    % (5) compute Pearson's R
    Pearson(ii)   = corr(corelib.vectorise(speed{ii}), corelib.vectorise(frequency{ii}));

    % (6) compute the linear and saturating exponential fits for speed vs. spike train
    linexpfit(ii) = best.fit(root);
  end % for

  % package the computed data in a table and add to the extant dataTable
  data2           = table(meanFiringRate, delay, delay_uncorrected, Pearson, linexpfit');
  data2.Properties.VariableNames{end} = 'stats';
  dataTable       = [dataTable data2];

  % save the data
  save([processed_data_filepath], 'dataTable', 'speed', 'frequency');
  disp(['[INFO] bandwidth data saved in ''' processed_data_filepath ''''])
end % try/catch

try
  load('~/code/MLE-time-course/data-Caitlin-BandwidthEstimator-2-hanning.mat')
  disp('[INFO] load the bandwidth data')
catch
  % if the bandwidth data can't be loaded, it will be computed instead
  disp('[INFO] bandwidth data couldn''t be loaded, computing instead')
  load('~/code/MLE-time-course/data-Caitlin-BandwidthEstimator-hanning.mat')
  Pearson       = zeros(height(dataTable), 1);
  delay         = zeros(height(dataTable), 1);
  delay_uncorrected = zeros(height(dataTable), 1);
  meanFiringRate= zeros(height(dataTable), 1);
  speed         = cell(height(dataTable), 1); % time series of animal speed
  frequency     = cell(height(dataTable), 1); % time series of firing rate

  for ii = 1:height(dataTable)
    corelib.textbar(ii, height(dataTable))

    % load the data
    [best, root] = RatCatcher.extract(dataTable, ii, 'BandwidthEstimator', @(x) preprocess_fcn(x), true)
    speed{ii}     = root.svel; % spatially-scaled speed in cm/s
    best.kernel   = 'hanning';

    % force bandwidth to be odd (it should already be, but to be sure...)
    if mod(dataTable.kmax(ii), 2) == 0
      bandwidth   = dataTable.kmax(ii) + 1;
    else
      bandwidth   = dataTable.kmax(ii);
    end

    % compute the mean firing rate
    meanFiringRate(ii) = length(best.spikeTimes)/length(best.timestamps)*best.Fs; % Hz

    % find the Pearson correlation and time delay between the signals in seconds
    % this method uses the cross-correlation

    % (1) compute the firing rate estimate using the best bandwidth parameter
    signal        = best.kconv(bandwidth);
    % (2) compute the delay between the spike train (real data) and the firing rate estimate
    D             = finddelay(best.spikeTrain, signal, 30);
    delay_uncorrected(ii) = D;
    % (3) pre-process the firing rate estimate to align with the spike train
    % this cannot be done with alignsignals because the function can shift the spike train
    if D > 0
      % prepend the firing rate estimate with zeros
      signal2     = [signal(D:end)'; zeros(D-1, 1)];
    elseif D < 0
      % append the firing rate estimate with zeros
      signal2     = [zeros(abs(D), 1); signal(1:end-abs(D))'];
    else
      signal2     = signal;
    end
    % define the frequency (firing rate estimate)
    % as the filtered spike train with delay correction
    frequency{ii} = signal2;
    % (4) compute the delay between the animal speed and the firing rate
    D             = finddelay(speed{ii}, frequency{ii}, 30);
    % if delay is positive, frequency lags behind speed
    delay(ii)     = D / best.Fs; % seconds
    % compute Pearson's R
    Pearson(ii)   = corr(corelib.vectorise(speed{ii}), corelib.vectorise(frequency{ii}));

    % compute the estimated transfer function between speed and frequency
    % use Srinivas' function
    options.filter_length         = 1000;
    options.reg                   = 1;
    options.normalise             = true;
    options.offset                = 0;
    options.debug_mode            = true;
    options.method                = 'least-squares';
    [transfer{ii}, transfreq{ii}] = fitFilter2Data(speed{ii}, frequency{ii}, options);
    [transfer2{ii}, transfreq2{ii}] = fitFilter2Data(speed{ii}, best.spikeTrain, options);

    % compute the linear and saturating exponential fits for speed vs. spike train
    linexpfit(ii) = best.fit(root);
  end % for

  % package the computed data in a table and add to the extant dataTable
  data2           = table(meanFiringRate, delay, delay_uncorrected, Pearson, linexpfit');
  data2.Properties.VariableNames{end} = 'stats';
  dataTable       = [dataTable data2];

  % save the data
  filename        = '~/code/MLE-time-course/data-Caitlin-BandwidthEstimator-2-hanning.mat';
  save(filename, 'dataTable', 'speed', 'frequency');
  disp(['[INFO] bandwidth data saved in ''' filename ''''])
end % try/catch

function x = preprocess_fcn(x)
  x = strrep(x, 'projectnb', 'mnt');
  x = strrep(x, 'hoyland', 'ahoyland');
end % function
