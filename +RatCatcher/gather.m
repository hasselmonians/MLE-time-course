function dataTable = gather(location, analysis, namespec)

  % gathers up data from a series of output files

  % Arguments:
    % location: character vector, the path to the output files
    % analysis: character vector, describes the type of gathering performed
      % expects 'BandwidthEstimator' or ???
    % namespec: character vector, is the non-unique identifier for output files
    % for example if your files are named output-1 output-2 etc.
    % then the namespec is 'output-'
  % Outputs:
    % dataTable: m x n table, a MATLAB data table, specific to the analysis

  returnToCWD = pwd;

  % assume that the output files are stored sensibly
  if nargin < 2
    namespec = 'output-';
    disp('[INFO] Assuming namespec is ''output-''')
  end

  % gather together all of the data points into a single matrix
  cd(location)
  files   = dir([namespec '*']);
  dim1    = length(files);
  dim2    = size(csvread(files(1).name));
  data    = NaN(dim1, dim2);
  for ii = 1:dim1
    data(ii, :) = csvread(files(ii).name);
  end

  switch analysis
  case 'BandwidthEstimator'
    % gather the data from the output files
    kmax = data(:, 1);
    CI = data(:, 2:3);
    filenames = cell(dim1, 1);
    for ii = 1:dim1
      filenames{ii} = files(ii).name;
    end
    % put the data in a MATLAB table
    dataTable = table(filenames, kmax, CI);
  otherwise
    disp('[ERROR] I don''t know which analysis you mean.')
  end



end % function
