function compileOFSWaveforms(waveformDir)

% format: Channel, Unit, Timestamp, Energy, Peak-Valley, Average, ISI
% (Previous), ISI (Next), Area, Waveform
waveformFiles = dir(fullfile(waveformDir,'*.txt'));
waveforms = {};
rowCount = 1;
for iFile = 1:length(waveformFiles)
    waveformFile = csvread(fullfile(waveformDir,waveformFiles(iFile).name),2);
    units = sort(unique(waveformFile(:,2)));
    for iUnit = 1:numel(units) % units are all exported to one file
        disp([waveformFiles(iFile).name,' unit ',num2str(units(iUnit))]);
        waveform = waveformFile(waveformFile(:,2) == units(iUnit),:);
        % convert ISI Next to percent ISI under 5ms, very rough measure of
        % firing rate of burstiness
        waveform(:,8) = length(find(waveform(:,7) < 5)) / length(waveform);
        parts = strsplit(waveformFiles(iFile).name,'_');
        parts{1,3} = [parts{1,3} char(96 + units(iUnit))];
        waveforms{rowCount,1} = strjoin(parts,'-');
        waveforms{rowCount,2} = mean(waveform);
        rowCount = rowCount + 1;
    end
end

T = table(waveforms);
writetable(T,fullfile(waveformDir,'compiledWaveformTable.csv'),'WriteVariableNames',false);