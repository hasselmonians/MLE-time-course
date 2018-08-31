% this script was written by Alec Hoyland at 13:43 28 August 2018
% using awesome-matlab-notebook by Srinivas Gorur-Shandilya (http://srinivas.gs/contact/)
% this work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License
% to view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/4.0/.ts

pHeader;
tic

%% Introduction
% Acquiring a good firing rate estimate from experimental data requires binning or convolving the binned spike train. In these analyses, it is common to use a kernel smoother, such as the Gaussian or Hanning filter. In these filters, the bandwidth is a free parameter, determining how wide each convolution is in the time-domain. This document describes using a maximum likelihood estimate method with cross-validation to determine the best estimate for the bandwidth parameter that permits an accurate firing rate estimate. This analysis is based on Prerau & Eden 2011.

%% Analysis
% A sample cell is loaded, using |CMBHOME| and the binned spike train with a time step of 0.02 s is acquired. A leave-one-out cross-validation strategy is performed on the likelihood analysis, yielding an estimate for the bandwidth parameter. The speed of the animal is computed by tracking two LEDs and smoothing the resulting recording with a Kalman filter.


% load the bandwidth data
load('BandwidthEstimator-Caitlin.mat'); % dataTable
if ~any(strcmp('Pearson', dataTable.Properties.VariableNames))
  Pearson       = zeros(height(dataTable), 1);
  pValue        = zeros(height(dataTable), 1);
  delay         = zeros(height(dataTable), 1);
  meanFiringRate= zeros(height(dataTable), 1);
  speed         = cell(height(dataTable), 1); % time series of animal speed
  frequency     = cell(height(dataTable), 1); % time series of firing rate
  transfer      = cell(height(dataTable), 1); % time series of the transfer function between speed and frequency
  for ii = 1:height(dataTable)
    textbar(ii, height(dataTable))

    % load the Session object associated with these data
    load(dataTable.filenames{ii})
    root.cel = dataTable.cellnums(ii, :);
    % clear the velocity
    root.b_vel    = [];
    % Kalman filter the animal velocity
    root          = root.AppendKalmanVel;
    % set the start time to zero
    root          = root.FixTime;
    % acquire the animal speed
    speed{ii}     = root.svel;

    % set up the bandwidth estimator object
    best          = BandwidthEstimator(root);
    % filter the data according to the optimal bandwidth parameter
    bandwidth     = round(best.Fs * dataTable.kmax(ii)); % in time-steps
    frequency{ii} = best.getFiringRate(bandwidth);

    % compute the mean firing rate
    meanFiringRate(ii) = length(best.spikeTimes)/length(best.timestamps);

    % find the Pearson correlation and time delay between the signals in seconds
    % this method uses the cross-correlation
    [S1, S2, D]   = alignsignals(speed{ii}, frequency{ii}, [], 'truncate');
    [R, P]        = corrcoef(S1, S2, 'alpha', 0.05);

    % compute the estimated transfer function between speed and frequency
    % using Welch's method (power spectra)
    transfer{ii}  = tfestimate(speed{ii}, frequency{ii}, [], [], [], best.Fs);
    % update the output vectors
    Pearson(ii)   = R(2);
    pValue(ii)    = P(1);
    % if delay is positive, frequency lags behind speed
    delay(ii)     = D / best.Fs; % seconds
  end
  data2           = table(meanFiringRate, Pearson, pValue, delay);
  dataTable       = [dataTable data2];

  % save the data
  filepath        = which('BandwidthEstimator-Caitlin.mat');
  save(filepath, 'dataTable', 'speed', 'frequency', 'transfer');
end


%% Distribution of Bandwidth Parameters
% The best-estimate bandwidth parameters were computed using the Prerau & Eden algorithm for maximum-likelihood estimate with leave-one-out cross-validation. These values contrast with the standard in the literature of $k = 0.125$ s.

passing = dataTable.kmax < 40;
mean(dataTable.kmax(passing))
std(dataTable.kmax(passing))
100*sum(~passing)/length(dataTable.kmax)

% 3.46 percent of recordings have MLE/CV bandwidth estimates above 40 s. These analyses have been discarded as outliers. Of the cells with best-estimate bandwidth parameters < 40 s, the mean bandwidth is 6.53 +/- 5.56 s. The smallest best-estimate bandwidth parameter is 0.63 s.


% distribution of mean firing rates based on best-estimate bandwidths
figure;
plot(dataTable.kmax, 29.7*dataTable.meanFiringRate, 'o')
xlabel('MLE/CV bandwidth parameter (s)')
ylabel('mean firing rate (Hz)')
title('mean firing rate by best bandwidth parameter')

prettyFig()
box(gca, 'off')

if being_published
	snapnow
	delete(gcf)
end

% mean firing rate by bandwidth bin
figure;
data2plot = 29.7*[mean(dataTable.meanFiringRate(passing)) mean(dataTable.meanFiringRate(~passing))];
err2plot  = 29.7*[std(dataTable.meanFiringRate(passing)) std(dataTable.meanFiringRate(~passing))];
barwitherr(err2plot, data2plot);
set(gca, 'XTickLabel', {'k \leq 40 s', 'k > 40 s'})
ylabel('mean firing rate (Hz)')
title('mean firing rate by bandwidth category')

prettyFig()
box(gca, 'off')

if being_published
  snapnow
  delete(gcf)
end

% distribution of MLE/CV bandwidth parameters
figure;
histogram(dataTable.kmax, 'BinMethod', 'fd', 'Normalization', 'probability')
xlabel('bandwidth (s)')
ylabel('count')
title('distribution of MLE/CV bandwidth parameters')

prettyFig()
box(gca, 'off')

if being_published
	snapnow
	delete(gcf)
end


%% Distribution of Delays Between Animal Speed and Firing Rate
% Phase delays were computed by aligning the animal speed and firing rate signals using the peak cross-correlation and reported in seconds. A positive phase delay means that the firing rate lags behind the animal speed. Inversely, a negative phase delay means that the firing rate anticipates the animal speed.


figure;
histogram(dataTable.delay, 'BinMethod', 'fd', 'Normalization', 'probability')
xlabel('phase delay (s)')
ylabel('count')
title('distribution of phase delays from firing rate to animal speed')

prettyFig()
box(gca, 'off')

if being_published
	snapnow
	delete(gcf)
end

%% Bandwidth Parameters Optimizing Cross-Correlation
% The cross-correlation between the animal speed and and the kernel-smoothed firing rate was computed for a range of bandwidth parameters up to 60 seconds. If the firing rate directly corresponds to the animal's speed, then there should be strong correlation between the signals. Instead of smoothing the signal to reflect the likelihood, cross-validated for each spike, this analysis attempts to select a bandwidth parameter that maximizes the cross-correlation between the speed and firing rate signals.

% The normalized difference between the MLE/CV-optimized bandwidth parameter and the XC-optimized bandwidth parameter is defined as the absolute ratio of the difference and the sum of the parameters.

% The bandwidth parameters maximizing cross-correlation were found invariably to be with minimal filtering. This is similar to the maximum likelihood estimate without cross-validation bandwidth parameters, which converge towards zero. Note that when the algorithm detects that the best estimate bandwidth parameter is at the first index (i.e. $3/F_s$), it picks the maximal bandwidth instead.


% sample cross-correlations, log-max-cross-correlation, etc.
figure;
for ii = 1:4
  ax(ii) = subplot(2, 2, ii); hold on;
end
% aligned speed and (kmax-bandwidth filtered) firing rate
[S1, S2, D]   = alignsignals(speed{1}, frequency{1}, [], 'truncate');
time          = (1/29.7) * (1:length(S1));
yyaxis(ax(1), 'left')
plot(ax(1), time, S1);
xlabel(ax(1), 'time (s)');
ylabel(ax(1), 'animal speed (cm/s)')
yyaxis(ax(1), 'right')
plot(ax(1), time, S2);
ylabel(ax(1), 'firing rate (Hz)')
% log-max correlation over bandwidth parameter
load(dataTable.filenames{1});
root.cel = dataTable.cellnums(1, :);
best = BandwidthEstimator(root);
[~, ~, logmaxcorr] = best.corrKernel(speed{1});
plot(ax(2), best.range / best.Fs, logmaxcorr);
xlabel(ax(2), 'bandwidth (s)');
ylabel(ax(2), 'maximum log-cross-correlation')
% correlation plot at maximal bandwidth
k = round(best.Fs * dataTable.kmax(1) * [0.1 1.0 10]);
k(mod(k, 2) == 0) = k(mod(k, 2) == 0) + 1;
leg = cell(length(k), 1);
for ii = 1:length(k)
  [corr, lag] = xcorr(speed{1}, best.kconv(hanning(k(ii))));
  plot(ax(3), lag/best.Fs, corr);
  leg{ii} = ['k = ' num2str(oval(k(ii)/best.Fs, 2)) ' s'];
end
legend(ax(3), leg, 'Location', 'best');
xlabel(ax(3), 'lag (s)')
ylabel(ax(3), 'cross-correlation')
xlim(ax(3), [-5 5]);
% distribution of kcorr parameters
histogram(ax(4), dataTable.kcorr, 'Normalization', 'pdf', 'BinMethod', 'fd')
xlabel(ax(4), 'bandwidth (s)')
ylabel(ax(4), 'count')

prettyFig()
labelFigure()
box(gca, 'off')

if being_published
	snapnow
	delete(gcf)
end

% normalized difference between the two optimization methods
figure;
bandwidth_difference = abs( (dataTable.kmax - dataTable.kcorr) ./ (dataTable.kmax + dataTable.kcorr) );
histogram(bandwidth_difference, 'BinMethod', 'fd', 'Normalization', 'probability');
xlabel('normalized bandwidth difference')
ylabel('count')
title('distribution of difference between MLE/CV and XC bandwidth parameters')

prettyFig()
box(gca, 'off')

if being_published
  snapnow
  delete(gcf)
end


%% Version Info
% The file that generated this document is called:
disp(mfilename)


%%
% and its md5 hash is:
Opt.Input = 'file';
disp(dataHash(strcat(mfilename,'.m'),Opt))


%%
% This file should be in this commit:
[status,m]=unix('git rev-parse HEAD');
if ~status
	disp(m)
end

t = toc;


%%
% This file has the following external dependencies:
showDependencyHash(mfilename);


%%
% This document was built in:
disp(strcat(oval(t,3),' seconds.'))
