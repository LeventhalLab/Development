freqList = logFreqList([1 200],10);
tWindow = 1;
savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/wholeSession/spikeTriggeredAvg';

tWindow_extract = 1.5;
for iNeuron = 1%:366
    curTs = all_ts{iNeuron};
    sevFile = uniqueLFPs_local{iNeuron};
    disp([num2str(iNeuron),': ',sevFile]);
    [sevFilt,Fs,decimateFactor] = loadCompressedSEV(sevFile);
    tsEnd = numel(sevFilt)/Fs;
    
    extractSamples = round(tWindow_extract * Fs);
    
    data = [];
    spikeCount = 0;
    f = waitbar(0,'spikes');
    for iSpike = 1:numel(curTs)
        waitbar(iSpike/numel(curTs),f,'spikes');
        if curTs(iSpike) < tWindow_extract || curTs(iSpike) > tsEnd - tWindow_extract
            continue;
        end
        spikeSample = round(curTs(iSpike) * Fs);
        sevRange = spikeSample - extractSamples : spikeSample + extractSamples;
        sevData = sevFilt(1,sevRange);
        % tune these if needed
        if max(abs(sevData - mean(sevData))) > 2000 || max(diff(sevData - mean(sevData))) > 1000
            continue;
        end
        spikeCount = spikeCount + 1;
        data(:,spikeCount) = sevData;
    end
    close(f);
    
    W = calculateComplexScalograms_EnMasse(data,'Fs',Fs,'freqList',freqList(1),'doplot',true);
end

h = figuree(250,250);
t = linspace(-tWindow_extract,tWindow_extract,size(W,1));
% subplot(211);

imagesc(t,freqList,squeeze(mean(abs(W).^2, 2))');
title({['u',num2str(iNeuron,'%03d')],'Power'}); hold on;


if false
    curTs = all_ts{iNeuron};
    curTs_shuffled = curTs(randperm(numel(curTs)));
    curTs_random = rand([1 numel(curTs_shuffled)*2]) * max(curTs);
    sevFile = uniqueLFPs_local{iNeuron};
    disp([num2str(iNeuron),': ',sevFile]);
    [sev,header] = read_tdt_sev(sevFile);
    sevFilt = decimate(double(sev),decimateFactor);
    sevFilt = artifactThresh(sevFilt,1,1000);
    tsEnd = numel(sev)/header.Fs;
    Fs = header.Fs / decimateFactor;
    W = calculateComplexScalograms_EnMasse(sevFilt','Fs',Fs,'freqList',freqList);
    W = squeeze(W);
    W_power = abs(W).^2;
    W_phase = angle(W);
    tW = linspace(0,tsEnd,size(W,1));
    Wsamples = round((size(W,1) / tsEnd) * tWindow);
    STAArr_power = [];
    STAArr_phase = [];
    
    allFreq_power = [];
    allFreq_phase = [];
    % breaking it up by freq, otherwise structures become too large
    allFreq_power = zeros(numel((-Wsamples:sampleInt:Wsamples)),numel(freqList));
    allFreq_phase = allFreq_power;
    for iFreq = 1:numel(freqList)
        STAArr_power = zeros(2,numel(curTs),size(allFreq_power,1));
        STAArr_phase = STAArr_power;
        disp(['working on ',num2str(freqList(iFreq)),' Hz...']);
        setupFlag = true;
        useTs = curTs_shuffled;
        forSpikes = numel(curTs);
        exitAfter = forSpikes;
        spikeCount = 0;
        for iSurr = 1:2
            if setupFlag && iSurr == 2
                useTs = curTs_random;
                exitAfter = spikeCount;
                forSpikes = exitAfter * 2;
                spikeCount = 0;
                setupFlag = false;
            end
            for iSpike = 1:forSpikes % first loop up to numel(curTs), second loop just meets spikeCount
                if useTs(iSpike) < tWindow || useTs(iSpike) > tsEnd - tWindow
                    continue;
                end
                Wcenter = round((size(W,1) / tsEnd) * useTs(iSpike)); %find(tW > useTs(iSpike),1);
                Wrange = Wcenter - Wsamples:sampleInt:Wcenter + Wsamples;
                if max(max(W_power(Wrange,iFreq))) < 1e5 % power filter
                    spikeCount = spikeCount + 1;
                    STAArr_power(iSurr,spikeCount,:) = W_power(Wrange,iFreq);
                    STAArr_phase(iSurr,spikeCount,:) = W_phase(Wrange,iFreq);
                else
                    disp('overpower');
                end
                if spikeCount == exitAfter
                    break;
                end
            end
            if iSurr == 1 % reshape to actual spikes
                STAArr_power = STAArr_power(:,1:spikeCount,:);
                STAArr_phase = STAArr_phase(:,1:spikeCount,:);
            end
        end
        
        STAArr_power_surr = mean(squeeze(STAArr_power(2,:,:)));
        STAArr_power_zMean = mean(STAArr_power_surr);
        STAArr_power_zStd = std(STAArr_power_surr);
        STAArr_power_shuf = mean(squeeze(STAArr_power(1,:,:)));
        STAArr_power_z = (STAArr_power_shuf - STAArr_power_zMean) ./ STAArr_power_zStd;

        STAArr_phase_surr = circ_r(squeeze(STAArr_phase(2,:,:)));
        STAArr_phase_zMean = mean(STAArr_phase_surr);
        STAArr_phase_zStd = std(STAArr_phase_surr);
        STAArr_phase_shuf = circ_r(squeeze(STAArr_phase(1,:,:)));
        STAArr_phase_z = (STAArr_phase_shuf - STAArr_phase_zMean) ./ STAArr_phase_zStd;

        allFreq_power(:,iFreq) = STAArr_power_z;
        allFreq_phase(:,iFreq) = STAArr_phase_z;
    end
    
    h = figuree(250,500);
    t = linspace(-tWindow,tWindow,size(allFreq_power,1));
    subplot(211);
    imagesc(t,freqList,allFreq_power');
    title({['u',num2str(iNeuron,'%03d')],'Power'}); hold on;
    
    subplot(212);
    imagesc(t,freqList,allFreq_phase');
    title('MRL'); hold on;
    
    for iSubplot = 1:2
        subplot(2,1,iSubplot);
        xlabel('time (s)');
        xlim([-tWindow,tWindow]);
        xticks(sort([0 xlim]));
        curyLim = ylim;
        ytickLocs = linspace(curyLim(1),curyLim(2),size(allFreq_power,2));
        yticks(ytickLocs);
        yticklabels({num2str(freqList(:),'%2.1f')});
        ylabel('freq (Hz)');
        set(gca,'ydir','normal');
        colormap(jet);
        caxis([-8 8]);
        cb = colorbar('Ticks',sort([0 caxis]));
        cb.Label.String = 'Z-score';
        set(gca,'fontSize',6);
    end
    set(h,'color','w');
    saveas(h,fullfile(savePath,[num2str(iNeuron,'%03d'),'.png']));
    close(h);
end