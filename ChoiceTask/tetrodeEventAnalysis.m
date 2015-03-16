function tetrodeEventAnalysis(sessionName,nexStruct,varargin)

    decimateFactor = 10;
    spectHalfWidth = 1; %seconds
    pethHalfWidth = 1; %seconds
    histBin = 50;
    spectCaxis = [15 50];
    fontSize = 5;
    
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
    figurePath = fullfile(leventhalPaths.graphs,'tetrodeAnalysis');
    if ~isdir(figurePath)
        mkdir(figurePath);
    end

    events = nexs_getEvents(nexStruct);
    compiledEvents = {};
    compiledEvents.cueOn = [1,3,5,7,9];
    compiledEvents.houselightOn = 11;
    compiledEvents.foodOn = 13;
    compiledEvents.noseIn = [17,19,21,23,25];
    compiledEvents.foodportOn = 27;
    compiledEvents.toneOn = [33,35];
    compiledEvents.goTrial = 39;
    eventFieldnames = fieldnames(compiledEvents);

    validTetrodes = find(any(sessionConf.validMasks,2).*sessionConf.chMap(:,1));
    % plot spectrums
    for iTet=1:length(validTetrodes)
        tetrodeName = sessionConf.tetrodeNames{iTet};
        disp(['Creating spectogram for ',tetrodeName]);

        %[] need real LFP channel
        lfpChannel = sessionConf.chMap(iTet,2);
        fullSevFiles = getChFileMap(leventhalPaths.session);
        disp(['Reading ',fullSevFiles{lfpChannel}]);
        [sev,header] = read_tdt_sev(fullSevFiles{lfpChannel});
        sevDec = decimate(double(sev),decimateFactor);

        movingwin = [0.5 0.05];
        params.tapers=[5 9];
        params.Fs = header.Fs/10;
        params.fpass = [5 80];
        params.trialave = 1;
        params.err = 0;
        [S1,t,f] = mtspecgramc(sevDec,movingwin,params);
        spectHalfWidthSamples = length(find(t <= spectHalfWidth));

        h = figure('position',[0 0 800 800]);
        for iEvent=1:length(eventFieldnames)
            eventName = eventFieldnames{iEvent};
            disp(['Working on event ',eventName]);
            % compile all timestamps
            eventTs = compileEventTs(nexStruct,compiledEvents,eventFieldnames,iEvent);
            % compile mean spectogram
            allEventTsS1 = [];
            for iTs=1:length(eventTs)
                centerIdx = length(find(t <= eventTs(iTs)));
                if centerIdx >= spectHalfWidthSamples && size(S1,1) >= centerIdx + spectHalfWidthSamples
                    allEventTsS1(iTs,:,:) = S1(centerIdx-spectHalfWidthSamples:centerIdx+spectHalfWidthSamples,:);
                end
            end
            subplot(3,3,iEvent);
            spectPethT = [fliplr(t(1:spectHalfWidthSamples))*-1 0 t(1:spectHalfWidthSamples)];
            plot_matrix(squeeze(mean(allEventTsS1,1)),spectPethT,f);
            hold on;
            plot([0 0],params.fpass,':','color','k');
            colormap(jet);
            caxis(spectCaxis);
            xlabel('Time (s)','FontSize',fontSize);
            ylabel('Frequency (Hz)','FontSize',fontSize);
            title([tetrodeName,':',eventName,', ',num2str(length(allEventTsS1)),' trials'],'FontSize',fontSize);
        end
        saveas(h,fullfile(figurePath,[tetrodeName,'_eventSpectograms']),'pdf');
        close(h);
    end

    if isfield(nexStruct,'neurons')
        for iNeuron=1:length(nexStruct.neurons)
            h = figure('position',[0 0 800 800]);
            neuronName = formatNeuronName(nexStruct.neurons{iNeuron}.name);
            disp(['Creating PETH for ',neuronName]);
            for iEvent=1:length(eventFieldnames)
                eventName = eventFieldnames{iEvent};
                disp(['Working on event ',eventName]);
                % compile all timestamps
                eventTs = compileEventTs(nexStruct,compiledEvents,eventFieldnames,iEvent);
                allEventTsPeth = [];
                for iTs=1:length(eventTs)
                    % gather unit ts that fall within PETH window
                    if eventTs(iTs) > pethHalfWidth && max(eventTs) - eventTs(iTs) > pethHalfWidth
                        pethTsRawIdx = nexStruct.neurons{iNeuron}.timestamps > eventTs(iTs) - pethHalfWidth...
                            & nexStruct.neurons{iNeuron}.timestamps < eventTs(iTs) + pethHalfWidth;
                        allEventTsPeth = [allEventTsPeth;nexStruct.neurons{iNeuron}.timestamps(pethTsRawIdx) - eventTs(iTs)];
                    end
                end
                subplot(3,3,iEvent);
                [counts,centers] = hist(allEventTsPeth,histBin);
                bar(centers,counts,1,'EdgeColor','none','FaceColor',[0 0.5 0.5]);
                hold on;
                plot([0 0],[0,max(counts)],':','color','k');
                xlabel('Time (s)','FontSize',fontSize);
                ylabel('Frequency (Hz)','FontSize',fontSize);
                title([neuronName,':',eventName,', ',num2str(length(allEventTsPeth)),' spikes'],'FontSize',fontSize);
            end
            saveas(h,fullfile(figurePath,[neuronName,'_eventUnits']),'pdf');
            close(h);
        end
    end
    disp('end')
end

function neuronName = formatNeuronName(neuronName)
    parts = strsplit(neuronName,'_');
    neuronName = strjoin(parts(end-1:end),'-');
end

function eventTs = compileEventTs(nexStruct,compiledEvents,eventFieldnames,iEvent)
    eventTs = [];
    for iSubFields=1:length(compiledEvents.(eventFieldnames{iEvent}))
        theEvent = nexStruct.events(compiledEvents.(eventFieldnames{iEvent}));
        eventTs = [eventTs;theEvent{iSubFields}.timestamps];
    end
end