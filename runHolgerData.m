r = RatCatcher;

r.expID = 'Holger';
r.remotepath = '/projectnb/hasselmogrp/hoyland/MLE-time-course/cluster/';
r.localpath = '/mnt/hasselmogrp/hoyland/MLE-time-course/cluster/';
r.protocol = 'BandwidthEstimator';
r.project = 'hasselmogrp';
r.verbose = true;

return

% batch files
r = r.batchify;

% NOTE: run the 'qsub' command on the cluster now (see output in MATLAB command prompt)

return

% NOTE: once the cluster finishes, run the following commands

% gather files
r = r.validate;
dataTable = r.gather;
dataTable = r.stitch(dataTable);

return
