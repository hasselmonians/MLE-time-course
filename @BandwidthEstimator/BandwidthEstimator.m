classdef BandwidthEstimator
  % a simple class to keep track of parameters and methods
  % for likelihood-based bandwidth estimation procedure for spike-trains

  properties

    Fs % sample frequency in Hz
    time % start and stop time in s
    spikeTrain % spike train as a 1 x N vector of doubles

  end % properties

  methods

    % constructor
    function obj = BandwidthEstimator(varargin)

      % use input parser to add values to the class
      p = inputParser;
      p.addParameter('Fs', 30, @(x) assert(isnumeric(x) && isscalar(x) && (x > 0), 'Sample frequency must be positive and scalar'));
      p.addParameter('spikeTrain', [], @(x) assert(isvector(x) && (isnumeric(x) || islogical(x)), 'spikeTrain must be a vector of numbers or logicals'));
      p.addParameter('time', 0, @(x) assert(isnumeric(x) && (x > 0), 'Time must be positive and numeric'));
      % parse the input arguments
      p.parse(varargin{:});
      Fs            = p.Results.Fs;
      spikeTrain    = p.Results.spikeTrain;
      time          = p.Results.time;

      % process the spike train
      spikeTrain = spikeTrain(:)';

      % process time
      if isscalar(time)
        time = [1/Fs, time];
      end

      % add to structure
      obj.Fs        = Fs;
      obj.spikeTrain= spikeTrain;
      obj.time      = timel;

    end % constructor

  end % methods

  methods (Static)

    [result] = kconv(data, k, dt);
    [estimate kmax loglikelihoods bandwidths] = cvkernel(spikecounts, dt, range, ploton);

  end % static methods

end % classdef
