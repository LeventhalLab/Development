for iSession = 1:numel(sessionPCA)
    t_vis = linspace(-tWindow_vis,tWindow_vis,SDEsamples);

    figuree(1300,800);
    rows = 7;
    cols = 7;
    nSmooth = 1;
    for iEvent = 1:cols
        covMatrix = squeeze(sessionPCA(iSession).PCA_arr(iEvent,:,:))';
        coeff = squeeze(sessionPCA_500ms(iSession).coeff(iEvent,:,:));
        pca_data = covMatrix * coeff;
        for iPCA = 1:rows
            subplot(rows,cols,prc(cols,[iPCA iEvent]));
            demixed_data = pca_data(:,iPCA);
            reshaped_demixed_data = reshape(demixed_data,[SDEsamples numel(demixed_data)/SDEsamples]);
            plot(t_vis,smooth(mean(reshaped_demixed_data,2),nSmooth),'k-','lineWidth',2);
            xlim([min(t_vis) max(t_vis)]);
            ylimVals = [-4 4];
            ylim(ylimVals);
            yticks(sort([ylimVals 0]));
            if iPCA == 1
                if iEvent == 1
                    title({['Session ',num2str(iSession)],eventFieldnames{iEvent},['PCA ',num2str(iPCA)]});
                else
                    title({'',eventFieldnames{iEvent},['PCA ',num2str(iPCA)]});
                end
            else
                title(['PCA ',num2str(iPCA)]);
            end
            if iPCA == rows
                xlabel('time (s)');
            end
            if iEvent == 1
                ylabel('Z');
            end
            grid on;
        end
    end
end