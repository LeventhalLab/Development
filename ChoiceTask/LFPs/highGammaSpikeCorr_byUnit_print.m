savePath = '/Users/mattgaidica/Box Sync/Leventhal Lab/Manuscripts/Mthal LFPs/Figures';
doSave = true;

data_source_labels = {'sessionRhos_byPower','sessionRhos_byEnvelope','sessionRhos_byPhase'};
bandLabels = {'\delta','\theta','\beta','\gamma','\gamma_h'};
% data_sources = {data_source_inTrial_no_alt,data_source_inTrial_alt,...
%     data_source_outTrial_no_alt,data_source_outTrial_alt};
load('session_20181129_highGamma_sub_data_sources.mat');
colors = [0 0 0;lines(1)];
grayColor = repmat(0.8,[1,4]);
source_labels = {'noAlt','Alt'};
in_out_labels = {'IN trial','OUT trial'};

h = ff(600,800);
rows = 3;
cols = 2;
for iInOut = 1:2
    for iAlt = 1:2
        data_source = data_sources{(iInOut-1)*2 + iAlt};
        for iCorr = 1:3
            theseData = abs(data_source{iCorr});

            subplot(rows,cols,prc(cols,[iCorr,iInOut]));
            errorbar(1:5,mean(theseData),std(theseData),'color',colors(iAlt,:),'lineWidth',2);
            hold on;
            ylim([-.01 .12]);
            ylabel('|rho|');
            title({in_out_labels{iInOut},data_source_labels{iCorr}},'interpreter','none');
            ffp
            xticks([1:5]);
            xticklabels(bandLabels);
            xlim([0 6]);
            yticklabels({'','0',num2str(max(ylim))});
        end
    end
    legend(source_labels);
    legend box off;
end

for iInOut = 1:2
    for iCorr = 1:3
        for iFreq = 1:5
            if iInOut == 1
                data_source1 = abs(data_sources{1}{iCorr}(:,iFreq)); % IN NO ALT
                data_source2 = abs(data_sources{2}{iCorr}(:,iFreq)); % IN ALT
            else
                data_source1 = abs(data_sources{3}{iCorr}(:,iFreq)); % IN NO ALT
                data_source2 = abs(data_sources{4}{iCorr}(:,iFreq)); % IN ALT
            end
            y = [data_source1;data_source2];
            groups = [zeros(size(data_source1));ones(size(data_source2))];
            p = anova1(y,groups,'off');
            subplot(rows,cols,prc(cols,[iCorr,iInOut]));
            fontColor = 'k';
            if p < 0.05
                fontColor = 'r';
            end
            text(iFreq,0.1,num2str(p,2),'fontSize',8,'color',fontColor);
        end
    end
end

if doSave
    saveas(h,fullfile(savePath,'highGammeSpikeCorr_byUnit_wAlt_inTrial.png'));
    close(h);
end