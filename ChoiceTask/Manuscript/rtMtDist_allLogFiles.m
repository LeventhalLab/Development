logPaths = {'/Volumes/RecordingsLeventhal2/ChoiceTask/R0088',...
    '/Volumes/RecordingsLeventhal2/ChoiceTask/R0117',...
    '/Volumes/RecordingsLeventhal2/ChoiceTask/R0142',...
    '/Volumes/RecordingsLeventhal2/ChoiceTask/R0154',...
    '/Volumes/RecordingsLeventhal2/ChoiceTask/R0182'};

if false
    all_RT = [];
    all_MT = [];
    all_pretone = [];
    allLog_RT = {};
    allLog_MT = {};
    iSession = 1;
    for iPath = 1:numel(logPaths)
        disp(logPaths{iPath});
        d = dir2(logPaths{iPath},'-r','*.log');
        for iFile = 1:numel(d)
            if ~strcmp(d(iFile).name(end-6:end),'old.log')
                logFile = fullfile(logPaths{iPath},d(iFile).name);
                logData = readLogData(logFile);
                if isfield(logData,'outcome')
                    corrIdx = find(logData.outcome == 0);
                    if (numel(corrIdx) / numel(logData.outcome)) > 0.5
                        RTs = logData.RT(corrIdx);
                        MTs = logData.MT(corrIdx);
                        pretones = logData.pretone(corrIdx);
                        validIdxs = find(RTs > 0 & RTs < 1 & MTs > 0 & MTs < 1);
                        if ~isempty(validIdxs)
                            allLog_RT{iSession} = RTs(validIdxs);
                            allLog_MT{iSession} = MTs(validIdxs);
                            all_RT = [all_RT;RTs(validIdxs)];
                            all_MT = [all_MT;MTs(validIdxs)];
                            all_pretone = [all_pretone;pretones(validIdxs)];
                            iSession = iSession + 1;
                        end
                    end
                end
            end
        end
    end
end

% color scatter
if false
    p_opacity = 0.05;
    colors = lines(numel(allLog_RT));
    nBins = 50;
    figure;
    subplot(4,4,[2 3 4 6 7 8 10 11 12]);
    for iSession = 1:numel(allLog_RT)
        plot(allLog_RT{iSession},allLog_MT{iSession},'.','MarkerSize',5,'color',colors(iSession,:));
        hold on;
    end
    xlabel('RT (s)');
    ylabel('MT (s)');
    xlim([0 1]);
    xticks([0:0.2:1]);
    ylim([0 1]);
    yticks([0:0.2:1]);
    
    subplot(4,4,[1 5 9]);
    h = histogram(all_MT,nBins);
    barh(h.BinEdges(1:end-1),h.Values/numel(all_MT),'FaceColor','k');
    hold on;
    p_lower = prctile(all_MT,5);
    p_upper = prctile(all_MT,95);
    patch('XData',[0 0 1 1],'YData',[0 p_lower p_lower 0],'FaceColor','k','FaceAlpha',p_opacity,'EdgeColor','none');
    patch('XData',[0 0 1 1],'YData',[p_upper 1 1 p_upper],'FaceColor','k','FaceAlpha',p_opacity,'EdgeColor','none');
    set(gca,'xdir','reverse');
    set(gca,'YTick',[]);
    xlabel({'Fraction of trials',['(n = ',num2str(numel(all_MT)),')']});
    ylim([0 1]);
    xlim([0 0.2]);
    
    subplot(4,4,[14 15 16]);
    h = histogram(all_RT,nBins);
    bar(h.BinEdges(1:end-1),h.Values/numel(all_RT),'FaceColor','k');
    hold on;
    p_lower = prctile(all_RT,5);
    p_upper = prctile(all_RT,95);
    patch('YData',[0 0 1 1],'XData',[0 p_lower p_lower 0],'FaceColor','k','FaceAlpha',p_opacity,'EdgeColor','none');
    patch('YData',[0 0 1 1],'XData',[p_upper 1 1 p_upper],'FaceColor','k','FaceAlpha',p_opacity,'EdgeColor','none');
    set(gca,'ydir','reverse');
    set(gca,'XTick',[]);
    xlim([0 1]);
    ylim([0 0.2]);
    
    set(gcf,'color','w');
%     ylabel(['Fraction of trials (n=',num2str(numel(all_MT)),')']);
end

% heatmap
if false
    tickLabels = {};
    tickVals = [];
    blockInterval = 0.1;
    fRTs = 0:blockInterval:1-blockInterval;
    fMTs = 0:blockInterval:1-blockInterval;
    probMatrix = [];
    figure;
    for iRT = 1:numel(fRTs)
        fRT = fRTs(iRT);
        tickLabels{iRT} = [num2str(fRT),' - ',num2str(fRT + blockInterval)];
        tickVals(iRT) = iRT;
        for iMT = 1:numel(fMTs)
            fMT = fMTs(iMT);
            binIdx = find(all_RT >= fRT & all_RT < fRT + blockInterval & all_MT >= fMT & all_MT < fMT + blockInterval);
            probMatrix(iMT,iRT) = numel(binIdx) / numel(all_RT);
            imagesc(probMatrix); drawnow; set(gca,'ydir','normal');
        end
    end
    set(gca,'ydir','normal');
    xlabel('RT (s)');
    ylabel('MT (s)');
    xticks(tickVals);
    xticklabels(tickLabels);
    xtickangle(90);
    yticks(tickVals);
    yticklabels(tickLabels);
    colorbar;
    colormap(hot);
    title('Fraction of trials');
end

disp('Mean RT: '); mean(all_RT)
disp(' +/- '); std(all_RT)
disp('Mean MT: '); mean(all_MT)
disp(' +/- '); std(all_MT)

if false
    surrMat = [];
    nSurr = 1000;
    for iSurr = 1:nSurr
        rndIdx = randperm(numel(all_MT));
        surrMat(iSurr,:) = sort(all_RT+all_MT(rndIdx));
    end

    sortedRTMT = sort(all_RT+all_MT);
    p_idx = [];
    for ii = 1:numel(all_MT)
        p_upper = prctile(surrMat(:,ii),95);
        p_lower = prctile(surrMat(:,ii),5);
        if sortedRTMT(ii) > mean(surrMat(:,ii))
            p_idx(ii) = numel(find(sortedRTMT(ii) > surrMat(:,ii))) / nSurr;
        else
            p_idx(ii) = numel(find(sortedRTMT(ii) < surrMat(:,ii))) / nSurr;
        end
    end
    figure;
    subplot(3,2,[1 2 3 4]);
    yyaxis left;
    h1 = plot(surrMat','r');
    hold on;
    h2 = plot(sortedRTMT,'k');
    ylabel('RT + MT (s)');
    title('Sorted RT + MT with Surrogate (MTs shuffled)');
    
    yyaxis right;
    plot(smooth(1-p_idx,100),'color',[.3 .3 .3]);
    hold on
    plot([0 numel(p_idx)],[.05 .05],'--','color',[.3 .3 .3]);
    ylabel('p');
    ylim([0 1]);
    xlim([0 numel(p_idx)]);
    
    subplot(3,2,5);
    h1 = plot(surrMat','r');
    hold on;
    h2 = plot(sortedRTMT,'k');
    ylabel('RT + MT (s)');
    ylim([0 0.6]);
    xlim([0 1000]);
    title('(zoomed)');
    
    subplot(3,2,6);
    h1 = plot(surrMat','r');
    hold on;
    h2 = plot(sortedRTMT,'k');
    ylabel('RT + MT (s)');
    ylim([0.8 1.4]);
    xlim([numel(p_idx)-1000 numel(p_idx)]);
    title('(zoomed)');
end

pretoneRTmeans = [];
pretoneRTmedians = [];
pretoneRTsurr = [];
pretoneMTmeans = [];
pretoneMTsurr = [];
preonteCorriis = [];
pretoneRTbelowPhys = [];
pretoneRTabovePhys = [];
pretoneInterval = .01;
countii = 1;
for ii = 0.5:pretoneInterval:1
    preonteCorriis = [preonteCorriis ii];
    iiIdx = find(all_pretone >= ii & all_pretone < ii + pretoneInterval);
    pretoneRTmeans = [pretoneRTmeans mean(all_RT(iiIdx))];
    pretoneRTmedians = [pretoneRTmedians median(all_RT(iiIdx))];
    pretoneMTmeans = [pretoneMTmeans mean(all_MT(iiIdx))];
    randIdx = randperm(numel(all_pretone),1000);
    pretoneRTsurr(countii) = numel(find(mean(all_RT(iiIdx)) > all_RT(randIdx))) / 1000;
    pretoneRTbelowPhys(countii) = numel(find(all_RT(iiIdx) < .08));
    pretoneRTabovePhys(countii) = numel(find(all_RT(iiIdx) > .4));
    countii = countii + 1;
end
figure;
subplot(4,1,[1 2]);
yyaxis left;
plot(preonteCorriis,pretoneRTmeans,'b-','LineWidth',3);
hold on;
plot(preonteCorriis,pretoneRTmedians,'b-','LineWidth',1);
plot([0 1],[mean(all_RT) mean(all_RT)],'b--');
plot(preonteCorriis,pretoneMTmeans,'k-','LineWidth',3);
scatter(all_pretone,all_RT,'.','MarkerEdgeAlpha',0.1,'MarkerEdgeColor',[0 0 1]);
legend('RT means','RT medians','All RT mean','MT');
ylim([0 .5]);
xlabel('pretone (s)');
ylabel('RT or MT (s)');

yyaxis right;
plot(preonteCorriis,1-pretoneRTsurr)
ylim([0 1]);
xlim([0.5 1]);
ylabel('p');

subplot(4,1,3);
bar(preonteCorriis,pretoneRTbelowPhys);
ylabel('RTs < 100 ms');
xlim([.5 1]);
subplot(4,1,4);
bar(preonteCorriis,pretoneRTabovePhys);
ylabel('RTs > 500 ms');
xlim([.5 1]);
set(gcf,'color','w');

figure;
subplot(211);
plot(all_RT,all_pretone,'k.');
xlim([0 1]); ylim([0.5 1]);
xlabel('RT'); ylabel('pretone');
subplot(212);
plot(all_MT,all_pretone,'k.');
xlim([0 1]); ylim([0.5 1]);
xlabel('MT'); ylabel('pretone');
