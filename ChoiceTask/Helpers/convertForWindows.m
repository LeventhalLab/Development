function filename = convertForWindows(filename)
    C = strsplit(filename,'/');
    filename = fullfile('\\172.20.138.142\RecordingsLeventhal2',C{4:end});
end