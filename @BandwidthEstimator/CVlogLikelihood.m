function like = CVlogLikelihood(self, varargin)
  % computes the cross-validated log-likelihood of the firing rate w.r.t. the bandwidth
  % based on Prerau & Eden 2011

  %% Arguments:
    % self: the BandwithEstimator object

  %% Outputs:
    % output: the log-likelihood of the bandwidth parameter

  p = inputParser;
  p.addParameter('kernel', @self.hanning);
  p.addParameter('bandwidth', self.Fs);
  p.parse(varargin{:});
  kernel = p.Results.kernel;
  bandwidth = p.Results.bandwidth;

% first, compute the rate estimate for the given parameter
rate = self.rateEstimate('kernel', kernel, 'bandwidth', bandwidth);
like = zeros(size(self.spikeTrain, 2), 1);

% then, compute the log-likelihood
nSteps  = length(self.spikeTrain);
dt      = self.time(2) / nSteps;

for recording = 1:size(self.spikeTrain, 2)
  val = 0;
  for step = 1:length(nSteps)
    val = val + self.spikeTrain(step, recording) * log(rate(step, recording) * dt) - rate(step, recording) * dt;
  end
  like(recording) = val;
end
