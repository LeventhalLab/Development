if false
    trialTypes = {'correctContra','correctIpsi'};
    useEvents = 1:7;
    binMs = 50;
    tWindow = 1;
    [unitEvents,all_zscores] = classifyUnitsToEvents(analysisConf,all_trials,all_ts,eventFieldnames,tWindow,binMs,trialTypes,useEvents);
end

if true
    nShuffle = 1000;
    pVal = 0.95;
    neuronClasses = [];
    neuronZScores = [];
    neuronIdxs = [];
    neuronCount = 1;
    for iNeuron = 1:numel(unitEvents)
        if ~isempty(unitEvents{iNeuron}.class)
            if ismember(unitEvents{iNeuron}.class(1),[3,4])
                neuronClasses(neuronCount) = unitEvents{iNeuron}.class(1);
                neuronIdxs(neuronCount) = iNeuron;
                neuronCount = neuronCount + 1;
            end
        end
    end
%     neuronZScores = all_zscores(neuronIdxs,:,:);
    class1Z = squeeze(mean(all_zscores(neuronIdxs(neuronClasses == 3),:,:)));
    class2Z = squeeze(mean(all_zscores(neuronIdxs(neuronClasses == 4),:,:)));
    
    matrixDiffShuffle = [];
    for iShuffle = 1:nShuffle
        ix = randperm(numel(neuronIdxs));
        neuronIdxs_shuff = neuronIdxs(ix);
        class1Zshuffled = squeeze(mean(all_zscores(neuronIdxs_shuff(neuronClasses == 3),:,:)));
        class2Zshuffled = squeeze(mean(all_zscores(neuronIdxs_shuff(neuronClasses == 4),:,:)));
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

figuree(1200,300);
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
legend('Tone Units','CenterOut Units');