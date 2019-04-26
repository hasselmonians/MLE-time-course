r             = RatCatcher;
r.localpath   = '/mnt/hasselmogrp/hoyland/MLE-time-course/cluster';
r.remotepath  = '/projectnb/hasselmogrp/hoyland/MLE-time-course/cluster';
r.protocol    = 'BandwidthEstimator';
r.project     = 'hasselmogrp';
r.expID       = {'Caitlin', 'A'; 'Caitlin', 'B'; 'Caitlin', 'C'; 'Caitlin', 'D'; 'Caitlin', 'E'};
r.verbose     = true;

r = r.batchify();
save(fullfile(r.localpath, 'RatCatcher.mat'), 'r')
