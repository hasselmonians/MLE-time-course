% generate the batch files for a simulation

% remove all old files
delete cluster/batch*

% the full path is [pathname 'AnimalName' filename '.mat']
pathname = '/projectnb/hasselmogrp/Speed Modulation/Caitlins_Cells/Raw/';
filename = {
  'Clamps/CMBobject_clamps-98.mat';
  'Clamps/CMBobject_clamps-98.mat';
  'Nibbler/CMBobject_nibbler-30.mat';
  'Clamps/CMBobject_clamps-134.mat';
  'Clamps/CMBobject_clamps-1342.mat';
  'Calculon/CMBobject_calculon-083.mat'};
cellnum = [9 3; 9 4; 3 2; 5 3; 12 2; 11 3];

% write the files
for ii = 1:length(filename)
  outfile = ['/projectnb/hasselmogrp/hoyland/MLE-time-course/cluster/output-' num2str(ii) '.csv'];
  fileID = fopen(['cluster/' 'batch-' num2str(ii)], 'w');
  fprintf(fileID, '#!/bin/csh\n');
  fprintf(fileID, 'module load matlab/2017a\n');
  fprintf(fileID, '#$ -l h_rt=72:00:00\n');
  fprintf(fileID, ['matlab -nodisplay -r "bandwidth_MLE_CV(''' pathname filename{ii} ''', [' num2str(cellnum(ii, 1)) ' ' num2str(cellnum(ii, 2)) '], ''' outfile '''); exit"']);
  fclose(fileID);
end

% add an output file
fileID = fopen('cluster/output.csv', 'w');
fclose(fileID);
