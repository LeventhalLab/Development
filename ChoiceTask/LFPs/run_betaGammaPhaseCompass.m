subject__names = {'R0088','R0117','R0142','R0154','R0182'};
subject__files = {'/Users/mattgaidica/Documents/Data/ChoiceTask/R0088/R0088-rawdata/R0088_20151102a/R0088_20151102a/R0088_20151102_R0088_20151102-1_data_ch42.sev',...
    '/Users/mattgaidica/Documents/Data/ChoiceTask/R0117/R0117-rawdata/R0117_20160504a/R0117_20160504a/R0117_20160504a_R0117_20160504a-2_data_ch93.sev',...
    '/Users/mattgaidica/Documents/Data/ChoiceTask/R0142/R0142-rawdata/R0142_20161207a/R0142_20161207a/R0142_20161207a_R0142_20161207a-1_data_ch42.sev',...
    '/Users/mattgaidica/Documents/Data/ChoiceTask/R0154/R0154-rawdata/R0154_20170227a/R0154_20170227a/R0154_20170227a_R0154_20170227a-1_data_ch41.sev',...
    '/Users/mattgaidica/Documents/Data/ChoiceTask/R0182/R0182-rawdata/R0182_20170723a/R0182_20170723a/R0182_20170723a_R0182_20170723a-1_data_ch2.sev'};

subject__logs = {'/Users/mattgaidica/Documents/Data/ChoiceTask/R0088/R0088-rawdata/R0088_20151102a/R0088_20151102_13-59-02.log',...
    '/Users/mattgaidica/Documents/Data/ChoiceTask/R0117/R0117-rawdata/R0117_20160504a/R0117_20160504_15-19-54.log',...
    '/Users/mattgaidica/Documents/Data/ChoiceTask/R0142/R0142-rawdata/R0142_20161207a/R0142_20161206_13-37-13.log',...
    '/Users/mattgaidica/Documents/Data/ChoiceTask/R0154/R0154-rawdata/R0154_20170227a/R0154_20170227_15-37-29.log',...
    '/Users/mattgaidica/Documents/Data/ChoiceTask/R0182/R0182-rawdata/R0182_20170723a/R0182_20170723_10-07-55.log'};

subject__nexFiles = {'/Users/mattgaidica/Documents/Data/ChoiceTask/R0088/R0088-processed/R0088_20151102a/R0088_20151102a_finished/R0088_20151102a.nex.mat',...
    '/Users/mattgaidica/Documents/Data/ChoiceTask/R0117/R0117-processed/R0117_20160504a/R0117_20160504a_finished/R0117_20160504a.nex.mat',...
    '/Users/mattgaidica/Documents/Data/ChoiceTask/R0142/R0142-processed/R0142_20161207a/R0142_20161207a_finished/R0142_20161207a.nex.mat',...
    '/Users/mattgaidica/Documents/Data/ChoiceTask/R0154/R0154-processed/R0154_20170227a/R0154_20170227a_finished/R0154_20170227a.nex.mat',...
    '/Users/mattgaidica/Documents/Data/ChoiceTask/R0182/R0182-processed/R0182_20170723a/R0182_20170723a_finished/R0182_20170723a.nex.mat'};

% setup
doSetup = true;
doVideo = true;

for iSubject = 5
    if doSetup
        fpass = [10 60];
        nFreqs = 30;
        freqList = logFreqList(fpass,nFreqs);
        decimateFactor = 10;
        timingField = 'RT';
        tWindow = 2;
        eventFieldnames = {'cueOn';'centerIn';'tone';'centerOut';'sideIn';'sideOut';'foodRetrieval'};
        
        disp(['Working on ',subject__names{iSubject}]);
        sevFile = subject__files{iSubject};
        [sev, header] = read_tdt_sev(sevFile);
        sevFilt = decimate(double(sev),decimateFactor);
        Fs = header.Fs / decimateFactor;
        load(subject__nexFiles{iSubject});
        logData = readLogData(subject__logs{iSubject});
        if strcmp(subject__names{iSubject},'R0154')
            nexStruct = fixMissingEvents(logData,nexStruct);
        end
        trials = createTrialsStruct_simpleChoice(logData,nexStruct);
        [trialIds,allTimes] = sortTrialsBy(trials,timingField); % forces to be 'correct'

        % compute
        allW = eventsLFP(trials(trialIds),sevFilt,tWindow,Fs,freqList,eventFieldnames);
        t = linspace(-tWindow,tWindow,size(allW,2));
    end

    iEvent = 3;
    betaIdx = closest(freqList,20);
    gammaIdx = closest(freqList,50);
    bandIdxs = [gammaIdx betaIdx];

    vis_tWindow = 0.2;
    t1Idx = closest(t,-vis_tWindow);
    t2Idx = closest(t,vis_tWindow);
    h = figuree(800,400);
    fontSize = 12;
    pLim = 0.01;

    if doVideo
        savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/betaGammaVideo';
        newVideo = VideoWriter(fullfile(savePath,[subject__names{iSubject},'_',datestr(now,'yyyymmdd-HHMMSS') '_betaGammaPhase']),'MPEG-4');
        newVideo.Quality = 100;
        open(newVideo);
    end

    Z = {};
    Zmean = {};
    rows = 2;
    cols = 7;
    iFrame = 1;
    for itx = t1Idx:t2Idx
        iSubplot = 1;
        for iEvent = 1:cols
            for iBand = 1:rows
                U = [];
                V = [];
                all_angles = [];
                for iTrial = 1:size(allW,3)
                    cur_angle = angle(allW(iEvent,itx,iTrial,bandIdxs(iBand)));
                    all_angles(iTrial) = cur_angle;
                    [U(iTrial), V(iTrial)] = pol2cart(cur_angle,1);
                end

                subplot(rows,cols,((cols*iBand)-cols)+iEvent);

                Z{iSubplot} = compass(U,V);
                thetaticks([0 90 180 270])
                thetaticklabels({'0','\pi/2','\pi','3\pi2'})
                modZ = Z{iSubplot};
                
                filename = '/Users/mattgaidica/Documents/MATLAB/LeventhalLab/Development/ChoiceTask/LFPs/utils/stoplight.jpg';
                colors = mycmap(filename,length(modZ));
                for ii=1:length(modZ)
                    modZ(ii).Color = colors(ii,:);
                    modZ(ii).LineWidth = 0.5;
                end
                hold on;

                Zmean{iSubplot} = compass(mean(U),mean(V));
                modZmean = Zmean{iSubplot};
                modZmean(1).Color = 'k';
                modZmean(1).LineWidth = 2;

                p = circ_rtest(all_angles);
                fontColor = 'k';
                if p < pLim
                    fontColor = 'r';
                end
                if iBand == 1
                    title({num2str(t(itx),'%1.3f'),eventFieldnames{iEvent},['\gamma p=',num2str(p,'%1.3f')]},'FontSize',fontSize,'color',fontColor);
                else
                    title({['\beta p=',num2str(p,'%1.3f')]},'FontSize',fontSize,'color',fontColor);
                end

                iSubplot = iSubplot + 1;
            end
        end
        set(gcf,'color','w');

        if doVideo
            F = getframe(h);
            disp(['Writing frame ',num2str(iFrame),'/',num2str(numel(t1Idx:t2Idx))]);
            iFrame = iFrame + 1;
            writeVideo(newVideo,F);
        end

        for ii=1:length(Z)
            delete(Z{ii});
            delete(Zmean{ii});
        end
    end
    if doVideo
        close(h);
        close(newVideo);
    end
end