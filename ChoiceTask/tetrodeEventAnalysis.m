function tetrodeEventAnalysis(sessionName,nexStruct,varargin)

decimateFactor = 10;
spectHalfWidth = 1; %second
spectCaxis = [15 50];

for iarg = 1 : 2 : nargin - 2
    switch varargin{iarg}
        case 'nasPath',
            nasPath = varargin{iarg + 1};
        case 'sessionConf'
            sessionConf = varargin{iarg + 1};
    end
end

if ~exist('sessionConf','var')
    if exist('nasPath','var')
        sessionConf = exportSessionConf(sessionName,'nasPath',nasPath);
    else
        sessionConf = exportSessionConf(sessionName);
    end
end

leventhalPaths = buildLeventhalPaths(sessionConf.nasPath,sessionName);

events = nexs_getEvents(nexStruct);
compiledEvents = {};
compiledEvents.cueOn = [1,3,5,7,9];
compiledEvents.houselightOn = 11;
compiledEvents.foodOn = 13;
compiledEvents.noseIn = [17,19,21,23,25];
compiledEvents.foodportOn = 27;
compiledEvents.toneOn = [33,35];
compiledEvents.goTrial = 39;

allTetSpectrums = [];
% plot spectrums
for iTet=1:length(sessionConf.validMasks)
    tetrodeName = sessionConf.tetrodeNames{iTet};
    if ~any(sessionConf.validMasks(iTet,:))
        disp(['Skipping ',tetrodeName]);
        continue;
    end
    
    %[] need real LFP channel
    lfpChannel = sessionConf.chMap(iTet,2);
    fullSevFiles = getChFileMap(leventhalPaths.session);
    disp(['Reading ',fullSevFiles{lfpChannel}]);
    [sev,header] = read_tdt_sev(fullSevFiles{lfpChannel});
    sevDec = decimate(double(sev),decimateFactor);
    disp(['Creating spectogram for ',tetrodeName]);
    movingwin = [0.5 0.05];
    params.tapers=[5 9];
    params.Fs = header.Fs/10;
    params.fpass = [5 80];
    params.trialave = 1;
    params.err = 0;
    [S1,t,f] = mtspecgramc(sevDec,movingwin,params);
    spectHalfWidthSamples = length(find(t <= spectHalfWidth));
    
%     allTetSpectrums(iTet,:,:) = S1;
    
    h = figure('position',[0 0 800 800]);
    eventFieldnames = fieldnames(compiledEvents);
    for iEvent=1:length(eventFieldnames)
        eventName = eventFieldnames{iEvent};
        disp(['Working on event ',eventName]);
        % compile all timestamps
        ts = [];
        eventTs = [];
        for iSubFields=1:length(compiledEvents.(eventFieldnames{iEvent}))
            theEvent = nexStruct.events(compiledEvents.(eventFieldnames{iEvent}));
            eventTs = [eventTs;theEvent{iSubFields}.timestamps];
        end
        % compile mean spectogram
        allEventTsS1 = [];
        for iTs=1:length(eventTs)
            centerIdx = length(find(t <= eventTs(iTs)));
            if centerIdx >= spectHalfWidthSamples && size(S1,1) >= centerIdx + spectHalfWidthSamples
                allEventTsS1(iTs,:,:) = S1(centerIdx-spectHalfWidthSamples:centerIdx+spectHalfWidthSamples,:);
            end
        end
        subplot(3,3,iEvent);
        spectPETHt = [fliplr(t(1:spectHalfWidthSamples))*-1 0 t(1:spectHalfWidthSamples)];
        plot_matrix(squeeze(mean(allEventTsS1,1)),spectPETHt,f);
        hold on;
        plot([0 0],params.fpass,':','color','k');
        colormap(jet);
        caxis(spectCaxis);
        xlabel('Time (s)');
        ylabel('Frequency (Hz)');
        title([tetrodeName,':',eventName,', ',num2str(length(allEventTsS1)),' trials']);
    end
    figurePath = fullfile(leventhalPaths.graphs,'tetrodeAnalysis');
    if ~isdir(figurePath)
        mkdir(figurePath)
    end
    saveas(h,fullfile(figurePath,[tetrodeName,'_eventSpectograms']),'png');
    close(h);
end

disp('end')