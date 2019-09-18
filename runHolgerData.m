r = RatCatcher;

r.expID = 'Holger';
r.remotepath = '/projectnb/hasselmogrp/hoyland/LNLModel/cluster/';
r.localpath = '/mnt/hasselmogrp/hoyland/LNLModel/cluster/';
r.protocol = 'LNLModel';
r.project = 'hasselmogrp';
r.verbose = true;

load('/mnt/hasselmogrp/hoyland/data/holger/data-unmerged.mat')

r.filenames = filenames;
r.filecodes = filecodes;

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
