% run this script to generate the batchfile

runLocal = true;

% generate batch files for clusters A-F, simulate and save

cluster_info_index = ['A' 'B' 'C' 'D' 'E' 'F'];
for ii = 1:length(cluster_info_index)
    namespec(ii, :) = ['output-Caitlin-' cluster_info_index(ii)];
end

for index = 1:length(cluster_info_index)

  experimenter  = 'Caitlin';
  alpha         = cluster_info_index(index);
  analysis      = 'BandwidthEstimator';
  location      = '/home/ahoyland/code/MLE-time-course/cluster';

  arg = RatCatcher.batchify('experimenter', experimenter, 'alpha', alpha, 'analysis', analysis, 'location', location, 'namespec', namespec(index, :));

  % run locally to test things
  if runLocal == true
    % run only as a test (i.e. do not add to the path)
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

end

% gather the data
dataTable = RatCatcher.gather('location', location, 'analysis', analysis, 'namespec', namespec(1, :));
dataTable = RatCatcher.stitch('experimenter', experimenter, 'alpha', cluster_info_index(1), 'data', dataTable);

for ii = 2:length(cluster_info_index)
  % create a data table from the next run
  dataTable2 = RatCatcher.gather('location', location, 'analysis', analysis, 'namespec', namespec(ii, :));
  dataTable2 = RatCatcher.stitch('experimenter', experimenter, 'alpha', cluster_info_index(ii), 'data', dataTable2);
  % add that data table to the total
  dataTable = [dataTable dataTable2];
end

save('/home/ahoyland/code/MLE-time-course/BandwidthEstimator-Caitlin.mat', 'dataTable');
