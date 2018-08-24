function batchify(experimenter, alpha, pathname)

  directory = pwd;
  if ~strcmp(directory(end-6:end), 'cluster')
    error('Error. Not in cluster/ directory. Aborting.')
  end

  % writes the batch scripts
  [filename, cellnum] = RatCatcher.parse(experimenter, alpha);

  % remove all old files
  delete batch*

  % write the batch files
  for ii = 1:length(filename)
    outfile = ['output-' num2str(ii) '.csv'];
    csvwrite(outfile, []);
    infile = ['batch-' num2str(ii)];
    fileID  = fopen(infile, 'w');
    fprintf(fileID, '#!/bin/csh\n');
    fprintf(fileID, 'module load matlab/2017a\n');
    fprintf(fileID, '#$ -l h_rt=72:00:00\n');
    fprintf(fileID, ['matlab -nodisplay -r "batchFunction(''' filename{ii} ''', [' num2str(cellnum(ii, 1)) ' ' num2str(cellnum(ii, 2)) '], ''' outfile ''', true); exit"']);
    fclose(fileID);
  end

  % add a qsub file
  fileID = fopen('batchfile.sh', 'w');
  log = '/projectnb/hasselmogrp/hoyland/MLE-time-course/cluster/log/';
  err = '/projectnb/hasselmogrp/hoyland/MLE-time-course/cluster/err/';
  for ii = 1:length(filename)
    fprintf(fileID, ['qsub -pe omp 16 -o ' log ' -e ' err ' -P ' 'hasselmogrp ' './batch-' num2str(ii) '\n']);
  end
  fclose(fileID);

end % function
