% run this script to generate the batchfile

runLocal = true;

arg = RatCatcher.batchify('Caitlin', 'A');

if runLocal == true
  for ii = 1:length(arg)
    strrep(arg, 'false', 'true');
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
