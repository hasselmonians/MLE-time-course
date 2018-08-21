classdef BandwidthEstimator
  % a simple class to keep track of parameters and methods
  % for likelihood-based bandwidth estimation procedure for spike-trains

  properties

    Fs % double, sample frequency in Hz
    time % 2x1 double, start and stop time in s
    spikeTrain % matrix of logicals, spike train as a binary series

  end % properties

  methods

    % constructor
    function obj = BandwidthEstimator(varargin)

      % use input parser to add values to the class
      p = inputParser;
      p.addParameter('Fs', 20e3, @(x) assert(isnumeric(x) && isscalar(x) && (x > 0), 'Sample frequency must be positive, scalar, and numeric'));
      p.addParameter('spikeTrain', logical(0));
      p.addParameter('time', 0, @(x) assert(isnumeric(x) && (x > 0), 'Time must be positive and numeric'));
      % parse the input arguments
      p.parse(varargin{:});
      Fs          = p.Results.Fs;
      spikeTrain  = p.Results.spikeTrain;
      time        = p.Results.time;

      % process the spikeTrain
      % spikeTrain should be nSteps x nRecordings
      if size(spikeTrain, 2) > size(spikeTrain, 1)
        spikeTrain = spikeTrain';
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

      % process time
      if isscalar(time)
        time = [1/Fs, time];
      end
      obj.Fs    = Fs;
      obj.time  = time;

    end % constructor

  end % methods

  methods (Static)

  end % static methods

end % classdef
