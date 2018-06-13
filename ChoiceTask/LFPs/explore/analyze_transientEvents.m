% eventsArr
% eventsArr_meta
% eventRTcorr
% eventMTcorr

condLabels = {'before','after','total'};
allPb = zeros(3,1);
allPg = zeros(3,1);
allRb = zeros(3,1);
allRg = zeros(3,1);
for iCond = 1:3
    beta = [];
    gamma = [];
    rtcorr = [];
    neuronCount = 0;
    subjectNames = {};
    for iNeuron = 1:numel(compiled_eventsArr)
        if isempty(compiled_eventsArr(iNeuron).eventsArr)
            continue;
        end
        neuronCount = neuronCount + 1;
        sevFile = LFPfiles_local{iNeuron};
        [~,name,~] = fileparts(sevFile);
        subject__name = name(1:5);
        subjectNames{neuronCount} = subject__name;
        eventsArr = compiled_eventsArr(iNeuron).eventsArr;
        eventRTcorr = compiled_eventsArr(iNeuron).eventRTcorr;
        beta = sum(eventsArr(14:20,~isnan(eventRTcorr),iCond));
        gamma = sum(eventsArr(26:28,~isnan(eventRTcorr),iCond));
        rtcorr = eventRTcorr(~isnan(eventRTcorr));
        [Rb,Pb] = corr(rtcorr',beta');
        [Rg,Pg] = corr(rtcorr',gamma');
        corrBar(neuronCount,:) = [Rb Rg];
        allPb(iCond,neuronCount) = Pb;
        allPg(iCond,neuronCount) = Pg;
        allRb(iCond,neuronCount) = Rb;
        allRg(iCond,neuronCount) = Rg;
    end
    [~,ia,ic] = unique(subjectNames);
    subplot(3,1,iCond);
    bar(corrBar);
    hold on;
    ylim([-0.5 0.5]);
    plot(ia,zeros(size(ia)),'rx');
    title(condLabels{iCond});
    legend({'beta','gamma'})
end

bandLabels = {'beta','gamma'};
figuree(800,600);
for iBand = 1:2
    if iBand == 1
        usePs = allPb;
    else
        usePs = allPg;
    end
    for iCond = 1:3
        subplot(2,3,prc(3,[iBand,iCond]));
        histogram(usePs(iCond,:),[0:0.05:1]);
        ylim([0 40]);
        title({'p-values',bandLabels{iBand},condLabels{iCond}});
    end
end

bandLabels = {'beta','gamma'};
figuree(800,600);
for iBand = 1:2
    if iBand == 1
        useRs = allRb;
    else
        useRs = allRg;
    end
    for iCond = 1:3
        subplot(2,3,prc(3,[iBand,iCond]));
        histogram(useRs(iCond,:),[-0.5:0.05:0.5]);
        ylim([0 40]);
        title({'r-values',bandLabels{iBand},condLabels{iCond}});
    end
end