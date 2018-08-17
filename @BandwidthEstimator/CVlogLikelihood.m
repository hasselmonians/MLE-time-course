function like = CVlogLikelihood(self, rate)
  % computes the cross-validated log-likelihood of the firing rate w.r.t. the bandwidth
  % based on Prerau & Eden 2011

  %% Arguments:
    % self: the BandwithEstimator object
    % rate: vector of kernel-smoothed rate values for each time-step, given a bandwidth

  %% Outputs:
    % like: scalar double, the log-likelihood of the bandwidth parameter
    % if the spike train is a matrix, then the likelihood is a vector

  % compute the log-likelihood
  nSteps  = length(self.spikeTrain);
  dt      = self.time(2) / nSteps;

  like = 0;
  for step = 1:length(nSteps)
    like = like + self.spikeTrain(step) * log(rate(step) * dt) - rate(step) * dt;
  end

end % function
