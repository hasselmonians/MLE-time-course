% run this script to generate the batchfile

runLocal = true;

% generate batch files
arg = RatCatcher.batchify('experimenter', 'Caitlin', 'alpha', 'A', 'analysis', 'BandwidthEstimator', 'location', '/home/ahoyland/code/MLE-time-course/cluster');
return
% run locally to test things
if runLocal == true
  for ii = 1:length(arg)
    arg = strrep(arg, 'false', 'true');
  end
  % create a parallel pool if it doesn't already exist
  pool = gcp;
  % run each of the scripts in the batch files
  for ii = 1:length(arg)
    disp(['[INFO] ' arg{ii}]);
    try
      eval(arg{ii});
    catch err
      disp(['[ERROR] ' err.identifier])
    end
  end
  disp(['[INFO] Done!'])
end

% gather the data
dataTable = RatCatcher.gather('location', '/home/ahoyland/code/MLE-time-course/cluster', 'analysis', 'BandwidthEstimator', 'namespec', 'output-');
dataTable = RatCatcher.stitch('experimenter', 'Caitlin', 'alpha', 'A', 'data', dataTable);
