function arg = batchify(experimenter, alpha)

  % automatically generates batch files for mouse or rat data
  % Arguments:
    % experimenter: expects either 'Holger' or 'Caitlin'
    % alpha: the alphanumeric identifier for the experimentalist's data
    % for experimenter = 'Caitlin', this should be an ID from cluster_info.mat
    % e.g. 'A' or 'B', etc.
  % Outputs:
    % arg: n x 1 cell of character vectors, contains the matlab command to run the batchFunction

  % run this from BandwidthEstimator/
  cwd = pwd;
  if strcmp(cwd(end-6:end), 'cluster')
    cd ..
  end

  % writes the batch scripts
  [filename, cellnum] = RatCatcher.parse(experimenter, alpha);

  % remove all old files
  delete batch*
  % copy over the new function
  copyfile +BandwidthEstimator/batchFunction.m cluster/
  cd cluster/

  % write the batch files
  arg = cell(length(filename), 1);
  for ii = 1:length(filename)
    outfile = ['output-' num2str(ii) '.csv'];
    csvwrite(outfile, []);
    infile = ['batch-' num2str(ii)];
    fileID  = fopen(infile, 'w');
    fprintf(fileID, '#!/bin/csh\n');
    fprintf(fileID, 'module load matlab/2017a\n');
    fprintf(fileID, '#$ -l h_rt=72:00:00\n');
    arg{ii} = ['batchFunction(''' filename{ii} ''', [' num2str(cellnum(ii, 1)) ' ' num2str(cellnum(ii, 2)) '], ''' outfile ''', false);'];
    fprintf(fileID, ['matlab -nodisplay -r "' arg{ii} ' exit;"']);
    fclose(fileID);
  end

  % add a qsub file
  fileID = fopen('batchFile.sh', 'w');
  log = '/projectnb/hasselmogrp/hoyland/MLE-time-course/cluster/log/';
  err = '/projectnb/hasselmogrp/hoyland/MLE-time-course/cluster/err/';
  for ii = 1:length(filename)
    fprintf(fileID, ['qsub -pe omp 16 -o ' log ' -e ' err ' -P ' 'hasselmogrp ' './batch-' num2str(ii) '\n']);
  end
  fclose(fileID);

end % function
