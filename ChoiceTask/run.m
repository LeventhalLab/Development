% load ts from nexStruct: > ts = nexStruct.neurons{1,1}.timestamps;
% run poisson function on ts: > [archive_burst_RS,archive_burst_length,archive_burst_start]=burst(ts);
% run code below
for ii=1:10
    h = figure('position',[0 0 1000 400]);
    eventTs = ts(archive_burst_start(ii));
    startTs = eventTs - 1;
    startIdx = round(startTs*header.Fs);
    endTs = eventTs + 1;
    endIdx = round(endTs*header.Fs);
    t = linspace(-1,1,length(startIdx:endIdx));
    
    plot(t,fdata(startIdx:endIdx));
    hold on;
    plot(0,fdata(round(eventTs*header.Fs)),'+');
    eventLength = archive_burst_length(ii);
    for jj=1:eventLength
        eventTs = ts(archive_burst_start(ii)+jj)-ts(archive_burst_start(ii));
        hold on;
        plot(eventTs,fdata(ceil(ts(archive_burst_start(ii)+jj)*header.Fs)),'o','color','red');
    end
    xlim([-1 1]);
    titleString = {['Neuron: R0088 20151102a T5a'],...
        ['Burst Start: ',num2str(ts(archive_burst_start(ii)))],...
        ['Burst Length: ',num2str(archive_burst_length(ii))],...
        ['Surprise Rank: ',num2str(archive_burst_RS(ii))]};
    title(titleString);
    saveas(h,['poissonFig_R0088-20151102a-T5a_',num2str(ii)],'fig');
end


% create avg waveform
sevFilename = '/Users/mattgaidica/Documents/Data/ChoiceTask/R0088/R0088-rawdata/R0088_20151102a/R0088_20151102a/R0088_20151102_R0088_20151102-1_data_ch37.sev';
[meanWaveform, upperStd, lowerStd, ch, windowSize] = aveWaveform(ts, sevFilename);
plotAveWaveform(meanWaveform, upperStd, lowerStd, ch, windowSize);