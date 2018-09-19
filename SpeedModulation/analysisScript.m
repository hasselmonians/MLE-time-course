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
  transfer2     = cell(height(dataTable), 1); % time series of the transfer function between speed and spike train
  transfreq2    = cell(height(dataTable), 1); % frequencies corresponding to the transfer function
  for ii = 1:height(dataTable)
    textbar(ii, height(dataTable))

    % load the data
    [best, root]  = RatCatcher.extract(dataTable, ii, 'BandwidthEstimator', false);
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

    % compute the estimated transfer function between speed and frequency
    % use Srinivas' function
    options.filter_length         = dataTable.kmax(ii);
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

  % package the computed data in a tabl and add to the extant dataTable
  data2           = table(meanFiringRate, delay, linexpfit');
  data2.Properties.VariableNames{end} = 'stats';
  dataTable       = [dataTable data2];

  % save the data
  filename        = '/home/ahoyland/code/MLE-time-course/BandwidthEstimator-Caitlin-2.mat';
  save(filename, 'dataTable', 'speed', 'frequency', 'transfer', 'transfreq', 'transfer2', 'transfreq2');
  disp(['[INFO] bandwidth data saved in ''' filename ''''])
end % try/catch

%% Distribution of Bandwidth Parameters
% The best-estimate bandwidth parameters were computed using the Prerau & Eden algorithm for maximum-likelihood estimate with leave-one-out cross-validation. These values contrast with the standard in the literature of $k = 0.125$ s.

% generate a BandwidthEstimator object
load(dataTable.filenames{1});
root.cel = dataTable.cellnums(1, :);
best = BandwidthEstimator(root);

% compute metrics
passing = dataTable.kmax / best.Fs < 10;
disp(['The mean bandwidth parameter < 10 s: ' num2str(mean(dataTable.kmax(passing)) / best.Fs) ' s'])
disp(['The standard deviation: ' num2str(oval(std(dataTable.kmax(passing) / best.Fs), 2)) ' s'])
disp(['The percent of ''passing'' models: ' num2str(oval(100*sum(passing)/length(dataTable.kmax) ,2)) '%'])

% distribution of mean firing rates based on best-estimate bandwidths
figure('OuterPosition',[0 0 1200 800],'PaperUnits','points','PaperSize',[1200 800]);
plot(dataTable.kmax/best.Fs, dataTable.meanFiringRate, 'o')
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
figure('OuterPosition',[0 0 1200 800],'PaperUnits','points','PaperSize',[1200 800]);
data2plot = [mean(dataTable.meanFiringRate(passing)) mean(dataTable.meanFiringRate(~passing))];
err2plot  = [std(dataTable.meanFiringRate(passing)) std(dataTable.meanFiringRate(~passing))];
barwitherr(err2plot, data2plot);
set(gca, 'XTickLabel', {'k \leq 10 s', 'k > 10 s'})
ylabel('mean firing rate (Hz)')
title('mean firing rate by bandwidth category')

prettyFig()
box(gca, 'off')

if being_published
  snapnow
  delete(gcf)
end

% distribution of MLE/CV bandwidth parameters
figure('OuterPosition',[0 0 1200 800],'PaperUnits','points','PaperSize',[1200 800]);
histogram(dataTable.kmax/best.Fs, 'BinMethod', 'fd', 'Normalization', 'probability')
xlabel('bandwidth (s)')
title('distribution of MLE/CV bandwidth parameters')

prettyFig()
box(gca, 'off')

if being_published
	snapnow
	delete(gcf)
end

%% Why is Preprocessing the Firing Rate Estimate for Phase Delay Important?
% Preprocessing the firing rate phase delay is necessary to confirm the phase relationship between the animal speed and the firing rate. Asymmetric kernels (such as the alpha function) introduce phase delays proportional to the bandwidth parameter. While the Prerau & Eden method of maximum-likelihood estimate with cross-validation is invariant to phase delay introduced by the kernel, delay must be eliminated before comparison to the animal speed (to avoid introduction spurious delays).

figure('OuterPosition',[0 0 1200 1500],'PaperUnits','points','PaperSize',[1200 1500]);
clear ax
for ii = 1:3
  ax(ii) = subplot(3, 1, ii); hold on
end
% phase delay vs. bandwidth parameter
band = 3:10:(30*best.Fs);
best.kernel = 'alpha';
for ii = 1:length(band)
  D(ii) = finddelay(best.spikeTrain, best.kconv(band(ii)));
end
plot(ax(1), band / best.Fs, D / best.Fs, 'ko');
xlabel(ax(1), 'bandwidth parameter (s)')
ylabel(ax(1), 'lag time (s)')
% spike train and firing rate (with delay)
yyaxis(ax(2), 'left')
h = stem(ax(2), best.timestamps, best.spikeTrain);
set(h, 'Marker', 'none');
xlabel(ax(2), 'time (s)')
xlim(ax(2), [300 303])
ylabel(ax(2), 'spike count')
yyaxis(ax(2), 'right')
plot(ax(2), best.timestamps, best.kconv(dataTable.kmax(1))/best.Fs)
ylabel(ax(2), 'firing rate (spikes/dt)')
% spike train and firing rate (without delay)
[S1, S2] = alignsignals(best.spikeTrain, best.kconv(dataTable.kmax(1)), [], 'truncate');
time = (1:length(S1)) / best.Fs;
h = stem(ax(3), time, S1);
set(h, 'Marker', 'none')
xlabel(ax(3), 'time (s)')
xlim(ax(3), [0 3])
ylabel(ax(3), 'spike count')
yyaxis(ax(3), 'right')
plot(ax(3), time, S2/best.Fs)
ylabel(ax(3), 'firing rate (spikes/dt)')

prettyFig()
if being_published
  snapnow
  delete(gcf)
end

%% Distribution of Delays Between Animal Speed and Firing Rate
% Phase delays were computed by aligning the animal speed and firing rate signals using the peak cross-correlation and reported in seconds. A positive phase delay means that the firing rate lags behind the animal speed. Inversely, a negative phase delay means that the firing rate anticipates the animal speed.

figure('OuterPosition',[0 0 1200 800],'PaperUnits','points','PaperSize',[1200 800]);
histogram(dataTable.delay(passing), 'BinMethod', 'fd', 'Normalization', 'probability')
xlabel('phase delay (s)')
ylabel('count')
xlim(mean(dataTable.delay(passing)) + 2 * [-std(dataTable.delay(passing)), std(dataTable.delay(passing))])
title('distribution of phase delays from firing rate to animal speed')

prettyFig()
box(gca, 'off')

if being_published
	snapnow
	delete(gcf)
end

%% The Transfer Function
% The transfer function $H(t)$ is defined as the impulse function, which when convolved with the speed signal $s(t)$ produces the firing rate $r(t)$. In the frequency domain $f$, this relationship is expressed as $H(f) = r(f)/s(f)$. The estimate is recovered with Welch's averaged periodogram.

figure('OuterPosition',[0 0 1200 800],'PaperUnits','points','PaperSize',[1200 800]); hold on
transfer_passing = transfer(passing);
transfreq_passing = transfreq(passing);
for ii = 1:length(transfer_passing)
  plot(best.Fs ./ transfreq_passing{ii}, mag2db(abs(fft(transfer_passing{ii}))), 'LineWidth', 1)
end
ylabel('amplitude (dB)')
xlabel('frequency (Hz)')
title('transfer functions between speed and firing rate')

prettyFig()
box(gca, 'off')

if being_published
  snapnow
  delete(gcf)
end

figure('OuterPosition',[0 0 1200 800],'PaperUnits','points','PaperSize',[1200 800]); hold on
transfer_passing = transfer2(passing);
transfreq_passing = transfreq2(passing);
for ii = 1:length(transfer_passing)
  plot(best.Fs ./ transfreq_passing{ii}, mag2db(abs(fft(transfer_passing{ii}))), 'LineWidth', 1)
end
ylabel('amplitude (dB)')
xlabel('frequency (Hz)')
title('transfer functions between speed and the spike train')

prettyFig()
box(gca, 'off')

if being_published
  snapnow
  delete(gcf)
end

figure('OuterPosition',[0 0 1200 800],'PaperUnits','points','PaperSize',[1200 800]); hold on
clear ax

ax(1) = subplot(2, 2, 1); hold on;
plot(ax(1), best.Fs ./ transfreq{1}, mag2db(abs(fft(transfer{1}))), 'k')
xlabel(ax(1), 'frequency (Hz)')
ylabel(ax(1), 'amplitude (dB)')
title(ax(1), 'transfer function (firing rate)')

ax(2) = subplot(2, 2, 3); hold on;
plot(ax(2), best.Fs ./ transfreq2{1}, mag2db(abs(fft(transfer2{1}))), 'k')
xlabel(ax(2), 'frequency (Hz)')
ylabel(ax(2), 'amplitude (dB)')
title(ax(2), 'transfer function (spike train)')

ax(3) = subplot(1, 2, 2); hold on;
alpha = best.alpha(dataTable.kmax(1)) / sum(best.alpha(dataTable.kmax(1)));
fill(ax(3), [[1/best.Fs 0.4] fliplr([1/best.Fs 0.4])], [max(alpha) max(alpha) 0 0], 'g', 'EdgeColor', 'none');
plot(ax(3), (1:dataTable.kmax(1))/best.Fs, alpha, 'k');
xlabel(ax(3), 'bandwidth (s)')
ylabel(ax(3), 'kernel density')
title(ax(3), 'alpha function kernel')

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
