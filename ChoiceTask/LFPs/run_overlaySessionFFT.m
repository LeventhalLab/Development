subject__names = {'R0088','R0117','R0142','R0154','R0182'};
subject__files = {'/Users/mattgaidica/Documents/Data/ChoiceTask/R0088/R0088-rawdata/R0088_20151102a/R0088_20151102a/R0088_20151102_R0088_20151102-1_data_ch42.sev',...
    '/Users/mattgaidica/Documents/Data/ChoiceTask/R0117/R0117-rawdata/R0117_20160504a/R0117_20160504a/R0117_20160504a_R0117_20160504a-2_data_ch93.sev',...
    '/Users/mattgaidica/Documents/Data/ChoiceTask/R0142/R0142-rawdata/R0142_20161207a/R0142_20161207a/R0142_20161207a_R0142_20161207a-1_data_ch42.sev',...
    '/Users/mattgaidica/Documents/Data/ChoiceTask/R0154/R0154-rawdata/R0154_20170227a/R0154_20170227a/R0154_20170227a_R0154_20170227a-1_data_ch41.sev',...
    '/Users/mattgaidica/Documents/Data/ChoiceTask/R0182/R0182-rawdata/R0182_20170723a/R0182_20170723a/R0182_20170723a_R0182_20170723a-1_data_ch2.sev'};

subject__logs = {'/Users/mattgaidica/Documents/Data/ChoiceTask/R0088/R0088-rawdata/R0088_20151102a/R0088_20151102_13-59-02.log',...
    '/Users/mattgaidica/Documents/Data/ChoiceTask/R0117/R0117-rawdata/R0117_20160504a/R0117_20160504_15-19-54.log',...
    '/Users/mattgaidica/Documents/Data/ChoiceTask/R0142/R0142-rawdata/R0142_20161207a/R0142_20161206_13-37-13.log',...
    '/Users/mattgaidica/Documents/Data/ChoiceTask/R0154/R0154-rawdata/R0154_20170227a/R0154_20170227_15-37-29.log',...
    '/Users/mattgaidica/Documents/Data/ChoiceTask/R0182/R0182-rawdata/R0182_20170723a/R0182_20170723_10-07-55.log'};

subject__nexFiles = {'/Users/mattgaidica/Documents/Data/ChoiceTask/R0088/R0088-processed/R0088_20151102a/R0088_20151102a_finished/R0088_20151102a.nex.mat',...
    '/Users/mattgaidica/Documents/Data/ChoiceTask/R0117/R0117-processed/R0117_20160504a/R0117_20160504a_finished/R0117_20160504a.nex.mat',...
    '/Users/mattgaidica/Documents/Data/ChoiceTask/R0142/R0142-processed/R0142_20161207a/R0142_20161207a_finished/R0142_20161207a.nex.mat',...
    '/Users/mattgaidica/Documents/Data/ChoiceTask/R0154/R0154-processed/R0154_20170227a/R0154_20170227a_finished/R0154_20170227a.nex.mat',...
    '/Users/mattgaidica/Documents/Data/ChoiceTask/R0182/R0182-processed/R0182_20170723a/R0182_20170723a_finished/R0182_20170723a.nex.mat'};

showFFT = true;
showLFP = false;

if showFFT
    all_A = [];
    % setup
    decimateFactor = 10;
    for iSubject = 1:numel(subject__names)
        sevFile = subject__files{iSubject};
        [sev, header] = read_tdt_sev(sevFile);
        sevFilt = decimate(double(sev),decimateFactor);
        Fs = header.Fs / decimateFactor;
        [A,f] = simpleFFT(sevFilt(1e6:end),Fs,true);
        all_A(iSubject,:) = A;
    end
    
    % plot
    nsmooth = 500;
%     colors = lines(5);
    colors = zeros([5 3]);
    colors(2:3,:) = [1 0 0;1 0 0]; % 50 um wires
    lns = [];
    figuree(600,600);
    for iSubject = 1:numel(subject__names)
        lns(iSubject) = semilogy(f,smooth(all_A(iSubject,:),nsmooth),'color',colors(iSubject,:));
        xlim([1 80]);
        xlabel('Frequency (Hz)');
        ylabel('|Y(f)|');
        hold on;
    end
    legend(lns,subject__names);
end

if showLFP
    fpass = [1 80];
    nFreqs = 30;
    tWindow_vis = 1;
    freqList = logFreqList(fpass,nFreqs);
    decimateFactor = 10;
    timingField = 'RT';
    tWindow = 3;
    eventFieldnames = {'cueOn';'centerIn';'tone';'centerOut';'sideIn';'sideOut';'foodRetrieval'};
    
    h1 = figuree(1200,600);
    iSubplot_h1 = 1;
    iSubplot_h2 = 1;
    h2 = figuree(1200,500);
    for iSubject = 1:numel(subject__names)
        disp(['Working on ',subject__names{iSubject}]);
        sevFile = subject__files{iSubject};
        [sev, header] = read_tdt_sev(sevFile);
        sevFilt = decimate(double(sev),decimateFactor);
        Fs = header.Fs / decimateFactor;
        load(subject__nexFiles{iSubject});
        logData = readLogData(subject__logs{iSubject});
        if strcmp(subject__names{iSubject},'R0154')
            nexStruct = fixMissingEvents(logData,nexStruct);
        end
        trials = createTrialsStruct_simpleChoice(logData,nexStruct);
        [trialIds,allTimes] = sortTrialsBy(trials,timingField); % forces to be 'correct'
        allW = eventsLFP(trials(trialIds),sevFilt,tWindow,Fs,freqList,eventFieldnames);
        t = linspace(-tWindow,tWindow,size(allW,2));
        
        % build data arrays
        scaloData = [];
        phaseData = [];
        for iFreq = 1:nFreqs
            for iEvent = 1:numel(eventFieldnames)
                freqData = squeeze(allW(iEvent,:,:,iFreq))';
                scaloData(iEvent,iFreq,:) = mean(abs(freqData));
                phaseData(iEvent,iFreq,:) = deg2rad(meanangle(rad2deg(angle(freqData))));
            end
        end
        
        figure(h1);
        for iEvent = 1:numel(eventFieldnames)
            ax = subplot(numel(subject__names),numel(useEvents),iSubplot_h1);
            imagesc(t,1:nFreqs,squeeze(scaloData(iEvent,:,:)));
            xlim([-tWindow_vis tWindow_vis]);
            xticks([-tWindow_vis 0 tWindow_vis]);
            yticks(1:nFreqs);
            yticklabels(round(freqList));
            set(ax,'YDir','normal');
            colormap(jet);
            grid on;

            if iEvent == 1
                ylabel([subject__names{iSubject},' - Freq (Hz)']);
            end

            scaloData_event = squeeze(scaloData(4,:,:));
            caxis([prctile(scaloData_event(:),5) prctile(scaloData_event(:),95)]);
            
            title(eventFieldnames{iEvent});
            set(gca,'fontSize',8);
            iSubplot_h1 = iSubplot_h1 + 1;
        end
        
        figure(h2);
        for iEvent = 1:numel(eventFieldnames)
            ax = subplot(numel(subject__names),numel(useEvents),iSubplot_h2);
            imagesc(t,1:nFreqs,squeeze(phaseData(iEvent,:,:)));
            xlim([-tWindow_vis tWindow_vis]);
            xticks([-tWindow_vis 0 tWindow_vis]);
            yticks(1:nFreqs);
            yticklabels(round(freqList));
            set(ax,'YDir','normal');
            cmocean('phase');
            grid on;
            
            if iEvent == 1
                ylabel([subject__names{iSubject},' - Freq (Hz)']);
            end
            
            title(eventFieldnames{iEvent});
            set(gca,'fontSize',8);
            iSubplot_h2 = iSubplot_h2 + 1;
        end
    end
end