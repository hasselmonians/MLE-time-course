function batchFunction(filename, cellnum, outfile, test)

  if nargin < 4
    test = false;
  end

  % preamble
  if ~test
    addpath(genpath('/projectnb/hasselmogrp/hoyland/MLE-time-course/'))
    addpath(genpath('/projectnb/hasselmogrp/hoyland/srinivas.gs_mtools/src/'))
    addpath(genpath('/projectnb/hasselmogrp/hoyland/CMBHOME/'))
    import CMBHOME.*
  end

  % acquire data using function arguments
  % pathname = '/projectnb/hasselmogrp/hoyland/data/caitlin/';
  load(filename);
  root.cel = cellnum;

  % generate the spike train from the in-vivo object
  spikeTrain = BandwidthEstimator.getSpikeTrain(root);

  % test bandwidths up to 1 minute
  range = 3:2:(60*root.fs_video);

  % perform leave-one-out cross-validation maximum likelihood of frequency estimate
  [estimate, kmax, loglikelihoods, bandwidths, CI] = BandwidthEstimator.cvKernel(root, spikeTrain, range, true);

  % save the data
  csvwrite(outfile, [kmax*(1/root.fs_video) CI]);

end % function
