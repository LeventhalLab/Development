function [] = calc_Power(amp_data, laser_data, pulses, type, sample_rate)

fs = 500; % desired sample rate after decimating (can change this)

on_index = find(laser_data > 0.25);

j=1;
laser_on(1) = on_index(1);
for i = 1:length(on_index) - 1
    if on_index(i+1) - on_index(i) > 1
        laser_off(j) = on_index(i);
        laser_on(j+1) = on_index(i+1);
        j=j+1;
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

else % if continuous pulses
    
    pulse_start = laser_on;
    pulse_end = laser_off;
    
end


figure;
t = linspace(0, length(amp_data)/sample_rate, length(amp_data));
plot(t, amp_data);
hold on;

yL = get(gca,'YLim');
xlim([0 length(amp_data)/sample_rate]);

for i=1:pulses
    l1 = line([pulse_start(i)/sample_rate pulse_start(i)/sample_rate], yL, 'Color', 'g');
    l2 = line([pulse_end(i)/sample_rate pulse_end(i)/sample_rate], yL, 'Color', 'r');
end

lgd = legend([l1 l2], 'ON','OFF');
title(lgd, 'Laser');

if type
    disp_type = ' - High Freq';
else
    disp_type = ' - Continuous';
end

title(['Amplifier Data & Laser Voltage' disp_type]);
xlabel('Time (s)');
hold off;


% power spectrum on
M = round(sample_rate / fs);
fxx = 1:100;

pxx_on = zeros(pulses,100);
ci_on = zeros(pulses,100,2);


%figure;
%subplot(2,1,1);
for i=1:pulses
    dec_on = decimate(amp_data(pulse_start(i):pulse_end(i)), M, 'fir');
    [pxx_on(i,:), ~, ci_on(i,:,:)] = pwelch(dec_on, [], [], 1:100, 500, 'ConfidenceLevel', 0.95);
   % plot(fxx, smooth(10*log10(pxx_on(i,:)), 5));
   % hold on;
end
%title('Power Spectrum - Laser ON');
%xlabel('Frequency (Hz)');
%ylabel('Power');
%hold off;

% power spectrum off
%subplot(2,1,2);

pxx_off = zeros(pulses+1,100);
ci_off = zeros(pulses+1,100,2);

dec_off = decimate(amp_data(1:pulse_start(1)), M, 'fir');
[pxx_off(1,:), ~, ci_off(1,:,:)] = pwelch(dec_off, [], [], 1:100, 500, 'ConfidenceLevel', 0.95);

%plot(fxx, smooth(10*log10(pxx_off(1,:)), 5));
%hold on;

if pulses > 1
    for j=1:pulses-1
        dec_off = decimate(amp_data(pulse_end(j):pulse_start(j+1)), M, 'fir');
        [pxx_off(j+1,:), ~, ci_off(j+1,:,:)] = pwelch(dec_off, [], [], 1:100, 500, 'ConfidenceLevel', 0.95);
        
        %plot(fxx, smooth(10*log10(pxx_off(j+1,:)), 5));
        %hold on;
    end
end

j = pulses;
dec_off = decimate(amp_data(pulse_end(j):end), M, 'fir');
[pxx_off(j+1,:), ~, ci_off(j+1,:,:)] = pwelch(dec_off, [], [], 1:100, 500, 'ConfidenceLevel', 0.95);

%plot(fxx, smooth(10*log10(pxx_off(j+1,:)), 5));
%title('Power Spectrum - Laser OFF');
%xlabel('Frequency (Hz)');
%ylabel('Power');
%hold off;


% average PS
ave_on = zeros(1,100);
ave_off = zeros(1,100);
ave_ci_on = zeros(2,100);
ave_ci_off = zeros(2,100);

for i = 1:100
    ave_on(i) = mean(pxx_on(:,i));
    ave_ci_on(1,i) = mean(ci_on(:,i,1));
    ave_ci_on(2,i) = mean(ci_on(:,i,2));
    ave_off(i) = mean(pxx_off(:,i));
    ave_ci_off(1,i) = mean(ci_off(:,i,1));
    ave_ci_off(2,i) = mean(ci_off(:,i,2));
end

% plot average PS for laser ON/OFF and CI
figure;
p1 = plot(fxx, smooth(10*log10(ave_on), 5), 'Color', 'g', 'DisplayName', 'Laser ON');
hold on;
ci1 = plot(fxx, smooth(10*log10(ave_ci_on(1,:)), 5), 'Color', 'g', 'LineStyle', ':', 'DisplayName', '95% CI');
hold on;
plot(fxx, smooth(10*log10(ave_ci_on(2,:)), 5), 'Color', 'g', 'LineStyle', ':');
hold on;

p2 = plot(fxx, smooth(10*log10(ave_off), 5), 'Color', 'r', 'DisplayName', 'Laser OFF');
hold on;
ci2 = plot(fxx, smooth(10*log10(ave_ci_off(1,:)), 5), 'Color', 'r', 'LineStyle', ':', 'DisplayName', '95% CI');
hold on;
plot(fxx, smooth(10*log10(ave_ci_off(2,:)), 5), 'Color', 'r', 'LineStyle', ':');
hold on;
legend([p1 p2 ci1 ci2]);
hold on;

ylim([-20 30]);
ylabel('Power');
xlabel('Frequency (Hz)');
title('Power Spectrum');
set(findall(gcf, '-property', 'FontSize'), 'FontSize', 10);

hold off;


end