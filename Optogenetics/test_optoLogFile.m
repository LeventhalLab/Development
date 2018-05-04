logFile = '/Users/mattgaidica/Downloads/ephys_test_20180405_15-37-17.log';
figuree(800,800);
subplot(211);
colors = lines(2);
plot(logData.pretone,'lineWidth',2,'color','k');
hold on;
plot(logData.opto_delay_from_tone/1000,'lineWidth',2,'color',colors(1,:));
plot(find(logData.opto_active_trial == 1),zeros(numel(find(logData.opto_active_trial == 1)),1),'gx','markerSize',15);
ylim([-1 1]);
yticks([-1 0 1]);
xlim([1 numel(logData.pretone)]);
xticks(1:numel(logData.pretone));
xlabel('trials');
ylabel('time (s)');
legend({'Pretone','Shutter from Tone','Opto Active Trial'},'location','northwest');
title({['Opto Step: ',num2str(logData.opto_step_ms),' ms'],['Opto P(trial): ',num2str(logData.opto_trial_probability,'%1.2f')],['Opto Shutter: ',num2str(logData.opto_shutter_ms),' ms']});
grid on;

[sorted_pretone,k] = sort(logData.pretone);
subplot(212);
plot(sorted_pretone,'lineWidth',2,'color','k');
hold on;
plot(logData.opto_delay_from_tone(k)/1000,'lineWidth',2,'color',colors(1,:));
plot(-sorted_pretone,':','lineWidth',2,'color','k');
ylim([-1 1]);
yticks([-1 0 1]);
xlim([1 numel(logData.pretone)]);
xticks(1:numel(logData.pretone));
xlabel('trials');
ylabel('time (s)');
legend({'Pretone','Shutter from Tone','-Pretone'},'northwest');
title('sorted');
grid on;