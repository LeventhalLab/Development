sessions_to_analyze = {'R0088_20151030a','R0088_20151031a','R0088_20151101a','R0088_20151102a',...
                       'R0117_20160503a','R0117_20160503b','R0117_20160504a','R0117_20160505a','R0117_20160506a','R0117_20160508a','R0117_20160510a'};

wireList = {[33,34,35,36,37,38,39,40,42,44,46,48],[33,34,35,36,37,38,39,40,42,44,46,48],[33,34,35,36,37,38,39,40,42,44,46,48],[33,34,35,36,37,38,39,40,42,44,46,48],...
            [93,95,100,104,120],[93,95,100,104,120],[93,100,104,118,120],[93,100,104,118,120],[93,100,104,118,120],[93,100,104,118,120],[93,100,104,118,120]};
rootDir = '/Volumes/RecordingsLeventhal2/ChoiceTask';
store_rootDir = '/Volumes/Tbolt_02/VM thal analysis';

fpass = [1,500];
decimateFactor = round(header.Fs / (fpass(2) * 2)); % 2x max desired LFP freq

for iSession = 1 : length(sessions_to_analyze)
    
    curSession = sessions_to_analyze{iSession};
    
    ratID = curSession(1:5);
    
    curDir = fullfile(rootDir, ratID, [ratID '-rawdata'], curSession, curSession);
    storeDir = fullfile(store_rootDir,[ratID '_spike_triggered_scalos'],curSession);
    cd(curDir);
    
%     T = sqlv2_getSessionElectrodes(curSession);
    curWires = wireList{iSession};
    
    for iWire = 1 : length(curWires)
        
        sevPart = sprintf('*ch%d.sev',curWires(iWire));
        sevList = dir(sevPart);

        for ii = 1 : length(sevList)
            if strcmpi(sevList(ii).name(1:2),'._')
                continue
            else
                sevName = sevList(ii).name;
                break;
            end
        end
        
        [sev,header] = read_tdt_sev(sevName);
        sevFilt = decimate(double(sev),decimateFactor);
        Fs = header.Fs / decimateFactor;
        
        [~,lfpName,~] = fileparts(sevName);
        lfpName = [lfpName '_lfp'];
        lfpName = fullfile(storeDir,lfpName);
        save(lfpName,'sevFilt','Fs','decimateFactor','header');
    end
    
end