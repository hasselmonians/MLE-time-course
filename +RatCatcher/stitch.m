function data = stitch(varargin)

  % stitches parsed filenames and cell numbers into datasets

  % Arguments:
    % experimenter: expects either 'Caitlin' or 'Holger'
    % alpha: the alphanumeric identifier for the experimentalist's data
    % for experimenter = 'Caitlin', this should be an ID from cluster_info.mat
    % e.g. 'A' or 'B', etc.
    % data: m x n table, the data table (probably from RatCatcher.gather)
  % Outputs:
    % data: m x n+2 table, the data table

    p = inputParser;
    p.CaseSensitive = false;
    p.addParameter('experimenter', [], @ischar);
    p.addParameter('alpha', [], @ischar);
    p.addParameter('data', []);
    p.parse(varargin{:});
    experimenter  = p.Results.experimenter;
    alpha         = p.Results.alpha;
    data          = p.Results.data;

  [filenames, cellnums] = RatCatcher.parse(experimenter, alpha);
  data2 = table(filenames, cellnums);
  data = [data data2];

end % function
