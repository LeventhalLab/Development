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

% setup
doSetup = true;

for iSubject = 2:5
    if doSetup
        fpass = [10 60];
        nFreqs = 30;
        freqList = logFreqList(fpass,nFreqs);
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
    end

    betaIdx = closest(freqList,20);
    gammaIdx = closest(freqList,50);
    bandIdxs = [gammaIdx betaIdx];
    pLim = 0.01;

    vis_tWindow = 0.1;
    t1Idx = closest(t,-vis_tWindow);
    t2Idx = closest(t,vis_tWindow);
    t_vis = linspace(-vis_tWindow,vis_tWindow,numel(t1Idx:t2Idx));
    
    rows = 2;
    cols = 7;
    nSmooth = 50;
    figuree(1200,350);
    fontSize = 14;
    for iEvent = 1:cols
        for iBand = 1:rows
            all_angles = squeeze(angle(allW(iEvent,t1Idx:t2Idx,:,bandIdxs(iBand))));
            all_ps = [];
            for ti = 1:size(all_angles,1)
                 p = circ_rtest(all_angles(ti,:));
                all_ps(ti) = p;
            end
            subplot(rows,cols,((cols*iBand)-cols)+iEvent);
            
            yyaxis left;
            colors = lines(1);
            shadedErrorBar(t_vis,circ_mean(all_angles'),circ_std(all_angles'),{'--','color',colors(1,:)});
            if iEvent == 1
                ylabel({subject__names{iSubject},'phase (rad)'});
            else
                ylabel('phase (rad)');
            end
            ylimVals = [-5 5];
            ylim(ylimVals);
            yticks(sort([ylimVals 0]));
            hold on;
            
            yyaxis right;
            plot(t_vis,all_ps,'lineWidth',0.75);
            ylabel('p (r-test)');
            ylimVals = [0 1];
            ylim(ylimVals);
            yticks(ylimVals);
            
            xlim([-vis_tWindow vis_tWindow]);
            xlabel('time (s)');
            plot(xlim,[pLim pLim],'r--');
            
            if iBand == 1
                title({eventFieldnames{iEvent},'\gamma'},'fontSize',fontSize);
            else
                title({'\beta'},'fontSize',fontSize);
            end
            
            set(gcf,'color','w');
        end
    end

end