function result = askFILE(datafile)
if exist(datafile,'file') %%% check to avoid overiding an existing logfile
    Q = sprintf(' %s\n already exists! Append a.x (1), overwrite (2), or break (default)? ',datafile);
    fileproblem = input(Q);
    if fileproblem==1
        result = [datafile '.x'];
    elseif fileproblem==2
        result = datafile;
    else
        result = NaN;
        error('No data file.');
    end
else
    result = datafile;
end
end