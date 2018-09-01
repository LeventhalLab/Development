% load('session_20180516_FinishedResubmission.mat', 'analysisConf');
doSave = true;
savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/wholeSession/spikePhaseUnitTypes';
dotSize_mm = .04;
colors = jet(50);
colors = [colors;repmat(colors(end,:),[951,1])];
if ismac
    local_nasPath = '/Users/mattgaidica/Documents/Data/ChoiceTask';
else
    local_nasPath = '\\172.20.138.142\RecordingsLeventhal2\ChoiceTask';
end

for iCond = 1:3
    switch iCond
        case 1
            histVals = all_spikeHist_pvals;
            titleLabel = 'ALL';
        case 2
            histVals = all_spikeHist_inTrial_pvals;
            titleLabel = 'IN TRIAL';
        case 3
            histVals = all_spikeHist_outTrial_pvals;
            titleLabel = 'OUT TRIAL';
    end
    atlas_ims = [];
    all_coords = NaN(size(analysisConf.neurons,1),3);
    for iNeuron = 1:numel(all_spikeHist_pvals)
        neuronName = analysisConf.neurons{iNeuron};
        sessionConf = analysisConf.sessionConfs{iNeuron};
        [electrodeName,electrodeSite,electrodeChannels] = getElectrodeInfo(neuronName);
        rows = sessionConf.session_electrodes.channel == electrodeChannels;
        channelData = sessionConf.session_electrodes(any(rows)',:);

        curPval = histVals(iNeuron);
        if isnan(curPval)
            %dotColor = [1 0 0];
            continue;
        else
            dotColor = colors(round(curPval*1000)+1,:);
        end

        wiggleFactor = 0.3;
        % AP
        wiggle = (rand(1) - 0.5) * wiggleFactor;
        actualAP = channelData{1,'ap'};
        AP = actualAP + wiggle;
        % ML
        actualML = channelData{1,'ml'}; % no wiggle, this controls the image/slice
        ML = actualML; % consistency in code
        % DV
        wiggle = (rand(1) - 0.5) * wiggleFactor;
        actualDV = channelData{1,'dv'};
        DV = actualDV + wiggle;

        all_coords(iNeuron,:) = [actualML,actualAP,actualDV];
        [atlas_ims,k] = plotMthalElectrode(atlas_ims,AP,ML,DV,local_nasPath,dotColor,dotSize_mm);
    end

    h = figuree(1400,600);
    subplot(131);
    imshow(atlas_ims{1});
    title(titleLabel);
    subplot(132);
    imshow(atlas_ims{2});
    title(titleLabel);
    subplot(133);
    imshow(atlas_ims{3});
    title(titleLabel);
    colormap(colors);
    cbAside(gca,'pval','k');

    set(gca,'fontSize',16);
    set(gcf,'color','w');
    if doSave
        saveFile = ['spikePhaseUnitsAnatomy_',titleLabel,'.png'];
        saveas(h,fullfile(savePath,saveFile));
        close(h);
    end
end