
% format: Channel, Unit, Timestamp, Energy, Peak-Valley, Average, ISI
% (Previous), ISI (Next), Area, Waveform
% [ ] generate unitHeaders

axcorrRange = [-0.01 0.01];
isiRange = [0 10^2];
waveformScale = [-400 400];
fontSize = 7;

waveformFile = fullfile(sessionConf.leventhalPaths.processed,[neuronName(1:end-1),'.txt']);
if ~exist(waveformFile,'file')
    disp(['No waveform file for ',neuronName]);
    disp('Pausing! Place file and press any key to continue...');
    pause();
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
    ax = subplot_tight(numel(units),3,startSubplot);
    t = linspace(0,(size(waveformTrace,2)/header.Fs)*1000,size(waveformTrace,2));
    errorbar(t,mean(waveformTrace),std(waveformTrace),'k');
    unitNames{iUnit} = [neuronName(1:end-1),char(96+iUnit)];
    title([unitNames{iUnit}],'interpreter','none');
    xlabel('ms');
    ylabel('uV');
    xlim([0 (size(waveformTrace,2)/header.Fs)*1000]);
    ax.XTick = [0 1 2];
    ylim(waveformScale);
    ay.YTick = waveformScale;

    % firing rate
    subplot_tight(numel(units),3,startSubplot+1);
    waveformTs = waveformInfo(:,3);
    allTimestamps{iUnit} = waveformTs;
    histBins = 200;
    [counts,centers] = histcounts(waveformTs,histBins);
    sessionLength = length(sevFilt) / Fs;
    binSeconds = sessionLength / histBins;
    firingRate = counts/binSeconds;
    plot(centers(1:end-1)/60,counts/binSeconds,'k');
    title(['mean: ',num2str(round(mean(firingRate))),' spikes/s']);
    xlabel('min');
    ylabel('spikes/s');
    xlim([0 centers(end-1)/60]);
    ylim([0 max(firingRate) + std(firingRate)]);

    % ISI histogram
    ax = subplot_tight(numel(units),3,startSubplot+2);
    ISI = waveformInfo(:,7); % ISI column
    ISI = ISI(ISI~=0); % fix weird issue in one data set where ISI=0
    bins = exp(linspace(log(min(ISI)),log(max(ISI)),100));
    [counts,centers] = histcounts(ISI,bins);
    plot(centers(1:end-1),counts,'k')
    title('ISI');
    set(gca,'XScale','log');
    xlabel('Time (s)');
    ylabel('spikes');
    xlim(isiRange);
    ax.XTick = isiRange;
end

subFolder = 'waveforms';
docName = [subFolder,'_',neuronName(1:end-1)];
savePDF(h,sessionConf.leventhalPaths,subFolder,docName,true);

h = figure;
for iUnit=1:numel(units)
    for jj=iUnit:numel(units)
        subplot_tight(numel(units),numel(units),((iUnit-1) * numel(units)) + jj);
        [tsOffsets, ts1idx, ts2idx] = crosscorrelogram(allTimestamps{iUnit},allTimestamps{jj},axcorrRange);
        [counts,centers] = hist(tsOffsets(tsOffsets ~= 0),100); % remove reference spike
        bar(centers,counts,'k','EdgeColor','k');
        plotTitle = [char(96+iUnit),' x ',char(96+jj)];
        if iUnit == 1 && jj == 1
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
savePDF(h,sessionConf.leventhalPaths,subFolder,docName,true);

rows = 9;
cols = 7;
for iUnit = 1:numel(units) % units are all exported to one file
    h = figure('position',[0 0 900 1100]);
    % mean waveform
    waveformInfo = waveforms(waveforms(:,2) == units(iUnit),:);
    waveformTrace = waveformInfo(:,11:end);
    waveformTrace = waveformTrace(:,~isnan(waveformTrace(1,:)));
    ax = subplot_tight(rows,cols,1);
    t = linspace(0,(size(waveformTrace,2)/header.Fs)*1000,size(waveformTrace,2));
    plot(t,mean(waveformTrace));
    title({unitNames{iUnit},'waveform'},'interpreter','none','HorizontalAlignment','left');
    xlabel('ms');
    ylabel('uV');
    xlim([0 (size(waveformTrace,2)/header.Fs)*1000]);
    ax.XTick = [0 1 2];
    ylim([-400 400]);
    ay.YTick = waveformScale;
    set(ax,'FontSize',fontSize);
    
    % firing rate
    ax = subplot_tight(rows,cols,2);
    waveformTs = waveformInfo(:,3);
    allTimestamps{iUnit} = waveformTs;
    histBins = 100;
    [counts,centers] = histcounts(waveformTs,histBins);
    sessionLength = length(sevFilt) / Fs;
    binSeconds = sessionLength / histBins;
    firingRate = counts/binSeconds;
    plot(centers(1:end-1)/60,counts/binSeconds,'k');
    title({'','FR'});
    xlabel('min');
    ylabel('spikes/s');
    xlim([0 centers(end-1)/60]);
    ax.XTick = [0 round(centers(end-1)/60)];
    ylim([0 max(firingRate) + std(firingRate)]);
    set(ax,'FontSize',fontSize);
    
    % ISI histogram
    ax = subplot_tight(rows,cols,3);
    ISI = waveformInfo(:,7);
    ISI = ISI(ISI~=0); % fix weird issue in one data set where ISI=0
    bins = exp(linspace(log(min(ISI)),log(max(ISI)),100));
    [counts,centers] = histcounts(ISI,bins);
    plot(centers(1:end-1),counts,'k')
    title({'','ISI'});
    set(gca,'XScale','log');
    xlabel('seconds');
    ylabel('spikes');
    xlim([0 10^2]);
    set(ax,'FontSize',fontSize);
    

    % axcorr, arrange loop to first do acorr then xcorr
    unitRange = 1:numel(units);
    unitOrder = [iUnit unitRange(unitRange ~= iUnit)];
    for jj=1:numel(units)
        ax = subplot_tight(rows,cols,cols+jj);
        [tsOffsets, ts1idx, ts2idx] = crosscorrelogram(allTimestamps{iUnit},allTimestamps{unitOrder(jj)},axcorrRange);
        [counts,centers] = hist(tsOffsets(tsOffsets ~= 0),50); % remove reference spike
        bar(centers,counts,'k','EdgeColor','k');
        title({'',[char(96+iUnit),' x ',char(96+unitOrder(jj))]}); % only unit
        xlabel('ms');
        ax.XTick = axcorrRange;
        if jj==1
            ylabel('spikes');
        end
        set(ax,'FontSize',fontSize);
    end
    
    channelData = get_channelData(sessionConf,electrodeChannels);
    atlas_ims = [];
    [atlas_ims,k] = plotMthalElectrode(atlas_ims,channelData.ap(1),channelData.ml(1),channelData.dv(1),nasPath,[1 0 0],0.1);
    ax = subplot_tight(rows,cols,cols+6);
    imshow(atlas_ims{1,k});
    p = get(ax,'position');
    p(3) = p(3)*2;
    p(4) = p(4)*2;
    set(ax,'position',p);
    
    % savePDF
    subFolder = 'unitHeader';
    docName = [subFolder,'_',unitNames{iUnit}];
    savePDF(h,sessionConf.leventhalPaths,subFolder,docName,false);
end