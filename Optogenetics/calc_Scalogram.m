function [] = calc_Scalogram(amp_data, laser_data, pulses, type, time_extra, sample_rate, full)

fs = 500; % desired sample rate after decimating (can change this)

if type ~= 2
on_index = find(laser_data > 0.1);
j = 1;
laser_on(1) = on_index(1);
for i = 1:length(on_index) - 1
    if on_index(i+1) - on_index(i) > 1
        laser_off(j) = on_index(i);
        laser_on(j+1) = on_index(i+1);
        j = j+1;
    end
end
laser_off(j) = on_index(end);
  

if type % high freq pulses
    
    % get pulse starts/ends
    pulse_start = zeros(1,pulses);
    pulse_end = zeros(1,pulses);
    
    pulse_start(1) = laser_on(1);
    p=2;
    for i=2:length(laser_on)
        if laser_on(i) - laser_on(i-1) > 2*sample_rate
            pulse_start(p) = laser_on(i);
            pulse_end(p-1) = laser_off(i-1);
            p=p+1;
        end
    end
    pulse_end(pulses) = laser_off(end);

else
    
    pulse_start = laser_on;
    pulse_end = laser_off;
    
end
end

% decimate
M = round(sample_rate/fs);

if ~full
    extra = round(time_extra*sample_rate);
    
    len_pulse = pulse_end(1) - pulse_start(1);
    
    % if you clicked too close to the first pulse so that 'extra' exceeds window
    if extra > pulse_start(1)
        extra = pulse_start(1) - 1;
    end
    
    % or too close to the last...
    if (pulse_start(pulses) + len_pulse + extra) > length(laser_data)
        extra = length(laser_data) - pulse_end(pulses) - 1;
    end
    
    for i = 1:pulses
        data(:,i) = decimate(amp_data(pulse_start(i) - extra:pulse_start(i) + len_pulse + extra) , M, 'fir');
    end
    %time = (1:1:length(data(:,i)))/fs;

else
    
    data(:,1) = decimate(amp_data, M, 'fir');
    %time = (1:1:length(data(:,1)))/fs;

end

%figure;

%W = calculateComplexScalograms_EnMasse(data, 'freqlist', 1:100, 'Fs', fs, 'kernelwidth', 1,'doplot',true);
calculateComplexScalograms_EnMasse(data, 'freqlist', 1:100, 'Fs', fs, 'kernelwidth', 1,'doplot',true);
caxis([0 1000]);
%figure;
%imagesc(time, 1:100, log(squeeze(mean(abs(W).^2, 2)))');

if type == 0
    title('Spectrogram - Continuous Pulses');
elseif type == 1
    title('Spectrogram - High Freq Pulses');
elseif type == 2
    title('Spectrogram - No Stimulation');
else
    title('Spectrogram');
end

ylabel('Frequency (Hz)');
xlabel('Time (s)');
set(gca, 'YDir', 'normal');
%yL = get(gca,'YLim');

if type ~= 2
if full

    for i = 1:pulses
        l1 = line([pulse_start(i)/sample_rate pulse_start(i)/sample_rate], [0 5], 'Color', 'w');
        l2 = line([pulse_end(i)/sample_rate pulse_end(i)/sample_rate], [0 5], 'Color', 'r');
    end
    
    lgd = legend([l1 l2], 'Pulses Start','Pulses Stop');
    set(lgd,'Location','northeastoutside');
        
    
else
    
    las = line([extra/sample_rate extra/sample_rate], [0 5], 'Color', 'w');
    line([(extra + len_pulse)/sample_rate (extra + len_pulse)/sample_rate], [0 5], 'Color', 'w');
    lgd=legend(las, 'Laser ON/OFF');
    set(lgd, 'Location','northeastoutside');
    
end
end

set(findall(gcf, '-property', 'FontSize'), 'FontSize', 10);


end