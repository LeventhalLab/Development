% code from simpleFFT.m
% load('session_20180925_entrainmentSurrogates.mat', 'LFPfiles_local')
% load('session_20180925_entrainmentSurrogates.mat', 'selectedLFPFiles')
% load('session_20180925_entrainmentSurrogates.mat', 'all_trials')
% load('session_20181129_sub_allA.mat')
doSetup = false;
doSave = false;

makeLength = 400000;
nSmooth = makeLength / 1000;
if doSetup
    for iInOut = 1:2
        if iInOut == 1
            useInTrial = true;
        else
            useInTrial = false;
        end
        iSession = 0;
        all_A = [];
        for iNeuron = selectedLFPFiles'
            iSession = iSession + 1;
            disp(iSession);
            sevFile = LFPfiles_local{iNeuron};
            [sevFilt,Fs,decimateFactor] = loadCompressedSEV(sevFile,[]);

            curTrials = all_trials{iNeuron};
            trialTimeRanges = compileTrialTimeRanges(curTrials);
            trialTimeRanges_s = round(trialTimeRanges*Fs);
            sample_range = [];
            if useInTrial
                for iTrial = 2:size(trialTimeRanges,1)-1
                    sample_range = [sample_range trialTimeRanges_s(iTrial,1):trialTimeRanges_s(iTrial,2)];
                end
            else
                for iTrial = 2:size(trialTimeRanges,1)-1
                    sample_range = [sample_range (trialTimeRanges_s(iTrial,1):trialTimeRanges_s(iTrial,2))+round((rand-0.5)*10*Fs)];
                end
            end
            sevFilt = sevFilt(sample_range) - mean(sevFilt(sample_range));
            [A,f] = getFFT(sevFilt,Fs);
            Anew = equalVectors(A,zeros(1,makeLength));
            all_A(iSession,:) = Anew;
        end
        if iInOut == 1
            all_A_in = all_A;
        else
            all_A_out = all_A;
        end
    end
    fnew = equalVectors(f,zeros(1,makeLength));
end
save('session_20181129_sub_allA','all_A_in','all_A_out');
h = figure;
data_out = (smooth(median(all_A_out),nSmooth));
loglog(fnew,data_out,'lineWidth',2,'color','r');
hold on;

data_in = (smooth(median(all_A_in),nSmooth));
loglog(fnew,data_in,'lineWidth',2,'color','k');
xmarks = [4 7 13 30 70];
xticks(xmarks);
xlim([1 200]);
for ii = 1:numel(xmarks)
    plot([xmarks(ii) xmarks(ii)],ylim,':','color',repmat(.8,[1,4]));
end
bandLabels = {'\delta','\theta','\alpha','\beta','\gamma','\gamma_h'};
bandLocs = [2,5.5,10,21.5,50,135];
for ii = 1:numel(bandLabels)
    text(bandLocs(ii),min(ylim) + mean(ylim)/4,bandLabels{ii},'color','k','fontSize',16,'horizontalAlignment','center');
end

xlabel('log freq. (Hz)');
% ylim([0.035 0.2]);
yticks([]);
ylabel('log power (uv^2)');
title('Median Spectrum All Sessions');
legend({'OUT trial','IN trial'});
set(gca,'fontSize',16);
set(gcf,'color','w');

if doSave
    saveas(h,fullfile(savePath,'sessionsFFT.png'));
    close(h);
end

function [A,f] = getFFT(data,Fs)
    T = 1/Fs; % Sample time
    L = length(data); % Length of signal
    t = (0:L-1)*T; % Time vector
    NFFT = 2^nextpow2(L); % Next power of 2 from length of y
    f = Fs/2*linspace(0,1,NFFT/2+1);

    Y = fft(double(data),NFFT)/L;
    A = 2*abs(Y(1:NFFT/2+1));
end