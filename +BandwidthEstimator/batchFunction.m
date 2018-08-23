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
  load(filename);
  root.cel = cellnum;

  % generate the spike train from the in-vivo object
  spikeTrain = BandwidthEstimator.getSpikeTrain(root);

  % perform leave-one-out cross-validation maximum likelihood of frequency estimate
  [estimate, kmax, loglikelihoods, bandwidths, CI] = BandwidthEstimator.cvKernel(root, spikeTrain, range);

  % save the data
  csvwrite(outfile, [kmax CI]);

end % function
