% run this script to generate the batchfile

directory = pwd;
if ~strcmp(directory(end-6:end), 'cluster')
  try
    cd cluster
  catch
    error('Error. Can''t find cluster/ directory. Aborting.')
  end
end

RatCatcher.batchify('Caitlin', 'A', '/projectnb/hasselmogrp/hoyland/data/caitlin/');
