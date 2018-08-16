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
  steps   = self.time(1) : dt : self.time(2); % number of time steps in the series
  rate    = NaN(length(steps), size(self.spikeTrain, 2));

  [~, normalization] = kernel(1, bandwidth);

  for recording = 1:size(self.spikeTrain, 2) % for each spike train in the matrix
    for step = 1:length(steps) % for each time step in the rate function
      textbar(step, length(steps));
      val = 0;
      for ii = 1:length(steps) % for each time step in the summand
        if self.spikeTrain(ii, recording) > 0
          val = val + kernel(step - ii, bandwidth, true) * self.spikeTrain(ii, recording);
        end
      end
      rate(step, recording) = dt / normalization * val;
    end
  end

end % end function
