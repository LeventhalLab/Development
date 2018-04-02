doSetup = false;
doCompile = true;
doPlot = true;
iSession = 18;
timingField = 'MT';

if doSetup
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
    
    n = 8;
    criteraCount = 0;
    unitsPerSession = [];
    for iSession = 1:numel(groupedNeurons)
        unitsPerSession(iSession) = numel(groupedNeurons{iSession});
        if numel(groupedNeurons{iSession}) >= 8
            criteraCount = criteraCount + 1;
        end
    end
    disp(criteraCount);
    figure;
    histogram(unitsPerSession,100);
    ylabel('number of sessions');
    xlabel('units per session');
    set(gcf,'color','w');

    
    % setup data
    groupNeurons = groupedNeurons{iSession};
    sessionConf = analysisConf.sessionConfs{groupNeurons(1)};
    neuronName = analysisConf.neurons{groupNeurons(1)};
    nexMatFile = [sessionConf.leventhalPaths.nex,'.mat'];
    load(nexMatFile);

    logFile = getLogPath(sessionConf.leventhalPaths.rawdata);
    logData = readLogData(logFile);
    if strcmp(neuronName(1:5),'R0154')
        nexStruct = fixMissingEvents(logData,nexStruct);
    end
    trials = createTrialsStruct_simpleChoice(logData,nexStruct);
end

[trialIds,allTimes] = sortTrialsBy(trials,timingField); % forces to be 'correct'

if doCompile
    tWindow = 3;
    tWindow_vis = 1;
    PCA_arr = [];

    neuronCount = 1;
    for iNeuron = groupNeurons
        tsPeths = eventsPeth(trials(trialIds),all_ts{iNeuron},tWindow,eventFieldnames);
        % do z-score
        [meanSDE,stdSDE] = getMeanSDE(tsPeths(:,1),tWindow);
        t = linspace(-tWindow,tWindow,numel(meanSDE));
        meanSDE_single = mean(meanSDE(closest(t,-2):closest(t,0))); % from -2s - 0
        stdSDE_single = mean(stdSDE(closest(t,-2):closest(t,0)));

        for iTrial = 1:numel(trialIds)
            for iEvent = 1:7
                s = spikeDensityEstimate_periEvent(tsPeths{iTrial,iEvent},tWindow);
                sZ = (s(closest(t,-tWindow_vis):closest(t,tWindow_vis)) - meanSDE_single) ./ stdSDE_single;
                PCA_arr(neuronCount,iTrial,iEvent,:) = sZ;
            end
        end
        neuronCount = neuronCount + 1;
    end
end

t_vis = linspace(-tWindow_vis,tWindow_vis,size(PCA_arr,4));
rows = 2;
cols = 7;
all_V = []; % components x events x bins
binCount = 1;
if doPlot
    figuree(1200,400);
end
for iBin = 1:size(PCA_arr,4)
    for iEvent = 1:size(PCA_arr,3)
        covMatrix = []; % neuron x RT
        trial_sZ = PCA_arr(:,:,iEvent,iBin)'; % all neurons, all trials, THIS event, THIS bin
        covMatrix = trial_sZ;
        
        % A is a matrix whose columns represent random variables and whose rows represent observations
        % C is the covariance matrix with the corresponding column variances along the diagonal.
        C = cov(covMatrix);
        % find the eigenvectors and eigenvalues
        [PC, V] = eig(C);
        % extract diagonal of matrix as vector
        V = diag(V);
        % sort the variances in decreasing order
        [~,k] = sort(-1*V);
        V = V(k);
        PC = PC(:,k);
        % project the original data set
% %         signals = PC'*data;
        if doPlot
            subplot(rows,cols,iEvent);
            x = repmat(allTimes,[1 size(covMatrix,2)]);
            y = reshape(covMatrix,[1 numel(covMatrix)]);
            scatter(x,y,5,'k','filled')
            xlimVals = [0 0.5];
            xlim(xlimVals);
            xticks(xlimVals);
            ylimVals = [-3 8];
            ylim(ylimVals);
            yticks(sort([ylimVals 0]));
            xlabel([timingField,' (s)']);
            ylabel('SDE Z-score');
            title({eventFieldnames{iEvent},['t = ',num2str(t_vis(iBin),'%1.3f')]});
            grid on;
            
            subplot(rows,cols,iEvent+cols);
            plot(cumsum((V ./ sum(V))).*100,'lineWidth',2);
            xlabel('Components');
            ylabel('Cum. Explained Variance (%)');
            xlimVals = [1 numel(V)];
            xlim(xlimVals);
            xticks(xlimVals);
            ylimVals = [0 100];
            ylim(ylimVals);
            yticks(sort([ylimVals,50]));
            title('PCA');
            grid on;

            set(gcf,'color','w');
            drawnow;
        end
        
        all_V(:,iEvent,binCount) = V;
    end
    binCount = binCount + 1;
end

% figuree(1200,800);
rows = 5; % components to show
cols = 7;
for iPCA = 1:rows
    for iEvent = 1:7
        subplot(rows, cols, prc(cols, [iPCA,iEvent]));
        cur_V = squeeze(all_V(iPCA,iEvent,:));
        plot(t_vis,cur_V);
        hold on;
        if iPCA == 1
            title({eventFieldnames{iEvent},['PCA ',num2str(iPCA)]});
        else
            title({['PCA ',num2str(iPCA)]});
        end
        xticks([-1 0 1]);
        ylim([0 8]);
        ylabel('Exp. Variance');
        grid on;
        if iPCA == rows
            xlabel('time (s)')
        end
    end
end