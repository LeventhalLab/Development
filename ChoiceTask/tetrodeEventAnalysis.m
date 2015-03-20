function tetrodeEventAnalysis(sessionConf,nexStruct)
    
    decimateFactor = 10;
    spectHalfWidth = 1; %seconds
    pethHalfWidth = 1; %seconds
    histBin = 50;
    fontSize = 6;
    
    spectFpass = [1 80];
    spectCaxis = [10 60];

    leventhalPaths = buildLeventhalPaths(sessionConf);
    figurePath = fullfile(leventhalPaths.graphs,'tetrodeAnalysis');
    if ~isdir(figurePath)
        mkdir(figurePath);
    end

    events = nexs_getEvents(nexStruct);
    compiledEvents = {};
    compiledEvents.cueOn = [1,3,5,7,9];
    compiledEvents.noseIn = [17,19,21,23,25];
    compiledEvents.toneOn = [33,35];
    compiledEvents.noseOut = [18,20,22,24,26];
    compiledEvents.foodOn = 13;
    compiledEvents.foodportOn = 27;
    compiledEvents.houselightOn = 11;
    compiledEvents.goTrial = 39;
    eventFieldnames = fieldnames(compiledEvents);

    validTetrodes = find(any(sessionConf.validMasks,2).*sessionConf.chMap(:,1));
    % plot spectrums
    for iTet=1:length(validTetrodes)
        tetrodeName = sessionConf.tetrodeNames{validTetrodes(iTet)};
        disp(['Creating spectogram for ',tetrodeName]);

        %[] need real LFP channel
        lfpChannel = sessionConf.lfpChannels(validTetrodes(iTet));
        fullSevFiles = getChFileMap(leventhalPaths.channels);
        disp(['Reading ',fullSevFiles{lfpChannel}]);
        [sev,header] = read_tdt_sev(fullSevFiles{lfpChannel});
        sevDec = decimate(double(sev),decimateFactor);

        movingwin = [0.5 0.05];
        params.tapers = [3 5];
        params.Fs = header.Fs/decimateFactor;
        params.fpass = spectFpass;
        [S1,t,f] = mtspecgramc(sevDec,movingwin,params);
        spectHalfWidthSamples = length(find(t <= spectHalfWidth));
        
        thetaIdxs = f >= 4 & f <= 8;
        thetaNormS1 = normalize(mean(S1(:,thetaIdxs),2));
        betaIdxs = f >= 13 & f <= 30;
        betaNormS1 = normalize(mean(S1(:,betaIdxs),2));
        gammaIdxs = f > 30;
        gammaNormS1 = normalize(mean(S1(:,gammaIdxs),2));

        h = formatSheet;
        h2 = formatSheet;
        for iEvent=1:length(eventFieldnames)
            eventName = eventFieldnames{iEvent};
            disp(['Working on event ',eventName]);
            % compile all timestamps
            eventTs = compileEventTs(nexStruct,compiledEvents,eventFieldnames,iEvent);
            % compile mean spectogram
            allEventTsS1 = [];
            allThetaTsS1 = [];
            allBetaTsS1 = [];
            allGammaTsS1 = [];
            for iTs=1:length(eventTs)
                centerIdx = length(find(t <= eventTs(iTs)));
                if centerIdx >= spectHalfWidthSamples && size(S1,1) >= centerIdx + spectHalfWidthSamples
                    spectIdxs = centerIdx-spectHalfWidthSamples:centerIdx+spectHalfWidthSamples;
                    allEventTsS1(iTs,:,:) = S1(spectIdxs,:);
                    allThetaTsS1(iTs,:) = thetaNormS1(spectIdxs);
                    allBetaTsS1(iTs,:) = betaNormS1(spectIdxs);
                    allGammaTsS1(iTs,:) = gammaNormS1(spectIdxs);
                end
            end
            
            figure(h);
            subplot(2,4,iEvent);
            spectPethT = [fliplr(t(1:spectHalfWidthSamples))*-1 0 t(1:spectHalfWidthSamples)];
            plot_matrix(squeeze(mean(allEventTsS1,1)),spectPethT,f);
            hold on;
            plot([0 0],params.fpass,':','color','k');
            colormap(jet);
            caxis(spectCaxis);
            xlabel('Time (s)','FontSize',fontSize);
            ylabel('Frequency (Hz)','FontSize',fontSize);
            title([tetrodeName,':',eventName,', ',num2str(length(allEventTsS1)),' events'],'FontSize',fontSize);
            
            figure(h2);
            subplot(2,4,iEvent);
            plot(spectPethT,mean(allThetaTsS1),'LineWidth',4);
            hold on;
            plot(spectPethT,mean(allBetaTsS1),'LineWidth',4);
            hold on;
            plot(spectPethT,mean(allGammaTsS1),'LineWidth',4);
            
            hold on;
            betaMin = min(min(S1(:,betaIdxs)));
            betaMax = max(max(S1(:,betaIdxs)));
            betaRaw = squeeze(mean(allEventTsS1(:,:,betaIdxs),3));
            betaStd = std(betaRaw);
            betaPlot = (squeeze(mean(betaRaw,1)) - betaMin) / betaMax;
            plot(spectPethT,betaPlot,'LineWidth',4);
            
            hold on;
            gammaMin = min(min(S1(:,gammaIdxs)));
            gammaMax = max(max(S1(:,gammaIdxs)));
            gammaRaw = squeeze(mean(allEventTsS1(:,:,gammaIdxs),3));
            gammaStd = std(gammaRaw);
            gammaPlot = (squeeze(mean(gammaRaw,1)) - gammaMin) / gammaMax;
            plot(spectPethT,gammaPlot,'LineWidth',4);
            
            hold on;
            plot([0 0],[0 1],':','color','k');
            legend('theta','beta','gamma');
            xlabel('Time (s)','FontSize',fontSize);
            ylabel('Norm. Power','FontSize',fontSize);
            title([tetrodeName,':',eventName,', ',num2str(length(allEventTsS1)),' events'],'FontSize',fontSize);
        end
        
        saveas(h,fullfile(figurePath,[tetrodeName,'_eventSpectrograms']),'pdf');
        close(h);
        saveas(h2,fullfile(figurePath,[tetrodeName,'_eventLFPBands']),'pdf');
        close(h2);
    end

    if isfield(nexStruct,'neurons')
        for iNeuron=1:length(nexStruct.neurons)
            h = formatSheet;
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
                subplot(2,4,iEvent);
                [counts,centers] = hist(allEventTsPeth,histBin);
                bar(centers,counts,1,'EdgeColor','none','FaceColor',[0 0.5 0.5]);
                hold on;
                plot([0 0],[0,max(counts)],':','color','k');
                xlabel('Time (s)','FontSize',fontSize);
                ylabel('Spikes','FontSize',fontSize);
                title([neuronName,':',eventName,', ',num2str(length(eventTs)),' events, ',num2str(length(allEventTsPeth)),' spikes'],'FontSize',fontSize);
            end
            saveas(h,fullfile(figurePath,[neuronName,'_eventUnits']),'pdf');
            close(h);
        end
    end
    
    disp('end')
end

function h = formatSheet()
    h = figure;
    set(h,'PaperOrientation','landscape');
    set(h,'PaperType','A4');
    set(h,'PaperUnits','centimeters');
    set(h,'PaperPositionMode','auto');
    set(h,'PaperPosition', [1 1 28 19]);
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