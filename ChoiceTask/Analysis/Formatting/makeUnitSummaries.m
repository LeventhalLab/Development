
% format: Channel, Unit, Timestamp, Energy, Peak-Valley, Average, ISI
% (Previous), ISI (Next), Area, Waveform
% [ ] generate unitHeaders

waveformFile = fullfile(sessionConf.leventhalPaths.processed,[neuronName(1:end-1),'.txt']);
if ~exist(waveformFile,'file')
    warning(['No waveform file for ',neuronName]);
end
waveforms = csvread(waveformFile,2);
units = sort(unique(waveforms(:,2)));

% plot first figure
% compile timestamps for xcorr
h = figure;
allTimestamps = {};
unitNames = {};
for iUnit = 1:numel(units) % units are all exported to one file
    waveformInfo = waveforms(waveforms(:,2) == units(iUnit),:);
    waveformTrace = waveformInfo(:,11:end);
    waveformTrace = waveformTrace(:,~isnan(waveformTrace(1,:)));
    startSubplot = 3*(iUnit-1)+1;

    % waveform plot
    subplot(numel(units),3,startSubplot);
    errorbar(mean(waveformTrace),std(waveformTrace),'k');
    unitNames{iUnit} = [neuronName(1:end-1),char(96+iUnit)];
    title([unitNames{iUnit}],'interpreter','none');
    xlabel('samples');
    ylabel('uV');
    xlim([1 size(waveformTrace,2)]);
    ylim([-400 400]);

    % firing rate
    subplot(numel(units),3,startSubplot+1);
    waveformTs = waveformInfo(:,3);
    allTimestamps{iUnit} = waveformTs;
    histBins = 200;
    [counts,centers] = histcounts(waveformTs,histBins);
    sessionLength = length(sevFilt) / Fs;
    binSeconds = sessionLength / histBins;
    firingRate = counts/binSeconds;
    plot(centers(1:end-1)/60,counts/binSeconds,'k');
    title(['mean: ',num2str(round(mean(firingRate))),' spikes/s']);
    xlabel('minutes');
    ylabel('spikes/s');
    xlim([0 centers(end-1)/60]);
    ylim([0 max(firingRate) + std(firingRate)]);

    % ISI histogram
    subplot(numel(units),3,startSubplot+2);
    ISI = waveformInfo(:,7);
    bins = exp(linspace(log(min(ISI)),log(max(ISI)),100));
    [counts,centers] = histcounts(ISI,bins);
    plot(centers(1:end-1),counts,'k')
    title('ISI histogram');
    set(gca,'XScale','log');
    xlabel('Time (s)');
    ylabel('spikes');
    xlim([0 10^2]);
end

subFolder = 'waveforms';
docName = [subFolder,'_',neuronName(1:end-1)];
savePDF(h,sessionConf.leventhalPaths,subFolder,docName);

h = figure;
for ii=1:numel(units)
    for jj=ii:numel(units)
        subplot(numel(units),numel(units),((ii-1) * numel(units)) + jj);
        [tsOffsets, ts1idx, ts2idx] = crosscorrelogram(allTimestamps{ii},allTimestamps{jj},[-0.05 0.05]);
        [counts,centers] = hist(tsOffsets(tsOffsets ~= 0),100); % remove reference spike
        bar(centers,counts,'k','EdgeColor','k');
        plotTitle = [char(96+ii),' x ',char(96+jj)];
        if ii == 1 && jj == 1
            title({unitNames{jj}(1:end-1),plotTitle},'interpreter','none'); % session, unit, channels
        else
            title(plotTitle); % only unit
        end
        xlabel('ms');
        ylabel('spikes');
    end
end

subFolder = 'axcorrs';
docName = [subFolder,'_',neuronName(1:end-1)];
savePDF(h,sessionConf.leventhalPaths,subFolder,docName);