function batchify(experimenter, alpha, pathname)

  % writes the batch scripts
  [filename, cellnum] = RatCatcher.parse(experimenter, alpha);

  % remove all old files
  delete cluster/batch*
  
  % write the batch files
  for ii = 1:length(filename)
    outfile = ['cluster/output-' num2str(ii) '.csv'];
    fileID  = fopen(outfile, 'w');
    fprintf(fileID, '#!/bin/csh\n');
    fprintf(fileID, 'module load matlab/2017a\n');
    fprintf(fileID, '#$ -l h_rt=72:00:00');
    fprintf(fileID, ['matlab -nodisplay -r "batchFunction(''' pathname filename{ii} ''', [' num2str(cellnum(ii, 1)) ' ' num2str(cellnum(ii, 2)) '], ''' outfile '''); exit"']);
    fclose(fileID);
  end

  % add a qsub file
  fileID = fopen('cluster/batchfile.sh', 'w');
  log = '/projectnb/hasselmogrp/hoyland/MLE-time-course/cluster/log/';
  err = '/projectnb/hasselmogrp/hoyland/MLE-time-course/cluster/err/';
  for ii = 1:length(filename)
    fprintf(fileID, ['qsub -pe omp 16 -o ' log ' -e ' err ' -P ' 'hasselmogrp ' './batch-' num2str(ii) '\n']);
  end
  fclose(fileID);

end % function
