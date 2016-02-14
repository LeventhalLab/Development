% get fdata from SEV files
% load ts from nexStruct: > ts = nexStruct.neurons{1,1}.timestamps;
% run LTS function on ts: > [LTSepochs, nonLTSepochs] = extractLTS(ts);
% run code below

for ii=1:15
    h = figure('position',[0 0 1000 800]);
    eventTs = ts_a(LTSepochs(ii,1));
    startTs = eventTs - 1;
    startIdx = round(startTs*header.Fs);
    endTs = eventTs + 1;
    endIdx = round(endTs*header.Fs);
    t = linspace(-1,1,length(startIdx:endIdx));
    
    % other neurons
    ts_bEvents = ts_b(ts_b < eventTs + 1 & ts_b > eventTs - 1);
    ts_cEvents = ts_c(ts_c < eventTs + 1 & ts_c > eventTs - 1);
    
    hs(1) = subplot(4,1,1);
    plot(t,fdata_33(startIdx:endIdx));
    hold on;
    plot(0,fdata_33(round(eventTs*header.Fs)),'+','color','black');
    xlim([-1 1]);
    
    titleString = {['Neuron: R0088 20151102a T5a'],...
        ['Burst Start: ',num2str(eventTs)],...
        ['Burst Length: ',num2str(LTSepochs(ii,2)-LTSepochs(ii,1)+1)],...
        [],['wire 1']};
    title(titleString);
    
    hs(2) = subplot(4,1,2);
    plot(t,fdata_35(startIdx:endIdx));
    hold on;
    plot(0,fdata_35(round(eventTs*header.Fs)),'+','color','black');
    xlim([-1 1]);
    title('wire 2');
    
    hs(3) = subplot(4,1,3);
    plot(t,fdata_37(startIdx:endIdx));
    hold on;
    plot(0,fdata_37(round(eventTs*header.Fs)),'+','color','black');
    xlim([-1 1]);
    title('wire 3');
    
    hs(4) = subplot(4,1,4);
    plot(t,fdata_39(startIdx:endIdx));
    hold on;
    p(1) = plot(0,fdata_39(round(eventTs*header.Fs)),'+','color','black');
    xlim([-1 1]);
    title('wire 4');
    
    eventLength = LTSepochs(ii,2)-LTSepochs(ii,1);
    for jj=1:eventLength
        eventTs = ts_a(LTSepochs(ii,1)+jj)-ts_a(LTSepochs(ii,1));
        
        subplot(4,1,1);
        hold on;
        plot(eventTs,fdata_33(round(ts_a(LTSepochs(ii,1)+jj)*header.Fs)),'o','color','black');
        
        subplot(4,1,2);
        hold on;
        plot(eventTs,fdata_35(round(ts_a(LTSepochs(ii,1)+jj)*header.Fs)),'o','color','black');
        
        subplot(4,1,3);
        hold on;
        plot(eventTs,fdata_37(round(ts_a(LTSepochs(ii,1)+jj)*header.Fs)),'o','color','black');
        
        subplot(4,1,4);
        hold on;
        p(2) = plot(eventTs,fdata_39(round(ts_a(LTSepochs(ii,1)+jj)*header.Fs)),'o','color','black');
    end
    
    for jj=1:length(ts_bEvents)
        eventTs = ts_bEvents(jj)-ts_a(LTSepochs(ii,1));
        
        subplot(4,1,1);
        hold on;
        plot(eventTs,fdata_33(round(ts_bEvents(jj)*header.Fs)),'x','color','red');
        
        subplot(4,1,2);
        hold on;
        plot(eventTs,fdata_35(round(ts_bEvents(jj)*header.Fs)),'x','color','red');
        
        subplot(4,1,3);
        hold on;
        plot(eventTs,fdata_37(round(ts_bEvents(jj)*header.Fs)),'x','color','red');
        
        subplot(4,1,4);
        hold on;
        p(3) = plot(eventTs,fdata_39(round(ts_bEvents(jj)*header.Fs)),'x','color','red');
    end
    
    for jj=1:length(ts_cEvents)
        eventTs = ts_cEvents(jj)-ts_a(LTSepochs(ii,1));
        
        subplot(4,1,1);
        hold on;
        plot(eventTs,fdata_33(round(ts_cEvents(jj)*header.Fs)),'x','color','green');
        
        subplot(4,1,2);
        hold on;
        plot(eventTs,fdata_35(round(ts_cEvents(jj)*header.Fs)),'x','color','green');
        
        subplot(4,1,3);
        hold on;
        plot(eventTs,fdata_37(round(ts_cEvents(jj)*header.Fs)),'x','color','green');
        
        subplot(4,1,4);
        hold on;
        p(4) = plot(eventTs,fdata_39(round(ts_cEvents(jj)*header.Fs)),'x','color','green');
    end
    
    linkaxes(hs);
    legend(p,'unit a, burst start','unit a, burst spikes','unit b','unit c','location','northwest');
    
    saveas(h,['LTSFig_R0088-20151102a-T5a_',num2str(ii)],'fig');
    close(h);
end


% create avg waveform
% % sevFilename = '/Users/mattgaidica/Documents/Data/ChoiceTask/R0088/R0088-rawdata/R0088_20151102a/R0088_20151102a/R0088_20151102_R0088_20151102-1_data_ch37.sev';
% % [meanWaveform, upperStd, lowerStd, ch, windowSize] = aveWaveform(ts, sevFilename);
% % plotAveWaveform(meanWaveform, upperStd, lowerStd, ch, windowSize);