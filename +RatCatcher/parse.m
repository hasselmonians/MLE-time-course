function [filename, cellnum] = parse(experimenter, alpha)
  % parses the name of a datafile listed within cluster_info.mat
  % extracts the main section of the filename and the cell index

switch experimenter
case 'Caitlin'
  % load the cluster info file
  try
    load('/projectnb/hasselmogrp/hoyland/cluster_info.mat');
  catch
    try
      load(which('cluster_info.mat'));
    catch
      error('Error. Cluster info could not be found.');
    end
  end

  % get the cluster name
  cluster         = eval(['Cluster_' alpha]);
  stringParts     = cell(1, 2);
  filename        = cell(length(cluster.RowNodeNames), 1);
  cellcell        = cell(length(cluster.RowNodeNames), 1);

  % split the cluster row node names into experiment and recording/cell names
  for ii = 1:length(cluster.RowNodeNames)
    stringParts   = strsplit(cluster.RowNodeNames{ii}, '_cell_');
    filename{ii}  = stringParts{1};
    cellcell{ii}   = stringParts{2};
  end

  % parse the cellnum
  cellnum = NaN(length(cellcell), 2);
  for ii = 1:length(cellcell)
    splt = strsplit(cellcell{ii}, '-');
    for qq = 1:size(cellnum, 2)
      cellnum(ii, qq) = str2num(splt{qq});
    end
  end

  case 'Holger'
    error('Error. I don''t know what to do yet.')
  end % end switch


  end % function