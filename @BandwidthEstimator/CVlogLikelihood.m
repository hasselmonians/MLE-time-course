function like = CVlogLikelihood(self, rate)
  % computes the cross-validated log-likelihood of the firing rate w.r.t. the bandwidth
  % based on Prerau & Eden 2011

  %% Arguments:
    % self: the BandwithEstimator object
    % rate: vector of kernel-smoothed rate values for each time-step, given a bandwidth

  %% Outputs:
    % like: scalar double, the log-likelihood of the bandwidth parameter
    % if the spike train is a matrix, then the likelihood is a vector

  % outputs
  like    = zeros(size(self.spikeTrain, 2), 1);

  % compute the log-likelihood
  nSteps  = length(self.spikeTrain);
  dt      = self.time(2) / nSteps;

  for recording = 1:size(self.spikeTrain, 2)
    val = 0;
    for step = 1:length(nSteps)
      val = val + self.spikeTrain(step, recording) * log(rate(step, recording) * dt) - rate(step, recording) * dt;
    end
    like(recording) = val;
  end
end
