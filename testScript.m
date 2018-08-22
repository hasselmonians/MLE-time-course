% this script was written by Alec Hoyland at 11:55, 22 August 2018
% using awesome-matlab-notebook by Srinivas Gorur-Shandilya (http://srinivas.gs/contact/)
% this work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License
% to view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/4.0/.ts

pHeader;
tic

%% Introduction
% Acquiring a good firing rate estimate from experimental data requires binning or convolving the binned spike train. In these analyses, it is common to use a kernel smoother, such as the Gaussian or Hanning filter. In these filters, the bandwidth is a free parameter, determining how wide each convolution is in the time-domain. This document describes using a maximum likelihood estimate method with cross-validation to determine the best estimate for the bandwidth parameter that permits an accurate firing rate estimate. This analysis is based on Prerau & Eden 2011.

%% Analysis
% A sample cell is loaded, using |CMBHOME| and the binned spike train with a time step of 0.02 s is acquired. A leave-one-out cross-validation strategy is performed on the likelihood analysis, yielding an estimate for the bandwidth parameter.


% load the example data
load('example_cell.mat')

% the recording/cell indices
root.cel = [2 1];

% make a binned spike train
spikeTrain = BandwidthEstimator.getSpikeTrain(root);

% analyze the first two minutes of data
nEpochSteps = 2*60*root.fs_video;
% hash the full spike train
h = GetMD5([GetMD5(nEpochSteps) GetMD5(spikeTrain)]);

if isempty(cache(h))
  [estimate, kmax, loglikelihoods, bandwidths, CI] = BandwidthEstimator.cvKernel(root, spikeTrain(1:nEpochSteps));
  cache(h, estimate, kmax, loglikelihoods, bandwidths, CI);
else
  [CI, bandwidths, estimate, kmax, loglikelihoods] = cache(h);
end

%% Cross-Validated Maximum Likelihood Bandwidth Estimate
% (Top) The cross-validated kernel smoother estimate represents the firing rate given smoothing by the Hanning kernel with the bandwidth parameter at the cross-validated maximum likelihood estimate. (Bottom) Distribution of bandwidth likelihood. Green rectangle demarcates the confidence interval, as computed by the Fisher information.


% plot the likelihood distribution
figure;
%Exponentiate the likelihood for easy viewing
likelihood = exp(loglikelihoods - max(loglikelihoods));
lmax = max(likelihood);
t = (1/root.fs_video):(1/root.fs_video):(length(spikeTrain(1:nEpochSteps))*(1/root.fs_video));

%Plot the data and the estimate of the true value
ax(1) = subplot(211);
hold on
plot(ax(1), t, estimate*root.fs_video, 'r')

xlabel(ax(1), 'Time (s)');
ylabel(ax(1), 'Rate (Hz)');
title(ax(1), 'Cross-Validated Kernel Smoother Estimate');
ylim(ax(1), [0 1.2*max(estimate*root.fs_video)]);

ax(2)=axes('position', get(ax(1), 'position'));
stem(ax(2), t, spikeTrain(1:nEpochSteps), 'marker', 'none', 'Color', [0 0 0]);
set(ax(2), 'color', 'none', 'yaxislocation', 'right', 'xticklabel', '', 'ylim', [0 2*max(spikeTrain)]);
ylabel(ax(2), 'Spike Count');

% Plot the likelihood and confidence bounds for the bandwidth estimate
ax(3) = subplot(212);
hold on
plot(ax(3), bandwidths*(1/root.fs_video), likelihood, 'k');
plot(ax(3), kmax*(1/root.fs_video), lmax, 'r.', 'markersize', 20);
axis(ax(3), [0 kmax*(1/root.fs_video)*2,  0,  lmax]);
fill(ax(3), (1/root.fs_video)*[CI fliplr(CI)], [lmax lmax 0 0], [0 1 0], 'FaceColor', [0 1 0], 'FaceAlpha', 0.2, 'edgecolor', 'none');
set(ax(3), 'yticklabel', '');
xlabel(ax(3), 'Hanning Bandwidth Size (s)');
ylabel(ax(3), 'Likelihood');
title(ax(3), 'Bandwidth Likelihood');

prettyFig()

for ii = 1:length(ax)
  box(ax(ii), 'off');
end

if being_published
	snapnow
	delete(gcf)
end


%% Assessment of Kernel Smoothing with Various Bandwidth Parameters
% Several bandwidth parameters were tested to demonstrate the effectiveness of the CV/MLE method.

fig = figure;
c = linspecer(4);

ax(4) = gca;
hold on
estimax = 0;
for ii = 1:4
  bandwidth = [191 253 381 571];
  estimate = BandwidthEstimator.getFiringRate(root, spikeTrain(1:nEpochSteps), bandwidth(ii));
  if estimax < max(estimate)
    estimax = max(estimate);
  end
  plot(ax(4), t, estimate, '-', 'LineWidth', 1, 'Color', c(ii, :));
  paramID{ii} = ['k = ' num2str(bandwidth(ii))];
end

xlabel(ax(4), 'Time (s)');
ylabel(ax(4), 'Rate (Hz)');
title(ax(4), 'Cross-Validated Kernel Smoother Estimate');
leg = legend(ax(4), paramID, 'Location', 'best');
ylim(ax(4), [0 1.2*estimax]);


ax(5)=axes('position', get(ax(4), 'position'));
stem(ax(5), t, spikeTrain(1:nEpochSteps), 'Color', [0 0 0], 'marker', 'none', 'LineWidth', 1);
set(ax(5), 'color', 'none', 'yaxislocation', 'right', 'xticklabel', '', 'ylim', [0 2*max(spikeTrain)])
ylabel(ax(5), 'Spike Count');

prettyFig()

for ii = 4:5
  box(ax(ii), 'off');
end

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
