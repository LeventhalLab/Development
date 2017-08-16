% are sensory signals accompanied by the drops in firing?
% can we determine tone vs. centerOut just by dips in z?

useSubjects = [88,117,142,154];
trialTypes = {'correctContra','correctIpsi'};
useEvents = 1:7;
tWindow = 1;
% 3

all_zPoints_xs = [];
all_zPoints_ys = [];
all_zPointNeuronsIds = [];
all_zPointNeuronsClass = [];
neuronCount = 1;
for iNeuron = 1:size(analysisConf.neurons,1)
    if isempty(unitEvents{iNeuron}.class) || ~ismember(sessionConf.subjects__id,useSubjects)
        continue;
    end
    if ~ismember(unitEvents{iNeuron}.class(1),[3,4]) % only tone, centerOut
        continue;
    end
    zData = squeeze(all_zscores(iNeuron,4,:));
    
    [v,k] = min(zData(5:15));
    all_zPoints_ys(neuronCount,1) = v;
    all_zPoints_xs(neuronCount,1) = k + 5 - 1;
    
    [v,k] = max(zData(15:25));
    all_zPoints_ys(neuronCount,2) = v;
    all_zPoints_xs(neuronCount,2) = k + 15 - 1;

    [v,k] = min(zData(25:35));
    all_zPoints_ys(neuronCount,3) = v;
    all_zPoints_xs(neuronCount,3) = k + 25 - 1;
    
    all_zPointNeuronsIds(neuronCount) = iNeuron;
    all_zPointNeuronsClass(neuronCount) = unitEvents{iNeuron}.class(1);
    
    neuronCount = neuronCount + 1;
end
if false
    figuree(1200,400);
    subplot(131);
    for ii = 1:numel(all_zPointNeuronsIds)
        curColor = 'k';
        if all_zPointNeuronsClass(ii) == 3
            curColor = 'r';
        end
        plot(all_zPoints_xs(ii,2),all_zPoints_ys(ii,1),'.','MarkerSize',20,'color',curColor);
        hold on;
        title('max zbin vs. ys1');
        ylabel('z');
        xlabel('bin');
    end
    subplot(132);
    for ii = 1:numel(all_zPointNeuronsIds)
        curColor = 'k';
        if all_zPointNeuronsClass(ii) == 3
            curColor = 'r';
        end
        plot(all_zPoints_xs(ii,2),all_zPoints_ys(ii,2),'.','MarkerSize',20,'color',curColor);
        hold on;
        title('max zbin vs. ys1');
        ylabel('z');
        xlabel('bin');
    end
    subplot(133);
    for ii = 1:numel(all_zPointNeuronsIds)
        curColor = 'k';
        if all_zPointNeuronsClass(ii) == 3
            curColor = 'r';
        end
        plot(all_zPoints_xs(ii,2),all_zPoints_ys(ii,3),'.','MarkerSize',20,'color',curColor);
        hold on;
        title('max zbin vs. ys1');
        ylabel('z');
        xlabel('bin');
    end
end


figure;
subplot(121);
zDist_tone = [];
zDist_centerOut = [];
all_zDist = [];
anovaGroup = {};
for ii = 1:numel(all_zPointNeuronsIds)
%     zDist = diff(diff(all_zPoints_ys(ii,:)))*-1; % 0.002775041429774
    zDist = all_zPoints_ys(ii,2) - all_zPoints_ys(ii,1); % 0.004319882424784
    all_zDist = [all_zDist zDist];
%     zDist = all_zPoints_ys(ii,3);
    if all_zPointNeuronsClass(ii) == 3
        curColor = 'r';
        zDist_tone = [zDist_tone zDist];
        anovaGroup{ii} = 'Tone';
    else
        curColor = 'k';
        zDist_centerOut = [zDist_centerOut zDist];
        anovaGroup{ii} = 'centerOut';
    end
    
    plot(all_zPoints_xs(ii,2),zDist,'.','MarkerSize',20,'color',curColor);
    hold on;
    ylabel('diff z');
    xlabel('bin');
end

subplot(122);
errorbar([1 2],[mean(zDist_tone) mean(zDist_centerOut)],[std(zDist_tone) std(zDist_centerOut)]);
xlim([0 3]);


[p,tbl,stats] = anova1(all_zDist,anovaGroup)