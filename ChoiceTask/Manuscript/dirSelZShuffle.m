% ipsiContraShuffle.m produces dirSelNeurons, use: logical(dirSelNeurons)
if false
    trialTypes = {'correctContra','correctIpsi'};
    useEvents = 1:7;
    binMs = 50;
    tWindow = 1;
    [unitEvents,all_zscores] = classifyUnitsToEvents(analysisConf,all_trials,all_ts,eventFieldnames,tWindow,binMs,trialTypes,useEvents);
end

if true
    nShuffle = 100;
    pVal = 0.95;
    neuronCount = 1;

    class1Z = squeeze(mean(all_zscores(dirSelNeurons,:,:))); % directionally selective
    class2Z = squeeze(mean(all_zscores(~dirSelNeurons,:,:))); % NOT directionally selective
    
    matrixDiffShuffle = [];
    for iShuffle = 1:nShuffle
        ix = randperm(numel(dirSelNeurons));
        dirSelNeurons_shuff = dirSelNeurons(ix);
        class1Zshuffled = squeeze(mean(all_zscores(logical(dirSelNeurons_shuff),:,:)));
        class2Zshuffled = squeeze(mean(all_zscores(~logical(dirSelNeurons_shuff),:,:)));
        for iEvent = 1:numel(useEvents)
            matrixDiffShuffle(iShuffle,iEvent,:) = abs(class1Zshuffled(iEvent,:) - class2Zshuffled(iEvent,:));
        end
    end
    
    pMatrix = [];
    for iEvent = 1:numel(useEvents)
        matrixDiff = abs(class1Z(iEvent,:) - class2Z(iEvent,:));
        for iBin = 1:size(class1Z,2)
            pMatrix(iEvent,iBin) = numel(find(matrixDiff(iBin) > matrixDiffShuffle(:,iEvent,iBin))) / nShuffle;
        end
    end
end

figuree(1200,400);
lns = [];
colors = lines(3);
for iEvent = 1:numel(useEvents)
    subplot(1,7,iEvent);
    yyaxis left;
    lns(1) = plot(smooth(class1Z(iEvent,:),3),'-','LineWidth',2,'color',colors(1,:));
    hold on;
    lns(2) = plot(smooth(class2Z(iEvent,:),3),'-','LineWidth',2,'color',colors(3,:));
    ylim([-4 20]);
    title(eventFieldnames{iEvent});
    ylabel('z score');
    
    yyaxis right;
    cur_pMatrix = smooth(1 - pMatrix(iEvent,:),3);
    plot(cur_pMatrix,'-','color',[colors(2,:) .3]);
    pMatrix_nans = cur_pMatrix;
    pMatrix_nans(find(cur_pMatrix > 1-pVal)) = NaN;
    plot(pMatrix_nans,'*','color',colors(2,:));
    ylim([0 1]);
    ylabel('p value');
    
    grid on;
end
legend(lns,['Dir Sel Units n=',num2str(sum(dirSelNeurons))],['NOT Dir Sel Units n=',num2str(sum(~dirSelNeurons))]);