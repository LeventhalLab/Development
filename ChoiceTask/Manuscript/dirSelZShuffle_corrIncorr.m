% ipsiContraShuffle.m produces dirSelNeurons, use: logical(dirSelNeurons)
if false
    trialTypes = {'correct'};
    useEvents = 1:7;
    binMs = 50;
    tWindow = 1;
    [unitEvents,all_zscores] = classifyUnitsToEvents(analysisConf,all_trials,all_ts,eventFieldnames,tWindow,binMs,trialTypes,useEvents);
end

if true
%     trialTypes = {'incorrectContra','incorrectIpsi'};
    trialTypes = {'falseStart'};
    useEvents = 1:7;
    binMs = 50;
    tWindow = 1;
    [unitEvents_incorr,all_zscores_incorr] = classifyUnitsToEvents(analysisConf,all_trials,all_ts,eventFieldnames,tWindow,binMs,trialTypes,useEvents);
end

if false
    trialTypes = {'correctContra'};
    useEvents = 1:7;
    binMs = 50;
    tWindow = 1;
    [unitEvents_contra,all_zscores_contra] = classifyUnitsToEvents(analysisConf,all_trials,all_ts,eventFieldnames,tWindow,binMs,trialTypes,useEvents);
    trialTypes = {'correctIpsi'};
    [unitEvents_ipsi,all_zscores_ipsi] = classifyUnitsToEvents(analysisConf,all_trials,all_ts,eventFieldnames,tWindow,binMs,trialTypes,useEvents);
end

if false
    trialTypes = {'correctContra','correctIpsi'};
    useEvents = 1:7;
    binMs = 50;
    tWindow = 1;
    MTmin = 0;
    MTmax = median(all_mt) + std(all_mt);
    [unitEvents_MTlow,all_zscores_MTlow] = classifyUnitsToEvents(analysisConf,all_trials,all_ts,eventFieldnames,tWindow,binMs,trialTypes,useEvents,MTmin,MTmax);
    MTmin = median(all_mt) + std(all_mt);
    MTmax = 2;
    [unitEvents_MThigh,all_zscores_MThigh] = classifyUnitsToEvents(analysisConf,all_trials,all_ts,eventFieldnames,tWindow,binMs,trialTypes,useEvents,MTmin,MTmax);
end

if true
    nShuffle = 1000;
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

figuree(1300,700);
lns = [];
colors = lines(3);
for iEvent = 1:numel(useEvents)
    subplot(2,7,iEvent);
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

% corr vs incorr
if true
    nShuffle = 1000;
    pVal = 0.95;
    neuronCount = 1;

    class1Z = squeeze(mean(all_zscores(dirSelNeurons,:,:)));
    class2Z = squeeze(mean(all_zscores_incorr(dirSelNeurons,:,:)));
    
    matrixDiffShuffle = [];
    for iShuffle = 1:nShuffle
        ix = randperm(numel(dirSelNeurons));
        dirSelNeurons_shuff = dirSelNeurons(ix);
        class1Zshuffled = squeeze(mean(all_zscores(dirSelNeurons_shuff,:,:)));
        class2Zshuffled = squeeze(mean(all_zscores_incorr(dirSelNeurons_shuff,:,:)));
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

lns = [];
colors = lines(3);
for iEvent = 1:numel(useEvents)
    subplot(2,7,iEvent+7);
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
legend(lns,['Dir Sel Units CORR TRIALS'],['Dir Sel Units INCORR TRIALS']);