% this script was written by Alec Hoyland at 14:36 2018 September 4
% using awesome-matlab-notebook by Srinivas Gorur-Shandilya (http://srinivas.gs/contact/)
% this work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License
% to view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/4.0/.ts

pdflib.header;
tic

%% Introduction
% Bandwidth parameters will be found for kernel smoothing, which maximimize the cross-correlation between animal speed and the MLE/CV firing rate estimate.

if ~exist('corrSpeedBand.mat', 'file')
  % load the analysis file
  load('BandwidthEstimator-Caitlin.mat')
  % instantiate output variables
  kcorr       = zeros(height(dataTable), 1);
  logmaxcorr  = zeros(height(dataTable), 1);
  delay       = zeros(height(dataTable), 1);
  for ii = 1:height(dataTable)
    corelib.textbar(ii, height(dataTable))
    % load the specific data file
    load(dataTable.filenames{ii})
    root.cel  = dataTable.cellnums(ii, :);
    root      = root.AppendKalmanVel;
    speed     = root.vel;
    % generate a BandwidthEstimator object
    best      = BandwidthEstimator(root);
    best.kernel = 'hanning';
    % acquire the firing rate estimate
    frequency = best.kconv(best.kernel(round(dataTable.kmax(ii)*best.Fs)));
    % futz with the object, since this isn't what it was intended to do
    best.spikeTrain = speed;
    % run the correlation analysis over the bandwidths
    [est, kcorr(ii), lmc] = best.corrKernel(frequency, true);
    logmaxcorr(ii) = max(lmc);
    [~, ~, delay(ii)] = alignsignals(est, frequency, [], 'truncate');
  end
  % convert to seconds
  delay = delay / best.Fs;
  % save the data
  dataTable = table(kcorr, logmaxcorr, delay);
  save('~/code/MLE-time-course/CorrelationSpeedBandwidth/corrSpeedBand.mat', 'dataTable');
  disp('data saved')
else
  load('corrSpeedBand.mat')
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
