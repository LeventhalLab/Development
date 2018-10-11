function [mean_surr_RTcorr, std_surr_RTcorr] = calcRTcorr_surrogates(s, trials, twin, Fs, numSurrogates, eventList)

samps_pre = floor(range(twin) * Fs / 2);
numSamps = samps_pre * 2 + 1;
RTcorr = zeros(numSurrogates, numSamps);
mean_surr_RTcorr = zeros(length(eventList), numSamps);
std_surr_RTcorr = zeros(length(eventList), numSamps);

RT = [];
trialStart = [];
trialEnd = [];
for iTr = 1 : length(trials)
    RT = [RT;trials(iTr).timing.RT];
    trialStart = [trialStart;trials(iTr).timestamps.cueOn];
    trialEnd = [trialEnd;trials(iTr).timestamps.foodRetrieval];
end
RT = RT(trialStart > -twin(1));
RT = RT(trialEnd < length(s)/Fs - twin(2));

s_matrix = NaN(length(trials),numSamps);

for iEvent = 1 : length(eventList)
    for iSurrogate = 1 : numSurrogates
    
        rand_RTidx = randperm(length(RT));
        for iTr = 1 : length(trials)

            centerSamp = round(trials(iTr).timestamps.(eventList{iEvent}) * Fs);
            sampIdx = centerSamp - samps_pre : centerSamp + samps_pre;

%             if sampIdx(1) < 1 || sampIdx(end) > length(s)
%                 continue;
%             end

            s_matrix(iTr,:) = s(sampIdx);

        end

        for iSamp = 1 : numSamps
            test_s = squeeze(s_matrix(:,iSamp));
            [a,~] = corrcoef(RT(rand_RTidx), test_s);
            RTcorr(iSurrogate,iSamp) = a(1,2);
        end
    end
    mean_surr_RTcorr(iEvent,:) = mean(RTcorr,1);
    std_surr_RTcorr(iEvent,:) = std(RTcorr,0,1);
end