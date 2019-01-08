close all;
h = ff(1200,800);
t = linspace(-0.2,0.2,size(W,2));
t2 = linspace(-1,1,size(W2,2));
n = 12;
nBins = 12;
iEvent = 4;
iFreq = 3;
rows = 6;
cols = 3;
colors = lines(n);
plotMap = [1,2,4,5,7,8,10,11,13,14,16,17];

alpha = [];
for iTrial = 1:size(W,3)
    if iTrial <= n
        subplot(rows,cols,plotMap(iTrial));
        plot(t2,angle(W2(iEvent,:,iTrial,iFreq)),'k');
        hold on;
        plot(t,angle(W(iEvent,:,iTrial,iFreq)),'k','lineWidth',4);
        ylim([-4 4]);
        yticks([-pi 0 pi]);
        yticklabels({'-\pi','0','\pi'});
        xlim([-1 1]);
        xticks(sort([0 -.2 .2 xlim]));
        title(['trial ',num2str(iTrial),'/',num2str(size(W,3))]);
        grid on;
        if iTrial >= n - 1
            xlabel('time (s)');
        end
    end    
    useTs = ts(ts > trialRanges(iEvent,iTrial,1) & ts < trialRanges(iEvent,iTrial,2)) - mean(trialRanges(iEvent,iTrial,:));
    for iTs = 1:numel(useTs)
        thisAngle = angle(W(iEvent,closest(t,useTs(iTs)),iTrial,iFreq));
        alpha = [alpha;thisAngle];
        if iTrial <= n
            % line plots
            subplot(rows,cols,plotMap(iTrial));
            plot([useTs(iTs) useTs(iTs)],[-pi pi],'color',colors(iTrial,:));
            ln = plot(useTs(iTs),thisAngle,'o','color',colors(iTrial,:));
            % polar plot
            subplot(rows,cols,[3,6]);
            polarplot(thisAngle,1,'o','color',colors(iTrial,:));
            hold on;
        else
            polarplot(thisAngle,1,'.','color','k');
        end
    end
end
r = circ_r(alpha);
mu = circ_mean(alpha);
subplot(rows,cols,[3,6]);
polarplot([mu mu],[0 r],'color','k','linewidth',4);
p = gca;
rlim([0 1]);
p.RTick = rlim;
p.ThetaTick = [0 90 180 270];

subplot(rows,cols,[9,12]);
hp = polarhistogram(alpha,nBins,'FaceColor','k');
p = gca;
p.RTick = rlim;
p.ThetaTick = [0 90 180 270];

subplot(rows,cols,[15,18]);
counts = histcounts(alpha,'BinEdges',hp.BinEdges);
bar([counts counts],'k');
xticks(linspace(1,24,9));
xticklabels([180 270 0 90 180 270 0 90 180]);
yticks(ylim);
ylabel('count');
xtickangle(270);
grid on;

set(gcf,'color','w');