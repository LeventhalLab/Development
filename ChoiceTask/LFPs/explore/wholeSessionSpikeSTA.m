% create session-wide SDE z-scores
compileTs = false;
compileWs = false;

if compileTs
    [uniqueSession,ic,ia] = unique(analysisConf.sessionNames);
    sessionTs = {};
    tsEndArr = [];
    for iNeuron = 1:366
        iSession = ia(iNeuron);
        if numel(sessionTs) < iSession
            sessionTs{ia(iNeuron)} = []; % init
            sevFile = LFPfiles_local{iNeuron}; % pluck one sev from the session
            disp(sevFile);
            [sev,header] = read_tdt_sev(sevFile);
            tsEndArr(iSession) = numel(sev)/header.Fs;
        end
        sessionTs{iSession} = [sessionTs{iSession} all_ts{iNeuron}']; % compile
    end
end

decimateFactor = 20;
if compileWs
    savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/wholeSession/saved_Ws';
    [uniqueLFPs_local,ic,ia] = unique(LFPfiles_local);
    for iFile = 1:numel(uniqueLFPs_local)
        sevFile = uniqueLFPs_local{iFile};
        disp(sevFile);
        [sev,header] = read_tdt_sev(sevFile);
        sevFilt = decimate(double(sev),decimateFactor);
        Fs = header.Fs / decimateFactor;
        W = calculateComplexScalograms_EnMasse(sevFilt','Fs',Fs,'freqList',freqList);
        W = squeeze(W);
        save(fullfile(savePath,[num2str(iFile,'%03d'),'W']),'W','Fs','decimateFactor','ic','ia');
    end
end

decimateFactor = 20;
freqList = logFreqList([3.5 100],30);
sampleInt = 100;
tWindow = 1;
savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/wholeSession/spikeTriggeredAvg';
for iNeuron = 1:366
% %     curTs = compressTs(all_ts{iNeuron},.02);
    curTs = all_ts{iNeuron};
    curTs_shuffled = curTs(randperm(numel(curTs)));
    curTs_random = rand([1 numel(curTs_shuffled)*2]) * max(curTs);
    sevFile = uniqueLFPs_local{iNeuron};
    disp([num2str(iNeuron),': ',sevFile]);
    [sev,header] = read_tdt_sev(sevFile);
    sevFilt = decimate(double(sev),decimateFactor);
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

% % tWindow = 1;
% % for iSession = 1%:numel(sessionTs)
% %     curTs = sessionTs{iSession};
% %     % load S
% %     STAArr = [];
% %     spikeCount = 0;
% %     for iSpike = 1:1000%numel(spikeTs)
% %         if curTs(iSpike) < tWindow || curTs(iSpike) > tsEndArr(iSession) - tWindow
% %             continue;
% %         end
% %         Wsamples = round((size(S.W,1) / tsEndArr(iSession)) * tWindow);
% %         tW = linspace(0,tsEndArr(iSession),size(S.W,1));
% %         Wcenter = closest(tW,curTs(iSpike));
% %         Wrange = Wcenter - Wsamples:Wcenter + Wsamples;
% %         powerData = abs(S.W(Wrange,:)).^2;
% %         if max(max(powerData)) < 1000
% %             spikeCount = spikeCount + 1;
% %             if spikeCount == 1
% %                 STAArr = powerData;
% %             else
% %                 takeMean = [];
% %                 takeMean(1,:,:) = STAArr;
% %                 takeMean(2,:,:) = powerData;
% %                 STAArr = squeeze(mean(takeMean));
% %             end
% %         end
% %     end
% % end

% z-score each band?


% % savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/wholeSession/saved_Ws';
% % [uniqueSession,ic,ia] = unique(analysisConf.sessionNames);
% % for iSession = 1:numel(sessionTs)
% %     s = get_SDE(sessionTs{iSession},tsEndArr(iSession));
% %     sz = (s - mean(s)) ./ std(s);
% %     % loop through LFP wires for each session
% %     LFPunits = find(ia == iSession);
% %     for iUnit = LFPunits'
% %         findFile = fullfile(savePath,[num2str(iUnit,'%03d'),'W.mat']);
% %         if exist(findFile)
% %             % do plot
% %             S = load(findFile);
% %             run_xcorr(sz,S,uniqueSession{iSession},iUnit,freqList);
% %         end
% %     end
% % end


function run_xcorr(sz,S,sessionName,iUnit,freqList)
figuree(1200,400);

sz_resized = interp1(sz,linspace(1,numel(sz),size(S.W,1)));
for iFreq = 1:numel(freqList)
    freqData = abs(S.W(:,iFreq)).^2;
    freqData(freqData > 1000) = 0;
    freqData = (freqData - mean(freqData)) ./ std(freqData);
    [acor,lag] = xcorr(sz_resized,freqData);
end
title([sessionName,', u',num2str(iUnit,'%03d')]);
end

% % figure;
% % t = linspace(0,tsEnd,numel(s));
% % plot(t,s);
% % hold on;
% % plot(t,sz);
% % plot(sessionTs{iSession},zeros(1,numel(sessionTs{iSession})),'rx');


% attempting to keep settings self-contained
function [s,binned,kernel,sigma] = get_SDE(ts,tsEnd)
% ts = timestamps in seconds
% trialLength = trial length in seconds (max(ts) is a rough estimate)
% sigma = std deviations for kernel edges
% modified from: MATLAB for Neuroscientists, p.319-320
% s = SDE at every ms of recording
% binned = integer of spikes for each ms of recording
% kernel = smoothing kernel

binWidth = .001; % 1ms
sigma = .02; % kernel std

tsEnd = round(tsEnd,3); % round to ms-precision
binned = hist(ts,[binWidth:binWidth:tsEnd]); % bin data
edges = [-3*sigma:.001:3*sigma]; % time ranges
kernel = normpdf(edges,0,sigma); % eval guassian kernel
kernel = kernel*.001; % multiply by bin width
s = conv(binned,kernel); % convolve
center = ceil(length(edges)/2); % index of kernel center
s = s(center:tsEnd*1000 + center-1);
end