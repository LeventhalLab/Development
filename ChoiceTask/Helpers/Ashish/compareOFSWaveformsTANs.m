function compareOFSWaveformsTANs(csvWaveformFiles)
%csvWaveformFiles = {'/Volumes/RecordingsLeventhal2/ChoiceTask/R0088/R0088-processed/Waveforms/compiledWaveformTable.csv',
%     '/Volumes/RecordingsLeventhal2/ChoiceTask/R0117/R0117-processed/Waveforms/compiledWaveformTable.csv'};
paramIdxEnergy = 5;
paramIdxPeakValley = 6;
paramIdxISIPrev = 8;
paramIdxISIProp = 9;
paramIdxAPeakToValleyTick = 10;

h2 = figure('position',[0 0 800 800]);
for iCsv = 1:length(csvWaveformFiles)
    T = readtable(csvWaveformFiles{iCsv});
    unitTitles = {};

    % waveforms
    figure('position',[0 0 800 800]);
    for ii = 1:size(T,1)
        subplot(ceil(sqrt(size(T,1))),ceil(sqrt(size(T,1))),ii);
        waveform = T{ii,11:end};
        waveform = waveform(~isnan(waveform));
        plot(waveform);
        xlabel('sample');
        ylabel('uV');
        xlim([1 length(waveform)]);
        ylim([-400 400]);
        unitTitles{ii} = T{ii,1}{1};
        title(unitTitles{ii});
    end
    
    % 3D scatterplot
    scatterData = {};
    scatterLabels = {};
    scatterCount = 1;
    for ii = 1:size(T,1)
        scatterData{1,scatterCount} = (1/24414.0625) * T{ii,paramIdxAPeakToValleyTick};
        scatterData{2,scatterCount} = 1 / (.001 * T{ii,paramIdxISIPrev}); % FR
        scatterData{3,scatterCount} = T{ii,paramIdxISIPrev}; % ISI
        scatterData{4,scatterCount} = T{ii,paramIdxISIProp}; % PropISI
        scatterLabels{scatterCount} = unitTitles{ii};% num2str(scatterCount);
        scatterCount = scatterCount + 1;
    end
    smallFontSize = 6;
    
    figure(h2);
    
    colors = jet(4);
    scatterColors = zeros(size(scatterData,2),3);
 
    % Parameters according to Cohen paper
    ISI = cell2mat(scatterData(4,:));
    FR = cell2mat(scatterData(2,:));
    PVD = cell2mat(scatterData(1,:));
    
    TANs = find(FR > 2.8 & FR < 6.0 & PVD > 255.6 & PVD < 541.2);
    scatterColors(TANs,:) = repmat(colors(2,:),[numel(TANs) 1]);
    
    MSNs = find(FR > 0.2 & FR < 1.8 & PVD > 459.5 & PVD < 534.5);
    scatterColors(MSNs,:) = repmat(colors(3,:),[numel(MSNs) 1]);
    
    FSIs = find(FR > 5.2 & FR < 27.8 & PVD > 142.2 & PVD < 260.8);
    scatterColors(FSIs,:) = repmat(colors(4,:),[numel(FSIs) 1]);
    
    UINs = find(FR > 0.3 & FR < 1.9 & PVD > 149.8 & PVD < 280.2);
    scatterColors(UINs,:) = repmat(colors(1,:),[numel(UINs) 1]);
    
    p = scatter3(cell2mat(scatterData(1,:)),cell2mat(scatterData(4,:)),cell2mat(scatterData(2,:)),24,scatterColors);
    p.MarkerFaceColor = 'white';
    ylabel('PROP_I_S_I (%)');
    zlabel('Firing Rate (spikes/s)');
    zlim([0 40]);
    xlabel('Valley Peak Duration');
  
    hold on;
    
    
    
    
end
