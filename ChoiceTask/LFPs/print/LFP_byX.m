doSetup = false;
zThresh = 2;
tWindow = 1;
freqList = logFreqList([1 200],30);
Wlength = 200;

if doSetup
    session_Wz_power = [];
    session_Wz_phase = [];
    iSession = 0;
    for iNeuron = selectedLFPFiles'
        iSession = iSession + 1;
        sevFile = LFPfiles_local{iNeuron};
        disp(sevFile);
        [~,name,~] = fileparts(sevFile);
        subjectName = name(1:5);
        curTrials = all_trials{iNeuron};
        [trialIds,allTimes] = sortTrialsBy(curTrials,'RT');
        [sevFilt,Fs,decimateFactor] = loadCompressedSEV(sevFile);
        W = eventsLFPv2(curTrials(trialIds),sevFilt,tWindow,Fs,freqList,eventFieldnames);
        [Wz_power,Wz_phase] = zScoreW(W,Wlength); % power Z-score
        [Wz_power,keepTrials] = removeWzTrials(Wz_power,zThresh);
        Wz_phase = Wz_phase(:,:,keepTrials,:);
        session_Wz_power(iSession,:,:,:) = squeeze(mean(Wz_power,3));
        session_Wz_phase(iSession,:,:,:) = squeeze(circ_r(Wz_phase,[],[],3));
    end
end

if false
    savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/perievent/LFP/bySession';
    for iSession = 1:size(session_Wz_power,1)
        sevFile = LFPfiles_local{selectedLFPFiles(iSession)};
        [~,name,~] = fileparts(sevFile);
        subjectName = name(1:5);
        saveFile = [subjectName,'_session',num2str(iSession,'%02d')];
        scaloPower = squeeze(session_Wz_power(iSession,:,:,:));
        scaloPhase = squeeze(session_Wz_phase(iSession,:,:,:));
        plotLFPandMRL(scaloPower,scaloPhase,savePath,saveFile,freqList,eventFieldnames);
    end
end

if false
    savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/perievent/LFP/bySubject';
    subjects = {'R0088','R0117','R0142','R0154','R0182'};
    subjectSessions = [1 4;5 11;12 24;25 29;30 30];
    for iSubject = 1:numel(subjects)
        sevFile = LFPfiles_local{selectedLFPFiles(iSession)};
        [~,name,~] = fileparts(sevFile);
        subjectName = name(1:5);
        saveFile = [subjectName,'_session',num2str(subjectSessions(iSubject,1),'%02d'),'-',...
            num2str(subjectSessions(iSubject,2),'%02d')];
        if subjectSessions(iSubject,1) < subjectSessions(iSubject,2)
            scaloPower = squeeze(mean(session_Wz_power(subjectSessions(iSubject,1):subjectSessions(iSubject,2),:,:,:)));
            scaloPhase = squeeze(mean(session_Wz_phase(subjectSessions(iSubject,1):subjectSessions(iSubject,2),:,:,:)));
        else
            scaloPower = squeeze(session_Wz_power(subjectSessions(iSubject,1):subjectSessions(iSubject,2),:,:,:));
            scaloPhase = squeeze(session_Wz_phase(subjectSessions(iSubject,1):subjectSessions(iSubject,2),:,:,:));
        end
        plotLFPandMRL(scaloPower,scaloPhase,savePath,saveFile,freqList,eventFieldnames);
    end
end

if true
    savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/perievent/LFP/allSessions';
    saveFile = 'allSubject_allSessions';
    scaloPower = squeeze(mean(session_Wz_power(:,:,:,:)));
    scaloPhase = squeeze(mean(session_Wz_phase(:,:,:,:)));
    plotLFPandMRL(scaloPower,scaloPhase,savePath,saveFile,freqList,eventFieldnames);

end

function plotLFPandMRL(scaloPower,scaloPhase,savePath,saveFile,freqList,eventFieldnames)
    cmapPath = '/Users/mattgaidica/Documents/MATLAB/LeventhalLab/Development/ChoiceTask/LFPs/utils/corr_colormap.jpg';
    cmap = mycmap(cmapPath);    
    ytickIds = [1 closest(freqList,20) closest(freqList,55) numel(freqList)]; % selected from freqList
    ytickLabelText = freqList(ytickIds);
    ytickLabelText = num2str(ytickLabelText(:),'%3.0f');    
    h = figuree(1300,500);
    rows = 2;
    cols = 7;
    gridColor = repmat(.7,[1,3]);
    for iEvent = 1:7
        subplot(rows,cols,prc(cols,[1,iEvent]));
        imagesc(linspace(-1,1,size(scaloPower,2)),1:numel(freqList),squeeze(scaloPower(iEvent,:,:))');
        colormap(gca,jet);
        caxis([-3 3]);
        xlim([-1 1]);
        xticks(sort([0 xlim]));
        yticks(ytickIds);
        yticklabels(ytickLabelText);
        set(gca,'YDir','normal');
        grid on;
        if iEvent == 1
            title({saveFile,eventFieldnames{iEvent}},'interpreter','none');
        else
            title({'',eventFieldnames{iEvent}});
        end
        if iEvent == 7
            cb = colorbar('Location','east');
            cb.Ticks = caxis;
            cb.Label.String = 'z power'; % !! label
            cb.Color = 'k';
        end
        
        subplot(rows,cols,prc(cols,[2,iEvent]));
        imagesc(linspace(-1,1,size(scaloPhase,2)),1:numel(freqList),squeeze(scaloPhase(iEvent,:,:))');
        colormap(gca,hot);
        caxis([0 1]);
        xlim([-1 1]);
        xticks(sort([0 xlim]));
        yticks(ytickIds);
        yticklabels(ytickLabelText);
        set(gca,'YDir','normal');
        grid on;
        set(gca,'GridColor',gridColor);
        if iEvent == 7
            cb = colorbar('Location','east');
            cb.Ticks = caxis;
            cb.Label.String = 'MRL'; % !! label
            cb.Color = 'w';
        end
    end
    set(gcf,'color','w');
    saveas(h,fullfile(savePath,[saveFile,'.png']));
    close(h);
end