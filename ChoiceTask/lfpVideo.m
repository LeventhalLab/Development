function lfpVideo(sessionConf,nexStruct,lfpChannels,neurons)
    tic
    FigureVisible = 'on';
    % get video
    leventhalPaths = buildLeventhalPaths(sessionConf);
    videos = dir(fullfile(leventhalPaths.rawdata,'*.avi'));
    if isempty(videos)
        error('novideo');
    end
    video = VideoReader(fullfile(leventhalPaths.rawdata,videos(1).name));
    
    % setup new video
    lfpVideoPath = fullfile(leventhalPaths.graphs,'lfpVideos');
    if ~isdir(lfpVideoPath)
        mkdir(lfpVideoPath);
    end
    saveVideoAs = fullfile(lfpVideoPath,[sessionConf.sessionName,'_',strrep(num2str(lfpChannels),'  ','-')]);
    newVideo = VideoWriter(saveVideoAs,'Motion JPEG AVI');
    newVideo.Quality = 75;
    newVideo.FrameRate = video.FrameRate;
    open(newVideo);

    plotHalfWidthSec = 4; % seconds
    behaviorStartTime = getBehaviorStartTime(nexStruct);
  
    fullSevFiles = getChFileMap(leventhalPaths.channels);
    
    videoDimDivider = 3;
    xEventCoords = [783.500000000000;733.500000000000;711.500000000000;707.500000000000;721.500000000000;1695.50000000000;1525.50000000000]/3;
    yEventCoords = [8.435000000000000e+02;6.915000000000000e+02;5.335000000000000e+02;3.795000000000000e+02;2.215000000000000e+02;4.755000000000000e+02;6.895000000000000e+02]/3;
    figureHeight = 800; % estimate figure height (pixels)
    subplotsHeight = (figureHeight - ceil(video.Height/videoDimDivider)); % remaining space for subplots
    lfpHeight = round(subplotsHeight / (round(length(neurons)/2) + length(lfpChannels))); % solve the problem
    neuronHeight = round(lfpHeight/2); % spikes get 1/2 space
    figureHeight = lfpHeight * length(lfpChannels) + neuronHeight * length(neurons) + ceil(video.Height/videoDimDivider); % adjust for rounding
    h = figure('Position',[0 0 ceil(video.Width/videoDimDivider) figureHeight]);
    set(h,'visible',FigureVisible);
    set(h,'color','w');
    
    hicutoff = 500;
    decimateFactor = floor((sessionConf.Fs/2) / hicutoff); % optimized
    dFs = sessionConf.Fs / decimateFactor;
    movingwin=[0.5 0.05];
    params.fpass = [0 80];
    params.tapers = [5 9];
    params.Fs = dFs;
    
    S = [];
    for iLfp = 1:length(lfpChannels)
        [sev,header] = read_tdt_sev(fullSevFiles{lfpChannels(iLfp)});
        sev = decimate(double(sev),decimateFactor);
        sev = eegfilt(sev,header.Fs,[],hicutoff); % lowpass
        disp(['Computing sepctrogram for ch',num2str(lfpChannels(iLfp)),'...']);
        [S1,t,f] = mtspecgramc(sev',movingwin,params);
        S(iLfp,:,:) = 10*log10(abs(S1));
    end
    
    orderedEventsTs = orderAllNexTs(nexStruct);
    cue1 = false;
    cue2 = false;
    cue3 = false;
    cue4 = false;
    cue5 = false;
    nose1 = false;
    nose2 = false;
    nose3 = false;
    nose4 = false;
    nose5 = false;
    tone = false;
    food = false;
    foodport = false;
    houselight = false;
    gotrial = false;
    
    totalSubplots = 1 + length(lfpChannels) + length(neurons);
    % flip these so we can plot from the bottom up, just easier
    lfpChannels = fliplr(lfpChannels);
    neurons = fliplr(neurons);
    
    padSubplots = 20;
    disp('Working on video...');
    iFrame = 1;
    while hasFrame(video)
%     for iFrame=1:video.NumberOfFrames
        disp(['Frame:',num2str(iFrame)]);
        curEphysTs = (1/video.FrameRate) * (iFrame-1) + behaviorStartTime;
        frameEvents = orderedEventsTs(orderedEventsTs(:,2) >= curEphysTs - (1/video.FrameRate) &...
            orderedEventsTs(:,2) < curEphysTs + (1/video.FrameRate));
        
        for iEvent=1:length(frameEvents)
            switch frameEvents(iEvent)
                case 1
                    cue1 = true;
                case 2
                    cue1 = false;
                case 3
                    cue2 = true;
                case 4
                    cue2 = false;
                case 5
                    cue3 = true;
                case 6
                    cue3 = false;
                case 7
                    cue4 = true;
                case 8
                    cue4 = false;
                case 9
                    cue5 = true;
                case 10
                    cue5 = false;
                case 11
                    houselight = true;
                case 12
                    houselight = false;
                case 13
                    food = true;
                case 14
                    food = false;
                case 17
                    nose1 = true;
                case 18
                    nose1 = false;
                case 19
                    nose2 = true;
                case 20
                    nose2 = false;
                case 21
                    nose3 = true;
                case 22
                    nose3 = false;
                case 23
                    nose4 = true;
                case 24
                    nose4 = false;
                case 25
                    nose5 = true;
                case 26
                    nose5 = false;
                case 27
                    foodport = true;
                case 28
                    foodport = false;
                case {33,35}
                    tone = true;
                case {34,36}
                    tone = false;
                case 39
                    gotrial = true;
                case 40
                    gotrial = false;
                otherwise
            end
        end
        
%         if iFrame < 22500
%             iFrame = iFrame + 1;
%             continue;
%         end
        
        frame = readFrame(video);
        frame = imresize(frame,1/videoDimDivider);
        frame = insertShape(frame,'FilledRectangle',[0 0 150 size(frame,1)],'color',[0 0 0],'Opacity',0.5);
        debugString = {sessionConf.sessionName,...
            ['Frame: ',num2str(iFrame)],...
            ['Behavior: ',num2str(round(curEphysTs-behaviorStartTime,3)),'s'],...
            ['Ephys: ',num2str(round(curEphysTs,3)),'s'],...
            ['Sample: ',num2str(round(curEphysTs * sessionConf.Fs))],...
            ['Frame Events: ',num2str(length(frameEvents))]};
        debugPos = zeros(length(debugString),2);
        debugPos(:,2) = linspace(0,length(debugString)*18,length(debugString))';
        frame = insertText(frame,debugPos,debugString,'FontSize',14,'BoxOpacity',0,'TextColor','green');
        
        if cue1
            frame = insertShape(frame,'FilledCircle',[xEventCoords(1) yEventCoords(1) 25]);
        end
        if cue2
            frame = insertShape(frame,'FilledCircle',[xEventCoords(2) yEventCoords(2) 25]);
        end
        if cue3
            frame = insertShape(frame,'FilledCircle',[xEventCoords(3) yEventCoords(3) 25]);
        end
        if cue4
            frame = insertShape(frame,'FilledCircle',[xEventCoords(4) yEventCoords(4) 25]);
        end
        if cue5
            frame = insertShape(frame,'FilledCircle',[xEventCoords(5) yEventCoords(5) 25]);
        end

        if nose1
            frame = insertShape(frame,'FilledCircle',[xEventCoords(1) yEventCoords(1) 15],'Color','blue');
        end
        if nose2
            frame = insertShape(frame,'FilledCircle',[xEventCoords(2) yEventCoords(2) 15],'Color','blue');
        end
        if nose3
            frame = insertShape(frame,'FilledCircle',[xEventCoords(3) yEventCoords(3) 15],'Color','blue');
        end
        if nose4
            frame = insertShape(frame,'FilledCircle',[xEventCoords(4) yEventCoords(4) 15],'Color','blue');
        end
        if nose5
            frame = insertShape(frame,'FilledCircle',[xEventCoords(5) yEventCoords(5) 15],'Color','blue');
        end

        if food
            frame = insertShape(frame,'FilledCircle',[xEventCoords(6) yEventCoords(6) 25]);
        end
        if foodport
            frame = insertShape(frame,'FilledCircle',[xEventCoords(6) yEventCoords(6) 15],'Color','blue');
        end
        if houselight
            frame = insertShape(frame,'FilledCircle',[xEventCoords(7) yEventCoords(7) 25],'Color','red');
        end
        if tone
            frame  = insertText(frame,[size(frame,2)/2 0],'TONE','FontSize',34,'BoxOpacity',0.5);
        end
        
        hVid = subplot(totalSubplots,1,1);
        set(hVid,'Units','pixels');
        imshow(frame,'border','tight');
        colormap(hVid,gray);
        hold on;
        
        curSubplot = 2; % subplot=1 is the video
        hs = []; % subplot handles
        
        for iLfp = 1:length(lfpChannels)
            hs(curSubplot) = subplot(totalSubplots,1,curSubplot);
            tRange = find(t >= curEphysTs - plotHalfWidthSec & t < curEphysTs + plotHalfWidthSec);
            tLin = linspace(-plotHalfWidthSec,plotHalfWidthSec,length(tRange));
            hold on;
            imagesc(tLin,f,squeeze(S(iLfp,tRange,:))');
            plot([0 0],[min(f) max(f)],'k','LineWidth',2);
            set(gca,'YDir','normal');
            axis xy; 
            axis tight;
            colormap(hs(curSubplot),jet);
            caxis([-4.5 65]);
            curSubplot = curSubplot + 1;
        end
        
        for iNeuron = 1:length(neurons)
            hs(curSubplot) = subplot(totalSubplots,1,curSubplot);
            neuronTs = nexStruct.neurons{neurons(iNeuron),1}.timestamps; % [] does this exist?
            neuronTs = neuronTs(neuronTs >= curEphysTs - plotHalfWidthSec & neuronTs < curEphysTs + plotHalfWidthSec) - curEphysTs;
            plotSpikeRaster({neuronTs'},'PlotType','vertline','FigureVisible',FigureVisible);
            xlim([-plotHalfWidthSec plotHalfWidthSec]);
            curSubplot = curSubplot + 1;
        end
        
        % I dont know why formatting has to be separated
        curBottom = 0;
        curSubplot = 2; % subplot=1 is the video
        for iLfp = 1:length(lfpChannels)
            set(hs(curSubplot),'Units','pixels');
            set(hs(curSubplot),'Position',[1+padSubplots curBottom size(frame,2)-2*padSubplots lfpHeight]);
            set(hs(curSubplot), 'XTick', []);
            set(hs(curSubplot),'YTick',linspace(params.fpass(1),params.fpass(2),3));
            subplotAnnotate(padSubplots,curBottom,['Channel ',num2str(lfpChannels(iLfp))]);
            curBottom = curBottom + lfpHeight;
            curSubplot = curSubplot + 1;
        end
        for iNeuron = 1:length(neurons)
            set(hs(curSubplot),'Units','pixels');
            set(hs(curSubplot),'Position',[1+padSubplots curBottom size(frame,2)-2*padSubplots neuronHeight]);
            set(hs(curSubplot),'xaxisLocation','top');
            if iNeuron == length(neurons)
                labels = get(hs(curSubplot),'xTickLabel');
                for iLabel=1:length(labels)
                    labels{iLabel} = [labels{iLabel} 's'];
                end
                set(hs(curSubplot),'xTickLabel',labels);
                set(hs(curSubplot), 'YTick', []);
            else
                set(hs(curSubplot), 'XTick', []);
                set(hs(curSubplot), 'YTick', []);
            end
            subplotAnnotate(padSubplots,curBottom,nexStruct.neurons{neurons(iNeuron),1}.name);
            curBottom = curBottom + neuronHeight;
            curSubplot = curSubplot + 1;
        end
        
        set(hVid,'Position',[1 figureHeight-size(frame,1) size(frame,2) size(frame,1)]);
        
        figFrame = getframe(h);
        writeVideo(newVideo,figFrame);
        clf(h);
        
        delete(findall(gcf,'Tag','subplotAnnotate'));
        iFrame = iFrame + 1;
    end
    
    close(newVideo);
    close(h);
    toc
end

function subplotAnnotate(pad,bottom,subplotString)
    t = annotation('Textbox');
    t.Units = 'pixels';
    t.Margin = 4;
    t.String = strrep(subplotString,'_','-');
    t.Color = 'black';
    t.BackgroundColor = [1 1 1];
    t.FaceAlpha = 0.0;
    t.LineStyle = 'none';
    t.Tag = 'subplotAnnotate';
    t.Position = [pad bottom 200 11];
%     t.FitBoxToText = 'on';
%     t.Position = [pad bottom t.Position(3) 11];
end