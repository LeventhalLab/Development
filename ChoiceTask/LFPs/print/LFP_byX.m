doSetup = false;
zThresh = 2;
tWindow = 2;
freqList = logFreqList([1 200],10);
Wlength = 400;

if doSetup
    session_Wz_power = [];
    session_Wz_phase = [];
    session_Wz_rayleigh_pval = [];
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
        
        for iEvent = 1:size(Wz_phase,1)
            for iBin = 1:size(Wz_phase,2)
                for iFreq = 1:size(Wz_phase,4)
                    alpha = squeeze(Wz_phase(iEvent,iBin,:,iFreq));
                    [pval,rho] = circ_rtest(alpha);
                    session_Wz_rayleigh_pval(iSession,iEvent,iBin,iFreq) = pval;
                end
            end
        end
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
        scaloRayleigh = squeeze(session_Wz_rayleigh_pval(iSession,:,:,:));
        plotLFPandMRLandRayleigh(scaloPower,scaloPhase,scaloRayleigh,savePath,saveFile,freqList,eventFieldnames);
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
            scaloRayleigh = squeeze(mean(session_Wz_rayleigh_pval(subjectSessions(iSubject,1):subjectSessions(iSubject,2),:,:,:)));
        else
            scaloPower = squeeze(session_Wz_power(subjectSessions(iSubject,1):subjectSessions(iSubject,2),:,:,:));
            scaloPhase = squeeze(session_Wz_phase(subjectSessions(iSubject,1):subjectSessions(iSubject,2),:,:,:));
            scaloRayleigh = squeeze(session_Wz_rayleigh_pval(subjectSessions(iSubject,1):subjectSessions(iSubject,2),:,:,:));
        end
        plotLFPandMRLandRayleigh(scaloPower,scaloPhase,scaloRayleigh,savePath,saveFile,freqList,eventFieldnames);
    end
end

if true
    savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/perievent/LFP/allSessions';
    saveFile = 'allSubject_allSessions';
    scaloPower = squeeze(mean(session_Wz_power(:,:,:,:)));
    scaloPhase = squeeze(mean(session_Wz_phase(:,:,:,:)));
    scaloRayleigh = squeeze(mean(session_Wz_rayleigh_pval(:,:,:,:)));
    plotLFPandMRLandRayleigh(scaloPower,scaloPhase,scaloRayleigh,savePath,saveFile,freqList,eventFieldnames);
end

function plotLFPandMRLandRayleigh(scaloPower,scaloPhase,scaloRayleigh,savePath,saveFile,freqList,eventFieldnames)
    cmapPath = '/Users/mattgaidica/Documents/MATLAB/LeventhalLab/Development/ChoiceTask/LFPs/utils/corr_colormap.jpg';
    cmap = mycmap(cmapPath);    
    ytickLabelText = num2str(freqList(:),'%3.1f');    
    h = figuree(1300,700);
    rows = 3;
    cols = 7;
    gridColor = repmat(.7,[1,3]);
    for iEvent = 1:7
        subplot(rows,cols,prc(cols,[1,iEvent]));
        imagesc(linspace(-2,2,size(scaloPower,2)),1:numel(freqList),squeeze(scaloPower(iEvent,:,:))');
        colormap(gca,jet);
        caxis([-3 3]);
        xlim([-1 1]);
        xticks(sort([0 xlim]));
        yticks(1:numel(freqList));
        yticklabels(ytickLabelText);
        set(gca,'YDir','normal');
        grid on;
        if iEvent == 1
            title({saveFile,eventFieldnames{iEvent}},'interpreter','none');
        else
            title({'',eventFieldnames{iEvent}});
        end
        if iEvent == 7
            cbAside(gca,'z power','k');
        end
        
        subplot(rows,cols,prc(cols,[2,iEvent]));
        imagesc(linspace(-2,2,size(scaloPhase,2)),1:numel(freqList),squeeze(scaloPhase(iEvent,:,:))');
        colormap(gca,gray);
        caxis([0 0.5]);
        xlim([-1 1]);
        xticks(sort([0 xlim]));
        yticks(1:numel(freqList));
        yticklabels(ytickLabelText);
        set(gca,'YDir','normal');
        grid on;
        set(gca,'GridColor',gridColor);
        if iEvent == 7
            cbAside(gca,'MRL','k');
        end

        subplot(rows,cols,prc(cols,[3,iEvent]));
        imagesc(linspace(-2,2,size(scaloRayleigh,2)),1:numel(freqList),squeeze(scaloRayleigh(iEvent,:,:))');
        colormap(gca,hot);
        caxis([0 0.2]);
        xlim([-1 1]);
        xticks(sort([0 xlim]));
        yticks(1:numel(freqList));
        yticklabels(ytickLabelText);
        set(gca,'YDir','normal');
        grid on;
        set(gca,'GridColor',gridColor);
        if iEvent == 7
            cbAside(gca,'Rayleigh pval','k');
        end
    end
    set(gcf,'color','w');
    saveas(h,fullfile(savePath,[saveFile,'.png']));
    close(h);
end