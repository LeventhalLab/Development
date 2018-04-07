load('session_20180330_PCAanalysis.mat', 'analysisConf', 'eventFieldnames', 'all_ts');

doVideo = false; % !! not working with updated PCA !!
savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/PCA';
% % nowStr = datestr(now,'yyyymmddHHMMSS');
% % saveFile = ['PCA_analysis_',nowStr];

doSetup = true;
doPlot = true;
doSavePlot = true;
timingField = 'RT';
binInc = 10; % ms

% cleanup
if exist('newVideo','var')
    close(newVideo);
end

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
    
    require_ncriteria = 8;
    criteriaSessions = [];
    unitsPerSession = [];
    for iSession = 1:numel(groupedNeurons)
        unitsPerSession(iSession) = numel(groupedNeurons{iSession});
        if numel(groupedNeurons{iSession}) >= require_ncriteria
            criteriaSessions = [criteriaSessions iSession];
        end
    end
% %     disp(numel(criteriaSessions));
    figure;
    histogram(unitsPerSession,100);
    ylabel('number of sessions');
    xlabel('units per session');
    set(gcf,'color','w');
end

tWindow = 2;
tWindow_vis = 0.5;
PCA_arr = [];
sessionPCA = {};

for iSession = criteriaSessions
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
    [trialIds,allTimes] = sortTrialsBy(trials,timingField); % forces to be 'correct'

    PCA_arr = [];
    neuronCount = 0;
    for iNeuron = groupNeurons
        ts = all_ts{iNeuron};
            
        tsPeths = eventsPeth(trials(trialIds),all_ts{iNeuron},tWindow,eventFieldnames);
        % remove low timestamp trials
        require_nts = 5;
        require_ntrials = 10;
        tsPeths = tsPeths(~any(cellfun(@numel,tsPeths) < require_nts,2),:);
        if size(tsPeths,1) < require_ntrials
            continue;
        end
        neuronCount = neuronCount + 1;
        % do z-score
        [meanSDE,stdSDE] = getMeanSDE(tsPeths(:,1),tWindow);
        t = linspace(-tWindow,tWindow,numel(meanSDE));
        meanSDE_single = mean(meanSDE(closest(t,-2):closest(t,0))); % from -2s - 0
        stdSDE_single = mean(stdSDE(closest(t,-2):closest(t,0)));

        validTrialCount = 0;
        for iTrial = 1:size(tsPeths,1)
            validTrialCount = validTrialCount + 1;
            for iEvent = 1:7
                s = spikeDensityEstimate_periEvent(tsPeths{iTrial,iEvent},tWindow);
                sZ = (s(closest(t,-tWindow_vis):closest(t,tWindow_vis)) - meanSDE_single) ./ stdSDE_single;
% %                 PCA_arr(neuronCount,validTrialCount,iEvent,:) = sZ;
                PCA_arr(:,neuronCount,iEvent) = [squeeze(PCA_arr(:,neuronCount,iEvent)) sZ];
            end
        end
    end

    sessionPCA(iSession).PCA_arr = PCA_arr;

    if neuronCount < require_ncriteria
        disp(['Session ',num2str(iSession),' no longer has ',num2str(require_ncriteria),' units']);
        continue;
    end
    saveFile = ['PCA_analysis_session',num2str(iSession)];
    saveFile = 'PCA_analysis_session_allValidSessions';
    t_vis = linspace(-tWindow_vis,tWindow_vis,size(PCA_arr,4));
    rows = 3;
    cols = 7;
    all_V = []; % components x events x bins
    all_V_t = [];
    binCount = 1;
    if doVideo
        newVideo = VideoWriter(fullfile(savePath,saveFile),'MPEG-4');
        newVideo.Quality = 95;
        newVideo.FrameRate = 30;
        open(newVideo);
    end
    if doPlot
        h = figuree(1300,700);
    end
    
    
% %     for iBin = 1:binInc:size(PCA_arr,4)
    for iEvent = 1:size(PCA_arr,3)
% %             trial_sZ = PCA_arr(:,:,iEvent,iBin)'; % all neurons, all trials, THIS event, THIS bin
        covMatrix = squeeze(PCA_arr(:,neuronCount,iEvent)); % +/- SDE data x neurons

        % A is a matrix whose columns represent random variables and whose rows represent observations
        % C is the covariance matrix with the corresponding column variances along the diagonal.
        C = cov(covMatrix);
        % find the eigenvectors and eigenvalues
        [PC,V] = eig(C);
        % extract diagonal of matrix as vector
        V = diag(V);
        % sort the variances in decreasing order
        [~,k] = sort(-1*V);
        V = V(k);
        PC = PC(:,k);
        % project the original data set
% %         signals = PC'*data;
        if doPlot || doVideo
            subplot(rows,cols,iEvent);
            imagesc(C);
            xticks(xlim);
            xticks([1 size(C,1)]);
            yticks(ylim);
            yticks([1 size(C,1)]);
            colormap(jet);
            caxis([-.5 .5]);
% %             colorbar('south');
            xlabel('neuron');
            ylabel('neuron');
            titleCell = {eventFieldnames{iEvent},['t = ',num2str(t_vis(iBin),'%1.3f')],'','covariance'};
            if iEvent == 1
                title({['Session ',num2str(iSession)],titleCell{:}});
            else
                title(titleCell);
            end
            grid on;

            n1 = 1;
            n2 = 2;
            subplot(rows,cols,iEvent+cols);
            x = trial_sZ(:,n1);
            y = trial_sZ(:,n2);
            scatter(x,y,5,'k','filled');
            hold on;
            R = corr(x,y);
            p = polyfit(x,y,1);
            f = polyval(p,x);
            plot(x,f,'r-');
            xlabel(['neuron ',num2str(n1)]);
            ylabel(['neuron ',num2str(n2)]);
            zLims = [-3 3];
            xlim(zLims);
            xticks(sort([zLims 0]));
            ylim(zLims);
            yticks(sort([zLims 0]));
            title(['R = ',num2str(R,'%1.3f')]);
            grid on;
            hold off;

            subplot(rows,cols,iEvent+cols*2);
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
        end

        all_V_t(binCount) = t_vis(iBin);
        all_V(:,iEvent,binCount) = V;
    end
    
    set(gcf,'color','w');
    drawnow;
    if doVideo
        imgcf = frame2im(getframe(h));
        imgcf = imresize(imgcf,[720 NaN]);
        writeVideo(newVideo,imgcf);
    end

% %         binCount = binCount + 1;
% %     end % end bins

    if doVideo
        close(newVideo);
        close(h);
    end
    
    % !! NEW PLOT USING PCA

    if false
        h = figuree(1200,800);
        rows = 5; % components to show
        cols = 7;
        for iPCA = 1:rows
            for iEvent = 1:7
                subplot(rows, cols, prc(cols, [iPCA,iEvent]));
                cur_V = squeeze(all_V(iPCA,iEvent,:));
                plot(all_V_t,cur_V,'linewidth',2);
                hold on;
                if iPCA == 1
                    title({eventFieldnames{iEvent},'',['PCA ',num2str(iPCA)]});
                else
                    title({['PCA ',num2str(iPCA)]});
                end
                xticks([-1 0 1]);
                ylim([0 30]);
                ylabel('Exp. Variance');
                grid on;
                if iPCA == rows
                    xlabel('time (s)')
                end
            end
        end
        set(h,'color','w');
        if doSavePlot
            saveas(h,fullfile(savePath,saveFile),'png');
            close(h);
        end
    end
end