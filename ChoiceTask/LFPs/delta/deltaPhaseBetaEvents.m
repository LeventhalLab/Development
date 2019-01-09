% load('session_20180919_NakamuraMRL.mat', 'eventFieldnames')
% load('session_20180919_NakamuraMRL.mat', 'all_trials')
% load('session_20180919_NakamuraMRL.mat', 'LFPfiles_local')
% load('session_20180919_NakamuraMRL.mat', 'selectedLFPFiles')
% load('session_20180919_NakamuraMRL.mat', 'all_ts')
close all;
doPlot = true;
doSave = true;
doSetup = false;
savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/perievent/entrainmentTrialShuffle/deltaPhaseBetaEvents';

tWindow = 1;
zThresh = 5;
freqList = [2,7,20,45]; % logFreqList([1 200],30);
flankBands = 2:4;
shuffleColors = [0 0 0;0 0 1];
nSurr = 100;
oversampleBy = 4;
eventFieldnames_wFake = {eventFieldnames{:} 'outTrial'};

if doSetup
    iSession = 0;
    alpha_events = {};
    alpha_rnd_events = {};
    for iNeuron = selectedLFPFiles'
        iSession = iSession + 1;
        sevFile = LFPfiles_local{iNeuron};
        disp(num2str(iNeuron));

        curTrials = all_trials{iNeuron};
        [trialIds,allTimes] = sortTrialsBy(curTrials,'RT');
        [sevFilt,Fs,decimateFactor] = loadCompressedSEV(sevFile,[]);
        sevFilt = artifactThresh(sevFilt,[1],2000);
        sevFilt = sevFilt - mean(sevFilt);
        [W,all_data] = eventsLFPv2(curTrials(trialIds),sevFilt,tWindow,Fs,freqList,eventFieldnames);
        keepTrials = threshTrialData(all_data,zThresh);
        W = W(:,:,keepTrials,:);
        
        % surrogates
        trialTimeRanges = compileTrialTimeRanges(curTrials);
        takeTime = tWindow * oversampleBy;
        takeSamples = round(takeTime * Fs);
        minTime = min(trialTimeRanges(:,2));
        maxTime = max(trialTimeRanges(:,1)) - takeTime;
        
        data = [];
        surrLog = [];
        iSurr = 0;
        disp('Gathering surrogates...');
        
        while iSurr < numel(keepTrials) + 40 % add buffer for artifact removal
            % try randTs
            randTs = (maxTime-minTime) .* rand + minTime;
            randSample = round(randTs * Fs);
            sampleRange = randSample:randSample + takeSamples - 1;
            thisData = sevFilt(sampleRange);
            if isempty(strfind(diff(thisData),zeros(1,round(numel(sampleRange)*0.1))))
                iSurr = iSurr + 1;
                data(:,iSurr) = thisData;
                surrLog(iSurr) = randTs;
            end
        end
        
        keepTrials = threshTrialData(data,zThresh);
        W_surr = [];
        W_surr = calculateComplexScalograms_EnMasse(data(:,keepTrials(1:size(W,3))),'Fs',Fs,'freqList',freqList);
        tWindow_sample = round(tWindow * Fs);
        reshapeRange = round(size(W_surr,1)/2)-tWindow_sample:round(size(W_surr,1)/2)+tWindow_sample-1;
        W_surr = W_surr(reshapeRange,:,:);
        W(8,:,:,:) = W_surr; % add fake trials
    
        for iShuffle = 1:2
            for iEvent = 1:size(W,1)
                keepLocs = dklPeakDetect(W(:,:,:,flankBands),iEvent);
                if iShuffle == 2
                    keepLocs = keepLocs(randsample(1:numel(keepLocs),numel(keepLocs)));
                end
                alpha = [];
                alpha_rnd = [];
                for iTrial = 1:size(W,3)
                    theseB = keepLocs{iTrial};
                    for iB = 1:size(theseB,1)
                        alpha = [alpha;angle(W(iEvent,theseB(iB,2),iTrial,1))];
                        alpha_rnd = [alpha_rnd;angle(W(iEvent,randsample(1:size(W,2),1),iTrial,1))];
                    end
                end
                alpha_events{iShuffle,iSession,iEvent} = alpha;
                alpha_rnd_events{iShuffle,iSession,iEvent} = alpha_rnd;
            end
        end

        if doPlot
            maxr = 0.25;
            h = ff(1200,600);
            rows = 2;
            cols = size(W,1);
            for iShuffle = 1:2
                for iEvent = 1:size(W,1)
                    r = circ_r(alpha_events{iShuffle,iSession,iEvent});
                    mu = circ_mean(alpha_events{iShuffle,iSession,iEvent});
                    r_rnd = circ_r(alpha_rnd_events{iShuffle,iSession,iEvent});
                    mu_rnd = circ_mean(alpha_rnd_events{iShuffle,iSession,iEvent});

                    subplot(rows,cols,prc(cols,[iShuffle iEvent]));
                    polarplot([mu mu],[0 r],'color',shuffleColors(iShuffle,:),'lineWidth',2);
                    hold on;
                    polarplot([mu_rnd mu_rnd],[0 r_rnd],'color','r','lineWidth',2);
                    p = gca;
                    rlim([0 maxr]);
                    p.RTick = rlim;
                    p.ThetaTick = [0 90 180 270];
                    if iShuffle == 1
                        if iEvent == 1
                            title({['session ',num2str(iSession)],'\delta-phase at \beta-event',eventFieldnames_wFake{iEvent}});
                        else
                            title(eventFieldnames_wFake{iEvent});
                        end
                    else
                        title('shuffle');
                    end
                end
            end
            legend({'real','random'},'location','eastoutside');
            set(gcf,'color','w');
            if doSave
                saveFile = ['deltaPhaseBetaEvent_s',num2str(iSession,'%02d'),'.png'];
                saveas(h,fullfile(savePath,saveFile));
                close(h);
            end
        end
    end
end

h = ff(1400,700);
maxr = 0.35;
rows = 4;
cols = size(W,1);
colorAlpha = 0.2;
all_r = [];
all_mu = [];
all_r_rnd = [];
all_mu_rnd = [];
for iShuffle = 1:2
    for iSession = 1:size(alpha_events,2)
        for iEvent = 1:size(W,1)
            r = circ_r(alpha_events{iShuffle,iSession,iEvent});
            all_r(iSession,iEvent) = r;
            mu = circ_mean(alpha_events{iShuffle,iSession,iEvent});
            all_mu(iSession,iEvent) = mu;
            r_rnd = circ_r(alpha_rnd_events{iShuffle,iSession,iEvent});
            all_r_rnd(iSession,iEvent) = r_rnd;
            mu_rnd = circ_mean(alpha_rnd_events{iShuffle,iSession,iEvent});
            all_mu_rnd(iSession,iEvent) = mu_rnd;

            subplot(rows,cols,prc(cols,[iShuffle*2-1,iEvent]));
            polarplot([mu mu],[0 r],'color',[shuffleColors(iShuffle,:) colorAlpha],'lineWidth',0.5);
            hold on;

            subplot(rows,cols,prc(cols,[iShuffle*2,iEvent]));
            polarplot([mu_rnd mu_rnd],[0 r_rnd],'color',[1 0 0 colorAlpha],'lineWidth',0.5);
            hold on;
        end
    end
    for iEvent = 1:size(W,1)
        r = mean(all_r(:,iEvent));
        mu = circ_mean(all_mu(:,iEvent));
        r_rnd = mean(all_r_rnd(:,iEvent));
        mu_rnd = circ_mean(all_mu_rnd(:,iEvent));

        subplot(rows,cols,prc(cols,[iShuffle*2-1,iEvent]));
        polarplot([mu mu],[0 r],'color',shuffleColors(iShuffle,:),'lineWidth',2);
        p = gca;
        rlim([0 maxr]);
        p.RTick = rlim;
        p.ThetaTick = [0 90 180 270];
        if iShuffle == 1
            title(eventFieldnames_wFake{iEvent});
        else
            title({'shuffled'});
        end

        subplot(rows,cols,prc(cols,[iShuffle*2,iEvent]));
        polarplot([mu_rnd mu_rnd],[0 r_rnd],'color',[1 0 0],'lineWidth',2);
        p = gca;
        rlim([0 maxr]);
        p.RTick = rlim;
        p.ThetaTick = [0 90 180 270];
        if iShuffle == 1
            title('randomized \beta');
        else
            title({'randomized \beta','shuffled'});
        end
    end
end
addNote(h,{['tWindow = ',num2str(tWindow),'s'],'','session in light-thin line','','randomized: a random time sample','to assess phase distribution',...
    'of entire trial window','','shuffled: shuffled trial order','','outTrial: random times outside','of trial (within session)'});
set(gcf,'color','w');
if doSave
    saveFile = 'deltaPhaseBetaEvent_allSessions.png';
    saveas(h,fullfile(savePath,saveFile));
    close(h);
end
