% code from simpleFFT.m
% load('session_20180925_entrainmentSurrogates.mat', 'LFPfiles_local')
% load('session_20180925_entrainmentSurrogates.mat', 'selectedLFPFiles')
% load('session_20180925_entrainmentSurrogates.mat', 'all_trials')
% load('session_20180925_entrainmentSurrogates.mat', 'eventFieldnames')

savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/wholeSession/FFT';

doSetup = false;
doSave = false;

maxTrialTime = 20; % s
makeLength = 400000;
nSmooth = makeLength / 500;
if doSetup
    for iInOut = 1:2
        iSession = 0;
        all_A = [];
        for iNeuron = selectedLFPFiles'
            iSession = iSession + 1;
            disp(iSession);
            sevFile = LFPfiles_local{iNeuron};
            [sevFilt,Fs,decimateFactor] = loadCompressedSEV(sevFile,[]);
            sevFilt = artifactThresh(sevFilt,[1],2000);
            sevFilt = sevFilt - mean(sevFilt);

            trials = all_trials{iNeuron};
            intrialTimeRanges = compileTrialTimeRanges(trials,maxTrialTime);
            [intrialSamples,intertrialSamples] = findIntertrialTimeRanges(intrialTimeRanges,Fs);
            sampleData = {intrialSamples,intertrialSamples};
            sampleRange = [];
            for iTrial = 1:size(intrialSamples,1)
                sampleRange = [sampleRange sampleData{iInOut}(iTrial,1):sampleData{iInOut}(iTrial,2)];
            end
            sevFilt = sevFilt(sampleRange) - mean(sevFilt(sampleRange));
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
% % save('20190404_sessionFFT_setup','all_A_in','all_A_out','fnew');
xlimVals = [1 200];
f1_idx = closest(fnew,xlimVals(1));
f2_idx = closest(fnew,xlimVals(2));
f3_idx = closest(fnew,70);
f4_idx = closest(fnew,150);

norm_data_out = [];
norm_data_in = [];
% % ff(500,500);
for ii = 1:size(all_A_out,1)
    data_out = (all_A_out(ii,f1_idx:f2_idx) - mean(all_A_out(ii,f3_idx:f4_idx))) ./ std(all_A_out(ii,f3_idx:f4_idx));
    norm_data_out(ii,:) = data_out;
    data_in = (all_A_in(ii,f1_idx:f2_idx) - mean(all_A_in(ii,f3_idx:f4_idx))) ./ std(all_A_in(ii,f3_idx:f4_idx));
    norm_data_in(ii,:) = data_in;
% %     plot(smooth(data_out,nSmooth));
% %     hold on;
end
usef = linspace(xlimVals(1),xlimVals(2),size(norm_data_in,2));
% save('session_20181129_sub_allA','all_A_in','all_A_out','fnew');
h = figure;
norm_med_out = smooth(mean(norm_data_out),nSmooth);
plot(usef,norm_med_out,'lineWidth',2,'color','r');
hold on;

norm_med_in = smooth(mean(norm_data_in),nSmooth);
plot(usef,norm_med_in,'lineWidth',2,'color','k');
% set(gca,'xscale','log');

xmarks = [4 8 13 30 70];
xticks(xmarks);
xlim(xlimVals);
xtickangle(270);
for ii = 1:numel(xmarks)
    plot([xmarks(ii) xmarks(ii)],ylim,':','color',repmat(.8,[1,4]));
end
bandLabels = {'\delta','\theta','\alpha','\beta','\gamma_L','\gamma_H'};
bandLocs = [2,5.5,10,21.5,50,135];
for ii = 1:numel(bandLabels)
    text(bandLocs(ii),min(ylim) + mean(ylim)/4,bandLabels{ii},'color','k','fontSize',16,'horizontalAlignment','center');
end

xlabel('freq. (Hz)');
% ylim([0.035 0.2]);
yticks([]);
ylabel('power (uv^2)');
title('Mean Spectrum All Sessions');
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