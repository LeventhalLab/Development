minBursts = 1000;

ratIDs = {'R0088','R0117'};

[ validNeuronList, validLTSunits ] = getValidNeurons();
units_to_use = validLTSunits;

numValidUnits = zeros(1,2);
mean_periBurstBeta = zeros(1,2035);
mean_periRandomBeta = zeros(1,2035);
for iRat = 1 : length(ratIDs)
%     analysisConf = exportAnalysisConfv2(ratIDs{iRat},nasPath);
    
    for iNeuron=1:size(analysisConf.neurons,1)
        
        neuronName = analysisConf.neurons{iNeuron};
        if ~any(strcmp(neuronName,units_to_use))
            continue;
        end
        sessionName = analysisConf.sessionNames{iNeuron};
        sessionIdx = find(strcmp(sessionName,sessions_to_analyze));
        cur_lfpWire = lfpWire(sessionIdx);

        tsScalo_subject_dir = fullfile(analysis_storage_dir, [analysisConf.subjects__name '_spike_triggered_scalos']);
        tsScalo_session_dir = fullfile(tsScalo_subject_dir, analysisConf.sessionNames{iNeuron});
        
        % filenames to store the analyzed LFP data
        periSpike_beta_name = [neuronName '_periSpikeBeta_correctOnly.mat'];
        periSpike_beta_name = fullfile(tsScalo_session_dir, periSpike_beta_name);
        
        if exist(periSpike_beta_name,'file') ~= 2; continue; end
        
        load(periSpike_beta_name);
        if size(periSpikeBeta,1) < minBursts
            continue;
        end
        
        numValidUnits(iRat) = numValidUnits(iRat) + 1;
        
        mean_periBurstBeta(numValidUnits(iRat),:) = mean(periSpikeBeta,1);
        mean_periRandomBeta(numValidUnits(iRat),:) = mean(periRandomBeta,1);
        
    end
    
end

        
        