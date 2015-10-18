function plotBurstLFPs(sessionConf)
    oldFs = 24414;
    newFs = 24414.0625;
    nLocs = 400;
    
    leventhalPaths = buildLeventhalPaths(sessionConf);
    matFiles = dir(fullfile(leventhalPaths.finished,'*.mat'));

    if isempty(matFiles)
        error('NOMATFILE','No .mat file found');
    else
        % load the nexStruct (first file)
        load(fullfile(leventhalPaths.finished,matFiles(1).name),'nexStruct');
    end

    for ii=1:length(nexStruct.neurons)
        neuronName = nexStruct.neurons{ii}.name;
        tetrodeName = getTetrodeName(neuronName);
        disp(neuronName);
        disp(tetrodeName);
        tetrodeIndex = getTetrodeIndex(sessionConf,tetrodeName);
        lfpWire = sessionConf.lfpChannels(tetrodeIndex);
        lfpChannel = sessionConf.chMap(tetrodeIndex,lfpWire+1);
        % get SEV file itself of LFP channel
        fullSevFiles = getChFileMap(leventhalPaths.channels);
        [sev,header] = read_tdt_sev(fullSevFiles{lfpChannel});
        
        % do burst detection
        ts = adjustTs(nexStruct.neurons{ii,1}.timestamps,oldFs,newFs);
        [burstEpochs,burstFreqs] = findBursts(ts);
        burstIdx = burstEpochs(:,1);
        burstLocs  = ts(burstIdx) * header.Fs;
        
        randomNospikeLocs = sort(datasample(min(burstLocs):max(burstLocs),length(burstLocs),'Replace',false));
        randomSpikeLocs = sort(datasample(ts,length(burstLocs),'Replace',false)) * header.Fs;

%         figure;plot(burstLocs);hold on;plot(randomNospikeLocs);plot(randomSpikeLocs); %sanity
%         legend('burstLocs','randomNospike','randomSpike');
        figure('position',[100 100 300 800]);
        randomNospikeLocsSample = sort(randsample(randomNospikeLocs,nLocs));
        [WlfprandomNospikeLocs,t,f,validBursts] = burstLFPAnalysis(sev,header.Fs,randomNospikeLocsSample);
        WavgrandomNospikeLocsSample = 10*log10(squeeze(mean(WlfprandomNospikeLocs,1)));
        
        subplot(511);
        %imagesc(t,f,WavgrandomNospikeLocsSample');
        plot_matrix(WavgrandomNospikeLocsSample,t,f);
        c = caxis;
        quickFormat('Random No Spike',c);
        
        randomSpikeLocsSample = sort(randsample(randomSpikeLocs,nLocs));
        [WlfprandomSpikeLocs,t,f,validBursts] = burstLFPAnalysis(sev,header.Fs,randomSpikeLocsSample);
        WavgrandomSpikeLocsSample = 10*log10(squeeze(mean(WlfprandomSpikeLocs,1)));
        
        subplot(512);
        plot_matrix(WavgrandomSpikeLocsSample,t,f);
        quickFormat('Random Spike',c);
        
        burstLocsSample = sort(randsample(burstLocs,nLocs));
        [Wlfpbursts,t,f,validBursts] = burstLFPAnalysis(sev,header.Fs,burstLocsSample);
        WavgburstLocsSample = 10*log10(squeeze(mean(Wlfpbursts,1)));
        
        subplot(513);
        plot_matrix(WavgburstLocsSample,t,f);
        quickFormat('Bursts',c);

        subplot(514);
        plot_matrix(abs(WavgburstLocsSample-WavgrandomNospikeLocsSample),t,f);
        c = caxis;
        quickFormat('(Burst - Random No Spike)',c);

        subplot(515);
        plot_matrix(abs(WavgburstLocsSample-WavgrandomSpikeLocsSample),t,f);
        quickFormat('(Burst - Random Spike)',c);
        
        disp('fig');
    end
end

function quickFormat(qtitle,qcaxis)
%     axis xy; 
    colorbar;
    colormap(jet);
    title(qtitle);
    caxis(qcaxis);
%     xlim([-1 1]);
    xlabel('time (s)');
    ylabel('freq (Hz)');
end

function tetrodeName = getTetrodeName(neuronName)
    startIndex = regexp(neuronName,'_T\d\d_');
    tetrodeName = neuronName(startIndex+1:startIndex+3);
end

function tetrodeIndex = getTetrodeIndex(sessionConf,tetrodeName)
    tetrodeIndex = strfind(sessionConf.tetrodeNames,tetrodeName);
    tetrodeIndex = find(not(cellfun('isempty', tetrodeIndex)));
end