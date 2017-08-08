function [] = calc_FFT(amp_data, laser_data, sample_rate, ps)
points = zeros(3,2);
figure;

for i=1:5
    
    plot(laser_data);
    xlim([0 length(laser_data)]);
    
    if i==1
        title('Click No Stimulation Window');
    
    elseif i==2
        title('Click Continuous (0Hz) Pulses Window');
    
    elseif i==3
        title('Click 20Hz Pulses Window');
        
    elseif i==4
        title('Click 50Hz Pulses Window');

    elseif i==5
        title('Click 100Hz Pulses Window');
    end
    [points(i,:),~] = ginput(2);

end
close(gcf);

if ps
    k=2;
else
    k=1;
end

for j=1:k
    figure;
    
    for i=1:5
        
        if i==1
            name = 'No Stim';
        elseif i==2
            name = '0 Hz';   
        elseif i==3
            name = '20 Hz';   
        elseif i==4
            name = '50 Hz';
        elseif i==5
            name = '100 Hz';
        end
        
        win = (amp_data(round(points(i,1)):round(points(i,2))));
        if j==1
            fft_amp = fft(win);
            P2 = abs(fft_amp/length(win));
            P1 = P2(1:round(length(win)/2)+1); % only positive frequencies
            P1(2:end-1) = 2*P1(2:end-1);
            f = sample_rate*(0:round(length(win)/2))/length(win);
            plot(f,smooth(P1,5),'DisplayName', name);
            xlim([0 100]);
            ylim([0 10]);
            xlabel('Frequency (Hz)');
            title('FFT');
            
            hold on;
            
        end
        
        if j==2
            win = amp_data(round(points(i,1)):round(points(i,2)));

            [pxx, fxx] = pwelch(win, [], [], 1:0.5:100, sample_rate);
            plot(fxx, smooth(10*log10(pxx),5), 'DisplayName', name);
            title('Power Spectrum');
            xlabel('Frequency (Hz)');
            ylabel('Power');
            hold on;
        end
        
    end
    
    legend('show');
    hold off;
    
end


end

