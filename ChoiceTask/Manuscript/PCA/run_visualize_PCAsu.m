savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/PCA/perSessionAnalysis/perUnit';
doSave = false;
colors = lines(2);
coeff_event = 4;
sessionPCA_coeff = sessionPCA_500ms;
sessionPCA_covMatrix = sessionPCA_1000ms;

t_vis = linspace(-tWindow_vis,tWindow_vis,SDEsamples);

rows = 8;
cols = 7;
    
for iSession = 1:numel(sessionPCA_coeff)
    for iNeuron = 1:size(sessionPCA(iSession).PCA_arr,2)
        h = figuree(1300,900);
        for iEvent = 1:cols
            covMatrix = squeeze(sessionPCA_covMatrix(iSession).PCA_arr(iEvent,:,:))';
            coeff = squeeze(sessionPCA_coeff(iSession).coeff(iEvent,:,:)); % NOTE COEFF SOURCE
            su_covMatrixcov = covMatrix(:,iNeuron);
            pca_data = su_covMatrixcov * coeff(iNeuron,:);
            
            reshaped_unit_covMatrix = reshape(su_covMatrixcov,[SDEsamples size(covMatrix,1)/SDEsamples]);
            subplot(rows,cols,iEvent);
            plot(t_vis,mean(reshaped_unit_covMatrix,2),'-','lineWidth',2,'color',colors(1,:));
            xlim([min(t_vis) max(t_vis)]);
            ylimVals = [-2 2];
            ylim(ylimVals);
            yticks(sort([ylimVals 0]));
            grid on;

            if iEvent == 1
                title({['Session ',num2str(iSession),', Unit ',num2str(iNeuron)],eventFieldnames{iEvent},'Mean SDE'});
                ylabel('Z');
            elseif iEvent == coeff_event
                title({'COEFF EVENT',eventFieldnames{iEvent},'Mean SDE'});
            else
                title({'',eventFieldnames{iEvent},'Mean SDE'});
            end

            for iPCA = 1:rows-1
                subplot(rows,cols,prc(cols,[iPCA+1 iEvent]));
                demixed_data = pca_data(:,iPCA);
                reshaped_demixed_data = reshape(demixed_data,[SDEsamples numel(demixed_data)/SDEsamples]);
                plot(t_vis,mean(reshaped_demixed_data,2),'k-','lineWidth',2);
                xlim([min(t_vis) max(t_vis)]);
                ylimVals = [-1 1];
                ylim(ylimVals);
                yticks(sort([ylimVals 0]));
                grid on;
                title(['PCA ',num2str(iPCA)]);
                if iPCA == rows-1
                    xlabel('time (s)');
                end
                if iEvent == 1
                    ylabel('Z');
                end
            end
        end

        set(h,'color','w');
        saveFile = ['Session',num2str(iSession,'%02d'),'_Unit',num2str(iNeuron,'%02d'),'_',datestr(now,'yyyymmdd')];

        if doSave
            saveas(h,fullfile(savePath,saveFile),'png');
            close(h);
        end
    end
end