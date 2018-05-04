doSetup = true;
doClasses = false;
doDirSel = true;
doAllUnits = false;
doLabels = false;
doSave = true;
figPath = '/Users/mattgaidica/Box Sync/Leventhal Lab/Manuscripts/Thalamus_behavior_2017/Figures/MATLAB';

eventFieldlabelsNR = {eventFieldlabels{:} 'NR'};
fontSize = 8;
gLabels = {'All Units','Dir Sel','Not Dir Sel'};

% set these up for plotByUnitClass.m
dirSelUnitIds = [];
ndirSelUnitIds = [];

if doSetup
    FRs = [];
    CVs = [];
    FRs_classes = cell(8,1);
    FRs_dirSel = cell(3,1);
    CVs_dirSel = cell(3,1);
    groupCount = 0;
    g = {};
    for iNeuron = 1:numel(all_ts)
        if ismember(iNeuron,removeUnits)
            continue;
        end
        curTs = all_ts{iNeuron};
        curFR = numel(curTs) / curTs(end);
        curCV = coeffVar(curTs);
        FRs = [FRs curFR];
        CVs = [CVs curCV];

        % by class
        curClass = primSec(iNeuron,1);
        if ~isnan(curClass)
            FRs_classes{curClass} = [FRs_classes{curClass} curFR];
        else
            FRs_classes{8} = [FRs_classes{8} curFR];
        end

        % by dirSel, primary and secondary, see plotPermutations.m
        % "Fig 5" units only
        excludeUnits = find(any(ismember(primSec,[3,4]),2) == 0);
        excludeUnits = unique([excludeUnits;removeUnits']);
        
        % "all" is truly all units
        groupCount = groupCount + 1;
        g{groupCount} = gLabels{1};
        FRs_dirSel{1} = [FRs_dirSel{1} curFR];
        CVs_dirSel{1} = [CVs_dirSel{1} curCV];
            if ~ismember(iNeuron,excludeUnits)
            if ~ismember(iNeuron,dirSelUsedNeurons)
                continue;
            end

            groupCount = groupCount + 1;
            if dirSelNeuronsNO(iNeuron)
                dirSelUnitIds = [dirSelUnitIds iNeuron];
                g{groupCount} = gLabels{2};
                FRs_dirSel{2} = [FRs_dirSel{2} curFR];
                CVs_dirSel{2} = [CVs_dirSel{2} curCV];
            else
                ndirSelUnitIds = [ndirSelUnitIds iNeuron];
                g{groupCount} = gLabels{3};
                FRs_dirSel{3} = [FRs_dirSel{3} curFR];
                CVs_dirSel{3} = [CVs_dirSel{3} curCV];
            end
        end
    end
end

if doDirSel
    gColors = [0 0 0;1 0 0;.5 .5 .5];
    % get 10/90th whiskers: https://www.mathworks.com/matlabcentral/answers/171414-how-to-show-95-quanile-in-a-boxplot
    q3 = norminv(.75);
    q9 = norminv(0.9);
    w9 = (q9-q3)/(2*q3);
    
    h = figuree(600,200);
    subplot(121);
    hb = boxplot([FRs_dirSel{1},FRs_dirSel{2},FRs_dirSel{3}],g,'Symbol','','Whisker',w9,'Boxstyle','filled','medianStyle','target','Colors',gColors);
    FR_ylims = [0 50];
    ylim(FR_ylims);
% %     yticks(FR_ylims(1):10:FR_ylims(2));
    yticks(FR_ylims);
    yText = 55;
    
    if doLabels
        xticklabels(gLabels);
        ylabel('Firing Rate (spikes/sec)');
        text(1,yText,[num2str(numel(CVs_dirSel{1}))],'horizontalAlignment','center','fontSize',fontSize);
        text(2,yText,[num2str(numel(CVs_dirSel{2}))],'horizontalAlignment','center','fontSize',fontSize);
        text(3,yText,[num2str(numel(CVs_dirSel{3}))],'horizontalAlignment','center','fontSize',fontSize);
%         cleanPlot;
    else
        yticklabels({});
        xticklabels({});
    end
    box off;
    
    subplot(122);
    hb = boxplot([CVs_dirSel{1},CVs_dirSel{2},CVs_dirSel{3}],g,'Symbol','','Whisker',w9,'Boxstyle','filled','medianStyle','target','Colors',gColors);
    hold on;
    CV_ylims = [0 2.5];
    ylim(CV_ylims);
% %     yticks([CV_ylims(1):0.5:CV_ylims(2)]);
    yticks(sort([1 CV_ylims]));
    cvLine = plot(xlim,[1 1],'-','color',repmat(.8,1,3));
    uistack(cvLine,'bottom');
    
    yText = 2.3;
    if doLabels
        ylabel('Firing Regularity (CV)');
        xticklabels(gLabels);
        text(1,yText,[num2str(numel(FRs_dirSel{1}))],'horizontalAlignment','center','fontSize',fontSize);
        text(2,yText,[num2str(numel(FRs_dirSel{2}))],'horizontalAlignment','center','fontSize',fontSize);
        text(3,yText,[num2str(numel(FRs_dirSel{3}))],'horizontalAlignment','center','fontSize',fontSize);
    else
        yticklabels({});
        xticklabels({});
    end
    
    tightfig;
    setFig('','',[1,.7]);
    if doSave
        saveName = 'FRallUnits_dirSel';
        print(h,'-painters','-depsc',fullfile(figPath,[saveName,'.eps']));
        close(h);
    end
end

if doClasses
    h = figuree(1300,200);
    for iEvent = 1:8
        subplot(1,8,iEvent);
        curFRs = FRs_classes{iEvent};
        plotSpread(curFRs','showMM',5);
        meanFR = mean(curFRs);
        stdFR = std(curFRs);
        title({[eventFieldlabelsNR{iEvent},' (',num2str(numel(curFRs)),' units)'],['mean: ',num2str(meanFR)],['std: ',num2str(stdFR)]});
        ylim([0 100]);
        ylabel('FR (spikes/sec)');
        set(gca,'fontSize',fontSize);
    end
    addNote(h,{'FR for units of primary class','mean +/- standard deviation'});
    set(gcf,'color','w');
end

if doAllUnits
    figure;
    subplot(121);
    histogram(FRs,linspace(0,100,20),'FaceColor','k','EdgeColor','k','FaceAlpha',1);
    xlim([0 100]);
    xlabel('Firing Rate (spikes/sec)');
    ylabel('Units');
    meanFR = mean(FRs);
    stdFR = std(FRs);
    title({['All Units FR distribution (',num2str(numel(all_ts)),' units)'],['mean: ',num2str(meanFR)],['std: ',num2str(stdFR)]});
    set(gca,'fontSize',fontSize);

    subplot(122);
    plotSpread(FRs','showMM',5);
    ylabel('FR (spikes/sec)');
    ylim([0 100]);
    set(gca,'fontSize',fontSize);

    set(gcf,'color','w');
end