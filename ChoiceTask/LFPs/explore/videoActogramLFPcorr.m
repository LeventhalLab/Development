% videoFile = '/Users/mattgaidica/Desktop/R0182_20170723_10-07-55 (Converted).mov';
% frameInterval = 1;
% resizePx = 50;
showCenters = false;
doSetup = false;

freqList = logFreqList([3.5 100],30);
iNeuron = 344;
curTrials = all_trials{iNeuron};

if doSetup
    sevFile = LFPfiles_local{iNeuron};
    disp(sevFile);
    decimateFactor = 10;
    [sev,header] = read_tdt_sev(sevFile);
    sevFilt = decimate(double(sev),decimateFactor);
    sevFilt = artifactThresh(sevFilt,1,1000);
    Fs = header.Fs / decimateFactor;
    W = calculateComplexScalograms_EnMasse(sevFilt','Fs',Fs,'freqList',freqList);
    clear sev;
end

if showCenters
    [trialIds,allTimes] = sortTrialsBy(curTrials,'RT');
    centerTimes = [];
    for iTrial = 1:numel(trialIds)
        centerTimes(iTrial) = curTrials(trialIds(iTrial)).timestamps.centerOut - behaviorStartTime;
    end

    figuree(1400,400);
    plot(frameData(:,2),frameData(:,3));
    hold on;
    plot([centerTimes;centerTimes],[zeros(size(centerTimes));ones(size(centerTimes))],'-k');
end

acto_rs = [];
acto_ps = [];
W_t = round(linspace(1,size(W,1),size(frameData,1)));
for iFreq = 1:numel(freqList)
    disp(num2str(iFreq));
    [R,P] = corrcoef(abs(W(W_t,iFreq).^2),frameData(:,3));
    acto_rs(iFreq) = R(2);
    acto_ps(iFreq) = P(2);
end
figuree(400,800);
subplot(211);
bar(acto_rs);
ylim([-0.05 0.05]);
yticks(sort([ylim,0]));
xlim([0 numel(freqList)+1]);
xticks(1:numel(freqList));
xticklabels({num2str(freqList(:),'%2.1f')});
xtickangle(90);
title('corr (LFP,movement)');
xlabel('Freq (Hz)');
ylabel('r');
set(gca,'fontsize',8);
grid on;

subplot(212);
bar(acto_ps);
ylim([0 1]);
yticks(sort([ylim,0.05]));
xlim([0 numel(freqList)+1]);
xticks(1:numel(freqList));
xticklabels({num2str(freqList(:),'%2.1f')});
xtickangle(90);
title('p-value');
xlabel('Freq (Hz)');
ylabel('p');
set(gca,'fontsize',8);
grid on;