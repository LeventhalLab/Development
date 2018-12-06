% see bottom of: /Users/mattgaidica/Documents/MATLAB/LeventhalLab/Development/ChoiceTask/LFPs/Figures/band_powerMRLlines.m
% load('deltaRTcorr_norm.mat');
% load('session_20180925_entrainmentSurrogates.mat', 'eventFieldnames')

doPlot1 = false;
drawPlot1 = false;
doPlot_pMat = false;

doPlot2 = false;

useNeighbor = false;

iEvent = 4;
[RTsorted,RTk] = sort(all_Times,'descend'); % SORTED HIGH RT -> LOW RT
phaseCorr = phaseCorrs_delta{iEvent}(RTk,:);

nBoot = 1000;
nSmooth = 200;
pvalThresh = 0.01;
bootThresh = nBoot * (1-pvalThresh);
rows = 3;
cols = 4;
% nTimes = rows*cols;
nTimes = size(phaseCorr,2);
if doPlot1
    if drawPlot1
        ff(1400,600);
    end
    tp = round(linspace(1,101,nTimes));
    pMat = NaN(nTimes,numel(RTsorted)-1);
    t = linspace(0,1,size(phaseCorr,2));
    MBoot = [];
    for iTime = 1:numel(tp)
        disp([num2str(iTime),'/',num2str(numel(tp))]);
        if useNeighbor
            r = circ_dist(phaseCorr(1:end-1,tp(iTime)),phaseCorr(2:end,tp(iTime)));
        else
            meanPhase = repmat(circ_mean(phaseCorr(:,tp(iTime))),[size(phaseCorr,1)-1,1]);
            r = circ_dist(phaseCorr(1:end-1,tp(iTime)),meanPhase);
        end
        M = movstd(r,nSmooth);

        for iBoot = 1:nBoot
            randIds = randperm(size(phaseCorr,1));
            if useNeighbor
                MBoot(iBoot,:) = movstd(circ_dist(phaseCorr(randIds(1:end-1),tp(iTime)),phaseCorr(2:end,tp(iTime))),nSmooth);
            else
                MBoot(iBoot,:) = movstd(circ_dist(phaseCorr(randIds(1:end-1),tp(iTime)),meanPhase),nSmooth);
            end
        end
        pArr = [];
        for iBoot = 1:nBoot
            pArr(iBoot,:) = M' < MBoot(iBoot,:);
        end
        pMat(iTime,:) = sum(pArr); % sum(pArr) > bootThresh;
        
        if drawPlot1
            subplot(rows,cols,iTime);
            yyaxis left;
            plot(r);
            if useNeighbor
                ylabel('dist (trial_n,trial_{n+1})');
            else
                ylabel('dist (trial_n, mean(trials_{all}))');
            end
            ylim([-4 4]);
            yticks([-pi 0 pi]);
            yticklabels({'-\pi',0,'\pi'});
            yyaxis right;

            plot(M,'lineWidth',2);
            hold on;
            plot(find(sum(pArr) > bootThresh == 1),M(sum(pArr) > bootThresh),'g*','lineWidth',0.5,'MarkerSize',5);
            ylabel(['std x',num2str(nSmooth)]);
            ylim([0 2]);
            yticks([min(ylim):1:max(ylim)]);
            xlim([1 numel(r)]);
            xticklabels(compose('%1.2f',RTsorted(xticks)));
            xlabel('RT');
            title({eventFieldnames{iEvent},['t = ',num2str(t(tp(iTime)),2),'s, ',num2str(tp(iTime)),'/101']});
            drawnow;
        end
    end
    if drawPlot1
        set(gcf,'color','w');
    end
end

if doPlot_pMat
    ff(500,300);
    imagesc(linspace(-1,1,size(pMat,1)),RTsorted,pMat');
    colormap(jet);
    caxis([950 1000]);
    set(gca,'ydir','normal');
    xlabel('Time (s)');
    xticks([-1,0,1]);
    ylabel('RT');
    if useNeighbor
        title([eventFieldnames{iEvent},' from Neighbor']);
    else
        title([eventFieldnames{iEvent},' from Mean']);
    end
    cb = colorbar;
    cb.Label.String = 'p-value';
    cb.Ticks = caxis;
    cb.TickLabels = {'0.05','0.00'};
    cb.Direction = 'reverse';
    grid on;
end

% sort by phase and assess RT correlation
% % midPhases = phaseCorr(:,55);
% % [v,k] = sort(circ_dist(midPhases,repmat(circ_mean(midPhases),size(midPhases))));
% % figure;
% % [rho,pval] = corr(RTsorted(k),v);

if true
    n = 1000;
    t = linspace(0,100,n);
    pd = makedist('Weibull','a',60,'b',5);
    y = pdf(pd,t);
    sig = fliplr(y.*sin(t));
    [env,~] = envelope(sig);
    figure;
    plot(t,sig,'k','lineWidth',2);
    hold on;
    title('RT Wave Function');
    xticks([]);
    xlabel('High   \leftarrow   RT (s)   \rightarrow   Low')
    yticks([0]);
    plot(t,env,'r','lineWidth',2);
    set(gca,'fontSize',16);
    legend({'\psi_{RT}','|\psi_{RT}|^2'},'location','northwest');
    grid on;
    set(gcf,'color','w');
end
    
if doPlot2
    colors = jet(numel(RTk));
    ff(1400,400);
    rows = 1;
    cols = 5;
    tp = round(linspace(1,101,rows*cols));
    t = linspace(-1,1,size(phaseCorr,2));
    for iTime = 1:numel(tp)
        subplot(rows,cols,iTime);
        for iTrial = 1:5:numel(RTk)
            polarplot([0 phaseCorr(iTrial,tp(iTime))],[0 RTsorted(iTrial)],'color',colors(iTrial,:));
            hold on;
        end
        rticks([0.75]);
        rlim([0 .75]);
        rticklabels({'RT = 0.75s'});
        thetaticks([0:90:360]);
        title({eventFieldnames{iEvent},['t = ',num2str(t(tp(iTime)),2),'s, ',num2str(tp(iTime)),'/101']});
        drawnow;
    end
    set(gcf,'color','w');
end