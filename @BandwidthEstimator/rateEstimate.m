function rate = rateEstimate(self, varargin)
  % leave-one-out rate estimate for a kernel smoother
  % smooths a spike train with a kernel (with a bandwidth parameter)
  % then computes the firing rate estimate at each point

  %% Arguments
    % self: a BandwidthEstimator object
    % kernel: a function handle
    % parallel: boolean, determines whether rateEstimate should be run in parallel

  %% Outputs
    % rate: vector of firing rate estimates after smoothing of the spike train by a kernel

  p = inputParser;
  p.addParameter('kernel', @self.hanning);
  p.addParameter('bandwidth', self.Fs);
  p.addParameter('parallel', false)
  p.parse(varargin{:});
  kernel = p.Results.kernel;
  bandwidth = p.Results.bandwidth;
  parallel = p.Results.parallel;

  % define important variables
  dt      = 1/self.Fs; % time step
  nSteps  = length(self.spikeTrain);
  rate    = NaN(nSteps, size(self.spikeTrain, 2));

  [~, normalization] = kernel(1, bandwidth);

  if parallel
    for recording = 1:size(self.spikeTrain, 2) % for each spike train in the matrix
      parfor step = 1:nSteps % for each time step in the rate function
        textbar(step, nSteps);
        val = 0;
        for ii = 1:nSteps % for each time step in the summand
          if self.spikeTrain(ii, recording) > 0
            val = val + kernel(step - ii, bandwidth, true) * self.spikeTrain(ii, recording);
          end
        end
        rate(step, recording) = dt / normalization * val;
      end
    end
  else
    for recording = 1:size(self.spikeTrain, 2) % for each spike train in the matrix
      for step = 1:nSteps % for each time step in the rate function
        % textbar(step, nSteps);
        val = 0;
        for ii = 1:nSteps % for each time step in the summand
          if self.spikeTrain(ii, recording) > 0
            val = val + kernel(step - ii, bandwidth, true) * self.spikeTrain(ii, recording);
          end
        end
        rate(step, recording) = dt / normalization * val;
      end
    end
  end

end % end function
