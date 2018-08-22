function rate = getFiringRate(root, spikeTrain, bandwidth)

  % wraps the kconv function in a CMBHOME object
  filter = hanning(bandwidth) / sum(hanning(bandwidth));
  rate = BandwidthEstimator.kconv(spikeTrain, filter, 1/root.fs_video);

end % function
