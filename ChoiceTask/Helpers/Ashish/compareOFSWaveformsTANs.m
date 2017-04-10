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

    scatterData = {};
    scatterLabels = {};
    scatterCount = 1;
    for ii = 1:size(T,1)
        scatterData{1,scatterCount} = T{ii,paramIdxAPeakToValleyTick};
        scatterData{2,scatterCount} = 1 / (.001 * T{ii,paramIdxISIPrev}); % FR
        scatterData{3,scatterCount} = T{ii,paramIdxISIPrev} % ISI
        scatterData{4,scatterCount} = T{ii,paramIdxISIProp} % PropISI
        scatterLabels{scatterCount} = unitTitles{ii};% num2str(scatterCount);
        scatterCount = scatterCount + 1;
    end
    smallFontSize = 6;
    
    figure(h2);
    subplot(311);
    hold off;
    plot(cell2mat(scatterData(1,:)),cell2mat(scatterData(2,:)),'.','MarkerSize',25);
    labelpoints(cell2mat(scatterData(1,:)),cell2mat(scatterData(2,:)),scatterLabels,'FontSize',smallFontSize);
    xlabel('Peak to Valley Tick');
    ylabel('Mean FR');

    subplot(312);
    hold off;
    plot(cell2mat(scatterData(4,:)),cell2mat(scatterData(2,:)),'.','MarkerSize',25);
    labelpoints(cell2mat(scatterData(4,:)),cell2mat(scatterData(2,:)),scatterLabels, 'FontSize',smallFontSize);
    xlabel('PROP ISI');
    ylabel('Mean FR');

    subplot(313);
    hold off;
    plot(cell2mat(scatterData(4,:)),cell2mat(scatterData(1,:)),'.','MarkerSize',25);
    labelpoints(cell2mat(scatterData(4,:)),cell2mat(scatterData(1,:)),scatterLabels, 'FontSize',smallFontSize);
    xlabel('PROP ISI');
    ylabel('Peak to Valley Tick');
    
    
    p = scatter3(cell2mat(scatterData(1,:)),cell2mat(scatterData(4,:)), cell2mat(scatterData(2,:)));
    p.MarkerFaceColor = [0 0.5 0.5];
    hold on;
    
end

% legend(unitTitles,'Location','northoutside');