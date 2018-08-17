function bandwidth_MLE_CV(filename, cellnum, outfile)
  % determines the best bandwidth parameter for acquiring a firing rate estimate

  % preamble
  addpath(genpath('/projectnb/hasselmogrp/hoyland/MLE-time-course/'))
  addpath(genpath('/projectnb/hasselmogrp/hoyland/srinivas.gs_mtools/src/'))
  addpath(genpath('/projectnb/hasselmogrp/hoyland/CMBHOME/'))
  import CMBHOME.*

  % acquire data using function arguments
  load(filename);
  root.cel = cellnum;

  % create BandwithEstimator object
  best = BandwidthEstimator('Fs', root.fs_video, 'time', root.ts(end), 'spikeTrain', root.cel_i{1});

  % leave-one-out cross-validated likelihood of frequency estimate
  bands = linspace(125/root.fs_video, 256*1000/root.fs_video, 11)
  like = best.characterizeLikelihood('kernel', @best.hanning, 'bandwidth', bands, 'parallel', true);

  % find the maximum likelihood estimate (MLE)
  [~, I] = max(like);

  bandwidth_MLE = bands(I);
  MLE = like(I);

  % write output to file
  csvwrite(outfile, [bandwidth_MLE MLE]);

end % function
