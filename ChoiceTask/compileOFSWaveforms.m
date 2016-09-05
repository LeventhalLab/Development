function compileOFSWaveforms(waveformDir)

% format: Channel, Unit, Timestamp, Energy, Peak-Valley, Average, ISI
% (Previous), ISI (Next), Area, Waveform
waveformFiles = dir(fullfile(waveformDir,'*.txt'));
waveforms = {};
for iFile = 1:length(waveformFiles)
    disp(waveformFiles(iFile).name);
    waveform = csvread(fullfile(waveformDir,waveformFiles(iFile).name),2);
    % convert ISI Next to percent ISI under 5ms
    waveform(:,8) = length(find(waveform(:,7) < 5)) / length(waveform);
    waveforms{iFile,1} = waveformFiles(iFile).name;
    waveforms{iFile,2} = mean(waveform);
end

T = table(waveforms);
writetable(T,fullfile(waveformDir,'compiledWaveformTable.csv'),'WriteVariableNames',false);