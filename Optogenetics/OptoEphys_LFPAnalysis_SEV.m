% LFP analysis for opto/ephys SEV files

load_data = true; % false if data is already loaded
laser_file = '\\172.20.138.142\RecordingsLeventhal2\ChoiceTask\R0181\R0181-opto\R0181_20170525_cylinder\R0181_20170525c_cylinder-6\R0181_20170525c_cylinder_R0181_20170525c_cylinder-6_data_ch65.sev';
ephys_file = '\\172.20.138.142\RecordingsLeventhal2\ChoiceTask\R0181\R0181-opto\R0181_20170525_cylinder\R0181_20170525c_cylinder-6\R0181_20170525c_cylinder_R0181_20170525c_cylinder-6_data_ch26.sev';


power_spectrum = false; % show PS figure (ave power on/off per pulse - single train)

scalogram = false; % show scalogram figure (for one type/train)
time_extra = 5; % seconds to show before/after pulse in scalogram (if full = false)
full = true; % show full train

% train info (for scalogram & power_spectrum)
pulses = 20; % pulses per train being analyzed
type = 0; % 0 for continuous pulses, 1 for high freq pulses, 2 for no stimulation

fft = true; % show fft of each type (continuous, high freq, no stim)
ps = true; % show PS figure - power spectrum for each type (continuous, high freq, no stim)



%% 




if load_data
    [laserData,~] = read_tdt_sev(laser_file);
    [ephysData,header] = read_tdt_sev(ephys_file);
end

sample_rate = header.Fs;

if power_spectrum || scalogram
    figure;
    plot(laserData);
    xlim([0 length(laserData)]);
    title('Click start & end of single train');
    [points,~] = ginput(2);
    close(gcf);
    
    laser_window = laserData(round(points(1)):round(points(2)))/(10^6);
    amp_window = double(ephysData(round(points(1)):round(points(2))));
end


if power_spectrum
    calc_Power(amp_window, laser_window, pulses, type, sample_rate);
end

if scalogram
    calc_Scalogram(amp_window, laser_window, pulses, type, time_extra, sample_rate, full);
end

if fft
    calc_FFT(ephysData, laserData, sample_rate, ps);
end