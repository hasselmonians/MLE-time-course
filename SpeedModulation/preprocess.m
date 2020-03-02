function x = preprocess(x)
  x = strrep(x, '/projectnb', '/mnt');
  x = strrep(x, '/hoyland', '/ahoyland');
end % function
