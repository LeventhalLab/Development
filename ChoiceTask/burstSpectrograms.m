function burstSpectrograms(analysisConf)
    % note: anaylsisConf is unit-based, whereas this analysis will pull out the
    % LFP wire based on the unit (i.e. two units from the same wire will result in
    % the same results)

    decimateFactor = 100;
    scalogramWindow = 2; % seconds
    fpass = [10 35];
    maxBurstISI = 0.007; % seconds
    nSample = 2000;

    for iNeuron=1:size(analysisConf.neurons,1)
        disp(['----- Working on ',analysisConf.neurons{iNeuron}]);

        % copied from lfpBurstsZEventAnalysis.m ---
        [tetrodeName,tetrodeId] = getTetrodeInfo(analysisConf.neurons{iNeuron});
        % save time if the sessionConf is already for the correct session
        if ~exist('sessionConf','var') || ~strcmp(sessionConf.sessionName,analysisConf.sessionNames{iNeuron})
            sessionConf = exportSessionConf(analysisConf.sessionNames{iNeuron},'nasPath',analysisConf.nasPath);
            leventhalPaths = buildLeventhalPaths(sessionConf);
            fullSevFiles = getChFileMap(leventhalPaths.channels);
        end

        % load nexStruct
        nexMatFile = [sessionConf.nexPath,'.mat'];
        if exist(nexMatFile)
            disp(['Loading ',nexMatFile]);
            load(nexMatFile);
        else
            error('No NEX .mat file');
        end

        % load timestamps for neuron
        for iNexNeurons=1:length(nexStruct.neurons)
            if strcmp(nexStruct.neurons{iNexNeurons}.name,analysisConf.neurons{iNeuron});
                disp(['Using timestamps from ',nexStruct.neurons{iNexNeurons}.name]);
                ts = nexStruct.neurons{iNexNeurons}.timestamps;
            end
        end

        % get the burst start times
        burstIdx = find(diff(ts) > 0 & diff(ts) <= maxBurstISI);
        burstStartIdx = [1;diff(burstIdx)>1];
        tsBurst = ts(burstIdx(logical(burstStartIdx)));
        tsLTS = filterLTS(tsBurst);
        [~,~,poissonIdx] = burst(ts);
        tsPoisson = ts(poissonIdx);

        lfpChannel = sessionConf.lfpChannels(tetrodeId);
        sevFile = fullSevFiles{sessionConf.chMap(tetrodeId,lfpChannel+1)};
        disp(['Reading LFP (SEV file) for ',tetrodeName]);
        disp(sevFile);
        [sev,header] = read_tdt_sev(sevFile);
        [b,a]=butter(4,200/(header.Fs/2)); % low-pass 200Hz
        sev = filtfilt(b,a,double(sev));
        sev = decimate(sev,decimateFactor);
        Fs = header.Fs/decimateFactor;
        % --- copy end

        disp(['Making tsRnd_realW']);
        tsSample = randsample(linspace(0,(length(sev)/Fs),1e5),nSample,true); % using replacement
        [tsRnd_realW, freqList] = pluckScalogram(sev,tsSample,scalogramWindow,Fs,fpass);
        
        disp(['Making ts_realW']);
        tsSample = randsample(ts,nSample,true); % using replacement
        [ts_realW, freqList] = pluckScalogram(sev,tsSample,scalogramWindow,Fs,fpass);
        
        disp(['Making tsBurst_realW']);
        tsSample = randsample(tsBurst,nSample,true); % using replacement
        [tsBurst_realW, freqList] = pluckScalogram(sev,tsSample,scalogramWindow,Fs,fpass);
        
        disp(['Making tsLTS_realW']);
        tsSample = randsample(tsLTS,nSample,true); % using replacement
        [tsLTS_realW, freqList] = pluckScalogram(sev,tsSample,scalogramWindow,Fs,fpass);
        
        disp(['Making tsPoisson_realW']);
        tsSample = randsample(tsPoisson,nSample,true); % using replacement
        [tsPoisson_realW, freqList] = pluckScalogram(sev,tsSample,scalogramWindow,Fs,fpass);
        
        t = linspace(-scalogramWindow,scalogramWindow,size(ts_realW,1));
        
        h = figure('position',[0 0 400 800]);
        nSubplots = 5;
        
        subplot(nSubplots,1,1);
        imagesc(t,freqList,log(tsRnd_realW));
        title({analysisConf.neurons{iNeuron},'Random ts'});
        formatSubplot;
        
        subplot(nSubplots,1,2);
        imagesc(t,freqList,log(ts_realW));
        title({analysisConf.neurons{iNeuron},'All ts'});
        formatSubplot;
        
        subplot(nSubplots,1,3);
        imagesc(t,freqList,log(tsBurst_realW));
        title({analysisConf.neurons{iNeuron},'Burst ts'});
        formatSubplot;
        
        subplot(nSubplots,1,4);
        imagesc(t,freqList,log(tsLTS_realW));
        title({analysisConf.neurons{iNeuron},'LTS ts'});
        formatSubplot;
        
        subplot(nSubplots,1,5);
        imagesc(t,freqList,log(tsPoisson_realW));
        title({analysisConf.neurons{iNeuron},'Poisson ts'});
        formatSubplot;
    end
end

function formatSubplot()
    ylabel('Frequency (Hz)');
    xlabel('Time (s)');
    set(gca, 'YDir', 'normal');
    colormap(jet);
    xlim([-1 1]);
    ylim([10 35]);
end

function [realW, freqList] = pluckScalogram(sev,ts,scalogramWindow,Fs,fpass)
    scalogramWindowSamples = round(scalogramWindow * Fs);
    data = [];
    for ii=1:length(ts)
        tsSample = round(ts(ii) * Fs);
        if tsSample - scalogramWindowSamples > 0 && tsSample + scalogramWindowSamples < length(sev)
            data(:,ii) = sev((tsSample - scalogramWindowSamples):(tsSample + scalogramWindowSamples - 1));
        end
    end
    % remove artifacts
    [W, freqList] = calculateComplexScalograms_EnMasse(data,'Fs',Fs,'fpass',fpass);
    
% --- insert
    tIdx = floor((scalogramWindowSamples)/2):3*floor((scalogramWindowSamples)/2);
    t = linspace(-1,1,length(tIdx));
    betaIdx = (freqList >= 13 & freqList <= 30);
    allBetaPower = [];
    figure;
    for ii=1:size(W,2)
        realW = squeeze(mean(abs(W(:,ii,:)).^2,2))';
        betaPower = mean(realW(betaIdx,tIdx),1);
        if mean(betaPower) < 1e4
            allBetaPower(ii,:) = betaPower;
            hold on;
            plot(t,betaPower);
        end
    end

    hold on;
    plot(t,mean(allBetaPower,1),'LineWidth',5);
    ylim([0 2*max(mean(allBetaPower,1))]);
% --- insert
    
    WIdx = [];
    for ii=1:length(ts)
        if max(max(squeeze(abs(W(:,ii,:)).^2))) < 1e6
            WIdx = [WIdx;ii];
        end
    end
    realW = squeeze(mean(abs(W(:,WIdx,:)).^2, 2))';
end