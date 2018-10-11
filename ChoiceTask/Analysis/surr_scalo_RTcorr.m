function [surr_scalo_RTcorr,surr_log_scalo_RTcorr,std_surr_scalo_RTcorr,std_surr_log_scalo_RTcorr] = surr_scalo_RTcorr(trials,sevFilt,tWindow,scaloWindow,Fs,freqList,eventList)
% upperPrctile = 85;
% lowerPrctile = 15;
lfpThresh = 0.5e6; % diff uV^2, *this depends on decimate factor, need to generalize it

fullWin = [-1 1] * tWindow;

windowSamples = round(Fs * tWindow);
scaloSamples = round(Fs * scaloWindow);
scaloSampleRange = (windowSamples - scaloSamples) : (windowSamples + scaloSamples) - 1;

RT = [];
trialStart = [];
trialEnd = [];
for iTr = 1 : length(trials)
    RT = [RT;trials(iTr).timing.RT];
    trialStart = [trialStart;trials(iTr).timestamps.cueOn];
    trialEnd = [trialEnd;trials(iTr).timestamps.foodRetrieval];
end
RT = RT(trialStart > -fullWin(1));
RT = RT(trialEnd < (length(sevFilt)/Fs - fullWin(2)));

scalo_RTcorr = zeros(length(eventList),length(freqList),scaloSamples*2);
log_scalo_RTcorr = zeros(length(eventList),length(freqList),scaloSamples*2);
for iEvent = 1 : length(eventList)
    scaloData = zeros(length(RT),windowSamples*2+1);
    for iTrial = 1 : length(trials)
        if trialStart(iTrial) < (-fullWin(1)); continue; end    % trial too early to include a full time window
        if trialEnd(iTrial) > (length(sevFilt)/Fs-fullWin(2)); continue; end    % trial too late to include a full time window
        
        midSamp = round(trials(iTrial).timestamps.(eventList{iEvent}) * Fs);
        sampRange = midSamp-windowSamples : midSamp+windowSamples;
        scaloData(iTrial,:) = sevFilt(sampRange);
    end
    [W, freqList] = calculateComplexScalograms_EnMasse(scaloData,'Fs',Fs,'freqList',freqList,'doplot',false);
    W = squeeze(W(:,scaloSampleRange,:));
    LFPpower = abs(W).^2;
    log_LFPpower = log10(LFPpower);
    
    for iFreq = 1 : size(W,3)
        for iSamp = 1 : size(W,2)
            q = squeeze(LFPpower(:,iSamp,iFreq));
            [a,~] = corrcoef(q,RT);
            scalo_RTcorr(iEvent,iFreq,iSamp) = a(1,2);
            
            q = squeeze(log_LFPpower(:,iSamp,iFreq));
            [a,~] = corrcoef(q,RT);
            log_scalo_RTcorr(iEvent,iFreq,iSamp) = a(1,2);
        end
    end
end
%     
% scaloData = [];
% curSpans = allSpans{iSpan};
% if isempty(curSpans)
%     if ~isempty(allScalograms)
%         scaloSize = size(allScalograms);
%         allScalograms(iSpan,:,:) = zeros(scaloSize(2:3));
%         all_logScalograms(iSpan,:,:) = zeros(scaloSize(2:3));
%     end
%     continue; 
% end
% nScalograms = min(length(curSpans),1000);
% 
% scaloCount = 1;
% whileCount = 1;
% while scaloCount < nScalograms
%     randSpanIdx = randi([1,size(curSpans,1)]);
%     midSpan = mean(curSpans(randSpanIdx,:)) / 1000; % seconds
% %         midSpan = curSpans(randSpanIdx,1) / 1000; % seconds
%     sampleRange = [(round(midSpan * Fs) - windowSamples):(round(midSpan * Fs) + windowSamples)-1];
%     if min(sampleRange) > 0 && max(sampleRange) < length(sevFilt)
%         if max(abs(diff(sevFilt(sampleRange))).^2) < lfpThresh
%             scaloData(:,scaloCount) = sevFilt(sampleRange);
%             scaloCount = scaloCount + 1;
%         else
%             disp(['skipping ',num2str(randSpanIdx),' (lfp thresh)']);
%         end
%     end
%     whileCount = whileCount + 1;
%     if whileCount > 2000
%         disp('exceeding while loop');
%         break;
%     end
% end
% [W, freqList] = calculateComplexScalograms_EnMasse(scaloData,'Fs',Fs,'freqList',freqList,'doplot',false);
% allScalograms(iSpan,:,:) = squeeze(mean(abs(W(scaloSampleRange,:,:).^2),2))';
% all_logScalograms(iSpan,:,:) = squeeze(mean(log10(abs(W(scaloSampleRange,:,:).^2)),2))';
% Wangle = angle(W(scaloSampleRange,:,:));
% mrl = squeeze(mean(exp(1i*Wangle), 2));
% allMRL(iSpan,:,:) = mrl';