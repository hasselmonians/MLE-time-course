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

% compute kmax for the first 2 minutes
nEpochSteps = 2*60*root.fs_video;

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
t = (1/root.fs_video):(1/root.fs_video):(length(spikeTrain)*(1/root.fs_video));

%Plot the data and the estimate of the true value
ax = subplot(211);
hold on
plot(t, estimate, 'r')

axis tight
xlabel('Time (s)');
ylabel('Rate (Hz)');
title('Cross-Validated Kernel Smoother Estimate');

ax2=axes('position', get(ax, 'position'));
subplot(ax2);
stem(t, spikeTrain, 'marker', 'none');
set(gca,'color', 'none', 'yaxislocation', 'right', 'xticklabel', '')
ylabel('Spike Count');

% Plot the likelihood and confidence bounds for the bandwidth estimate
subplot(212)
hold on
fill([CI fliplr(CI)], [lmax lmax 0 0], 'g', 'edgecolor', 'none');
plot(bandwidths*(1/root.fs_video), likelihood, 'k');
plot(kmax*(1/root.fs_video), lmax, 'r.', 'markersize', 20);
axis([0 kmax*(1/root.fs_video)*2,  0,  lmax]);
set(gca, 'yticklabel', '');
xlabel('Hanning Bandwidth Size (s)');
ylabel('Likelihood');
title('Bandwidth Likelihood');

prettyFig()

if being_published
	snapnow
	delete(gcf)
end


%% Assessment of Kernel Smoothing with Various Bandwidth Parameters
% Several bandwidth parameters were tested to demonstrate the effectiveness of the CV/MLE method.

figure;
c = linspecer(4);

ax = gca;
hold on
for ii = 1:4
  bandwidth = [191 253 381 571];
  estimate = BandwidthEstimator.getFiringRate(root, SpikeTrain, bandwidth(ii));
  plot(t, estimate, '-', 'LineWidth', 1, 'Color', c(ii, :));
  paramID{ii} = ['k = ' num2str(bandwidth(ii))];
end

axis tight
xlabel('Time (s)');
ylabel('Rate (Hz)');
title('Cross-Validated Kernel Smoother Estimate');
leg = legend(ax, paramID, 'Location', 'eastoutside');

ax2=axes('position', get(ax, 'position'));
subplot(ax2);
stem(t, spikeTrain, 'marker', 'none');
set(gca,'color', 'none', 'yaxislocation', 'right', 'xticklabel', '')
ylabel('Spike Count');

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
showDependencyHash(mfilename);

%%
% This document was built in:
disp(strcat(oval(t,3),' seconds.'))
