
function [spktimes] = getSpikeTimes(root)

  % computes the spike times (in seconds) for the given recording/cell
  % requires root.cel to be set

  % get spike times
  spktimes = CMBHOME.Utils.ContinuizeEpochs(root.cel_ts);

end % function
