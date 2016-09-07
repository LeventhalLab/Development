function compareOFSWaveforms(csvWaveformFiles)
%csvWaveformFiles = {'/Volumes/RecordingsLeventhal2/ChoiceTask/R0088/R0088-processed/Waveforms/compiledWaveformTable.csv',
%     '/Volumes/RecordingsLeventhal2/ChoiceTask/R0117/R0117-processed/Waveforms/compiledWaveformTable.csv'};
paramIdxEnergy = 5;
paramIdxPeakValley = 6;
paramIdxISIPrev = 8;
paramIdxISIThresh = 9;
paramIdxArea = 10;

h2 = figure('position',[0 0 800 800]);
for iCsv = 1:length(csvWaveformFiles)
    T = readtable(csvWaveformFiles{iCsv});
    unitTitles = {};

    % waveforms
    figure('position',[0 0 800 800]);
    for ii = 1:size(T,1)
        subplot(ceil(sqrt(size(T,1))),ceil(sqrt(size(T,1))),ii);
        plot(T{ii,11:end});
        xlabel('sample');
        ylabel('uV');
        parts = strsplit(T{ii,1}{1},'_');
        unitTitles{ii} = strjoin(parts(1:3));
        title(unitTitles{ii});
    end

    scatterData = {};
    scatterLabels = {};
    scatterCount = 1;
    for ii = 1:size(T,1)
        scatterData{1,scatterCount} = T{ii,paramIdxEnergy};
        scatterData{2,scatterCount} = T{ii,paramIdxISIPrev};
        scatterData{3,scatterCount} = T{ii,paramIdxISIThresh};
        scatterLabels{scatterCount} = unitTitles{ii};% num2str(scatterCount);
        scatterCount = scatterCount + 1;
    end
    figure(h2);
    subplot(311);
    hold on;
    plot(cell2mat(scatterData(1,:)),cell2mat(scatterData(2,:)),'.','MarkerSize',25);
    labelpoints(cell2mat(scatterData(1,:)),cell2mat(scatterData(2,:)),scatterLabels);
    xlabel('Energy');
    ylabel('Mean ISI');

    subplot(312);
    hold on;
    plot(cell2mat(scatterData(1,:)),cell2mat(scatterData(3,:)),'.','MarkerSize',25);
    labelpoints(cell2mat(scatterData(1,:)),cell2mat(scatterData(3,:)),scatterLabels);
    xlabel('Energy');
    ylabel('ISI < 5ms');

    subplot(313);
    hold on;
    plot(cell2mat(scatterData(2,:)),cell2mat(scatterData(3,:)),'.','MarkerSize',25);
    labelpoints(cell2mat(scatterData(2,:)),cell2mat(scatterData(3,:)),scatterLabels);
    xlabel('Mean ISI');
    ylabel('ISI < 5ms');
end

% legend(unitTitles,'Location','northoutside');