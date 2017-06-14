eventFieldnames = {'cueOn';'centerIn';'tone';'centerOut';'sideIn';'sideOut';'foodRetrieval'};
tWindow = 2;

if false
    trialCount = 1;
    all_cvs = [];
    all_cvs_numel = [];
    all_iNeuron = [];
    all_rt = [];
    all_mt = [];
    all_pretone = [];
    for iNeuron = 1:size(analysisConf.neurons,1)
        neuronName = analysisConf.neurons{iNeuron};
        disp(['Working on ',neuronName]);
        [electrodeName,electrodeSite,electrodeChannels] = getElectrodeInfo(neuronName);
        if ~exist('sessionConf','var') || ~strcmp(sessionConf.sessions__name,analysisConf.sessionConfs{iNeuron})
            sessionConf = analysisConf.sessionConfs{iNeuron};
            % load nexStruct.. I don't love using 'load'
            nexMatFile = [sessionConf.leventhalPaths.nex,'.mat'];
            if exist(nexMatFile,'file')
                disp(['Loading ',nexMatFile]);
                load(nexMatFile);
            else
                error('No NEX .mat file');
            end
        end

        logFile = getLogPath(sessionConf.leventhalPaths.rawdata);
        logData = readLogData(logFile);
        if strcmp(neuronName(1:5),'R0154')
            nexStruct = fixMissingEvents(logData,nexStruct);
        end
        trials = createTrialsStruct_simpleChoice(logData,nexStruct);
        timingField = 'RT';
        [trialIds,rt] = sortTrialsBy(trials,timingField); % forces to be 'correct'
        all_rt = [all_rt rt];
        timingField = 'MT';
        [trialIds,mt] = sortTrialsBy(trials,timingField); % forces to be 'correct'
        all_mt = [all_mt mt];
        timingField = 'pretone';
        [trialIds,pretone] = sortTrialsBy(trials,timingField); % forces to be 'correct'
        all_pretone = [all_pretone pretone];
        % load timestamps for neuron
        for iNexNeurons = 1:length(nexStruct.neurons)
            if strcmp(nexStruct.neurons{iNexNeurons}.name,analysisConf.neurons{iNeuron})
                disp(['Using timestamps from ',nexStruct.neurons{iNexNeurons}.name]);
                ts = nexStruct.neurons{iNexNeurons}.timestamps;
            end
        end

    % %     tsPeths = eventsPeth(trials(trialIds),ts,tWindow,eventFieldnames);

        % running CV, but results in a lot of NaNs
    % %     curTs = 0;
    % %     ts_snippet = [];
    % %     running_cv = [];
    % %     t_cv = [];
    % %     while curTs < max(ts)
    % %         ts_snippet = ts(ts >= curTs & ts < curTs + (binSize_ms/1000));
    % %         cv_snippet = coeffVar(ts_snippet);
    % %         running_cv = [running_cv cv_snippet];
    % %         t_cv = [t_cv curTs];
    % %         curTs = curTs + (binSize_ms/1000);
    % %     end

        % this is basically tsPeths
        for iTrial = trialIds
            iField = 2;
            centerTs = getfield(trials(iTrial).timestamps,eventFieldnames{iField});
    %         windowIdxs = find(t_cv >= centerTs - tWindow & t_cv < centerTs + tWindow);
            tsWindow_before = ts(ts < centerTs & ts >= centerTs - tWindow);
            tsWindow_after = ts(ts >= centerTs & ts < centerTs + tWindow);

            a = tWindow;
            b = ts(end)-tWindow;
            n = 1;
            centerTs_rand = a + (b-a).*rand(n,1);
            tsWindow_rand = ts(ts >= centerTs_rand & ts < centerTs_rand + tWindow);

            coeffVar_before = coeffVar(tsWindow_before);
            coeffVar_after = coeffVar(tsWindow_after);
            coeffVar_rand = coeffVar(tsWindow_rand);
            all_cvs(trialCount,:) = [coeffVar_before,coeffVar_after,coeffVar_rand];
            all_cvs_numel(trialCount,:) = [numel(tsWindow_before) numel(tsWindow_after) numel(tsWindow_rand)];
            all_iNeuron(trialCount) = iNeuron;
            trialCount = trialCount + 1;
        end
    end
end

% classify based on CV threshold
neuronCvClass = [];
neuronCvMean = [];
highThresh = 1.3;
lowThresh = 0.7;
for iNeuron = 1:size(analysisConf.neurons,1)
    entryIdxs = find(all_iNeuron == iNeuron);
    mean_all_neuron_cvs = nanmean(all_cvs(entryIdxs,:));
    neuronCvMean(iNeuron,:) = mean_all_neuron_cvs;
    if mean_all_neuron_cvs(1) >= highThresh || mean_all_neuron_cvs(2) >= highThresh
        neuronCvClass(iNeuron) = 1;
    elseif mean_all_neuron_cvs(1) < lowThresh || mean_all_neuron_cvs(2) < lowThresh
        neuronCvClass(iNeuron) = 2;
    else
        neuronCvClass(iNeuron) = 3;
    end
end

figuree(900,600);
subplot(311);
plot(neuronCvMean);
xlabel('neuron');
xlim([1 size(neuronCvMean,1)]);
ylabel('CV');
legend({'before','after','random'});
grid on;

subplot(312);
[v,k] = sort(neuronCvMean(:,3));
% plot(neuronCvMean(repmat(k,[1 3]),:));
plot(neuronCvMean(k,:));
xlabel('neuron');
xlim([1 size(neuronCvMean,1)]);
ylabel('CV');
legend({'before','after','random'});
grid on;

nSmooth = 10;
shiftBy = .02;
subplot(313);
% % bar(centers-shiftBy,counts,.3);
for ii=1:3
    [counts,centers] = hist(neuronCvMean(:,ii),[0:.1:3]);
plot(interp(centers,nSmooth),interp(counts,nSmooth),'LineWidth',3);
hold on;
end
% % bar(centers+shiftBy,counts,.3,'r');
xlabel('CV');
ylabel('neuron count');
legend({'before','after','random'});
xlim([0 3]);
grid on;

neuronClasses = {'high CV','low CV','NS CV'};
figuree(600,800);
iSubplot = 1;
for ii=1:3
    classIdxs = find(neuronCvClass == ii);
    idxsForClass = find(ismember(all_iNeuron,classIdxs));
    % all units, all trials
    subplot(3,2,iSubplot);
    errorbar(nanmean(all_cvs(idxsForClass,:)),nanstd(all_cvs(idxsForClass,:)),'--.','MarkerSize',25);
    xlim([0 4]);
    ylabel('CV');
    ylim([0 2]);
    xticks([1:3])
    xticklabels({'before','after','random'});
    if ii == 1
        title({[neuronClasses{ii},' N=',num2str(numel(classIdxs))],analysisConf.subjects{:},[eventFieldnames{iField},', tWindow = ',num2str(tWindow),'s']});
    else
        title([neuronClasses{ii},' N=',num2str(numel(classIdxs))]);
    end
    grid on;
    iSubplot = iSubplot + 1;

    % errorbar so large because units have different FR
    subplot(3,2,iSubplot);
    errorbar(mean(all_cvs_numel(idxsForClass,:)/tWindow),std(all_cvs_numel(idxsForClass,:)/tWindow),'r--.','MarkerSize',25);
    xlim([0 4]);
    ylabel('Window FR');
    ylim([0 60]);
    xticks([1:3])
    xticklabels({'before','after','random'});
    if ii == 1
        title({[neuronClasses{ii},' N=',num2str(numel(classIdxs))],analysisConf.subjects{:},[eventFieldnames{iField},', tWindow = ',num2str(tWindow),'s']});
    else
        title([neuronClasses{ii},' N=',num2str(numel(classIdxs))]);
    end
    grid on;
    iSubplot = iSubplot + 1;
end


if true
    % rt/mt corr with individual trials
    figuree(800, 800);
    subplot(221);
    plot(all_rt,all_cvs,'.','color',[0 0 1 .7]);
    ylabel('CV');
    xlabel('rt');
    grid on;
    subplot(222);
    plot(all_mt,all_cvs,'.','color',[1 0 0 .7]);
    ylabel('CV');
    xlabel('mt');
    grid on;
    subplot(223);
    plot(all_rt,all_pretone,'.','color',[0 0 1 .7]);
    ylabel('pretone');
    xlabel('rt');
    ylim([.5 1]);
    grid on;
    subplot(224);
    plot(all_mt,all_pretone,'.','color',[1 0 0 .7]);
    ylabel('pretone');
    xlabel('mt');
    ylim([.5 1]);
    grid on;
end