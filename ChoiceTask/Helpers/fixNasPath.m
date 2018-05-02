function filename = fixNasPath(filename)
% todo: create else
if ~ismac
    C = strsplit(filename,'/');
    if numel(C) == 1
        C = strsplit(filename,'\'); % weird case
    end
    filename = fullfile('\\172.20.138.142\RecordingsLeventhal2',C{4:end});
end