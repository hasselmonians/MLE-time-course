% run this script to generate the batchfile

runLocal = true;

% generate batch files for clusters A-F, simulate and save

cluster_info_index = {'A' 'B' 'C' 'D' 'E' 'F'};
for ii = 1:length(cluster_info_index)
    namespec(ii, :) = ['output-Caitlin-' cluster_info_index{ii}];
end

r = RatCatcher;
r.experimenter  = 'Caitlin';
r.alpha         = cluster_info_index;
r.analysis      = 'BandwidthEstimator';
r.location      = '/home/ahoyland/code/MLE-time-course/cluster';

for index = 1:length(cluster_info_index)

  r.alpha = cluster_info_index{index};
  r.namespec = namespec(index, :);

  arg = r.batchify();

  % run locally to test things
  if runLocal == true
    cd(r.location)
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
r.alpha   = {'A', 'B', 'C', 'D', 'E', 'F'};
r.namespec = 'output-';
dataTable = r.gather();
dataTable = r.stitch(dataTable);

save('/home/ahoyland/code/MLE-time-course/BandwidthEstimator-Caitlin.mat', 'dataTable');
