timingField = 'RT';
eventFieldnames = {'cueOn';'centerIn';'tone';'centerOut';'sideIn';'sideOut';'foodRetrieval'};
useEvent = 4;
if true
    all_AP = [];
    all_ML = [];
    all_DV = [];
    
    all_mi = [];
    all_si = [];
    all_CV = [];
    
    all_eventIds = [];
    all_timesRT = [];
    all_timesMT = [];
    nCorr = 1;

    for iNeuron = 1:size(all_tsPeths,2)
        neuronName = analysisConf.neurons{iNeuron};
        sessionConf = analysisConf.sessionConfs{iNeuron};
        [electrodeName,electrodeSite,electrodeChannels] = getElectrodeInfo(neuronName);
        rows = sessionConf.session_electrodes.channel == electrodeChannels;
        channelData = sessionConf.session_electrodes(any(rows)',:);
        event_id = eventIds_by_maxHistValues(iNeuron);
%         if ~ismember(event_id,useEvent)
%             continue;
%         end
        if isempty(channelData)
            continue;
        end
        AP = channelData{1,'ap'};
        ML = channelData{1,'ml'};
        DV = channelData{1,'dv'};
    
        trials = all_trials{iNeuron};
        [trialIds,allTimesRT] = sortTrialsBy(trials,'RT');
        [trialIds,allTimesMT] = sortTrialsBy(trials,'MT');
        ts = all_ts{iNeuron};
        tsPeths = eventsPeth(trials(trialIds),ts,tWindow,eventFieldnames);
        for iTrial = 1:size(tsPeths,1)
            if allTimesRT(iTrial) <= 0
                continue;
            end
            % get values from first event to normalize
            z_tsPeth = tsPeths{iTrial,1};
            [z_counts,z_centers] = hist(z_tsPeth,nBins_tWindow);
            z_idxs = find(nBins_tWindow <= 0);
            z_counts = z_counts(z_idxs);
            z_centers = z_centers(z_idxs);
            z_meanISI = mean(diff(z_tsPeth));

% %             if mean(z_counts) < 0.25
% %                 continue;
% %             end

            tsPeth = tsPeths{iTrial,event_id};
            CV = std(diff(tsPeth)) / z_meanISI;
            [counts,centers] = hist(tsPeth,nBins_tWindow);
            zscore = (counts - mean(z_counts)) / std(z_counts);
% %             [mi,si] = msIndex(zscore);
% %             all_mi = [all_mi mi];
% %             all_si = [all_si si];
            all_AP = [all_AP AP];
            all_ML = [all_ML ML];
            all_DV = [all_DV DV];
            all_eventIds = [all_eventIds event_id];
            
            all_timesRT = [all_timesRT allTimesRT(iTrial)];
            all_timesMT = [all_timesMT allTimesMT(iTrial)];
            
            all_CV = [all_CV CV];
 
            nCorr = nCorr + 1;
        end
    end
end

figure;
subplot(121);
plot(all_timesRT,all_CV,'k.','markerSize',10);
xlabel('RT');
ylabel('CV');
ylim([0 5]);
subplot(122);
plot(all_timesMT,all_CV,'k.','markerSize',10);
xlabel('MT');
ylabel('CV');
ylim([0 5]);


CV_data = [];
for iEvent = 1:7
    CV_vals = all_CV(find(all_eventIds == iEvent));
    CV_data(iEvent,1) = nanmean(CV_vals);
    CV_data(iEvent,2) = nanstd(CV_vals);
end
figure;
errorbar([1:7],CV_data(:,1),CV_data(:,2),'b.');
hold on;
lg(1) = bar([1:7],CV_data(:,1),0.2,'b');
grid on;
xlabel('event');
ylabel('CV');
ylim([0 2.5]);

figure;
jitterAmt = .1;
jitter = (rand(1,numel(all_ML)) * jitterAmt) - (jitterAmt / 2);
subplot(131);
scatter(all_AP+jitter,all_CV,'filled','MarkerFaceAlpha',.05,'MarkerFaceColor',[0 0 0]);
xlabel('AP');
ylabel('CV');
ylim([0 5]);
subplot(132);
scatter(all_ML+jitter,all_CV,'filled','MarkerFaceAlpha',.05,'MarkerFaceColor',[0 0 0]);
xlabel('ML');
ylabel('CV');
ylim([0 5]);
subplot(133);
scatter(all_DV+jitter,all_CV,'filled','MarkerFaceAlpha',.05,'MarkerFaceColor',[0 0 0]);
xlabel('DV');
ylabel('CV');
ylim([0 5]);

% % figure;
% % plot(all_timesRT,all_mi,'b.','markerSize',10);
% % xlabel('RT'); ylabel('mi');
% % 
% % figure;
% % plot(all_timesRT,all_si,'b.','markerSize',10);
% % xlabel('RT'); ylabel('si');
% % 
% % figure;
% % plot(all_timesMT,all_mi,'b.','markerSize',10);
% % xlabel('MT'); ylabel('mi');
% % 
% % figure;
% % plot(all_timesMT,all_si,'b.','markerSize',10);
% % xlabel('MT'); ylabel('si');


% % mi_data = [];
% % si_data = [];
% % for iEvent = 1:7
% %     mi_vals = all_mi(find(all_eventIds == iEvent));
% %     mi_data(iEvent,1) = mean(mi_vals);
% %     mi_data(iEvent,2) = std(mi_vals);
% %     
% %     si_vals = all_si(find(all_eventIds == iEvent));
% %     si_data(iEvent,1) = mean(si_vals);
% %     si_data(iEvent,2) = std(si_vals);
% % end
% % figure;
% % sepBy = .15;
% % errorbar([1:7]-sepBy,mi_data(:,1),mi_data(:,2),'b.');
% % hold on;
% % lg(1) = bar([1:7]-sepBy,mi_data(:,1),0.2,'b');
% % errorbar([1:7]+sepBy,si_data(:,1),si_data(:,2),'r.');
% % lg(2) = bar([1:7]+sepBy,si_data(:,1),0.2,'r');
% % legend(lg,{'mi','si'});

