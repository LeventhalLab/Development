function RTcorr = calcRTcorrelations(s, trials, twin, Fs, eventList)

eventList = {'cueOn','centerIn','tone','centerOut','sideIn','sideOut','foodRetrieval'};
samps_pre = floor(range(twin) * Fs / 2);
numSamps = samps_pre * 2 + 1;
RTcorr = zeros(length(eventList), numSamps);

RT = [];
trialStart = [];
trialEnd = [];
for iTr = 1 : length(trials)
    RT = [RT;trials(iTr).timing.RT];
    trialStart = [trialStart;trials(iTr).timestamps.cueOn];
    trialEnd = [trialEnd;trials(iTr).timestamps.foodRetrieval];
end
RT = RT(trialStart > -twin(1));
RT = RT(trialEnd < (length(s)/Fs - twin(2)));

s_matrix = zeros(length(RT),numSamps);
for iEvent = 1 : length(eventList)
    
    for iTr = 1 : length(trials)
        
        centerSamp = round(trials(iTr).timestamps.(eventList{iEvent}) * Fs);
        sampIdx = centerSamp - samps_pre : centerSamp + samps_pre;
        
%         if sampIdx(1) < 1 || sampIdx(end) > length(s)
%             continue;
%         end
        
        s_matrix(iTr,:) = s(sampIdx);
        
    end
    
    for iSamp = 1 : numSamps
        test_s = squeeze(s_matrix(:,iSamp));
        [a,~] = corrcoef(RT, test_s);
        RTcorr(iEvent,iSamp) = a(1,2);
    end
    
end
