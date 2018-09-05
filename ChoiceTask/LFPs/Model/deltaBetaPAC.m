fs = 1000; % Sampling frequency (samples per second) 
dt = 1/fs; % seconds per sample 
StopTime = 1.5; % seconds 
t = (0:dt:StopTime)'; % seconds 
data_delta = sin(2*pi*2*t);
data_beta = 0.5 * sin(2*pi*20*t);
data_beta = data_beta .* (logspace(1,0,numel(data_beta)) / 10).^2';

tones = [0:0.1:0.5]+0.5;
rows = numel(tones);
cols = 1;
figuree(500,800);

for iTone = 1:numel(tones)
    subplot(rows,cols,iTone);
    tone_start = find(t >= tones(iTone),1);
    
    mod_delta = data_delta;
    for ii = tone_start:numel(data_delta)
        if data_delta(ii) > 0
            mod_delta(ii) = data_delta(ii) + data_beta(ii-tone_start+1) .* data_delta(ii);
        end
    end
    
    plot(t,mod_delta,'k','lineWidth',2);
    hold on;
    plot(t+tones(iTone),data_beta,'lineWidth',1,'color',[1 0 0]);
    xlim([0 StopTime]);
    xticks([0 tones(iTone)]);
    xticklabels({'Nose In',['Tone (',num2str(tones(iTone),2),'s)']});
    ylim([-1.5 1.5]);
    yticks([-1 0 1]);
    grid on;
    set(gcf,'color','w');
end