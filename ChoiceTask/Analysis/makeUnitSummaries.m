function makeUnitSummaries(waveformDir)
% format: Channel, Unit, Timestamp, Energy, Peak-Valley, Average, ISI
% (Previous), ISI (Next), Area, Waveform

waveformFiles = dir(fullfile(waveformDir,'*.txt'));

for iFile = 1:length(waveformFiles)
    waveformFile = csvread(fullfile(waveformDir,waveformFiles(iFile).name),2);
    units = sort(unique(waveformFile(:,2)));
    
    % plot first figure
    % compile timestamps for xcorr
%     figure('position',[0 0 800 800]);
    h1 = formatSheet;
    allTimestamps = {};
    unitNames = {};
    for iUnit = 1:numel(units) % units are all exported to one file
        fileParts = strsplit(waveformFiles(iFile).name,'_');
        fileParts{1,3} = [fileParts{1,3} char(96 + units(iUnit))];
        unitNames{iUnit} = strjoin(fileParts,'-');
        disp([waveformFiles(iFile).name,' unit ',num2str(units(iUnit))]);
        waveformInfo = waveformFile(waveformFile(:,2) == units(iUnit),:);
        waveformTrace = waveformInfo(:,11:end);
        waveformTrace = waveformTrace(:,~isnan(waveformTrace(1,:)));
        startSubplot = 3*(iUnit-1)+1;
        
        % waveform plot
        subplot(numel(units),3,startSubplot);
        errorbar(mean(waveformTrace),std(waveformTrace),'k');
        title(unitNames{iUnit});
        xlabel('samples');
        ylabel('uV');
        xlim([1 size(waveformTrace,2)]);
        ylim([-400 400]);
        
        % firing rate
        subplot(numel(units),3,startSubplot+1);
        timestamps = waveformInfo(:,3);
        allTimestamps{iUnit} = timestamps;
        sessionLength = max(timestamps); % roughly, unless unit never fires
        divideSession = 20;
        [N,edges] = histcounts(timestamps,round(sessionLength/divideSession));
        plot(edges(1:end-1)/60,N/divideSession,'k');
        title(['firing rate - avg: ',num2str(round(mean(N))),' s/s']);
        xlabel('minutes');
        ylabel('spikes/second');
        xlim([0 edges(end-1)/60]);
        ylim([0 max(N/divideSession) + std(N/divideSession)]);
        
        % ISI histogram
        subplot(numel(units),3,startSubplot+2);
        ISI = waveformInfo(:,7);
        bins = exp(linspace(log(min(ISI)),log(max(ISI)),100));
        [N,edges] = histcounts(ISI,bins);
        plot(edges(1:end-1),N,'k')
        title('ISI histogram');
        set(gca,'XScale','log');
        xlabel('ms');
        ylabel('spikes');
        xlim([0 10^2]);
    end
    
    h2 = formatSheet;
    for ii=1:numel(units)
        for jj=ii:numel(units)
            subplot(numel(units),numel(units),((ii-1) * numel(units)) + jj);
            [tsOffsets, ts1idx, ts2idx] = crosscorrelogram(allTimestamps{ii},allTimestamps{jj},[-0.05 0.05]);
            [counts,centers] = hist(tsOffsets(tsOffsets ~= 0),100); % remove reference spike
            bar(centers,counts,'k','EdgeColor','k');
            if ii == 1
                parts = strsplit(unitNames{jj},'-');
                if jj == 1
                    title(unitNames{jj}); % session, unit, channels
                else
                    title(parts{3}); % only unit
                end
            end
            xlabel('ms');
            ylabel('spikes');
        end
    end
    saveDir = fullfile(waveformDir,'PDF Summaries');
     if ~exist(saveDir,'dir')
        mkdir(saveDir);
     end
    parts = strsplit(waveformFiles(iFile).name,'.');
    saveas(h1,fullfile(saveDir,['waveform_',parts{1},'.pdf']));
    saveas(h2,fullfile(saveDir,['axcorr_',parts{1},'.pdf']));
    close(h1);
    close(h2);
end