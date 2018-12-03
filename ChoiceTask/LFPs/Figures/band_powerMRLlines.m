% load('fig__spectrum_MRL_20181108');
% load('deltaRTcorr_norm.mat');

% copied setup from LFP_byX.m, using band freqList here
doSetup = false;
zThresh = 5;
tWindow = 1;
freqList = {[1 4;4 8;13 30;30 70;70 200]};
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

%         session_Wz_power(iSession,:,:,:) = squeeze(mean(Wz_power,3));
        session_Wz_power(iSession,:,:,:) = squeeze(median(Wz_power,3));
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

doSave = false;
figPath = '/Users/mattgaidica/Box Sync/Leventhal Lab/Manuscripts/Mthal LFPs/Figures';
subplotMargins = [.05 .02];

scaloPower = squeeze(median(session_Wz_power(:,:,:,:)));
scaloPhase = squeeze(median(session_Wz_phase(:,:,:,:)));
scaloRayleigh = squeeze(median(session_Wz_rayleigh_pval(:,:,:,:)));

h = ff(600,900);
rows = 4;
cols = 2;

% useFreqs = [1 4;4 7;13 30;30 70];
nSmooth = Wlength / 20;
bandLabels = {'\delta','\theta','\beta','\gamma'};
colors = lines(10);
lineWidth = 1;
phaseMap = cmocean('phase');
for iEvent = 3:4
    subplot_tight(rows,cols,prc(cols,[1 iEvent-2]),subplotMargins);
    for iFreq = 1:5
%         useRange = closest(freqList,useFreqs(iFreq,1)):closest(freqList,useFreqs(iFreq,2));
%         data = mean(squeeze(scaloPower(iEvent,:,useRange)),2);
        data = smooth(squeeze(scaloPower(iEvent,:,iFreq)),nSmooth);
        plot(linspace(-1,1,size(scaloPower,2)),data,'color',colors(iFreq,:),'lineWidth',lineWidth);
        hold on;
    end
    xticks(0);
    xticklabels([]);
    ylim([-0.75 0.75]);
    yticks(0);
    yticklabels([]);
    grid on;
    
    subplot_tight(rows,cols,prc(cols,[2 iEvent-2]),subplotMargins);
    for iFreq = 1:5
%         useRange = closest(freqList,useFreqs(iFreq,1)):closest(freqList,useFreqs(iFreq,2));
%         data = mean(squeeze(scaloPhase(iEvent,:,useRange)),2);
        data = smooth(squeeze(scaloPhase(iEvent,:,iFreq)),nSmooth);
        plot(linspace(-1,1,size(scaloPhase,2)),data,'color',colors(iFreq,:),'lineWidth',lineWidth);
        hold on;
    end
    xticks(0);
    xticklabels([]);
    ylim([0 1]);
    yticks(0);
    yticklabels([]);
    grid on;
    
% %     if iEvent == 3
% %         legend(bandLabels,'location','northeast','fontSize',6,'fontName','helvetica');
% %         legend boxoff;
% %     end
    
    subplot_tight(rows,cols,[iEvent+2 iEvent+4],[.1 .02]);
    [v,k] = sort(all_Times);
    phaseCorr = phaseCorrs_delta{iEvent};
    imagesc(linspace(-1,1,size(phaseCorr,2)),1:size(phaseCorr,1),phaseCorr(k,:));
    colormap(gca,parula);
    caxis([-pi pi]);
    xticks(0);
    xticklabels([]);
    yticks([]);
    ylim([1 size(phaseCorr,1)]);
    grid on;
    hold on;
    if iEvent == 3
        plot(v,1:numel(v),'k','lineWidth',1); % plot RT
    else
        plot(-v,1:numel(v),'k','lineWidth',1); % plot RT
    end
end

tightfig;
setFig('','',[1,1]);
if doSave
    print(gcf,'-painters','-depsc',fullfile(figPath,'band_powerMRLlines.eps'));
    close(h);

    h = ff(200,400);
    colormap(gca,parula);
    cb = colorbar;
    cb.Ticks = [];
    set(cb,'YAxisLocation','bottom');
    set(cb,'location','southoutside');
    setFig('','',[1,1]);
    print(gcf,'-painters','-depsc',fullfile(figPath,'band_powerMRLlines_colorbar.eps'));
    close(h);
end