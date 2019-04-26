% determine whether cells are speed modulated and visualize the data

pHeader;
tic;

% load the data (alpha kernel)
load('BandwidthEstimator-Caitlin-2.mat');

% generate dummy BandwidthEstimator
[best, root] = RatCatcher.extract(dataTable, 1);

%% Determining which Cells are Speed-Modulated
% A cell is defined as speed-modulating when the Pearson's R correlation between the
% animal speed and the firing rate estimate (smoothed at the MLE/CV bandwidth parameter)
% is above a threshold $R <= 0.5$. This threshold was determined by establishing a null
% distribution over R-values computed using bootstrapped data (Moser's method).
% Just kidding. This is arbitrary at the moment.

% distribution of speed-score
figure('OuterPosition',[0 0 1200 800],'PaperUnits','points','PaperSize',[1200 800]); hold on
histogram(dataTable.Pearson)
xlabel('Pearson''s R')
ylabel('count')
title('Distribution of Speed Score')

figlib.pretty()
box(gca, 'off')

if being_published
  snapnow
  delete(gcf)
end

modulated   = dataTable.Pearson >= 0.0795;

disp('Percent of speed-modulated cells')
disp([num2str(sum(modulated)/length(modulated)*100) '%'])

% acquire the model fits for the modulated cells
stats       = dataTable.stats;
for ii = 1:length(stats)
  p(ii) = stats(ii).p;
end

%% Determining which Cells are Linearly Speed-Modulated
% An F-test between the linear and saturating exponential models was performed.
% If $p <= 0.05$, then a saturating model could be appropriate. The Akaike and Bayesian
% information criteria were also computed.

linear      = corelib.vectorise(p >= 0.05);
passing     = corelib.vectorise(dataTable.kmax / best.Fs < 10);

% kmax between linear and saturating exponential models
figure('OuterPosition',[0 0 1200 800],'PaperUnits','points','PaperSize',[1200 800]);
data2plot = (1/best.Fs) * [mean(dataTable.kmax(modulated & linear & passing)) mean(dataTable.kmax(modulated & ~linear & passing))];
err2plot  = (1/best.Fs) * [std(dataTable.kmax(modulated & linear & passing)) std(dataTable.kmax(modulated & ~linear & passing))];
barwitherr(err2plot, data2plot);
set(gca, 'XTickLabel', {'linear', 'saturating exponential'})
ylabel('k_{max} (s)')
title('bandwidth parameter by model category')

figlib.pretty()
box(gca, 'off')

if being_published
  snapnow
  delete(gcf)
end

% mean firing rate between linear and saturating exponential models
figure('OuterPosition',[0 0 1200 800],'PaperUnits','points','PaperSize',[1200 800]);
data2plot = [mean(dataTable.meanFiringRate(modulated & linear & passing)) mean(dataTable.meanFiringRate(modulated & ~linear & passing))];
err2plot  = [std(dataTable.meanFiringRate(modulated & linear & passing)) std(dataTable.meanFiringRate(modulated & ~linear & passing))];
barwitherr(err2plot, data2plot);
set(gca, 'XTickLabel', {'linear', 'saturating exponential'})
ylabel('mean firing rate (Hz)')
title('mean firing rate by model category')

figlib.pretty()
box(gca, 'off')

if being_published
  snapnow
  delete(gcf)
end

%% Comparing Speed Modulation using Clustering

% set up RatCatcher object
r               = RatCatcher;
r.experimenter  = 'Caitlin';
r.analysis      = 'BandwidthEstimator';
alphas          = {'A', 'B', 'C', 'D', 'E', 'F'};

% store the indices mapping the clusters to the dataTable
indices         = zeros(height(dataTable), length(alphas));

for ii = 1:length(alphas)
  r.alpha       = alphas{ii};
  temp          = r.index(dataTable);
  indices(temp, ii) = 1;
end
indices = logical(indices);

% kmax between clusters
for ii = 1:length(alphas)
  data2plot(ii) = (1/best.Fs) * mean(dataTable.kmax(modulated & passing & indices(:, ii)));
  err2plot(ii)  = (1/best.Fs) * std(dataTable.kmax(modulated & passing & indices(:, ii)));
end

figure('OuterPosition',[0 0 1200 800],'PaperUnits','points','PaperSize',[1200 800]);
barwitherr(err2plot, data2plot);
set(gca, 'XTickLabel', alphas)
ylabel('k_{max} (s)')
title('bandwidth parameter by cluster')

figlib.pretty()
box(gca, 'off')

if being_published
  snapnow
  delete(gcf)
end

% meanFiringRate between clusters
for ii = 1:length(alphas)
  data2plot(ii) = (1/best.Fs) * mean(dataTable.kmax(modulated & linear & passing & indices(:, ii)));
  err2plot(ii)  = (1/best.Fs) * std(dataTable.kmax(modulated & linear & passing & indices(:, ii)));
end

figure('OuterPosition',[0 0 1200 800],'PaperUnits','points','PaperSize',[1200 800]);
barwitherr(err2plot, data2plot);
set(gca, 'XTickLabel', alphas)
ylabel('mean firing rate (Hz)')
title('mean firing rate by cluster')

figlib.pretty()
box(gca, 'off')

if being_published
  snapnow
  delete(gcf)
end

%% Bandwidth Estimation
% The MLE/CV method computes the optimal bandwidth parameter using the Prerau & Eden method.
% The MCE/CV method uses the Pearson's R value without accounting for delay.

% scatter plot of the bandwidths
figure('OuterPosition',[0 0 1200 800],'PaperUnits','points','PaperSize',[1200 800]);
plot(dataTable.kcorr(linear & passing), dataTable.kmax(linear & passing), 'o');
xlabel('k_{corr}')
ylabel('k_{max}')
title('MLE/CV vs. correlation bandwidths')

figlib.pretty()
box(gca, 'off')

if being_published
  snapnow
  delete(gcf)
end

% fit linear model to the scatter plot
fitlm(dataTable.kcorr(linear & passing), dataTable.kmax(linear & passing))

%% Outliers
% Relevant outliers include cells which are flagged as speed-modulated but have
% abnormally high bandwidth parameters. These cells have little variation in spikes/bin.

disp('Indices of outlying cells:')
disp(find(modulated & ~passing))
disp(dataTable([find(modulated & ~passing)], :))

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
