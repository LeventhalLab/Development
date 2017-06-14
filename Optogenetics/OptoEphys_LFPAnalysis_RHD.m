% LFP analysis for opto/ephys RHD files

load_data = false; % true if data needs to be loaded
file = '\\172.20.138.142\RecordingsLeventhal2\OptoEphys\R0177\R0177-rawdata\052417_opto\R0177_052417_optoephys4_170524_174455.rhd';

channel=20;

power_spectrum = false; % show PS figure (ave power on/off per pulse - single train)

scalogram = true; % show scalogram figure
time_extra = 2.5; % seconds to show before/after pulse in scalogram (if full = false)
full = false; % show full train

% train info (for scalogram & power_spectrum)
pulses = 10; % pulses per train being analyzed
type = 0; % 0 for continuous pulses, 1 for high freq pulses, 2 for no stimulation

fft = true; % show fft of each type (continuous, high freq, no stim)
ps = true; % show PS figure - power spectrum for each type (continuous, high freq, no stim)






%% 





if load_data
    read_Intan_RHD2000_file(file);
end

sample_rate = frequency_parameters.amplifier_sample_rate;

if power_spectrum || scalogram
% click figure to set window
figure;
plot(board_adc_data(1,:));
xlim([0 length(board_adc_data(1,:))]);
title('Click start & end of single train');
[points,~] = ginput(2);
close(gcf);

laser_window = board_adc_data(1, round(points(1)):round(points(2)));
amp_window = amplifier_data(channel+1, round(points(1)):round(points(2)));
end

if power_spectrum
    calc_Power(amp_window, laser_window, pulses, type, sample_rate);
end

if scalogram
    calc_Scalogram(amp_window, laser_window, pulses, type, time_extra, sample_rate, true);
end

if fft
    calc_FFT(amplifier_data(channel+1,:), board_adc_data(1,:), sample_rate, ps);
end
