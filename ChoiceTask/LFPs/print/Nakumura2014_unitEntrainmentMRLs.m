savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/wholeSession/entrainmentVectors';
doSave = true;
nBins = 12;
binEdges = linspace(-pi,pi,nBins+1);
binCenters = linspace(-pi,pi,nBins);

rows = 4;
cols = 5;
rlimVals = [0 0.05];
freqPos = [1 2 3 4 5 11 12 13 14 15;6 7 8 9 10 16 17 18 19 20];

if true
    pval_thresh = 0.01;
    noteText = {'All Units',['Red p < ',num2str(pval_thresh,'%1.2f')]};
    h = figuree(1400,900);
    for iInOut = 1:2
        for iFreq = 1:numel(freqList)
            subplot(rows,cols,freqPos(iInOut,iFreq));
            for iNeuron = validUnits
                if iInOut == 1
                    r = all_spikeHist_inTrial_rs(iNeuron,iFreq);
                    pval = all_spikeHist_inTrial_pvals(iNeuron,iFreq);
                    mu = all_spikeHist_inTrial_mus(iNeuron,iFreq);
                    titleLabel = 'IN trial';
                else
                    r = all_spikeHist_rs(iNeuron,iFreq);
                    pval = all_spikeHist_pvals(iNeuron,iFreq);
                    mu = all_spikeHist_mus(iNeuron,iFreq);
                    titleLabel = 'OUT trial';
                end
                useColor = repmat(0.8,[1,3]);
                if pval < pval_thresh
                    useColor = 'r';
                end
                polarplot([mu mu],[0 r],'color',useColor);
                hold on;
                polarplot(mu,rlimVals(2),'o','MarkerSize',4,'color',useColor);
                ax = gca;
                hold on;
            end
            ax.ThetaDir = 'counterclockwise';
            ax.ThetaZeroLocation = 'top';
            ax.ThetaTick = [0 90 180 270];
            rlim(rlimVals);
            rticks(rlimVals);
            title([titleLabel,' ',num2str(freqList(iFreq),'%2.1f'),' Hz MRLs']);
            set(gca,'fontsize',8)
        end
    end
    set(gcf,'color','w');
    addNote(h,noteText);
    if doSave
        saveas(h,fullfile(savePath,['allUnits.png']));
        close(h);
    end
end

if true
    pval_thresh = 1;
    noteText = {'Red dirSel','Black ndirSel',['*only p < ',num2str(pval_thresh,'%1.2f')]};
    h = figuree(1400,900);
    for iInOut = 1:2
        alphas = {};
        for iFreq = 1:numel(freqList)
            subplot(rows,cols,freqPos(iInOut,iFreq));
            for iNeuron = validUnits
                if iInOut == 1
                    r = all_spikeHist_inTrial_rs(iNeuron,iFreq);
                    pval = all_spikeHist_inTrial_pvals(iNeuron,iFreq);
                    mu = all_spikeHist_inTrial_mus(iNeuron,iFreq);
                    titleLabel = 'IN trial';
                else
                    r = all_spikeHist_rs(iNeuron,iFreq);
                    pval = all_spikeHist_pvals(iNeuron,iFreq);
                    mu = all_spikeHist_mus(iNeuron,iFreq);
                    titleLabel = 'OUT trial';
                end
                if pval >= pval_thresh || ~ismember(iNeuron,[dirSelUnitIds ndirSelUnitIds])
                    continue;
                end
                if ismember(iNeuron,dirSelUnitIds)
                    useColor = 'r';
                    iCond = 1;
                else
                    useColor = 'k';
                    iCond = 2;
                end
                try alphas{iFreq,iCond};
                    alphas{iFreq,iCond} = [alphas{iFreq,iCond} mu];
                catch
                    alphas{iFreq,iCond} = mu;
                end
                polarplot([mu mu],[0 r],'color',useColor);
                hold on;
                polarplot(mu,rlimVals(2),'o','MarkerSize',4,'color',useColor);
                ax = gca;
                hold on;
            end
            ax.ThetaDir = 'counterclockwise';
            ax.ThetaZeroLocation = 'top';
            ax.ThetaTick = [0 90 180 270];
            rlim(rlimVals);
            rticks(rlimVals);
        end

        for iFreq = 1:numel(freqList)
            subplot(rows,cols,freqPos(iInOut,iFreq));
            dir_pval = 1;
            if ~isempty(alphas{iFreq,1})
                dir_pval = circ_rtest(alphas{iFreq,1});
            end
            ndir_pval = 1;
            if ~isempty(alphas{iFreq,2})
                ndir_pval = circ_rtest(alphas{iFreq,2});
            end
            kuiper_pval = 1;
            if numel(alphas{iFreq,1}) > 20 && numel(alphas{iFreq,2}) > 20
                kuiper_pval = circ_kuipertest(alphas{iFreq,1},alphas{iFreq,2});
            end
            title({[titleLabel,' ',num2str(freqList(iFreq),'%2.1f'),' Hz MRLs']...
% %                 ['dir r-test: ',num2str(dir_pval,2)],...
% %                 ['ndir r-test: ',num2str(ndir_pval,2)],...
                ['dir x ndir kuiper-test: ',num2str(kuiper_pval,2)]});
            set(gca,'fontsize',8)
        end
        for iFreq = 1:numel(freqList)
            subplot(rows,cols,freqPos(iInOut,iFreq));
            for iCond = 1:2
                if ~isempty(alphas{iFreq,iCond})
                    useColor = 'k';
                    if iCond == 1
                        useColor = 'r';
                    end
                    polarplot(circ_mean(alphas{iFreq,iCond}'),rlimVals(2),'.','MarkerSize',40,'color',useColor);
                    event_pval = circ_rtest(alphas{iFreq,iCond});
                    if event_pval < 0.01
                        polarplot(circ_mean(alphas{iFreq,iCond}'),rlimVals(2),'*','MarkerSize',30,'color',useColor);
                    end
                end
            end
        end
    end
    lns = [];
    lns(1) = polarplot([mu mu],[0 0],'color','r','lineWidth',2);
    lns(2) = polarplot([mu mu],[0 0],'color','k','lineWidth',2);
    legend(lns,{'dirSel','ndirSel'});
    set(gcf,'color','w');
    addNote(h,noteText);
    if doSave
        saveas(h,fullfile(savePath,['dirSelndirSelUnits.png']));
        close(h);
    end
end

if true
    pval_thresh = 1;
    noteText = {'Colored by event',['*only p < ',num2str(pval_thresh,'%1.2f')]};
    colors = [cool(7); repmat(0.8,[1,3])];
    h = figuree(1400,900);
    for iInOut = 1:2
        alphas = {};
        for iFreq = 1:numel(freqList)
            subplot(rows,cols,freqPos(iInOut,iFreq));
            for iNeuron = validUnits
                if iInOut == 1
                    r = all_spikeHist_inTrial_rs(iNeuron,iFreq);
                    pval = all_spikeHist_inTrial_pvals(iNeuron,iFreq);
                    mu = all_spikeHist_inTrial_mus(iNeuron,iFreq);
                    titleLabel = 'IN trial';
                else
                    r = all_spikeHist_rs(iNeuron,iFreq);
                    pval = all_spikeHist_pvals(iNeuron,iFreq);
                    mu = all_spikeHist_mus(iNeuron,iFreq);
                    titleLabel = 'OUT trial';
                end
                if pval >= pval_thresh
                    continue;
                end
                if isnan(primSec(iNeuron,1))
                    useColor = colors(8,:);
                else
                    useColor = colors(primSec(iNeuron,1),:);
                    try alphas{iFreq,primSec(iNeuron,1)};
                        alphas{iFreq,primSec(iNeuron,1)} = [alphas{iFreq,primSec(iNeuron,1)} mu];
                    catch
                        alphas{iFreq,primSec(iNeuron,1)} = mu;
                    end
                end
                polarplot([mu mu],[0 r],'color',useColor);
                hold on;
                polarplot(mu,rlimVals(2),'o','MarkerSize',4,'color',useColor);
                ax = gca;
                hold on;
            end
            ax.ThetaDir = 'counterclockwise';
            ax.ThetaZeroLocation = 'top';
            ax.ThetaTick = [0 90 180 270];
            rlim(rlimVals);
            rticks(rlimVals);
            title([titleLabel,' ',num2str(freqList(iFreq),'%2.1f'),' Hz MRLs']);
            set(gca,'fontsize',8)
        end
        for iFreq = 1:numel(freqList)
            subplot(rows,cols,freqPos(iInOut,iFreq));
            for iEvent = 1:7
                if ~isempty(alphas{iFreq,iEvent})
                    polarplot(circ_mean(alphas{iFreq,iEvent}'),rlimVals(2),'.','MarkerSize',40,'color',colors(iEvent,:));
                    event_pval = circ_rtest(alphas{iFreq,iEvent});
                    if event_pval < 0.01
                        polarplot(circ_mean(alphas{iFreq,iEvent}'),rlimVals(2),'*','MarkerSize',30,'color',colors(iEvent,:));
                    end
                end
            end
        end
    end
    lns = [];
    for iEvent = 1:8 % legend
        lns(iEvent) = polarplot([mu mu],[0 0],'color',colors(iEvent,:),'lineWidth',2);
    end
    legend(lns,{eventFieldnames{:} 'NaN'});
    set(gcf,'color','w');
    addNote(h,noteText);
    if doSave
        saveas(h,fullfile(savePath,['eventUnits.png']));
        close(h);
    end
end