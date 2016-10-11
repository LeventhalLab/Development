nasPath = '/Volumes/RecordingsLeventhal2/ChoiceTask';

% allSessions = {'R0117_20160503a','R0117_20160503b','R0117_20160504a','R0117_20160505a','R0117_20160506a','R0117_20160507a','R0117_20160508a','R0117_20160510a','R0117_20160510b'};
allSessions = {'R0088_20151030a','R0088_20151031a','R0088_20151101a','R0088_20151102a'};
for ii=1:length(allSessions)
    sessionConf = exportSessionConf(allSessions{ii},'nasPath',nasPath)
    nexData = TDTtoNex(sessionConf);
    createDDTFiles(sessionConf);
end
