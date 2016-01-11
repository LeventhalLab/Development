function plotBurstLFPs(sessionConf)
    %[] should do burst detection first and save results, then process LFPs
%     oldFs = 24414;
%     newFs = 24414.0625;
    nLocs = 400; % old was 400
    nDownsample = 10;
    
    leventhalPaths = buildLeventhalPaths(sessionConf);
    matFiles = dir(fullfile(leventhalPaths.finished,'*.mat'));

    if isempty(matFiles)
        error('NOMATFILE','No .mat file found');
    else
        % load the nexStruct (first file)
        load(fullfile(leventhalPaths.finished,matFiles(1).name),'nexStruct');
    end
    
    neuronNames = {};
    for ii=1:length(nexStruct.neurons)
        neuronNames{ii} = nexStruct.neurons{ii}.name;
    end
    neuronIds = listdlg('PromptString','Select neurons:',...
                'SelectionMode','multiple','ListSize',[200 200],...
                'ListString',neuronNames);

    for ii=neuronIds
        neuronName = nexStruct.neurons{ii}.name;
        [tetrodeName,tetrodeId] = getTetrodeInfo(neuronName);
        disp(neuronName);
        disp(tetrodeName);
%         tetrodeIndex = getTetrodeIndex(sessionConf,tetrodeName);
        lfpWire = sessionConf.lfpChannels(tetrodeId);
        lfpChannel = sessionConf.chMap(tetrodeId,lfpWire+1);
        % get SEV file itself of LFP channel
        fullSevFiles = getChFileMap(leventhalPaths.channels);
        [sev,header] = read_tdt_sev(fullSevFiles{lfpChannel});
        
        disp('Scaling data...');
        [b,a] = butter(2, 0.015); % 183Hz lowpass
%         data = artifactThresh(sev,1,750);s
        data = filtfilt(b,a,double(sev)); % filter both ways
        data = downsample(data,nDownsample); % make smaller to run faster
        Fs = header.Fs / nDownsample;
        
        % do burst detection
        ts = nexStruct.neurons{ii,1}.timestamps;
        %[] save figure?
        [burstEpochs,burstFreqs] = findBursts(ts);
        disp('Analyzing LFP based on burst locs...');
        burstIdx = burstEpochs(:,1);
        burstLocs = round(ts(burstIdx) * Fs);
%         burstLocs = round(burstLocs / nDownsample);
        
        randomNospikeLocs = sort(datasample(min(burstLocs):max(burstLocs),length(burstLocs),'Replace',false));
        randomSpikeLocs = sort(datasample(ts,length(burstLocs),'Replace',false)) * Fs;

%         figure;plot(burstLocs);hold on;plot(randomNospikeLocs);plot(randomSpikeLocs); %sanity
%         legend('burstLocs','randomNospike','randomSpike');
        h = figure('position',[100 100 300 800]);
        randomNospikeLocsSample = sort(randsample(randomNospikeLocs,nLocs));
        [WlfprandomNospikeLocs,t,f,validBursts] = burstLFPAnalysis(data,Fs,randomNospikeLocsSample);
        WavgrandomNospikeLocsSample = squeeze(mean(WlfprandomNospikeLocs,1));
        
        figure(h);
        subplot(511);
        %imagesc(t,f,WavgrandomNospikeLocsSample');
        plot_matrix(WavgrandomNospikeLocsSample,t,f);
        c = caxis;
        quickFormat('Random No Spike',c);
        
        randomSpikeLocsSample = sort(randsample(randomSpikeLocs,nLocs));
        [WlfprandomSpikeLocs,t,f,validBursts] = burstLFPAnalysis(data,Fs,randomSpikeLocsSample);
        WavgrandomSpikeLocsSample = squeeze(mean(WlfprandomSpikeLocs,1));
        
        figure(h);
        subplot(512);
        plot_matrix(WavgrandomSpikeLocsSample,t,f);
        quickFormat('Random Spike',c);
        
        burstLocsSample = sort(randsample(burstLocs,nLocs));
        [Wlfpbursts,t,f,validBursts] = burstLFPAnalysis(data,Fs,burstLocsSample);
        WavgburstLocsSample = squeeze(mean(Wlfpbursts,1));
        
        figure(h);
        subplot(513);
        plot_matrix(WavgburstLocsSample,t,f);
        quickFormat('Bursts',c);

        figure(h);
        subplot(514);
        plot_matrix(abs(WavgburstLocsSample-WavgrandomNospikeLocsSample),t,f);
        c = caxis;
        quickFormat('(Burst - Random No Spike)',c);

        figure(h);
        subplot(515);
        plot_matrix(abs(WavgburstLocsSample-WavgrandomSpikeLocsSample),t,f);
        quickFormat('(Burst - Random Spike)',c);
        
        str = {['Neuron: ',neuronName]};
        annotation('textbox', [.1 .9 .9 .1],'String', str, 'edgeColor','none');
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