all_CV = [];
all_CVclass = [];

for iNeuron = 1:numel(analysisConf.neurons)
    neuronName = analysisConf.neurons{iNeuron}
    curTrials = all_trials{iNeuron};
    
    TIMEmin = 0;
    TIMEmax = median(all_rt) + std(all_rt);
    trialIdInfo_lowTIME = organizeTrialsById_RT(curTrials,TIMEmin,TIMEmax);
    TIMEmin = median(all_rt) + std(all_rt);
    TIMEmax = 2;
    trialIdInfo_highTIME = organizeTrialsById_RT(curTrials,TIMEmin,TIMEmax);
    
    useTrials = [trialIdInfo_lowTIME.correctContra trialIdInfo_lowTIME.correctIpsi trialIdInfo_highTIME.correctContra trialIdInfo_highTIME.correctIpsi];
    nlow = numel([trialIdInfo_lowTIME.correctContra trialIdInfo_lowTIME.correctIpsi]);
    tsPeths = eventsPeth(curTrials(useTrials),all_ts{iNeuron},1,eventFieldnames);
    for iTrial = 1:size(tsPeths,1)
        for iEvent = 3
            curTs = tsPeths{iTrial,iEvent};
            CV = coeffVar(curTs(curTs>=0));
            if CV == 0 || CV > 5
                continue;
            end
            all_CV = [all_CV CV];
            if iTrial <= nlow
                all_CVclass = [all_CVclass 0];
            else
                all_CVclass = [all_CVclass 1];
            end
        end
    end
end
all_CVclass = logical(all_CVclass);

group = {};
for ii = 1:numel(all_CVclass)
    if all_CVclass(ii)
        group{ii} = 'Low RT';
    else
        group{ii} = 'High RT';
    end
end
anova1(all_CV,group);
grid on;
ylim([0 2]);

% % figure;
% % plotSpread({all_CV(all_CVclass),all_CV(~all_CVclass)});

% % colors = lines(3);
% % figure;
% % h1 = histogram(all_CV(all_CVclass),linspace(min(all_CV),max(all_CV),100),'FaceColor',colors(1,:),'FaceAlpha',0.5);
% % hold on;
% % h2 = histogram(all_CV(~all_CVclass),linspace(min(all_CV),max(all_CV),100),'FaceColor',colors(3,:),'FaceAlpha',0.5);
% % grid on;