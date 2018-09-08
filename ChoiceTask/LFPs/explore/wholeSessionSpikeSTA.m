% create session-wide SDE z-scores
compileTs = false;
compileWs = false;
doBurst = false;

% % if compileTs
% %     [uniqueSession,ic,ia] = unique(analysisConf.sessionNames);
% %     sessionTs = {};
% %     tsEndArr = [];
% %     for iNeuron = 1:366
% %         iSession = ia(iNeuron);
% %         if numel(sessionTs) < iSession
% %             sessionTs{ia(iNeuron)} = []; % init
% %             sevFile = LFPfiles_local{iNeuron}; % pluck one sev from the session
% %             disp(sevFile);
% %             [sevFilt,Fs,decimateFactor] = loadCompressedSEV(sevFile);
% %             tsEndArr(iSession) = numel(sevFilt)/Fs;
% %         end
% %         sessionTs{iSession} = [sessionTs{iSession} all_ts{iNeuron}']; % compile
% %     end
% % end
% % 
% % decimateFactor = 20;
% % if compileWs
% %     savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/wholeSession/saved_Ws';
% %     [uniqueLFPs_local,ic,ia] = unique(LFPfiles_local);
% %     for iFile = 1:numel(uniqueLFPs_local)
% %         sevFile = uniqueLFPs_local{iFile};
% %         disp(sevFile);
% %         [sev,header] = read_tdt_sev(sevFile);
% %         sevFilt = decimate(double(sev),decimateFactor);
% %         Fs = header.Fs / decimateFactor;
% %         W = calculateComplexScalograms_EnMasse(sevFilt','Fs',Fs,'freqList',freqList);
% %         W = squeeze(W);
% %         save(fullfile(savePath,[num2str(iFile,'%03d'),'W']),'W','Fs','decimateFactor','ic','ia');
% %     end
% % end

freqList = logFreqList([1 200],10);
sampleInt = 50;
tWindow = 1;
if doBurst
    savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/wholeSession/spikeTriggeredAvg_ISI';
else
    savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/wholeSession/spikeTriggeredAvg';
end
for iNeuron = 1:numel(all_ts)
    curTs = all_ts{iNeuron};
    curTrials = all_trials{iNeuron};
    trialTimeRanges = compileTrialTimeRanges(curTrials);
    if doBurst
        [tsISI,tsLTS,tsPoisson] = tsBurstFilters(curTs);
        curTs = tsISI;
    end
% %     curTs_shuffled = curTs(randperm(numel(curTs))); % not needed
    curTs_random = rand([1 numel(curTs)*2]) * max(curTs);
    sevFile = LFPfiles_local{iNeuron};
    disp([num2str(iNeuron),': ',sevFile]);
%     [sevFilt,Fs,decimateFactor] = loadCompressedSEV(sevFile);
%     tsEnd = numel(sevFilt)/Fs;
%     W = calculateComplexScalograms_EnMasse(sevFilt','Fs',Fs,'freqList',freqList);
%     W = squeeze(W);
%     W_power = abs(W).^2;
%     W_phase = angle(W);
%     tW = linspace(0,tsEnd,size(W,1));
%     Wsamples = round((size(W,1) / tsEnd) * tWindow);
    STAArr_power = [];
    STAArr_phase = [];
    
    allFreq_power_inTrial = [];
    allFreq_phase_inTrial = [];
    allFreq_power_outTrial = [];
    allFreq_phase_outTrial = [];
    % breaking it up by freq, otherwise structures become too large
    allFreq_power_inTrial = zeros(numel((-Wsamples:sampleInt:Wsamples)),numel(freqList));
    allFreq_phase_inTrial = allFreq_power_inTrial;
    allFreq_power_outTrial = allFreq_power_inTrial;
    allFreq_phase_outTrial = allFreq_power_inTrial;
    for iFreq = 1:numel(freqList)
        STAArr_power = zeros(2,numel(curTs),size(allFreq_power_inTrial,1));
        STAArr_phase = STAArr_power;
        disp(['working on ',num2str(freqList(iFreq)),' Hz...']);
        setupFlag = true;
        useTs = curTs;
        forSpikes = numel(curTs);
        exitAfter = forSpikes;
        spikeCount = 0;
        used_ts = [];
        for iSurr = 1:2
            if setupFlag && iSurr == 2
                useTs = curTs_random;
                exitAfter = spikeCount;
                forSpikes = exitAfter * 2;
                spikeCount = 0;
                setupFlag = false;
            end
            for iSpike = 1:forSpikes % first loop up to numel(curTs), second loop just meets spikeCount
                Wcenter = round((size(W,1) / tsEnd) * useTs(iSpike)); %find(tW > useTs(iSpike),1);
                Wrange = Wcenter - Wsamples:sampleInt:Wcenter + Wsamples;
                if min(Wrange) < 1 || max(Wrange) > size(W_power,1)
                    continue;
                end
                if max(max(W_power(Wrange,iFreq))) < 1e5 % power filter
                    spikeCount = spikeCount + 1;
                    STAArr_power(iSurr,spikeCount,:) = W_power(Wrange,iFreq);
                    STAArr_phase(iSurr,spikeCount,:) = W_phase(Wrange,iFreq);
                    if iSurr == 1
                        used_ts(spikeCount) = useTs(iSpike);
                    end
                else
                    if iSurr == 1
                        disp(['overpower: f',num2str(iFreq),', s',num2str(iSpike)]);
                    end
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
        inTrial_ids = [];
        for ii = 1:size(trialTimeRanges,1)
            inTrial_ids = [inTrial_ids find(used_ts > trialTimeRanges(ii,1) & used_ts <= trialTimeRanges(ii,2))];
        end
        outTrial_ids = ones(1,numel(used_ts));
        outTrial_ids(inTrial_ids) = 0;
        outTrial_ids = find(outTrial_ids == 1);
        
        STAArr_power_surr = mean(squeeze(STAArr_power(2,:,:)));
        STAArr_power_zMean = mean(STAArr_power_surr);
        STAArr_power_zStd = std(STAArr_power_surr);
        STAArr_power_inTrial = mean(squeeze(STAArr_power(1,inTrial_ids,:)));
        STAArr_power_z_inTrial = (STAArr_power_inTrial - STAArr_power_zMean) ./ STAArr_power_zStd;
        STAArr_power_outTrial = mean(squeeze(STAArr_power(1,outTrial_ids,:)));
        STAArr_power_z_outTrial = (STAArr_power_outTrial - STAArr_power_zMean) ./ STAArr_power_zStd;

        STAArr_phase_surr = circ_r(squeeze(STAArr_phase(2,:,:)));
        STAArr_phase_zMean = mean(STAArr_phase_surr);
        STAArr_phase_zStd = std(STAArr_phase_surr);
        STAArr_phase_inTrial = circ_r(squeeze(STAArr_phase(1,inTrial_ids,:)));
        STAArr_phase_z_inTrial = (STAArr_phase_inTrial - STAArr_phase_zMean) ./ STAArr_phase_zStd;
        STAArr_phase_outTrial = circ_r(squeeze(STAArr_phase(1,outTrial_ids,:)));
        STAArr_phase_z_outTrial = (STAArr_phase_outTrial - STAArr_phase_zMean) ./ STAArr_phase_zStd;

        allFreq_power_inTrial(:,iFreq) = STAArr_power_z_inTrial;
        allFreq_phase_inTrial(:,iFreq) = STAArr_phase_z_inTrial;
        allFreq_power_outTrial(:,iFreq) = STAArr_power_z_outTrial;
        allFreq_phase_outTrial(:,iFreq) = STAArr_phase_z_outTrial;
    end
    
    h = figuree(600,500);
    t = linspace(-tWindow,tWindow,size(allFreq_power_inTrial,1));
    subplot(221);
    imagesc(t,freqList,allFreq_power_inTrial');
    title({['u',num2str(iNeuron,'%03d')],'Power IN'}); hold on;
    
    subplot(223);
    imagesc(t,freqList,allFreq_phase_inTrial');
    title('MRL IN'); hold on;
    
    subplot(222);
    imagesc(t,freqList,allFreq_power_outTrial');
    title({['u',num2str(iNeuron,'%03d')],'Power OUT'}); hold on;
    
    subplot(224);
    imagesc(t,freqList,allFreq_phase_outTrial');
    title('MRL OUT'); hold on;
    
    for iSubplot = 1:4
        subplot(2,2,iSubplot);
        xlabel('time (s)');
        xlim([-tWindow,tWindow]);
        xticks(sort([0 xlim]));
        curyLim = ylim;
        ytickLocs = linspace(curyLim(1),curyLim(2),size(allFreq_power_inTrial,2));
        yticks(ytickLocs);
        yticklabels({num2str(freqList(:),'%2.1f')});
        ylabel('freq (Hz)');
        set(gca,'ydir','normal');
        colormap(jet);
        caxis([-20 20]);
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