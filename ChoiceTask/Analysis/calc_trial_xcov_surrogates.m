function [ mean_surr_xcorr, std_surr_xcorr ] = calc_trial_xcov_surrogates( s, trialTimes, filtLFP, Fs, twin, numSurrogates )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
% s - spike density estimate

sampWin = round(twin * Fs);
numSamps = range(sampWin) + 1;
% mean_xcorr = zeros(1, numSamps);

if size(s,2) == length(s); s = s'; end
if size(filtLFP,2) == length(filtLFP); filtLFP = filtLFP'; end

num_valid_ts = 0;

mean_xcorr = zeros(numSurrogates, numSamps*2-1);

centerSamps = round(trialTimes * Fs);

for ii = 1 : numSurrogates
    jitterTime = rand(length(trialTimes),1) * range(twin) + min(twin);
    surrogate_centerSamps = round((trialTimes + jitterTime) * Fs);
%     trialIdx = randperm(length(trialTimes));
    
    for i_ts = 1 : length(trialTimes)

        centerSamp = centerSamps(i_ts);%round(trialTimes(i_ts) * Fs);
        if centerSamp < (1-sampWin(1)) || centerSamp > length(filtLFP) - sampWin(2)
            continue;
        end
        
        surrogate_centerSamp = surrogate_centerSamps(i_ts);
        if surrogate_centerSamp < (1-sampWin(1)) || surrogate_centerSamp > length(filtLFP) - sampWin(2)
            continue;
        end
        
        num_valid_ts = num_valid_ts + 1;
        sampRange = centerSamp + sampWin;
        surrogate_sampRange = surrogate_centerSamp + sampWin;
        curr_s = s(sampRange(1):sampRange(2));
        curr_LFP = filtLFP(surrogate_sampRange(1):surrogate_sampRange(2));
        curr_xcorr = xcov(curr_s, curr_LFP); 

        all_xcorr(num_valid_ts,:) = curr_xcorr;
    %     STA = STA + lfp(sampRange(1):sampRange(2));

    end
    
    mean_xcorr(ii,:) = mean(all_xcorr,1);
end



mean_surr_xcorr = mean(mean_xcorr,1);
std_surr_xcorr = std(mean_xcorr,0,1);

