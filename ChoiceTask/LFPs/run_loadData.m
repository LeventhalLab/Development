% % iSubject = 5;

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

doSetup = true;
if doSetup
    fpass = [3.5 80];
    nFreqs = 30;
    freqList = logFreqList(fpass,nFreqs);
% %     freqList = [4:12 13 15 20 25 30 40 50 80 100];
    decimateFactor = 10;
    timingField = 'RT';
    tWindow = 2;
    eventFieldnames = {'cueOn';'centerIn';'tone';'centerOut';'sideIn';'sideOut';'foodRetrieval'};

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

    % compute
    allW = eventsLFP(trials(trialIds),sevFilt,tWindow,Fs,freqList,eventFieldnames);
    t = linspace(-tWindow,tWindow,size(allW,2));
    
    if false
        allW_allTrials = mean(pow(allW),3);
        allW_allTrials = squeeze(squeeze(allW_allTrials(4,:,:,:)));
        figure;
        imagesc(t,1:numel(freqList),allW_allTrials');
        xlim([-tWindow tWindow]);
        xticks([-tWindow 0 tWindow]);
        yticks(1:numel(freqList));
        yticklabels(freqList);
        set(gca,'YDir','normal');
        colormap(jet);
        grid on;
    end
end