% eventFieldnames = {'cueOn';'centerIn';'tone';'centerOut';'sideIn';'sideOut';'foodRetrieval'};
doSave = true;
doFigure = false;
figPath = '/Users/mattgaidica/Box Sync/Leventhal Lab/Manuscripts/Thalamus_behavior_2017/Figures/MATLAB';

doAnalysis = 1; % 1 = all events, 2 = dirSel
colors = jet(7);
dirColors = [1 0 0;.5 .5 .5];
dotSize_mm = .04;
atlas_ims = [];
useEvents = [1:7];
if ismac
    local_nasPath = '/Users/mattgaidica/Documents/Data/ChoiceTask';
else
    local_nasPath = '\\172.20.138.142\RecordingsLeventhal2\ChoiceTask';
end

a1_hist = cell(numel(useEvents),1);
a2_hist = cell(2,1);
all_coords = NaN(size(analysisConf.neurons,1),3);
all_DV = [];

for iNeuron = 1:size(analysisConf.neurons,1)
    neuronName = analysisConf.neurons{iNeuron};
    sessionConf = analysisConf.sessionConfs{iNeuron};
    [electrodeName,electrodeSite,electrodeChannels] = getElectrodeInfo(neuronName);
    rows = sessionConf.session_electrodes.channel == electrodeChannels;
    channelData = sessionConf.session_electrodes(any(rows)',:);
    
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
    
    neuronClass = primSec(iNeuron,1);
    analysisLabel = '';
    switch doAnalysis
        case 1
            analysisLabel = 'byClass';
            if ~isnan(neuronClass)
                dotColor = colors(neuronClass,:);
                a1_hist{neuronClass} = [a1_hist{neuronClass} actualDV];
            else
                continue;
            end
        case 2
            if ismember(iNeuron,dirSelUnitIds)
                dotColor = dirColors(1,:);
                a2_hist{1} = [a2_hist{1} actualDV];
            elseif ismember(iNeuron,ndirSelUnitIds)
                dotColor = dirColors(2,:);
                a2_hist{2} = [a2_hist{2} actualDV];
            else
                continue;
            end
    end
    
    % override
%     dotColor = colors(dirSelNeurons(iNeuron) + 1,:);

    if isempty(channelData) || ~ismember(neuronClass,useEvents) || sum(isnan([AP ML DV]))
        disp(['!!! missing data: ',analysisConf.sessionNames{iNeuron}]);
        continue;
    end
    all_DV = [all_DV actualDV];
    [atlas_ims,k] = plotMthalElectrode(atlas_ims,AP,ML,DV,local_nasPath,dotColor,dotSize_mm);
end

if doSave
    for iim = 1:2
        h = figure;
        nCrop = 75;
        im = atlas_ims{iim};
        im = imcrop(im,[0 nCrop size(im,2) size(im,1) - nCrop]);
        imshow(im);
        saveas(h,fullfile(figPath,['atlas_ims',num2str(iim),analysisLabel,'.png']));
        close(h);
    end
end

if doFigure
    figure('position',[0 0 1400 600]);
    subplot(131);
    imshow(atlas_ims{1});
    subplot(132);
    imshow(atlas_ims{2});
    subplot(133);
    imshow(atlas_ims{3});

    set(gca,'fontSize',16);
    set(gcf,'color','w');
    hold on;

    lns = [];

    histLims = [5.5 8.3];
    binSpacing = 0.1; % mm
    binEdges = histLims(1):binSpacing:histLims(2);
    nSmooth = 10;
    lineWidth = 3;
    tightfig;

    switch doAnalysis
            case 1
                for ii = 1:numel(useEvents)
                    lns(ii) = plot(Inf,Inf,'.','markerSize',20,'color',colors(useEvents(ii),:));
                    hold on;
                end
                legend(lns,eventFieldlabels(useEvents));
                figuree(200,500);
                for ii = 1:numel(useEvents)
                    counts = histcounts(a1_hist{ii},binEdges);
                    countsPrct = counts ./ sum(counts);
                    plot(smooth(interp(countsPrct,nSmooth),nSmooth),interp(binEdges(2:end),nSmooth),'lineWidth',lineWidth,'color',colors(ii,:));
                    hold on;
                end
                ylim([5.9 7.9]);
            case 2
                for ii = 1:2
                    lns(ii) = plot(Inf,Inf,'.','markerSize',20,'color',dirColors(ii,:));
                    hold on;
                end
                legend(lns,{'Directionally Selective','Not Directionally Selective'});
                figuree(200,500);
                for ii = 1:2
                    counts = histcounts(a2_hist{ii},binEdges);
                    countsPrct = counts ./ sum(counts);
                    plot(smooth(interp(countsPrct,nSmooth),nSmooth),interp(binEdges(2:end),nSmooth),'lineWidth',lineWidth,'color',dirColors(ii,:));
                    hold on;
                end
                ylim([5.9 7.9]);
    end

    ylabel('DV');
    ylabel('DV');
    xlabel('% of Total');
    set(gca,'YDir','reverse');
    set(gcf,'color','w');
end