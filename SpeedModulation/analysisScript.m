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
try
  load('/home/ahoyland/code/MLE-time-course/BandwidthEstimator-Caitlin-2.mat')
  disp('[INFO] load the bandwidth data')
catch
  % if the bandwidth data can't be loaded, it will be computed instead
  disp('[INFO] bandwidth data couldn''t be loaded, computing instead')
  load('/home/ahoyland/code/MLE-time-course/BandwidthEstimator-Caitlin.mat')
  Pearson       = zeros(height(dataTable), 1);
  pValue        = zeros(height(dataTable), 1);
  delay         = zeros(height(dataTable), 1);
  meanFiringRate= zeros(height(dataTable), 1);
  speed         = cell(height(dataTable), 1); % time series of animal speed
  frequency     = cell(height(dataTable), 1); % time series of firing rate
  transfer      = cell(height(dataTable), 1); % time series of the transfer function between speed and frequency
  transfreq     = cell(height(dataTable), 1); % frequencies corresponding to the transfer function
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
    % force bandwidth to be odd
    if mod(bandwidth, 2) == 0
      bandwidth = bandwidth + 1;
    end
    % compute the firing rate estimate using the best bandwidth parameter
    frequency{ii} = best.getFiringRate(bandwidth);

    % compute the mean firing rate
    meanFiringRate(ii) = length(best.spikeTimes)/length(best.timestamps);

    % find the Pearson correlation and time delay between the signals in seconds
    % this method uses the cross-correlation
    [S1, S2, D]   = alignsignals(speed{ii}, frequency{ii}, [], 'truncate');
    [R, P]        = corrcoef(S1, S2, 'alpha', 0.05);

    % compute the estimated transfer function between speed and frequency
    % use Srinivas' function
    options.filter_length         = dataTable.kmax(ii);
    options.reg                   = 1;
    options.normalise             = true;
    options.offset                = 0;
    options.debug_mode            = true;
    options.method                = 'least-squares';
    [transfer{ii}, transfreq{ii}] = fitFilter2Data(speed{ii}, frequency{ii}, options);
    % update the output vectors
    Pearson(ii)   = R(2);
    pValue(ii)    = P(1);
    % if delay is positive, frequency lags behind speed
    delay(ii)     = D / best.Fs; % seconds
  end % for
  data2           = table(meanFiringRate, Pearson, pValue, delay);
  dataTable       = [dataTable data2];

  % save the data
  filename        = '/home/ahoyland/code/MLE-time-course/BandwidthEstimator-2.mat';
  save(filename, 'dataTable', 'speed', 'frequency', 'transfer', 'transfreq');
  disp(['[INFO] bandwidth data saved in ''' filename ''''])
end % try/catch

%% Distribution of Bandwidth Parameters
% The best-estimate bandwidth parameters were computed using the Prerau & Eden algorithm for maximum-likelihood estimate with leave-one-out cross-validation. These values contrast with the standard in the literature of $k = 0.125$ s.

upperBound = mean(dataTable.kmax) + 2 * std(dataTable.kmax);
passing = dataTable.kmax < upperBound;
mean(dataTable.kmax(passing));
std(dataTable.kmax(passing));
100*sum(~passing)/length(dataTable.kmax);

% 3.46 percent of recordings have MLE/CV bandwidth estimates above 40 s. These analyses have been discarded as outliers. Of the cells with best-estimate bandwidth parameters < 40 s, the mean bandwidth is 6.53 +/- 5.56 s. The smallest best-estimate bandwidth parameter is 0.63 s.

% generate a BandwidthEstimator object
load(dataTable.filenames{1});
root.cel = dataTable.cellnums(1, :);
best = BandwidthEstimator(root);

% distribution of mean firing rates based on best-estimate bandwidths
figure('outerposition',[0 0 1200 800],'PaperUnits','points','PaperSize',[1200 800]);
plot(dataTable.kmax, best.Fs * dataTable.meanFiringRate, 'o')
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
figure('outerposition',[0 0 1200 800],'PaperUnits','points','PaperSize',[1200 800]);
data2plot = 29.7*[mean(dataTable.meanFiringRate(passing)) mean(dataTable.meanFiringRate(~passing))];
err2plot  = 29.7*[std(dataTable.meanFiringRate(passing)) std(dataTable.meanFiringRate(~passing))];
barwitherr(err2plot, data2plot);
set(gca, 'XTickLabel', {'k \leq ' num2str(upperBound / best.Fs) ' s', 'k > ' num2str(upperBound / best.Fs) ' s'})
ylabel('mean firing rate (Hz)')
title('mean firing rate by bandwidth category')

prettyFig()
box(gca, 'off')

if being_published
  snapnow
  delete(gcf)
end

% distribution of MLE/CV bandwidth parameters
figure('outerposition',[0 0 1200 800],'PaperUnits','points','PaperSize',[1200 800]);
histogram(dataTable.kmax, 'BinMethod', 'fd', 'Normalization', 'probability')
xlabel('bandwidth (s)')
ylabel('count')
xlim([0, upperBound / best.Fs])
title('distribution of MLE/CV bandwidth parameters')

prettyFig()
box(gca, 'off')

if being_published
	snapnow
	delete(gcf)
end


%% Distribution of Delays Between Animal Speed and Firing Rate
% Phase delays were computed by aligning the animal speed and firing rate signals using the peak cross-correlation and reported in seconds. A positive phase delay means that the firing rate lags behind the animal speed. Inversely, a negative phase delay means that the firing rate anticipates the animal speed.


figure('outerposition',[0 0 1200 800],'PaperUnits','points','PaperSize',[1200 800]);
histogram(dataTable.delay, 'BinMethod', 'fd', 'Normalization', 'probability')
xlabel('phase delay (s)')
ylabel('count')
xlim(mean(dataTable.delay) + 2 * [-std(dataTable.delay), std(dataTable.delay)])
title('distribution of phase delays from firing rate to animal speed')

prettyFig()
box(gca, 'off')

if being_published
	snapnow
	delete(gcf)
end

%% The Transfer Function
% The transfer function $H(t)$ is defined as the impulse function, which when convolved with the speed signal $s(t)$ produces the firing rate $r(t)$. In the frequency domain $f$, this relationship is expressed as $H(f) = r(f)/s(f)$. The estimate is recovered with Welch's averaged periodogram.

disp('ping!')
return

figure('outerposition',[0 0 1200 800],'PaperUnits','points','PaperSize',[1200 800]);
clear ax
for ii = 1:2
  ax(ii) = subplot(2, 1, ii); hold on;
end
for ii = 1:length(bandex)
  plot(ax(1), transfreq{bandex(ii)}, mag2db(abs(transfer{bandex(ii)})));
end
ylabel(ax(1), 'amplitude (dB)')
title(ax(1), 'transfer functions')

% filter the transfer functions
figure; hold on;
for ii = 1:length(bandex)
  plot(ax(2), transfreq{bandex(ii)}, mag2db(abs(conv(transfer{bandex(ii)}, hanning(1001), 'same'))));
end
xlabel(ax(2), 'frequency (Hz)')
ylabel(ax(2), 'amplitude (dB)')
title(ax(2), 'hanning-filtered transfer function')

prettyFig()

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
% showDependencyHash(mfilename);


%%
% This document was built in:
disp(strcat(oval(t,3),' seconds.'))
