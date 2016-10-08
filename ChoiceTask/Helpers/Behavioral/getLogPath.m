function logFile = getLogPath(rawdataDir)

logFile = dir(fullfile(rawdataDir,'*.log'));
fnames = {logFile.name};
logFile = cellfun(@isempty,regexp(fnames,'old.log')); %logical
logFile = fullfile(rawdataDir,fnames{logFile});