% load('session_20180804_ERPAC.mat', 'LFPfiles_local');
% load('session_20180901_SpikePhaseAllFreq.mat', 'analysisConf');
% load('session_20181106_entrainmentData.mat', 'all_trials');
% load('session_20181106_entrainmentData.mat', 'selectedLFPFiles');
doSetup = false;
if doSetup
    load('/Users/mattgaidica/Documents/Data/ChoiceTask/R0182/R0182-processed/R0182_20170723a/R0182_20170723a_finished/R0182_20170723a.nex.mat');
    behaviorStartTime = getBehaviorStartTime(nexStruct);
    iNeuron = 344;
    curTrials = all_trials{iNeuron};
    sevFile = LFPfiles_local{iNeuron};
    [sevFilt,Fs,decimateFactor] = loadCompressedSEV(sevFile,[]);
    delta_data = eegfilt(sevFilt,Fs,1,4);
    gamma_data = eegfilt(sevFilt,Fs,30,70);
    
    hx_delta = hilbert(delta_data);
    power_delta = abs(hx_delta);
    delta_z = (power_delta - mean(power_delta)) ./ std(power_delta);
    
    hx_gamma = hilbert(gamma_data);
    power_gamma = abs(hx_gamma);
    gamma_z = (power_gamma - mean(power_gamma)) ./ std(power_gamma);
end

smooth_gamma = smooth(gamma_z,round(Fs*2)).^2;
smooth_delta = smooth(delta_z,round(Fs*2)).^2;
[locs,pks] = peakseek(smooth_delta,Fs,1);
delta_locs = locs(smooth_gamma(locs) < 1);
delta_time = (delta_locs / Fs)' - behaviorStartTime;
delta_time_fmt = datestr(seconds(delta_time),'MM:SS');

figure;
plot(smooth_gamma,'lineWidth',2);
hold on;
plot(smooth_delta,'lineWidth',2);
plot(locs,pks,'ro');