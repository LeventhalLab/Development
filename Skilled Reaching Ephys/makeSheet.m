%%Create sheet of information for one neuron

function [] = makeSheet(varargin)
%Inputs: 
%   -sessionConf 
%   -whichNeuron = name of tetrode/wire and which sorted neuron to look at 
%   -i.e. "T01_01" for 1st sorted neuron on tetrode1 or "100_1" for wire100
%Assumes that combined nex file stored in
%               '..R00XX\R0098-proceessed\Processed'
%
%If no inputs, then it will allow you to select everything yourself
if nargin == 0
    nexPath     = uigetfile({'*.nex'});
    whichNeuron = input('Neuron Name(i.e. T01_01)=')
    [f,p]=uigetfile({'*.sev'});
    [sev,header] = read_tdt_sev(fullfile(p,f));
   
    
    
else
    for iarg=1:2:nargin-1
        switch varargin{iarg}
            case 'sessionConf'
                sessionConf = varargin{iarg+1};
                samplingRate = 24414;
            case 'whichNeuron'    
                whichNeuron = varargin{iarg+1}; 
        end
    end
    leventhalPaths = buildLeventhalPaths(sessionConf)
    nexPath = sessionConf.nexPath;
    [neuronName,neuronCh] = getNeuronID(sessionConf, whichNeuron);
    fullSevFiles = getChFileMap(leventhalPaths.channels);
    [sev,header] = read_tdt_sev(fullSevFiles{neuronCh});
    
    
    %whichNeuron = 'T02_1', neuronName = 'sessionName_whichNeuron'

end


%load time stamp data
[n,ts] = nex_ts(nexPath,neuronName);

%High Pass filter data
t = linspace(0,length(sev)/header.Fs, length(sev));
data = double(sev);
[b,a] = butter(4, [0.02 0.2]);
%
HPdata = wavefilter(data,4);
HPdata2 = filtfilt(b,a,data);



%Get Average Waveform
[meanWF, tWidth, upperStd, lowerStd]  = avgWF(ts,HPdata,2000,2000,samplingRate);

%Valley peak duration
VPD = abs((find(meanWF == max(meanWF)) - find(meanWF == min(meanWF)))./samplingRate);

%Valley Amplitude Ratio


%plot average WF
figure();clf; 
sp1 = subplot(5,1,1);
grid on;
color = [145/255, 205/255, 114/255];
fill([tWidth fliplr(tWidth)], [upperStd fliplr(lowerStd)], color, 'edgeColor', color);
alpha(.25); hold on
plot(tWidth, meanWF, 'color', color, 'lineWidth', 2)
xlabel('time (us)');
ylabel('uV');ylim([-300 400])
title([whichNeuron ' Average Waveform'])

%plot ISI
%figure(2);clf
sp2 = subplot(5,1,2);grid on
histogram(diff(ts*1000),[0:1:500],'Normalization','probability');
xlabel('t(ms)'); ylabel('Count');title('ISI');

%Plot unfiltered and filtered data
%figure(3);clf
sp3 = subplot(5,1,3); grid on
dataMid = round(length(sev)./2);
dataWindow = round(10*samplingRate);  %60 seconds
dataRange = (dataMid-dataWindow):dataMid+dataWindow;  %in samples

%tsInSpan = find(ts>= dataRange./samplingRate & ts<dataRange./samplingRate);

plot(dataRange./samplingRate, sev(dataRange));
title('Raw Data'); xlabel('time(s)');ylabel('uV')
ylim([-500 500])
sp4 = subplot(5,1,4);
plot(dataRange./samplingRate,HPdata(dataRange));hold on;
tsIDX = find(ts>(dataRange(1)./samplingRate) & ts<(dataRange(end)./samplingRate));
plot(ts(tsIDX),50*ones(1,length(tsIDX)),'*');hold off

title('High Filtered Data'); xlabel('time(s)');ylabel('uV')
ylim([-200 200])

sp5 = subplot(5,1,5);
plot(dataRange./samplingRate,HPdata2(dataRange));hold on;
tsIDX = find(ts>(dataRange(1)./samplingRate) & ts<(dataRange(end)./samplingRate));
plot(ts(tsIDX),50*ones(1,length(tsIDX)),'*');hold off

title('High Filtered Data'); xlabel('time(s)');ylabel('uV')
ylim([-200 200])
%%%Set custom positions of subplots
sp1.Position = [.05 .57 .5 .4]
sp2.Position = [.6 .6 .3 .3]
sp3.Position = [.05 .05 .5 .17]
sp4.Position = [.05 .3 .5 .17]
sp5.Position = [.6 .3 .4 .3]
set(sp1, 'FontSize', 10, 'LineWidth', 1); %<- Set properties
linkaxes([sp3,sp4,sp5],'x');

%Firing Rate, calculated over middle 30 min.
FRidx = find(ts>(15*60)&ts<(45*60));
firingRate = length(FRidx)./(30*60)


%
tx1 = axes('Position',[0.6 .5 1 1],'Visible','off');


text(0,0,['VPD=' num2str(VPD)],'FontSize', 12);
tx2 = axes('Position',[0.6 .45 1 1],'Visible','off');
text(0,0,['FR=' num2str(firingRate)],'FontSize', 12);

end
