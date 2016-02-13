% get fdata from SEV files
% load ts from nexStruct: > ts = nexStruct.neurons{1,1}.timestamps;
% run poisson function on ts: > [archive_burst_RS,archive_burst_length,archive_burst_start]=burst(ts);
% run code below
for ii=1:15
    h = figure('position',[0 0 1000 800]);
    eventTs = ts(archive_burst_start(ii));
    startTs = eventTs - 1;
    startIdx = round(startTs*header.Fs);
    endTs = eventTs + 1;
    endIdx = round(endTs*header.Fs);
    t = linspace(-1,1,length(startIdx:endIdx));
    
    hs(1) = subplot(4,1,1);
    plot(t,fdata_33(startIdx:endIdx));
    hold on;
    plot(0,fdata_33(round(eventTs*header.Fs)),'+');
    xlim([-1 1]);
    
    titleString = {['Neuron: R0088 20151102a T5a'],...
        ['Burst Start: ',num2str(ts(archive_burst_start(ii)))],...
        ['Burst Length: ',num2str(archive_burst_length(ii))],...
        ['Surprise Rank: ',num2str(archive_burst_RS(ii))],...
        [],['wire 1']};
    title(titleString);
    
    hs(2) = subplot(4,1,2);
    plot(t,fdata_33(startIdx:endIdx));
    hold on;
    plot(0,fdata_35(round(eventTs*header.Fs)),'+');
    xlim([-1 1]);
    title('wire 2');
    
    hs(3) = subplot(4,1,3);
    plot(t,fdata_35(startIdx:endIdx));
    hold on;
    plot(0,fdata_37(round(eventTs*header.Fs)),'+');
    xlim([-1 1]);
    title('wire 3');
    
    hs(4) = subplot(4,1,4);
    plot(t,fdata_39(startIdx:endIdx));
    hold on;
    plot(0,fdata_39(round(eventTs*header.Fs)),'+');
    xlim([-1 1]);
    title('wire 4');
    
    eventLength = archive_burst_length(ii);
    for jj=1:eventLength
        eventTs = ts(archive_burst_start(ii)+jj)-ts(archive_burst_start(ii));
        
        subplot(4,1,1);
        hold on;
        plot(eventTs,fdata_33(round(ts(archive_burst_start(ii)+jj)*header.Fs)),'o','color','red');
        
        subplot(4,1,2);
        hold on;
        plot(eventTs,fdata_35(round(ts(archive_burst_start(ii)+jj)*header.Fs)),'o','color','red');
        
        subplot(4,1,3);
        hold on;
        plot(eventTs,fdata_37(round(ts(archive_burst_start(ii)+jj)*header.Fs)),'o','color','red');
        
        subplot(4,1,4);
        hold on;
        plot(eventTs,fdata_39(round(ts(archive_burst_start(ii)+jj)*header.Fs)),'o','color','red');
    end
    linkaxes(hs);
    saveas(h,['poissonFig_R0088-20151102a-T5a_',num2str(ii)],'fig');
end


% create avg waveform
% % sevFilename = '/Users/mattgaidica/Documents/Data/ChoiceTask/R0088/R0088-rawdata/R0088_20151102a/R0088_20151102a/R0088_20151102_R0088_20151102-1_data_ch37.sev';
% % [meanWaveform, upperStd, lowerStd, ch, windowSize] = aveWaveform(ts, sevFilename);
% % plotAveWaveform(meanWaveform, upperStd, lowerStd, ch, windowSize);