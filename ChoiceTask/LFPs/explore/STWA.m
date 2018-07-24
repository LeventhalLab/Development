doSave = true;
doSetup = true;
savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/perievent/STWA';
sevFile = '';
zThresh = 2;
tWindow = 3;
Wlength = tWindow * 100 * 2;
t = linspace(-tWindow,tWindow,Wlength);
tWindow_vis = 1;
STWA_centers = linspace(-tWindow_vis,0,5);
STWA_centers = 0;
STWA_window = 0.25; % on either side
STWA_samples = (Wlength / tWindow) * tWindow_vis / 2;
freqList = logFreqList([1 200],30);
ytickIds = [1 closest(freqList,20) closest(freqList,55) numel(freqList)]; % selected from freqList
ytickLabelText = freqList(ytickIds);
ytickLabelText = num2str(ytickLabelText(:),'%3.0f');
gridColor = repmat(.7,[1,3]);

cmapPath = '/Users/mattgaidica/Documents/MATLAB/LeventhalLab/Development/ChoiceTask/LFPs/utils/corr_colormap.jpg';
cmap = mycmap(cmapPath);

cols = 7;
rows = numel(STWA_centers)*2;

for iNeuron = 1:numel(LFPfiles_local)
    if doSetup
        if ~strcmp(sevFile,LFPfiles_local{iNeuron})
            sevFile = LFPfiles_local{iNeuron};
            disp(sevFile);
            [~,name,~] = fileparts(sevFile);
            subjectName = name(1:5);
            curTrials = all_trials{iNeuron};
            [trialIds,allTimes] = sortTrialsBy(curTrials,'RT');
            [sevFilt,Fs,decimateFactor] = loadCompressedSEV(sevFile);
            W = eventsLFPv2(curTrials(trialIds),sevFilt,tWindow,Fs,freqList,eventFieldnames);
            [Wz_power,Wz_phase] = zScoreW(W,Wlength); % power Z-score
            [Wz_power,keepTrials] = removeWzTrials(Wz_power,zThresh);
            trialIds = trialIds(keepTrials);
        end
        ts = all_ts{iNeuron};
        tsPeths = eventsPeth(curTrials(trialIds),ts,tWindow,eventFieldnames);
        eventScalos_power = [];
        eventScalos_phase = [];
        spikeCounts = [];
        eventSpikes = {};
        for iEvent = 1:7
            binScalos_power = [];
            binScalos_phase = [];
            for iCenter = 1:numel(STWA_centers)
                trialScalos_power = [];
                trialScalos_phase = [];
                trialSpikes = [];
                trialTsCount = 0;
                for iTrial = 1:size(tsPeths,1)
                    theseTs = tsPeths{iTrial,iEvent};
                    for iTs = 1:numel(theseTs)
                        if theseTs(iTs) >= STWA_centers(iCenter) - STWA_window && theseTs(iTs) < STWA_centers(iCenter) + STWA_window
                            trialTsCount = trialTsCount + 1;
                            centerIdx = closest(t,theseTs(iTs));
                            STWA_range = centerIdx - STWA_samples:centerIdx + STWA_samples - 1;
                            trialScalos_power(trialTsCount,:,:) = squeeze(Wz_power(iEvent,STWA_range,iTrial,:));
                            trialScalos_phase(trialTsCount,:,:) = squeeze(Wz_phase(iEvent,STWA_range,iTrial,:));
                            trialSpikes(trialTsCount) = theseTs(iTs);
                        end
                    end
                end
                if trialTsCount == 1
                    binScalos_power(iCenter,:,:) = trialScalos_power;
                    binScalos_phase(iCenter,:,:) = trialScalos_phase;
                elseif trialTsCount > 1
                    binScalos_power(iCenter,:,:) = squeeze(mean(trialScalos_power));
                    binScalos_phase(iCenter,:,:) = squeeze(circ_r(trialScalos_phase));
                else
                    binScalos_power(iCenter,:,:) = NaN(numel(STWA_range),numel(freqList));
                    binScalos_phase(iCenter,:,:) = NaN(numel(STWA_range),numel(freqList));
                end
                eventSpikes{iEvent,iCenter} = trialSpikes;
            end
            eventScalos_power(iEvent,:,:,:) = binScalos_power;
            eventScalos_phase(iEvent,:,:,:) = binScalos_phase;
        end
    end
    
    iiLabels = {'Power','MRL'};
    iiCaxis = [-2 2;0 0.5];
    for ii = 1:2
        h = figuree(1400,400);
        for iEvent = 1:size(eventScalos_power,1)
            for iCenter = 1:size(eventScalos_power,2)
                subplot(rows,cols,prc(cols,[iCenter*2-1,iEvent]));
                if ii == 1
                    thisScalo = squeeze(squeeze(eventScalos_power(iEvent,iCenter,:,:)));
                else
                    thisScalo = squeeze(squeeze(eventScalos_phase(iEvent,iCenter,:,:)));
                end
                imagesc(linspace(-tWindow_vis,tWindow_vis,size(thisScalo,1)),1:numel(freqList),thisScalo');
                if ii == 1
                    colormap(gca,cmap);
                else
                    colormap(gca,hot);
                end
                xlim([-tWindow_vis tWindow_vis]);
                xticks(sort([0 xlim STWA_window -STWA_window]));
                xticklabels({'-1','','0','','1'});
                yticks(ytickIds);
                yticklabels(ytickLabelText);
                set(gca,'YDir','normal');
                caxis(iiCaxis(ii,:));
                if iCenter == 1
                    primSecLabel = '';
                    if primSec(iNeuron,1) == iEvent
                        primSecLabel = '^{primary}';
                    end
                    if primSec(iNeuron,2) == iEvent
                        primSecLabel = '^{secondary}';
                    end
                    title({[eventFieldnames{iEvent},primSecLabel],['STA +/- ',num2str(STWA_window,'%1.2f'),'s'],iiLabels{ii}});
                end
                if iEvent == 1
                    ylabel([num2str(STWA_centers(iCenter),'%1.2f'),'s']);
                end
                if iEvent == size(eventScalos_power,1) && iCenter == size(eventScalos_power,2)
                    cb = colorbar('Location','east');
                    cb.Ticks = caxis;
                    cb.Label.String = ''; % !! label
                    cb.Color = 'w';
                end
                grid on;
                set(gca,'GridColor',gridColor);
                set(gca,'fontSize',8);

                subplot(rows,cols,prc(cols,[iCenter*2,iEvent]));
                binEdges = linspace(STWA_centers(iCenter) - tWindow_vis,STWA_centers(iCenter) + tWindow_vis,100);
                theseTs = eventSpikes{iEvent,iCenter};
                counts = histcounts(eventSpikes{iEvent,iCenter},binEdges);
                if iEvent == 1 && iCenter == 1
                    refMean = mean(counts);
                    refStd = std(counts);
                end
                zcounts = (counts - refMean) / refStd;
                zcounts(counts == 0) = NaN;
                plot(linspace(-tWindow_vis,tWindow_vis,numel(zcounts)),zcounts,'k');
                xlim([-tWindow_vis,tWindow_vis]);
                xticks(sort([xlim,0]));
                ylim([-2 6]);
                yticks(sort([ylim,0]));
                ylabel('z FR');
                title([num2str(numel(eventSpikes{iEvent,iCenter})),' spikes']);
                grid on;
                set(gca,'fontSize',8);
            end
        end
        set(gcf,'color','w');
        if doSave
            saveFile = [num2str(iNeuron,'%03d'),'_',iiLabels{ii},'.png'];
            saveas(h,fullfile(savePath,saveFile));
            close(h);
        end
    end
end