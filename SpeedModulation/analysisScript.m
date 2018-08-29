% this script was written by Alec Hoyland at 13:43 28 August 2018
% using awesome-matlab-notebook by Srinivas Gorur-Shandilya (http://srinivas.gs/contact/)
% this work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License
% to view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/4.0/.ts

pHeader;
tic

%% Introduction
% Acquiring a good firing rate estimate from experimental data requires binning or convolving the binned spike train. In these analyses, it is common to use a kernel smoother, such as the Gaussian or Hanning filter. In these filters, the bandwidth is a free parameter, determining how wide each convolution is in the time-domain. This document describes using a maximum likelihood estimate method with cross-validation to determine the best estimate for the bandwidth parameter that permits an accurate firing rate estimate. This analysis is based on Prerau & Eden 2011.

%% Analysis
% A sample cell is loaded, using |CMBHOME| and the binned spike train with a time step of 0.02 s is acquired. A leave-one-out cross-validation strategy is performed on the likelihood analysis, yielding an estimate for the bandwidth parameter. The speed of the animal is computed by tracking two LEDs and smoothing the resulting recording with a Kalman filter.


% load the bandwidth data
load('BandwidthEstimator-Caitlin.mat'); % dataTable
if ~any(strcmp('Pearson', dataTable.Properties.VariableNames))
  Pearson       = zeros(length(dataTable), 1);
  pValue        = zeros(length(dataTable), 1);
  delay         = zeros(length(dataTable), 1);
  for ii = 1:size(dataTable, 1)
    textbar(ii, size(dataTable, 1))

    % load the Session object associated with these data
    load(dataTable.filenames{ii})
    % set the start time to zero
    root        = root.FixTime;
    % clear the velocity
    root.b_vel  = [];
    % Kalman filter the animal velocity
    root        = root.AppendKalmanVel;
    % acquire the animal speed
    speed       = root.svel;

    % set up the bandwidth estimator object
    best        = BandwidthEstimator(root);
    % filter the data according to the optimal bandwidth parameter
    frequency   = best.getFiringRate(dataTable.kmax(ii));

    % find the Pearson correlation and time delay between the signals in seconds
    % this method uses the cross-correlation
    [S1, S2, D] = alignsignals(speed, frequency)
    [R, P]      = corrcoef(S1, S2, 'alpha', 0.05);

    % update the output vectors
    Pearson(ii) = R(2);
    pValue(ii)  = P;
    % if delay is positive, frequency lags behind speed
    delay(ii)   = D / best.Fs; % seconds
  end

  data2         = table(Pearson, pValue, delay);
  dataTable     = [dataTable data];
end

if being_published
	snapnow
	delete(gcf)
end

%% Version Info
% The file that generated this document is called:
disp(mfilename)

%%
% and its md5 hash is:
Opt.Input = 'file';
disp(dataHash(strcat(mfilename,'.m'),Opt))

%%
% This file should be in this commit:
[status,m]=unix('git rev-parse HEAD');
if ~status
	disp(m)
end

t = toc;

%%
% This file has the following external dependencies:
showDependencyHash(mfilename);

%%
% This document was built in:
disp(strcat(oval(t,3),' seconds.'))
