% this is a test script for the MLE time course package
% we will calculate the binned spike times and generate a complete MLE/CV analysis
% to determine the best bandwidth for kernel filtering of the firing rate from the spike train


% load the example data
load('example_cell.mat')

% the recording/cell indices
root.cel = [2 1];

% make a binned spike train
spikeTrain = BandwidthEstimator.getSpikeTrain(root);

% perform the MLE/CV test
% [estimate, kmax, loglikelihoods, bandwidths, CI] = BandwidthEstimator.cvKernel(root, spikeTrain(1:10000));

% compute kmax for the first 10 minutes in 1 minute sections
nEpochSteps = 60*root.fs_video;
kmaxEpoch = NaN(10, 1);
for epoch = 1:10
  textbar(epoch, 10)
  [~, kmaxEpoch(epoch)] = BandwidthEstimator.cvKernel(root, spikeTrain(1 + nEpochSteps*(epoch - 1) : nEpochSteps*epoch));
end

% benchmark the speed of the MLE/CV computation
kmaxAllEpochs = NaN(10, 1);
time = NaN(10, 1);
for epoch = 1:10
  textbar(epoch, 10)
  tic;
  [~, kmaxAllEpochs(epoch), loglikelihoods] = BandwidthEstimator.cvKernel(root, spikeTrain(1 : nEpochSteps * epoch));
  time(epoch) = toc;
end

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%          PLOT UP THE ESTIMATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure;
%Exponentiate the likelihood for easy viewing
likelihood=exp(loglikelihoods-max(loglikelihoods));
lmax=max(likelihood);
t=(1/root.fs_video):(1/root.fs_video):(length(spikeTrain)*(1/root.fs_video));

% truncate data
t = t(1:1000);
spikeTrain = spikeTrain(1:1000);

%Plot the data and the estimate of the true value
ax=subplot(211);
hold on
plot(t,estimate,'r','linewidth',2);

axis tight
xlabel('Time (s)');
ylabel('Rate (Hz)');
title('Cross-Validated Kernel Smoother Estimate');

ax2=axes('position',get(ax,'position'));
subplot(ax2);
stem(t,spikeTrain,'marker','none');
set(gca,'color','none','yaxislocation','right','xticklabel','')
ylabel('Spike Count');

%Plot the likelihood and confidence bounds for the bandwidth estimate
subplot(212)
hold on
fill([CI fliplr(CI)],[lmax lmax 0 0],'g','edgecolor','none');
plot(bandwidths*(1/root.fs_video),likelihood,'k','linewidth',2);
plot(kmax*(1/root.fs_video),lmax,'r.','markersize',20);
axis([0 kmax*(1/root.fs_video)*2, 0, lmax]);
set(gca,'yticklabel','');
xlabel('Hanning Bandwidth Size (s)');
ylabel('Likelihood');
title('Bandwidth Likelihood');
