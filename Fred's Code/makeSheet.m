%%Create sheet of information for one neuron

function [] = makeSheet(neuron)
%sessionName is the folder where the data is located
%Neuron is the sorted neuron #
%
%


samplingRate = 24414;

%load data
temp = ['Channel01b', 'Channel01c', 'Channel01d,''Channel01e','Channel01f']
whichUnit = temp(neuron)
[f,p]=uigetfile({'*.nex'});


[n,ts] = nex_ts(fullfile(p,f),whichUnit)

[f,p]=uigetfile({'*.sev'});
[sev,header] = read_tdt_sev(fullfile(f,p));
t = linspace(0,length(sev)/header.Fs, length(sev));
data = double(sev);
[b,a] = butter(4, [0.02 0.2]);
HPdata = filtfilt(b,a,data);


%Get Average Waveform
[avgWF, tWidth, upperStd, lowerStd]  = avgWF(ts, HPdata, .0005,.0005,samplingRate)

%Valley peak duration
VPD = abs((find(avgWF == max(avgWF)) - find(avgWF == min(avgWF)))./samplingRate);

%plot stuff
figure()
grid on
fill([tWidth fliplr(tWidth)], [upperStd fliplr(lowerStd)], color, 'edgeColor', color);
alpha(.25); hold on
plot(tWidth, avgWF, 'color', [145/255, 205/255, 114/255], 'lineWidth', 2)
xlabel('time (s)');
ylabel('uV');
title(['Channel ', num2str(ch), ' Average Waveform'])
set(gca, 'FontSize', 14, 'LineWidth', 2); %<- Set properties



end
