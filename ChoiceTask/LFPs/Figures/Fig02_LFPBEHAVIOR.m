% LFPBEHAVIOR
if ~exist('session_Wz_power')
    load('fig__spectrum_MRL_20181108');
    load('session_20191124.mat')
end
% raw data was compiled with LFP_byX.m (doSetup = true)
freqList = logFreqList([1 200],30);

do_linePlot = false;
do_lineSupp = true;
doLabels = false;

doSave = false;
figPath = '/Users/matt/Box Sync/Leventhal Lab/Manuscripts/Mthal LFPs/Figures';
subplotMargins = [.03 .01];

eventfields = {'Cue','Nose In','Tone','Nose Out','Side In','Side Out','Reward'};
load('zscoreSessions_20200423.mat');
% scaloPower = squeeze(mean(session_Wz_power(:,:,:,:))); % OLD
scaloPower = squeeze(mean(zscoreSessions(:,:,:,:))); % NEW, surrogate method
scaloPhase = squeeze(mean(session_Wz_phase(:,:,:,:)));
scaloRayleigh = squeeze(mean(session_Wz_rayleigh_pval(:,:,:,:)));
t = linspace(-1,1,size(scaloPower,2));

if do_linePlot
    h = ff(1200,500);
    rows = 2;
    cols = 7;
    colors = magma(30);
    hFreq = closest(freqList,9);
    for iEvent = 1:7
        for iFreq = 1:numel(freqList)
            subplot(rows,cols,prc(cols,[1,iEvent]));
            plot(t,smooth(squeeze(scaloPower(iEvent,:,iFreq))),'color',colors(iFreq,:));
            hold on;
        end
%         plot(t,smooth(squeeze(scaloPower(iEvent,:,hFreq))),'color',colors(hFreq,:),'linewidth',3);
        ylim([-3 10]);
        yticks(sort([0 ylim]));
        xticks(sort([0 xlim]));
        grid on;
        title({eventfields{iEvent},'power'},'color','w');
        set(gca,'color','k');
        set(gca,'XColor','w');
        set(gca,'YColor','w');
        if iEvent == 1
            ylabel('Z-score','color','w');
        end
        if iEvent == 7
            cb = colorbar;
            colormap(colors);
            cb.Limits = [0 1];
            cb.Ticks = linspace(0,1,numel(freqList));
            cb.TickLabels = compose('%2.0f',freqList);
            cb.Color = 'w';
        end
        
        for iFreq = 1:numel(freqList)
            subplot(rows,cols,prc(cols,[2,iEvent]));
            plot(t,smooth(squeeze(scaloPhase(iEvent,:,iFreq))),'color',colors(iFreq,:));
            hold on;
        end
%         plot(t,smooth(squeeze(scaloPhase(iEvent,:,hFreq))),'color',colors(hFreq,:),'linewidth',3);
        ylim([0 0.6]);
        yticks(ylim);
        xticks(sort([0 xlim]));
        grid on;
        title('phase','color','w');
        set(gca,'color','k');
        set(gca,'XColor','w');
        set(gca,'YColor','w');
        if iEvent == 1
            ylabel('MRL','color','w');
        end
        if iEvent == 7
            cb = colorbar;
            colormap(colors);
            cb.Limits = [0 1];
            cb.Ticks = linspace(0,1,numel(freqList));
            cb.TickLabels = compose('%2.0f',freqList);
            cb.Color = 'w';
        end
        
        set(gcf,'color','k');
    end
end

if do_lineSupp
    useFreqs = [closest(freqList,2.5),closest(freqList,20),closest(freqList,55),closest(freqList,100)];
    colors = lines(4);
    h = ff(500,350);
    useEvents = [3:4];
    rows = 1;
    cols = numel(useEvents);
    iSubplot = 1;
    for iEvent = useEvents
        subplot_tight(rows,cols,iSubplot,subplotMargins);
        freqCount = 1;
        for iFreq = useFreqs
            plot(t,squeeze(scaloPower(iEvent,:,iFreq)),'color',colors(freqCount,:),...
                'LineWidth',1);
            hold on;
            freqCount = freqCount + 1;
        end
        xlim([min(t) max(t)]);
        xticks(sort([xlim,0]));
        ylim([-3 10]);
        yticks(sort([ylim,0]));
        if ~doLabels
            xticklabels({});
            yticklabels({});
        end
        grid on;
        iSubplot = iSubplot + 1;
    end
    
    tightfig;
    set(gcf,'color','w');
    if doSave
        setFig('','',[1,0.5]);
        print(gcf,'-painters','-depsc',fullfile(figPath,'LFPLINES.eps'));
        close(h);
    end
end

% setup
if true
    scaloPower2 = squeeze(mean(all_Wz_power));
    scaloPhase2 = zeros(size(scaloPower2));
    
    all_rtests = zeros([size(all_Wz_phase,2),size(all_Wz_phase,3),size(all_Wz_phase,4)]);
    for iEvent = 1:size(all_Wz_phase,2)
        for iTime = 1:size(all_Wz_phase,3)
            for iFreq = 1:size(all_Wz_phase,4)
                theseTrials = squeeze(all_Wz_phase(:,iEvent,iTime,iFreq));
                scaloPhase2(iEvent,iTime,iFreq) = circ_r(theseTrials);
                all_rtests(iEvent,iTime,iFreq) = circ_rtest(theseTrials);
            end
        end
    end
    
% % % %     all_ptests = zeros([size(all_Wz_power,2),size(all_Wz_power,3),size(all_Wz_power,4)]);
% % % %     for iEvent = 1:size(all_Wz_power,2)
% % % %         for iTime = 1:size(all_Wz_power,3)
% % % %             for iFreq = 1:size(all_Wz_power,4)
% % % %                 %                 X = rmoutliers(squeeze(all_Wz_power(:,iEvent,iTime,iFreq)));
% % % %                 %                 parmhat = gevfit(X);
% % % %                 thisTrial = squeeze(mean(abs(squeeze(all_Wz_power(:,iEvent,iTime,iFreq)))));
% % % %                 %                 all_ptests(iEvent,iTime,iFreq) = gevcdf(thisTrial,parmhat(1),parmhat(2),parmhat(3));
% % % %                 y = rmoutliers(squeeze(all_Wz_power(:,8,iTime,iFreq)));
% % % %                 %                 theseSurr = abs(y);
% % % %                 if thisTrial > 0
% % % %                     all_ptests(iEvent,iTime,iFreq) = 1 - (sum(thisTrial > y) / numel(y));
% % % %                 else
% % % %                     all_ptests(iEvent,iTime,iFreq) = 1 - (sum(thisTrial < y) / numel(y));
% % % %                 end
% % % %                 
% % % %                 %                 all_ptests(iEvent,iTime,iFreq) = 2*normcdf(-abs(thisTrial));%*size(all_Wz_power,1);
% % % %             end
% % % %         end
% % % %     end
end

rtest = ones(size(all_rtests))*3;
rtest(all_rtests < .05) = 2;
rtest(all_rtests < .01) = 1;
rtest(all_rtests < .001) = 0;

ptest = ones(size(all_ptests))*3;
ptest(all_ptests < .05) = 2;
ptest(all_ptests < .01) = 1;
ptest(all_ptests < .001) = 0;

phaseColors = [0 0 0;1 0 0;0 0 1;1 1 1];
close all
h = ff(1000,650);
rows = 4;
cols = 8;
caxisVals = [-0.5 3];
xmarks = round(logFreqList([1 200],6),0);
usexticks = [];
for ii = 1:numel(xmarks)
    usexticks(ii) = closest(freqList,xmarks(ii));
end

for iEvent = 1:7
    subplot_tight(rows,cols,prc(cols,[1,iEvent]),subplotMargins);
    imagesc(t,1:numel(freqList),squeeze(scaloPower2(iEvent,:,:))');
    hold on;
    colormap(gca,jet);
    caxis(caxisVals);
    xlim([-1 1]);
    xticks(0);
    xticklabels([]);
    yticks(usexticks);
    yticklabels([]);
    plot([0,0],ylim,'k:'); % center line
    set(gca,'YDir','normal');
    
    subplot_tight(rows,cols,prc(cols,[2,iEvent]),subplotMargins);
    imagesc(linspace(-1,1,size(ptest,2)),1:numel(freqList),squeeze(ptest(iEvent,:,:))');
    hold on;
    colormap(gca,phaseColors);
    caxis([0 3]);
    xlim([-1 1]);
    xticks(0);
    xticklabels([]);
    yticks(usexticks);
    yticklabels([]);
    plot([0,0],ylim,'k:'); % center line
    set(gca,'YDir','normal');
    
    subplot_tight(rows,cols,prc(cols,[3,iEvent]),subplotMargins);
    imagesc(linspace(-1,1,size(scaloPhase2,2)),1:numel(freqList),squeeze(scaloPhase2(iEvent,:,:))');
    hold on;
    colormap(gca,hot);
    caxis([0 1]);
    xlim([-1 1]);
    xticks(0);
    xticklabels([]);
    yticks(usexticks);
    yticklabels([]);
    plot([0,0],ylim,'k:'); % center line
    set(gca,'YDir','normal');
    
    subplot_tight(rows,cols,prc(cols,[4,iEvent]),subplotMargins);
    imagesc(linspace(-1,1,size(rtest,2)),1:numel(freqList),squeeze(rtest(iEvent,:,:))');
    hold on;
    colormap(gca,phaseColors);
    caxis([0 3]);
    xlim([-1 1]);
    xticks(0);
    xticklabels([]);
    yticks(usexticks);
    yticklabels([]);
    plot([0,0],ylim,'k:'); % center line
    set(gca,'YDir','normal');
end
tightfig;
setFig('','',[2,3.5]);
if doSave
    print(gcf,'-painters','-depsc',fullfile(figPath,'re_LFPBEHAVIOR.eps'));
    close(h);
end

if doSave
    h = ff(1200,450);
    subplot_tight(rows,cols,7,subplotMargins);
    colormap(gca,jet);
    cb = colorbar;
    cb.Ticks = [];
    
    subplot_tight(rows,cols,14,subplotMargins);
    colormap(gca,hot);
    cb = colorbar;
    cb.Ticks = [];
    if doSave
        print(gcf,'-painters','-depsc',fullfile(figPath,'LFPBEHAVIOR_legends.eps'));
        close(h);
    end
end