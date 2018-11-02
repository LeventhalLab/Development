doSetup = false;
zThresh = 2;
tWindow = 1;
freqList = logFreqList([2 200],30);
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
        [sevFilt,Fs,decimateFactor] = loadCompressedSEV(sevFile,[]);
        [W,all_data] = eventsLFPv2(curTrials(trialIds),sevFilt,tWindow,Fs,freqList,eventFieldnames);
        keepTrials = threshTrialData(all_data,zThresh);
        W = W(:,:,keepTrials,:);
        
        [Wz_power,Wz_phase] = zScoreW(W,Wlength); % power Z-score

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

% delta MRL envelope
if false
    scaloPower = squeeze(mean(session_Wz_power(:,:,:,:)));
    scaloPhase = squeeze(mean(session_Wz_phase(:,:,:,:)));
    h = figuree(1400,300);
    for iEvent = 1:7
        subplot(1,7,iEvent);
        yyaxis left;
        iFreq = 2;
        REF = squeeze(scaloPower(4,:,selectFreqs(iFreq)));
        plot(normalize2(squeeze(scaloPower(iEvent,:,selectFreqs(iFreq))),REF),'-','color',colors(iFreq,:),'lineWidth',2);
        hold on;
        iFreq = 1;
        REF = squeeze(scaloPower(4,:,selectFreqs(iFreq)));
        plot(normalize2(squeeze(scaloPower(iEvent,:,selectFreqs(iFreq))),REF),':','color',colors(iFreq,:),'lineWidth',1);
        ylim([0 1]);
        yticks(ylim);
        if iEvent == 1
            ylabel('normalized units');
        end
        yyaxis right;
% %         MRLZ = (squeeze(scaloPhase(iEvent,:,selectFreqs(iFreq))) - mean(squeeze(scaloPhase(1,:,selectFreqs(iFreq)))))...
% %             ./  std(squeeze(scaloPhase(1,:,selectFreqs(iFreq))));
        REF = squeeze(scaloPhase(4,:,selectFreqs(iFreq)));
        plot(normalize2(squeeze(scaloPhase(iEvent,:,selectFreqs(iFreq))),REF),'-','color',colors(iFreq,:),'lineWidth',2);
        title(eventFieldnames{iEvent});
        ylim([0 1]);
        yticks(ylim);
        if iEvent == 7
            legend('Beta Power','Delta Power','Delta MRL');
        end
        
    end
    set(gcf,'color','w');
    if true
        savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/perievent/LFP/allSessions';
        saveas(h,fullfile(savePath,'betaPowerDeltaMRLEnvelope.png'));
        close(h);
    end
end

% for phase of trials
% iNeuron = 148;
if false
    figuree(500,250);
    subplot(121);
    imagesc(squeeze(Wz_phase(3,100:300-1,:,2))');
    cmap_phase = cmocean('phase');
    colormap(gca,cmap_phase);
    caxis([-pi pi]);
    colorbar;
    title('\delta Phase at Tone');
    ylabel('trials');
    yticks([]);
    xlabel('time (s)');
    xticks([1 100 200]);
    xticklabels({'-1','0','1'});
    subplot(122);
    imagesc(squeeze(Wz_phase(4,100:300-1,:,2))');
    cmap_phase = cmocean('phase');
    colormap(gca,cmap_phase);
    caxis([-pi pi]);
    colorbar;
    title('\delta Phase at Nose Out');
    ylabel('trials');
    yticks([]);
    xlabel('time (s)');
    xticks([1 100 200]);
    xticklabels({'-1','0','1'});
    set(gcf,'color','w');
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
    scaloPower = squeeze(median(session_Wz_power(:,:,:,:)));
    scaloPhase = squeeze(median(session_Wz_phase(:,:,:,:)));
    scaloRayleigh = squeeze(median(session_Wz_rayleigh_pval(:,:,:,:)));
    plotLFPandMRLandRayleigh(scaloPower,scaloPhase,scaloRayleigh,savePath,saveFile,freqList,eventFieldnames);
end

if false
    scaloPower = squeeze(mean(session_Wz_power(:,:,100:300-1,:)));
    scaloPhase = squeeze(mean(session_Wz_phase(:,:,100:300-1,:)));
    savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/perievent/LFP/allSessions';
    selectFreqs = [2,6,7,8];
    freqLabels = {'\delta','\beta','\gamma_L','\gamma_H'};
    rows = 2;
    cols = 7;
    h = figuree(1400,400);
    for iEvent = 1:7
% %         iEvent = iCol + 2;
        subplot(rows,cols,prc(cols,[1 iEvent]));
        colors = lines(numel(selectFreqs));
        for iFreq = 1:numel(selectFreqs)
            plot(squeeze(scaloPower(iEvent,:,selectFreqs(iFreq))),'color',colors(iFreq,:),'lineWidth',2);
            hold on;
        end
        xlim([1 size(scaloPower,2)]);
        xticks([1 round(size(scaloPower,2)/2) size(scaloPower,2)]);
        xticklabels({'-1','0','1'});
        xlabel('Time (s)');
        ylim([-0.5 2]);
        yticks(sort([ylim,0]));
        if iEvent == 1
            ylabel('LFP Power Z-score');
        end
        grid on;
% %         legend(freqLabels);
        title(['Power at ',eventFieldnames{iEvent}]);
    %     set(gcf,'color','w');
    %     saveFile = 'allSubject_allSessions_Power_freqBands';
    %     saveas(h,fullfile(savePath,[saveFile,'.png']));
    %     close(h);
        subplot(rows,cols,prc(cols,[2 iEvent]));
        for iFreq = 1:numel(selectFreqs)
            MRLZ = (squeeze(scaloPhase(iEvent,:,selectFreqs(iFreq))) - mean(squeeze(scaloPhase(1,:,selectFreqs(iFreq))))) ...
                ./  std(squeeze(scaloPhase(1,:,selectFreqs(iFreq))));
            plot(MRLZ,'color',colors(iFreq,:),'lineWidth',2);
            hold on;
        end
        xlim([1 size(scaloPower,2)]);
        xticks([1 round(size(scaloPower,2)/2) size(scaloPower,2)]);
        xticklabels({'-1','0','1'});
        xlabel('Time (s)');
        ylim([-5 20]);
        yticks(sort([ylim,0]));
        if iEvent == 1
            ylabel('LFP MRL Z-score');
        end
        grid on;
        if iEvent == 7
            legend(freqLabels);
        end
        title(['MRL at ',eventFieldnames{iEvent}]);
    end
    set(gcf,'color','w');
    saveFile = 'allSubject_allSessions_PowerAndMRL_freqBands';
    saveas(h,fullfile(savePath,[saveFile,'.png']));
    close(h);
end

if false
    scaloPower = squeeze(mean(session_Wz_power(:,:,:,:)));
    scaloPhase = squeeze(mean(session_Wz_phase(:,:,:,:)));
    colors = lines(4);
    savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/perievent/LFP/allSessions';
    selectFreqs = [2,6,7,8];
    freqLabels = {'\delta','\beta','\gamma_L','\gamma_H'};
    iEvent = 3;
    h = figuree(800,200);
    rows = 1;
    cols = numel(selectFreqs);
    for iFreq = 1:numel(selectFreqs)
        subplot(rows,cols,iFreq);
        yyaxis left;
        plot(squeeze(scaloPower(iEvent,:,selectFreqs(iFreq))),'lineWidth',2);
        ylim([-0.5 2]);
        yticks(sort([ylim 0]));
        ylabel('Power');
        hold on;
        yyaxis right;
        plot(squeeze(scaloPhase(iEvent,:,selectFreqs(iFreq))) - mean(squeeze(scaloPhase(1,:,selectFreqs(iFreq)))),'lineWidth',2);
        ylim([-0.05 0.4]);
        yticks(sort([ylim 0]));
        ylabel('MRL');
        title(freqLabels{iFreq});
    end
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
        imagesc(linspace(-1,1,size(scaloPower,2)),1:numel(freqList),squeeze(scaloPower(iEvent,:,:))');
        colormap(gca,jet);
        caxis([-2 2]);
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
        imagesc(linspace(-1,1,size(scaloPhase,2)),1:numel(freqList),squeeze(scaloPhase(iEvent,:,:))');
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
        imagesc(linspace(-1,1,size(scaloRayleigh,2)),1:numel(freqList),squeeze(scaloRayleigh(iEvent,:,:))');
        colormap(gca,hot);
        caxis([0 0.05]);
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