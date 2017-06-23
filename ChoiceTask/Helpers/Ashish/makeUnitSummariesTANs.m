function makeUnitSummariesTANs(textFile)

% format: Channel, Unit, Timestamp, Energy, Peak-Valley, Average, ISI
% (Previous), ISI (Next), Area, Waveform
% [ ] generate unitHeaders

axcorrRange = [-0.01 0.01];
isiRange = [0 10^2];
waveformScale = [-400 400];
fontSize = 7;
paramIdxEnergy = 5;
paramIdxPeakValley = 6;
paramIdxISIPrev = 8;
paramIdxISIProp = 9;
paramIdxAPeakToValleyTick = 10;
waveformFile = textFile;
[path,name,ext] = fileparts(waveformFile);
neuronName = name;
if ~exist(waveformFile,'file')
    warning(['No waveform file for ',neuronName]);
end
waveforms = csvread(waveformFile,2);
units = sort(unique(waveforms(:,2)));

% plot first figure
% compile timestamps for xcorr
h = figure;
allTimestamps = {};
unitNames = {};
for iUnit = 1:numel(units) % units are all exported to one file
    
    waveformInfo = waveforms(waveforms(:,2) == units(iUnit),:);
    waveformTrace = waveformInfo(:,11:end);
    waveformTrace = waveformTrace(:,~isnan(waveformTrace(1,:)));
    startSubplot = 3*(iUnit-1)+1;

    % waveform plot
    ax = subplot(numel(units),3,startSubplot);
    t = linspace(0,(size(waveformTrace,2))*1000,size(waveformTrace,2));
    errorbar(t,mean(waveformTrace),std(waveformTrace),'k');
    unitNames{iUnit} = [neuronName(1:end-1),char(96+iUnit)];
    title([unitNames{iUnit}],'interpreter','none');
    xlabel('microsec');
    ylabel('uV');
    ax.XTick = [0 1 2];
    ylim(waveformScale);
    ay.YTick = waveformScale;

    % ISI histogram
    ax = subplot(numel(units),3,startSubplot+1);
    ISI = waveformInfo(:,7); % ISI column
    ISI = ISI(ISI~=0); % fix weird issue in one data set where ISI=0
    bins = exp(linspace(log(min(ISI)),log(max(ISI)),100));
    [counts,centers] = histcounts(ISI,bins);
    plot(centers(1:end-1),counts,'k')
    title('ISI');
    set(gca,'XScale','log');
    xlabel('Time (s)');
    ylabel('spikes');
    xlim(isiRange);
    ax.XTick = isiRange;
    
    %3D scatterplot
    subplot(numel(units),3,startSubplot+2);
    Prop_ISI = 100 * (length(find(waveformInfo(:,7) > 500)) / length(waveformInfo)); % Proportion of ISI over 5 ms
    PVD = (1/24414.0625) * abs(waveformInfo(:,9)) * 10^6;
    PVD = mean(PVD)
    FR = .001 * waveformInfo(:,7);
    FR = mean(FR);
    FR = 1/FR;
    p = scatter3(PVD,mean(Prop_ISI),FR,30,'k');
    ylabel('PROP_I_S_I (%)');
    zlabel('Firing Rate (spikes/s)');
    zlim([0 40]);
    xlabel('Valley Peak Duration (in microsec)');
    
    % parameters for waveform according to Cohen papers
    TANs = find(FR > 2.8 & FR < 6.0 & PVD > 455.6 & PVD < 541.2);
    MSNs = find(FR > 0.2 & FR < 1.8 & PVD > 459.5 & PVD < 534.5);
    FSIs = find(FR > 5.2 & FR < 27.8 & PVD > 142.2 & PVD < 260.8);
    UINs = find(FR > 0.3 & FR < 1.9 & PVD > 149.8 & PVD < 280.2);
    
    if FR > 2.8 & FR < 6.0 & PVD > 455.6 & PVD < 541.2
        p.MarkerFaceColor = 'g';
    elseif FR > 0.2 & FR < 1.8 & PVD > 459.5 & PVD < 534.5
        p.MarkerFaceColor = 'r';
    elseif FR > 5.2 & FR < 27.8 & PVD > 142.2 & PVD < 260.8
        p.MarkerFaceColor = 'b';
    elseif FR > 0.3 & FR < 1.9 & PVD > 149.8 & PVD < 280.2
        p.MarkerFaceColor = 'k';
    end
   
   % saves figure
   saveas(gcf,name);
end
