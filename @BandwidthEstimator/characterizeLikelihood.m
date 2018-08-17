function like = characterizeLikelihood(self, varargin)
  % perform a sweep over bandwidth parameters to find the best bandwidth
  % given the principle of leave-one-out cross-validation of maximum likelihood

  %% Arguments
    % self: a BandwidthEstimator object
    % kernel: a function handle to the kernel smoothing function
    % bandwidth: a vector of bandwidth parameters to test
    % parallel: boolean, determines whether rateEstimate should be run in parallel

  %% Outputs
    % rate: vector of firing rate estimates after smoothing of the spike train by a kernel

  p = inputParser;
  p.addParameter('kernel', @self.hanning);
  p.addParameter('bandwidth', [10:10:1000])
  p.addParameter('parallel', false)
  p.parse(varargin{:});
  kernel = p.Results.kernel;
  bandwidth = p.Results.bandwidth;
  parallel = p.Results.parallel;

  %% Outputs:
    % like: the vector of log-likelihoods of the bandwidth parameters
    % if the spike train is a matrix, then this is also a matrix

  like = NaN(length(bandwidth), 1);

  for ii = 1:length(bandwidth)
    textbar(ii, length(bandwidth))
    like(ii) = self.CVlogLikelihood(self.rateEstimate('kernel', kernel, 'bandwidth', bandwidth(ii), 'parallel', parallel));
  end
