% script to plot average LTS triggered scalograms for all units with
% significant LTS bursts

% do one rat at a time

nasPath = '/Volumes/RecordingsLeventhal2/ChoiceTask';
analysis_storage_dir = '/Volumes/Tbolt_02/VM thal analysis';

ratIDs = {'R0088','R0117'};

[ validNeuronList, validLTSunits ] = getValidNeurons();
allScalos = cell(1,2);
numValidUnits = zeros(1,2);
meanScalo = zeros(2,50,2034);
for iRat = 1 : length(ratIDs)
    analysisConf = exportAnalysisConfv2(ratIDs{iRat},nasPath);

    units_to_use = validLTSunits;
    
    
    
    for iNeuron = 1 : length(analysisConf.neurons)

        neuronName = analysisConf.neurons{iNeuron};
        if ~any(strcmp(neuronName,units_to_use))
            continue;
        end
        cur_ratID = neuronName(1:5);
        ratIdx = strcmp(cur_ratID,ratIDs);
        numValidUnits(ratIdx) = numValidUnits(ratIdx) + 1;

        sessionName = analysisConf.sessionNames{iNeuron};
        sessionIdx = find(strcmp(sessionName,sessions_to_analyze));

        tsScalo_subject_dir = fullfile(analysis_storage_dir, [analysisConf.subjects__name '_spike_triggered_scalos']);
        tsScalo_session_dir = fullfile(tsScalo_subject_dir, analysisConf.sessionNames{iNeuron});

        tsScalo_name = [neuronName '_scalos_correctOnly.mat'];
        tsScalo_name = fullfile(tsScalo_session_dir, tsScalo_name);
        load(tsScalo_name);
        curScalo = squeeze(allTsScalograms{3}(1,:,:));
    %     allScalos(numValidUnits(ratIdx),:,:) = curScalo;
        tempScalo = squeeze(meanScalo(ratIdx,:,:)) + curScalo;
        meanScalo(ratIdx,:,:) = tempScalo;
    end
end

for iRat = 1 : 2
    if numValidUnits(iRat) > 0
        meanScalo(iRat,:,:) = meanScalo(iRat,:,:) / numValidUnits(iRat);
    end
end

%%
ratIdx = 1;
figure(ratIdx)
toPlot = log10(squeeze(meanScalo(ratIdx,:,:)));
t = scaloMetadata.t;
f = scaloMetadata.f;

h_pcolor = pcolor(t,f,toPlot);
h_pcolor.EdgeColor = 'none';
set(gca,'ydir','normal','yscale','log','ytick',[10 20 50 100 200],'xlim',[-0.2,0.2]);