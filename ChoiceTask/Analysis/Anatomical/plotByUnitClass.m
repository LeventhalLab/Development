% eventFieldnames = {'cueOn';'centerIn';'tone';'centerOut';'sideIn';'sideOut';'foodRetrieval'};
doAnalysis = 1; % 1 = all events, 2 = dirSel
colors = lines(7);
dirColors = [1 0 0;.5 .5 .5];
dotSize_mm = .04;
atlas_ims = [];
useEvents = [1:7];
local_nasPath = '/Users/mattgaidica/Documents/Data/ChoiceTask';

a1_hist = cell(numel(useEvents),1);
a2_hist = cell(2,1);
all_DV = [];
for iNeuron = 1:size(analysisConf.neurons,1)
    neuronName = analysisConf.neurons{iNeuron};
    sessionConf = analysisConf.sessionConfs{iNeuron};
    [electrodeName,electrodeSite,electrodeChannels] = getElectrodeInfo(neuronName);
    rows = sessionConf.session_electrodes.channel == electrodeChannels;
    channelData = sessionConf.session_electrodes(any(rows)',:);
    
    wiggleFactor = 0.3;
    wiggle = (rand(1) - 0.5) * wiggleFactor;
    AP = channelData{1,'ap'} + wiggle;
    wiggle = (rand(1) - 0.5) * wiggleFactor;
    ML = channelData{1,'ml'}; % no wiggle, this controls the image/slice
    wiggle = (rand(1) - 0.5) * wiggleFactor;
    actualDV = channelData{1,'dv'};
    DV = actualDV + wiggle;
    
    switch doAnalysis
        case 1
            if ~isempty(unitEvents{iNeuron}.class)
                neuronClass = unitEvents{iNeuron}.class(1);
                dotColor = colors(neuronClass,:);
                a1_hist{neuronClass} = [a1_hist{neuronClass} actualDV];
            else
                continue;
            end
        case 2
            if ~isempty(unitEvents{iNeuron}.class) && any(ismember(unitEvents{iNeuron}.class(1:2),4))
                if dirSelNeurons(iNeuron)
                    dotColor = dirColors(1,:);
                    a2_hist{1} = [a2_hist{1} actualDV];
                else
                    dotColor = dirColors(2,:);
                    a2_hist{2} = [a2_hist{2} actualDV];
                end
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
            figure;
            for ii = 1:numel(useEvents)
                counts = histcounts(a1_hist{ii},binEdges);
                plot(smooth(interp(counts,nSmooth),nSmooth),interp(binEdges(2:end),nSmooth),'lineWidth',lineWidth,'color',colors(ii,:));
                hold on;
            end
        case 2
            for ii = 1:2
                lns(ii) = plot(Inf,Inf,'.','markerSize',20,'color',dirColors(ii,:));
                hold on;
            end
            legend(lns,{'Directionally Selective','Not Directionally Selective'});
            figure;
            for ii = 1:2
                counts = histcounts(a2_hist{ii},binEdges);
                plot(smooth(interp(counts,nSmooth),nSmooth),interp(binEdges(2:end),nSmooth),'lineWidth',lineWidth,'color',dirColors(ii,:));
                hold on;
            end
end

ylabel('DV');
ylabel('DV');
xlabel('Units');
set(gca,'YDir','reverse');
set(gcf,'color','w');
