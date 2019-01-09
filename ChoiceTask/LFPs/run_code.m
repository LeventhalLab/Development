savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/perievent/entrainmentTrialShuffle/wBeta';
doSave = true;
rows = 6;
cols = 4;

tWindow = 0.2;
zThresh = 5;
freqList = logFreqList([1 200],30);
n = 12;
nBins = 12;
binEdges = linspace(-pi,pi,nBins+1);
iEvent = 4;
iFreq = 3;
colors = lines(n);
plotMap = [1,2,5,6,9,10,13,14,17,18,21,22];
nShuff = [1,100];
maxr = 0.5;

loadedFile = [];
all_r = [];
all_mu = [];
all_n = [];
all_session = [];
iSession = 0;
for iNeuron = 1:numel(all_ts)
    sevFile = LFPfiles_local{iNeuron};
    % replace with alternative for LFP
    sevFile = LFPfiles_local_altLookup{strcmp(sevFile,{LFPfiles_local_altLookup{:,1}}),2};
    disp(sevFile);
    [~,name,~] = fileparts(sevFile);
    % only load uniques
    if isempty(loadedFile) || ~strcmp(loadedFile,sevFile)
        iSession = iSession + 1;
        [sevFilt,Fs,decimateFactor,loadedFile] = loadCompressedSEV(sevFile,[]);
        curTrials = all_trials{iNeuron};
        [trialIds,allTimes] = sortTrialsBy(curTrials,'RT');
        [W,all_data] = eventsLFPv2(curTrials(trialIds),sevFilt,tWindow,Fs,freqList,eventFieldnames);
        trialRanges = periEventTrialTs(curTrials(trialIds),tWindow,eventFieldnames);
        keepTrials = threshTrialData(all_data,zThresh);
        W = W(:,:,keepTrials,:);
        trialRanges = trialRanges(:,keepTrials,:);
        
        W2 = eventsLFPv2(curTrials(trialIds),sevFilt,1,Fs,freqList,eventFieldnames);
        W2 = W2(:,:,keepTrials,:);
        
        keepLocs = dklPeakDetect(W(:,:,:,[12,17,22]),4);
    end
    all_session(iNeuron) = iSession;

    ts = all_ts{iNeuron};

    h = ff(1200,800);
    set(gcf,'color','w');
    t = linspace(-tWindow,tWindow,size(W,2));
    t2 = linspace(-1,1,size(W2,2));
    
    alpha = [];
    lns = [];
    for iTrial = 1:size(W,3)
        if iTrial <= n
            subplot(rows,cols,plotMap(iTrial));
            plot(t2,angle(W2(iEvent,:,iTrial,iFreq)),'k'); drawnow;
            hold on;
            lns(1) = plot(t,angle(W(iEvent,:,iTrial,iFreq)),'k','lineWidth',4); drawnow;

            % take a look at beta events
            theseB = keepLocs{iTrial};
            for iB = 1:size(theseB,1)
                idx = theseB(iB,2);
                lns(3) = plot(t(idx),0,'rx','MarkerSize',10,'lineWidth',2); drawnow;
            end

            ylim([-4 4]);
            yticks([-pi 0 pi]);
            yticklabels({'-\pi','0','\pi'});
            xlim([-1 1]);
            xticks(sort([0 -.2 .2 xlim]));
            if iTrial == 1
                title(['u',num2str(iNeuron),'/366, s',num2str(iSession),'/30, t',num2str(iTrial),'/',num2str(size(W,3))]);
            else
                title(['t',num2str(iTrial),'/',num2str(size(W,3))]);
            end
            grid on;
            if iTrial >= n - 1
                xlabel('time (s)');
            end
        end    
        useTs = ts(ts > trialRanges(iEvent,iTrial,1) & ts < trialRanges(iEvent,iTrial,2)) - mean(trialRanges(iEvent,iTrial,:));
        for iTs = 1:numel(useTs)
            thisAngle = angle(W(iEvent,closest(t,useTs(iTs)),iTrial,iFreq));
            alpha = [alpha;thisAngle];
            if iTrial <= n
                % line plots
                subplot(rows,cols,plotMap(iTrial));
                lns(2) = plot([useTs(iTs) useTs(iTs)],[-pi pi],'color',colors(iTrial,:));
                plot(useTs(iTs),thisAngle,'o','color',colors(iTrial,:));
                % polar plot
                subplot(rows,cols,[3,7]);
                polarplot(thisAngle,maxr,'o','color',colors(iTrial,:));
                hold on;
            else
                subplot(rows,cols,[3,7]);
                polarplot(thisAngle,maxr,'.','color','k');
            end
        end
    end
    subplot(rows,cols,plotMap(n));
    legend(lns,{'\delta','spike','\beta'});
    drawnow;

    for iType = 1:2 % spiking, beta
        for iShuffle = 1:2
            alpha = [];
            for iShuff = 1:nShuff(iShuffle)
                if iShuffle == 1
                    useW = W;
                    useColor = 'k';
                else
                    useW = W(:,:,randsample(1:size(W,3),size(W,3)),:);
                    useColor = 'r';
                end
                for iTrial = 1:size(W,3)
                    if iType == 1
                        typeLabel = 'spiking';
                        histMap = [3 7;11 15;19 23];
                        useTs = ts(ts > trialRanges(iEvent,iTrial,1) & ts < trialRanges(iEvent,iTrial,2)) - mean(trialRanges(iEvent,iTrial,:));
                        for iTs = 1:numel(useTs)
                            thisAngle = angle(useW(iEvent,closest(t,useTs(iTs)),iTrial,iFreq));
                            alpha = [alpha;thisAngle];
                            if iShuffle == 1
                                if iTrial < n % line plots
                                    subplot(rows,cols,plotMap(iTrial));
                                    plot([useTs(iTs) useTs(iTs)],[-pi pi],'color',colors(iTrial,:));
                                    plot(useTs(iTs),thisAngle,'o','color',colors(iTrial,:));
                                end
                                % polar plot
                                subplot(rows,cols,histMap(1,:));
                                polarplot(thisAngle,maxr,'.','color','k');
                            end
                        end
                    elseif iType == 2
                        typeLabel = '\beta';
                        histMap = [4 8;12 16;20 24];
                        theseB = keepLocs{iTrial};
                        for iB = 1:size(theseB,1)
                            thisAngle = angle(useW(iEvent,theseB(iB,2),iTrial,iFreq));
                            alpha = [alpha;thisAngle];
                            if iShuffle == 1
                                subplot(rows,cols,histMap(1,:));
                                polarplot(thisAngle,maxr,'.','color','k');
                                hold on;
                            end
                        end
                    end
                end
            end
            drawnow;
            
            subplot(rows,cols,histMap(1,:));
            r = circ_r(alpha);
            mu = circ_mean(alpha);
            
            all_r(iNeuron,iType,iShuffle) = r;
            all_mu(iNeuron,iType,iShuffle) = mu;
            all_n(iNeuron,iType,iShuffle) = numel(alpha);
            
            polarplot([mu mu],[0 r],'color',useColor,'linewidth',4);
            hold on;

            counts = histcounts(alpha,'BinEdges',binEdges);
            if iShuffle == 2
                counts = counts / nShuff(2);
            end

            subplot(rows,cols,histMap(2,:));
            hp = polarhistogram('BinEdges',binEdges,'BinCounts',counts,'FaceColor',useColor);
            if iShuffle == 2
                hp.DisplayStyle = 'stairs';
            end
            hold on;

            subplot(rows,cols,histMap(3,:));
            if iShuffle == 1
                bar([counts counts],useColor);
            else
                ln = plot([counts counts],[useColor,':'],'linewidth',2);
            end
            hold on;
            drawnow;
        end
        subplot(rows,cols,histMap(1,:));
        p = gca;
        rlim([0 maxr]);
        p.RTick = rlim;
        p.ThetaTick = [0 90 180 270];
        title(typeLabel);

        subplot(rows,cols,histMap(2,:));
        p = gca;
        p.RTick = rlim;
        p.ThetaTick = [0 90 180 270];

        subplot(rows,cols,histMap(3,:));
        xticks(linspace(1,24,9));
        xticklabels([180 270 0 90 180 270 0 90 180]);
        yticks(ylim);
        ylabel('count');
        xtickangle(270);
        grid on;
        legend(ln,'shuffle');
        legend boxoff;
        
        drawnow;
    end
    
    if doSave
        saveFile = ['entrainment_wBeta_u',num2str(iNeuron,'%03d'),'_e',num2str(iEvent),'_f',num2str(iFreq),'.png'];
        saveas(h,fullfile(savePath,saveFile));
        close(h);
    end
end

save('entrainment_wBeta_20190108','all_r','all_mu','all_n','all_session');

