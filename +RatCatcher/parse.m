function [filename, cellnum] = parse(varargin)
  % parses the name of a datafile listed within cluster_info.mat
  % extracts the main section of the filename and the cell index

  % Arguments:
    % experimenter: expects either 'Caitlin' or 'Holger'
    % alpha: the alphanumeric identifier for the experimentalist's data
    % for experimenter = 'Caitlin', this should be an ID from cluster_info.mat
    % e.g. 'A' or 'B', etc.
  % Outputs:
    % filename: n x 1 cell, the parsed filenames for where the data are stored
    % cellnum: n x 2 double, the recording/cell indices corresponding to the filenames

    p = inputParser;
    p.CaseSensitive = false;
    p.addParameter('experimenter', [], @ischar);
    p.addParameter('alpha', [], @ischar);
    p.parse(varargin{:});
    experimenter  = p.Results.experimenter;
    alpha         = p.Results.alpha;

  switch experimenter
  case 'Caitlin'
    % load the cluster info file
    try
      load('/projectnb/hasselmogrp/hoyland/cluster_info.mat');
    catch
      try
        load(which('cluster_info.mat'));
      catch
        error('[ERROR] Cluster info could not be found.');
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
      cellcell{ii}  = stringParts{2};
    end

    % parse the filenames
    old             = {'bender-', 'calculon-', 'clamps-', 'cm-19-', 'cm-20-', 'cm-41-', 'cm-47-', 'cm-48-', 'cm-51-', 'nibbler-', 'zoidberg-'};
    new             = {'1_', '2_', '3_', '4_', '5_', '6_', '7_', '8_', '9_', '0_', '01_'};
    for ii = 1:length(old)
      filename      = strrep(filename, old{ii}, new{ii});
    end
    for ii = 1:length(filename)
      filename{ii}  = ['/projectnb/hasselmogrp/hoyland/data/caitlin/' filename{ii} '.mat'];
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
    error('[ERROR] I don''t know what to do yet.')
  otherwise
    error('[ERROR] I don''t know which experimenter you mean.')
  end % end switch

end % function
