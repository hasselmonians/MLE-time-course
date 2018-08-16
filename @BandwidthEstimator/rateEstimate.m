function rate = rateEstimate(self, varargin)
  % leave-one-out rate estimate for a kernel smoother

  %% Arguments
    % self: a BandwidthEstimator object
    % kernel: a function handle

  %% Outputs
    %
    %

  p = inputParser;
  p.addParameter('kernel', @self.hanning);
  p.addParameter('bandwidth', self.Fs);
  p.parse(varargin{:});
  kernel = p.Results.kernel;
  bandwidth = p.Results.bandwidth;

  % define important variables
  dt      = 1/self.Fs; % time step
  nSteps  = self.time(1) : dt : self.time(2); % number of time steps in the series
  rate    = NaN(length(nSteps), size(self.spikeTrain, 2));

  [~, normalization] = kernel(1, bandwidth);

  for recording = 1:size(self.spikeTrain, 2) % for each spike train in the matrix
    for step = 1:length(nSteps) % for each time step
      textbar(step, length(nSteps));
      rate(step, recording) = normalization * dt * sum(kernel(step - nSteps, bandwidth, true) * self.spikeTrain(:, recording));
    end
  end

end % end function
