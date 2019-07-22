% This is a demonstration of how to use RatCatcher.
% We will perform a bandwidth estimation analysis
% on some peristimulus time histogram data collected by Caitlin Monaghan.

%% Instantiate the RatCatcher object
r             = RatCatcher;

%% Set up some basic properties

% describe the dataset that we're looking at
r.expID       = {'Caitlin', 'A'};

% give the remote and local
r.remotepath  = '/projectnb/hasselmogrp/hoyland/MLE-time-course/cluster';
r.localpath   = '/mnt/hasselmogrp/hoyland/MLE-time-course/cluster';

% specify the protocol we want to use
r.protocol    = 'BandwidthEstimator';

% specify the project name
r.project     = 'hasselmogrp';

% create the batched files on the cluster
r.batchify();

%% Run the simulation

return

%% Collect the data afterwards

dataTable = r.gather;
dataTable = r.stitch(dataTable);
