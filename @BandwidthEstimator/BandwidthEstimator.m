classdef BandwidthEstimator
  % a simple class to keep track of parameters and methods
  % for likelihood-based bandwidth estimation procedure for spike-trains

  properties

    Fs % sample frequency in Hz
    spikeTrain % spike train as a binary series (logicals)

  end % properties

  methods

    % constructor
    function obj = BandwidthEstimator(Fs, spikeTrain)
      assert(isnumeric(Fs), 'Sample frequency must be numeric')
      assert(isscalar(Fs), 'Sample frequency must be scalar')

      % process the spikeTrain
      % spikeTrain should be nSteps x nRecordings
      if size(spikeTrain, 2) > size(spikeTrain, 1)
        spikeTrain = spikeTrain;
      end

      % spikeTrain should be a logical array (1 == spike)
      if islogical(spikeTrain)
        obj.spikeTrain = spikeTrain;
      else
        % assume that spike time data has been loaded instead
        if iscell(spikeTrain)
          % if spikeTrain is a cell of spike-times, add them to a matrix of spike-times
          maxStep = 0;
          for ii = 1:length(spikeTrain)
            if maxStep < max(spikeTrain{ii}(:))
              maxStep = max(spikeTrain{ii}(:));
            end
          end
          spikeTimes = zeros(maxStep, size(spikeTrain, 2));
          for ii = 1:length(spikeTrain)
            spikeTimes(spikeTrain{ii}(:), ii) = 1;
          end
        else % if spikeTrain is a matrix of spike-times, add them to a matrix of spike-times
          spikeTimes = zeros(max(spikeTrain(:)), size(spikeTrain, 2));
          spikeTimes(spikeTrain) = 1;
        end
        obj.spikeTrain = logical(spikeTimes);
      end
    end % constructor

  end % methods

end % classdef
