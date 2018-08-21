function [spikeTrain] = getSpikeTrain(root, spikeTimes)

  % accepts an in-vivo recording object and returns the binned spike train
  % requires root.cel to be set
  % if spikeTimes is input, then it uses those values and doesn't perform a computation

  if nargin > 1 && ~isempty(spikeTimes)
    % continue
  else
    % if spikeTimes is not defined
    spikeTimes = BandwidthEstimator.getSpikeTimes(root);
  end

  spikeTrain = zeros(size(root.ts));
  [~,~,temp] = histcounts(spikeTimes,root.ts);
  tt = unique(temp);

  for i = 1:length(tt)
      spikeTrain(tt(i)) = sum(temp == tt(i));
  end

end % function
