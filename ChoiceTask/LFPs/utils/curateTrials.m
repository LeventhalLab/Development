function [trials,trialsMap] = curateTrials(trials,sevFilt,Fs,eventName)
% passing in only successful trials
trialTimeRanges = getTrialTimes(trials);
minTime = min(trialTimeRanges(:,1));
maxTime = max(trialTimeRanges(:,2));

% check real event compliance
% recursive add event until compliant
trialCount = 0;
trialsMap = [];
for iTrial = 1:numel(trials)
    if ~any(isnan(trialTimeRanges(iTrial,:))) && ...
            isTrialCompliant(trialTimeRanges(iTrial,1),trialTimeRanges(iTrial,2),sevFilt,Fs)
        % log trial, save ID
        trialCount = trialCount + 1;
        trialsMap = [trialsMap iTrial];
        setEvent = true;
        close all
        if ~isempty(eventName)
            while(setEvent)
                randTs = (maxTime-minTime) .* rand + minTime;
                if (randTs+diff(trialTimeRanges(iTrial,:)))*Fs < numel(sevFilt) && ...
                        isTrialCompliant(randTs,randTs+diff(trialTimeRanges(iTrial,:)),sevFilt,Fs)
                    trials(iTrial).timestamps = setfield(trials(iTrial).timestamps,eventName,randTs);
                    setEvent = false;
                end
            end
        end
    end
end
trials = trials(trialsMap);
end

function compliant = isTrialCompliant(startTime,endTime,sevFilt,Fs)
snippet = sevFilt(round(startTime*Fs):round(endTime*Fs));
[b,a] = butter(4, [1/(Fs/2) 100/(Fs/2)]); % 1-200Hz
lpfilt = filtfilt(b,a,double(snippet));
[b,a] = butter(4, [200/(Fs/2) .9999]); % 1-200Hz
hpfilt = filtfilt(b,a,double(snippet));
compliant = true;
if any(abs(diff(lpfilt)).^2 > 6000)
    compliant = false;
end

% h1 = ff(1200,800);
% gcas = [];
% gcas(1) = subplot(411);
% plot(snippet);
% title('raw');
% gcas(2) = subplot(412);
% plot(lpfilt);
% title('low pass');
% gcas(4) = subplot(413);
% plot(abs(diff(lpfilt)).^2);
% title('abs diff lp energy');
% ylim([0 10000]);
% gcas(3) = subplot(414);
% plot(abs(diff(hpfilt)).^2);
% title('abs diff hp energy');
% ylim([0 1000000]);
% linkaxes(gcas,'x');

end

function trialTimeRanges = getTrialTimes(trials)
trialTimeRanges = NaN(numel(trials),2);
for iTrial = 1:numel(trials)
    if isfield(trials(iTrial).timestamps,'cueOn')
        trialTimeRanges(iTrial,1) = getfield(trials(iTrial).timestamps,'cueOn');
        if isfield(trials(iTrial).timestamps,'foodRetrieval')
            trialTimeRanges(iTrial,2) = getfield(trials(iTrial).timestamps,'foodRetrieval');
        end
    end
end
end