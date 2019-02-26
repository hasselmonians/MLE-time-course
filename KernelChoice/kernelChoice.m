% this script was written by Alec Hoyland at 11:32 2018 September 4
% using awesome-matlab-notebook by Srinivas Gorur-Shandilya (http://srinivas.gs/contact/)
% this work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License
% to view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/4.0/.ts

pHeader;
tic

%% Introduction
% Kernel-smoothing of a signal can remove erroneous or unimportant details in order to garner a better understanding of the general trend. In this way, the kernel acts as a low-pass filter, removing high-frequency noise (or other confounding signals). The choice of kernel can make a signficant difference in the degree and type of smoothing performed. In Prerau & Eden 2011, where the maximum-likelihood estimate with cross-validation (MLE/CV) algorithm was introduced, the authors opted for a hanning filter, which has a well-defined bandwidth parameter, though is generally less successful than the Blackman or Hamming kernels (Podder et al. 2014). All three of this filters also suffer from the additional drawback that filtering necessarily includes future information. These filters are symmetric and weight past and future information equally when filtering the data. In contrast, asymmetric filters, such as the alpha kernel, do not require future information.
% This property makes the alpha function ideal for convolution when each data point in the output signal should not rely on any future information. Here we demonstrate the hanning kernel and the alpha kernel, using the MLE/CV algorithm to determine bandwidth parameters.

%% Data
% The data sample comes from Holger Dannenberg's |example_cell.mat|.

load('example_cell.mat');
root.cel      = cel;
best          = BandwidthEstimator(root);
best.range    = 20;

%% The Hanning Kernel
% The hanning kernel is described by $\frac{1}{2} \big( 1 - \cos(\frac{2 \pi n}{k - 1}) \big)$ where $k$ is the bandwidth parameter (in seconds).

best.kernel   = 'hanning';
[estimate, kmax, loglikelihoods] = best.cvKernel;
w1            = best.kernel(kmax);

%% The Alpha Kernel
% The alpha kernel is described by $k \exp (- k / \tau)$. Here, $\tau$ is set to $1 + \ln(n)$ time steps, where $n$ is the length of the filter in time steps.

best.kernel   = 'alpha';
[estimate2, kmax2, loglikelihoods2] = best.cvKernel;
w2            = best.kernel(kmax2);
w3            = best.kernel(kmax);

%% Non-Causal Events are Caused by Two-Tailed Kernels
% Filtering with non-causal kernels determines the value of a firing rate estimate at time $t$ by relying on information from time $\tau > t$. This occurs when the kernel is two-tailed. In this situation, the value of the firing rate estimate is composed of a weighted sum of values before and after that point in time.
% In the following plot, the hanning filter estimates the firing rate as positive before a single spike is shown.

figure('outerposition',[0 0 1200 800],'PaperUnits','points','PaperSize',[1200 800]); hold on;
x             = zeros(100,1);
x([40 50 70]) = 1;
rate1         = conv(x, BandwidthEstimator.hanning(30), 'same');
rate2         = conv(x, BandwidthEstimator.alpha(30), 'same');
for ii = 1:length(x)
  if x(ii) == 1
    plot([ii ii], [0 1], 'k');
  end
end
plot(rate1);
plot(16:115, rate2);
xlabel('time steps')
ylabel('firing rate (Hz)')
legend({'data', 'hanning', 'alpha'})

figlib.pretty()
box off

if being_published
  snapnow
  delete(gcf)
end

%% Comparison
% The |kconv| algorithm accounts for edge and shifting effects. The lag is zero. For the following plots, the bandwidth parameter was determined by the MLE/CV method. The alpha kernel and smoothed firing rate is plotted twice: (1) using the alpha kernel MLE/CV bandwidth parameter estimate, and (2) using the hanning kernel MLE/CV bandwidth parameter estimate.

% superimposed kernels in the time domain
figure('outerposition',[0 0 1200 800],'PaperUnits','points','PaperSize',[1200 800]); hold on;
plot((1:length(w1)) - median(1:length(w1)), w1 / sum(w1));
plot(w2 / sum(w2));
plot(w3 / sum(w3));
xlabel('time steps')
ylabel('kernel density (a.u.)')
xlim([-50 50])
legend({'hanning', 'alpha', 'alpha2'})

figlib.pretty()
box off

if being_published
  snapnow
  delete(gcf)
end

% snippet of the firing rate signals
figure('outerposition',[0 0 1200 800],'PaperUnits','points','PaperSize',[1200 800]); hold on;
time          = (1 / best.Fs) * (1:length(estimate));
time2         = (1 / best.Fs) * (1:length(estimate2));
estimate3     = best.kconv(best.alpha(kmax));
time3         = (1 / best.Fs) * (1:length(estimate3));
plot(time, estimate, 'LineWidth', 1);
plot(time2, estimate2, 'LineWidth', 1);
plot(time3, estimate3, 'LineWidth', 1);
xlabel('time (s)')
ylabel('firing rate (Hz)')
xlim([0 10])
ylim([0 80])
legend({'hanning', 'alpha', 'alpha2'})

figlib.pretty()
box off

if being_published
  snapnow
  delete(gcf)
end

% align the signals to determine lag
[~, ~, D]   = alignsignals(best.spikeTrain, estimate, [], 'truncate');
[~, ~, D2]  = alignsignals(estimate, estimate2, [], 'truncate');

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
