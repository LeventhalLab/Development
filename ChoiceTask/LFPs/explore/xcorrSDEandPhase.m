doSetup = false;
[uniqueLFPs,ic,ia] = unique(LFPfiles);
bandLabels = {'\beta','\gamma'};
rows = 1;
cols = 7;
iBand = 1;

if doSetup
    pvals_neuron = {};
    for iNeuron = 1:366
        sevFile = LFPfiles_local{iNeuron};
        disp(sevFile);
        curTrials = all_trials{iNeuron};
        [W,freqList,allTimes] = getW(sevFile,curTrials,eventFieldnames,freqList);
        curSDEs = all_SDEs_zscore{iNeuron};
        pvals_event = [];
        for iEvent = 1:cols
            pvals_trials = [];
            for iTrial = 1:size(curSDEs,1)
                W_event = squeeze(W(iEvent,:,iTrial,iBand));
                SDE_event = curSDEs{iTrial,iEvent};
                t = linspace(-1,1,numel(SDE_event));
                t_W = round(linspace(1,numel(W_event),numel(SDE_event)));
                W_event = W_event(t_W);
                [rho,pval] = circ_corrcl(angle(W_event),SDE_event);
                pvals_trials = [pvals_trials pval];
            end
            pvals_event(iEvent,:) = pvals_trials;
        end
        pvals_neuron{iNeuron} = pvals_event;
    end
end

figuree(900,800);
imagescArr = ones(366,100);
for iEvent = 1:7
    sort_event = [];
    for iNeuron = 1:numel(pvals_neuron)
        cur_pvals = pvals_neuron{iNeuron};
        pvals_event = cur_pvals(iEvent,:);
        imagescArr(iNeuron,1:numel(pvals_event)) = sort(pvals_event);
        sort_event(iNeuron) = numel(find(pvals_event < 0.05)) / numel(pvals_event);
    end
    [~,k] = sort(sort_event);
    subplot(1,7,iEvent);
    imagesc(imagescArr(k,:));
    xlim([1 100]);
    colormap(jet);
    caxis([0 1]);
    title(eventFieldnames{iEvent});
    ylabel('units');
    xlabel('sorted trials');
end