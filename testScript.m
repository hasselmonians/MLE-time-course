% test all the features within the BandwithEstimator class

% load a cell
import CMBHOME.*
load('/projectnb/hasselmogrp/Speed Modulation/Caitlins_Cells/Raw/Clamps/CMBobject_clamps-98.mat')
root.cel = [9, 3];

% create BandwithEstimator object
best = BandwidthEstimator('Fs', root.fs_video, 'time', root.ts(end), 'spikeTrain', root.cel_i{1});

% leave-one-out cross-validated likelihood of frequency estimate
bands = 10:10:1000;
like = best.characterizeLikelihood('kernel', @best.hanning, 'bandwidth', bands, 'parallel', true);

% visualize
figure;
plot(bands, like);
title('Likelihood over Bandwidth')
xlabel('bandwidth (ms)')
ylabel('likelihood')
