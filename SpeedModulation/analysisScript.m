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
  for ii = 1:height(dataTable)
    textbar(ii, height(dataTable))

    % load the Session object associated with these data
    load(dataTable.filenames{ii})
    root.cel = dataTable.cellnums(ii, :);
    % set the start time to zero
    root        = root.FixTime;
    % clear the velocity
    root.b_vel  = [];
    % Kalman filter the animal velocity
    root        = root.AppendKalmanVel;
    % acquire the animal speed
    speed       = root.svel;

    % set up the bandwidth estimator object
    best        = BandwidthEstimator(root);
    % filter the data according to the optimal bandwidth parameter
    bandwidth   = round(best.Fs * dataTable.kmax(ii)); % in time-steps
    frequency   = best.getFiringRate(bandwidth);

    % compute the mean firing rate
    meanFiringRate(ii) = length(best.spikeTimes)/length(best.timestamps);

    % find the Pearson correlation and time delay between the signals in seconds
    % this method uses the cross-correlation
    [S1, S2, D] = alignsignals(speed, frequency, [], 'truncate');
    [R, P]      = corrcoef(S1, S2, 'alpha', 0.05);

    % update the output vectors
    Pearson(ii) = R(2);
    pValue(ii)  = P(1);
    % if delay is positive, frequency lags behind speed
    delay(ii)   = D / best.Fs; % seconds
  end
  data2         = table(meanFiringRate, Pearson, pValue, delay);
  dataTable     = [dataTable data2];

  % save the data
  filepath      = which('BandwidthEstimator-Caitlin.mat');
  save(filepath, 'dataTable');
end

return;
%% Distribution of Bandwidth Parameters
% The best-estimate bandwidth parameters were computed using the Prerau & Eden algorithm for maximum-likelihood estimate with leave-one-out cross-validation. These values contrast with the standard in the literature of $k = 0.125$ s.

passing = dataTable.kmax < 40;
mean(dataTable.kmax(passing))
std(dataTable.kmax(passing))
100*sum(~passing)/length(dataTable.kmax)

% 3.46 percent of recordings have MLE/CV bandwidth estimates above 40 s. These analyses have been discarded as outliers. Of the cells with best-estimate bandwidth parameters < 40 s, the mean bandwidth is 6.53 +/- 5.56 s. The smallest best-estimate bandwidth parameter is 0.63 s.


% distribution of mean firing rates based on best-estimate bandwidths
figure;
plot(dataTable.kmax, 50*dataTable.meanFiringRate, 'o')
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
data2plot = 50*[mean(dataTable.meanFiringRate(passing)) mean(dataTable.meanFiringRate(~passing))];
err2plot  = 50*[std(dataTable.meanFiringRate(passing)) std(dataTable.meanFiringRate(~passing))];
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
hist(dataTable.kmax, 30)
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
hist(dataTable.delay, 30)
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


% distribution of XC bandwidth parameters
figure;
hist(dataTable.kcorr, 30)
xlabel('bandwidth (s)')
ylabel('count')
title('distribution of XC bandwidth parameters')

if being_published
	snapnow
	delete(gcf)
end

% normalized difference between the two optimization methods
figure;
bandwidth_difference = abs( (dataTable.kmax - dataTable.kcorr) / (dataTable.kmax + dataTable.kcorr) );
hist(bandwidth_difference, 30);
xlabel('normalized bandwidth difference')
ylabel('count')
title('distribution of difference between MLE/CV and XC bandwidth parameters')

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
