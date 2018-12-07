doSetup = false;
zThresh = 5;
tWindow = 1;
freqList = {[1 4;4 8;13 30;30 70]};
Wlength = 400;

if doSetup
    trial_Wz_power = [];
    trial_Wz_phase = [];
    session_Wz_rayleigh_pval = [];
    compiledRTs = [];
    iSession = 0;
    trialCount = 0;
    for iNeuron = selectedLFPFiles'
        iSession = iSession + 1;
        disp(iSession);
        sevFile = LFPfiles_local{iNeuron};
        disp(sevFile);
        [~,name,~] = fileparts(sevFile);
        subjectName = name(1:5);
        curTrials = all_trials{iNeuron};
        [trialIds,allTimes] = sortTrialsBy(curTrials,'RT');
        [sevFilt,Fs,decimateFactor] = loadCompressedSEV(sevFile,[]);
        [W,all_data] = eventsLFPv2(curTrials(trialIds),sevFilt,tWindow,Fs,freqList,eventFieldnames);
        keepTrials = threshTrialData(all_data,zThresh);
        W = W(:,:,keepTrials,:);
        compiledRTs = [compiledRTs allTimes(keepTrials)];
        [Wz_power,Wz_phase] = zScoreW(W,Wlength); % power Z-score
        
        trialCount = trialCount + size(Wz_power,3);
        % iEvent, iTrial, iTime, iFreq
        if iSession == 1
            trial_Wz_power = Wz_power;
            trial_Wz_phase = Wz_phase;
        else
            trial_Wz_power(:,:,size(trial_Wz_power,3)+1:trialCount,:) = Wz_power;
            trial_Wz_phase(:,:,size(trial_Wz_phase,3)+1:trialCount,:) = Wz_phase;
        end
    end
end

data_source = {trial_Wz_power trial_Wz_phase};
[RTv,RTk] = sort(compiledRTs);
bandLabels = {'\delta','\theta','\beta','\gamma'};
titleLabels = {'power','phase'};

% k1 = closest(RTv,0);
% k2 = closest(RTv,1);
% RTrange = k1:k2;
pThresh = .001;
intv = 100;
useRange = intv:intv:numel(RTv);
rows = 4;
cols = 7;
for iCond = 2%:2
    ff(1500,800);
    useData = data_source{iCond};
    for iEvent = 1:7
        for iFreq = 1:4
            thisData = squeeze(useData(iEvent,:,:,iFreq));
            pMat = NaN(numel(useRange),numel(useRange));
            range_log = [];
            for iRange = 1:numel(useRange)-1
                disp(iRange);
                curRange = useRange(iRange);
                for RTcenter = useRange(iRange:end-iRange)
                    RTrange = (RTcenter - curRange + 1) : (RTcenter + curRange);
                    range_log = [range_log numel(RTrange)];
                    all_pval = [];
                    all_rho = [];
                    for iTime = 1:size(thisData,1)
                        if iCond == 1
                            [rho,pval] = corr(thisData(iTime,RTrange)',RTv(RTrange)');
                        else
                            [rho,pval] = circ_corrcl(thisData(iTime,RTrange)',RTv(RTrange)');
                        end
                        all_pval(iTime) = pval;
                        all_rho(iTime) = rho;
                    end
                    pMat(find(useRange == curRange),find(useRange == RTcenter)) = sum(all_pval < pThresh);
                end
            end
            % do plot
            subplot(rows,cols,prc(cols,[iFreq,iEvent]));
            imagesc((100*pMat/numel(all_pval))');
            colormap(jet);
            caxis([0 100]);
%             cb = colorbar;
%             cb.Ticks = caxis;
%             cb.Label.String = ['p < ',num2str(pThresh,'%1.3f'),' (% window)'];
            xlabel('RT range (%)');
            ylabel('RT center (s)');
            
            xInt = 11;
            xtickVals = floor(linspace(0,numel(unique(range_log)),xInt));
            xticks(xtickVals);
            xtickLabelVals = linspace(0,100,xInt);
            xticklabels(compose('%3.0f',xtickLabelVals));
            xtickangle(270);
            xlim([1 max(xtickVals)]);
            
            yInt = 11;
            ytickVals = floor(linspace(1,numel(useRange),yInt));
            yticks(ytickVals);
            yticklabels(compose('%1.2f',RTv(useRange(ytickVals))));
            set(gca,'ydir','normal');
            title([bandLabels{iFreq},'-',titleLabels{iCond},' at ',eventFieldnames{iEvent}]);
% %             set(gca,'fontSize',14);
            drawnow;
        end
    end
    set(gcf,'color','w');
end

if false
    rows = 1;%size(trial_Wz_power,4);
    useEvents = 1:7;
    cols = numel(useEvents);
    cmaps = {'jet','parula'};
    caxisVals = {[-2 5],[-pi pi]};
    for iCond = 2
        ff(1400,800);
        useData = data_source{iCond};
        for iEvent = useEvents
            for iFreq = 1%:size(trial_Wz_power,4)
                subplot(rows,cols,prc(cols,[iFreq,iEvent]));
                thisData = squeeze(useData(iEvent,:,RTk,iFreq));
                imagesc(linspace(-tWindow,tWindow,size(thisData,1)),RTv,thisData');
                colormap(gca,cmaps{iCond});
                caxis(caxisVals{iCond});
                if iFreq == 1
                    title({[eventFieldnames{iEvent},' - ',titleLabels{iCond}],bandLabels{iFreq}});
                else
                    title(bandLabels{iFreq});
                end
                if iEvent == 1
                    ylabel('RT (s)');
                else
                    yticklabels([]);
                end
                if iFreq == size(trial_Wz_power,4)
                    xticks([-tWindow,0,tWindow]);
                    xlabel('Time (s)');
                else
                    xticks([]);
                end
                grid on;
            end
        end
    end
end