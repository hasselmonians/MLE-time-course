function bandwidth_MLE_CV(pathname, filename)
  % determines the best bandwidth parameter for acquiring a firing rate estimate

  % preamble
  addpath(genpath('/projectnb/hasselmogrp/hoyland/MLE-time-course/'))
  addpath(genpath('/projectnb/hasselmogrp/hoyland/srinivas.gs_mtools/src/'))
  addpath(genpath('/projectnb/hasselmogrp/hoyland/CMBHOME/'))
  import CMBHOME.*

  load(strcat(pathname,filename));
  root.cel = [9, 3];

  % create BandwithEstimator object
  best = BandwidthEstimator('Fs', root.fs_video, 'time', root.ts(end), 'spikeTrain', root.cel_i{1});

  % leave-one-out cross-validated likelihood of frequency estimate
  bands = linspace(125/root.fs_video, 256*1000/root.fs_video, 11)
  like = best.characterizeLikelihood('kernel', @best.hanning, 'bandwidth', bands, 'parallel', true);

  [~, I] = max(like);

  bandwidth_MLE = bands(I);
  MLE = like(I);

end % function
