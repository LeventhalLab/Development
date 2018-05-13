% % useDir = ''; % '' or 'ipsi' or 'contra'
% % shortPCA = true;
% % timingField = 'RT'; % timing assumes useDir = '';

if shortPCA
    tWindow = 2;
    tWindow_vis = 0.5;
else
    tWindow = 3;
    tWindow_vis = 1;
end
SDEsamples = tWindow_vis * 2 * 1000;

require_nts = 5;
require_ntrials = 10;

% let's see how many units per session we have
sessionName = '';
groupedNeurons = {};
iSession = 0;
for iNeuron = 1:numel(analysisConf.neurons)
    if strcmp(sessionName,analysisConf.sessionNames{iNeuron}) == 0
        sessionName = analysisConf.sessionNames{iNeuron};
        iSession = iSession + 1;
        groupedNeurons{iSession} = [];
    end
    groupedNeurons{iSession} = [groupedNeurons{iSession} iNeuron];
end

require_ncriteria = 8;
criteriaSessions = [];
unitsPerSession = [];
for iSession = 1:numel(groupedNeurons)
    unitsPerSession(iSession) = numel(groupedNeurons{iSession});
    if numel(groupedNeurons{iSession}) >= require_ncriteria
        criteriaSessions = [criteriaSessions iSession];
    end
end

PCA_arr = [];
sessionPCA = {};
sessionCount = 0;
sessionNames = {};
for iSession = criteriaSessions
    groupNeurons = groupedNeurons{iSession};
    sessionConf = analysisConf.sessionConfs{groupNeurons(1)};
    neuronName = analysisConf.neurons{groupNeurons(1)};
    
    trials = all_trials{groupNeurons(1)};
    trialIdInfo = organizeTrialsById(trials);
% %     if numel(trialIdInfo.correctIpsi) < require_ntrials || numel(trialIdInfo.correctContra) < require_ntrials
% %         disp(['Removing session ',num2str(iSession),' for low ipsi/contra trials']);
% %         continue;
% %     end
    
    sessionCount = sessionCount + 1;
    % use for presentation
    sessionNames{sessionCount} = analysisConf.sessionConfs{groupNeurons(1)}.sessions__name;
    
    switch useDir
        case 'ipsi'
            trialIds = trialIdInfo.correctIpsi;
        case 'contra'
            trialIds = trialIdInfo.correctContra;
        otherwise
            [trialIds,allTimes] = sortTrialsBy(trials,timingField); % forces to be 'correct'
% %             require_ntrials = require_ntrials / 2;
    end

    PCA_arr = zeros(7,numel(groupNeurons),SDEsamples*numel(trialIds));
    neuronCount = 0;
    for iNeuron = groupNeurons
        ts = all_ts{iNeuron};
            
        tsPeths = eventsPeth(trials(trialIds),all_ts{iNeuron},tWindow,eventFieldnames);
        % remove low timestamp trials
% %         tsPeths = tsPeths(~any(cellfun(@numel,tsPeths) < require_nts,2),:);
% %         if size(tsPeths,1) < require_ntrials
% %             disp(['Removing neuron ',num2str(iNeuron),' for low FR']);
% %             continue;
% %         end
        neuronCount = neuronCount + 1;
        % do z-score
        [meanSDE,stdSDE] = getMeanSDE(tsPeths(:,1),tWindow);
        t = linspace(-tWindow,tWindow,numel(meanSDE));
        meanSDE_single = mean(meanSDE(closest(t,-2*tWindow_vis):closest(t,0))); % pre-cue period
        stdSDE_single = mean(stdSDE(closest(t,-2*tWindow_vis):closest(t,0)));

        for iTrial = 1:size(tsPeths,1)
            for iEvent = 1:7
                s = spikeDensityEstimate_periEvent(tsPeths{iTrial,iEvent},tWindow);
                sZ = (s(closest(t,-tWindow_vis):closest(t,tWindow_vis)) - meanSDE_single) ./ stdSDE_single;
                if sum(sZ) == 0
                    sz;
                end
                startRange = ((iTrial-1)*SDEsamples)+1;
                endRange = startRange + SDEsamples - 1;
                PCA_arr(iEvent,neuronCount,startRange:endRange) = sZ;
            end
        end
    end

% %     if neuronCount < require_ncriteria
% %         disp(['Session ',num2str(iSession),' no longer has ',num2str(require_ncriteria),' units']);
% %         continue;
% %     end
    
    sessionPCA(sessionCount).PCA_arr = PCA_arr;
    if isempty(useDir) % NOT ipsi/contra analysis
        switch timingField
            case 'RT'
                sessionPCA(sessionCount).RT = allTimes;
            case 'MT'
                sessionPCA(sessionCount).MT = allTimes;
        end
    end
end