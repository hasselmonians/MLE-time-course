% test all the features within the BandwithEstimator class

% load a cell
import CMBHOME.*
load('/projectnb/hasselmogrp/Speed Modulation/Caitlins_Cells/Raw/Clamps/CMBobject_clamps-98.mat')
root.cel = [9, 3];

% create BandwithEstimator object
best = BandwidthEstimator('Fs', root.fs_video, 'time', root.ts(end), 'spikeTrain', root.cel_i{1});

% rate estimate
rate = best.rateEstimate('bandwidth', 125, 'parallel', true);
figure
plot(rate / max(vectorise(rate)));
