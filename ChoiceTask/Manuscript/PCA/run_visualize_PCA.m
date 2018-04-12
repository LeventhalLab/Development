doSave = true;
coeff_event = 0;
nSources = 1; % 1 = standard, 2 = ipsi/contra

colors = lines(2);
tWindow_vis = 1;
SDEsamples = tWindow_vis * 2 * 1000;
t_vis = linspace(-tWindow_vis,tWindow_vis,SDEsamples);
rows = 7;
cols = 7;

for iSession = 1:numel(sessionPCA_coeff)
    h = figuree(1300,800);
    for iSource = 1:nSources
        if nSources == 1
            sessionPCA_coeff = sessionPCA_500ms;
            sessionPCA_covMatrix = sessionPCA_1000ms;
            lineColor = [0 0 0];
            fileLabel = '';
            savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/PCA/perSessionAnalysis';
        else
            fileLabel = '_contraIpsi';
            savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/PCA/perSessionAnalysis/contraIpsi';
            if iSource == 1
                sessionPCA_coeff = sessionPCA_500ms_contra;
                sessionPCA_covMatrix = sessionPCA_1000ms_contra;
                sessionPCA_covMatrix = sessionPCA_1000ms;
                lineColor = colors(1,:);
            else
                sessionPCA_coeff = sessionPCA_500ms_ipsi;
                sessionPCA_covMatrix = sessionPCA_1000ms_ipsi;
                sessionPCA_covMatrix = sessionPCA_1000ms;
                lineColor = colors(2,:);
            end
        end
        
        for iEvent = 1:cols
            covMatrix = squeeze(sessionPCA_covMatrix(iSession).PCA_arr(iEvent,:,:))';
            coeff = squeeze(sessionPCA_coeff(iSession).coeff(iEvent,:,:)); % NOTE COEFF SOURCE: coeff_event or iEvent?
            pca_data = covMatrix * coeff;
            for iPCA = 1:rows
                subplot(rows,cols,prc(cols,[iPCA iEvent]));
                demixed_data = pca_data(:,iPCA);
                reshaped_demixed_data = reshape(demixed_data,[SDEsamples numel(demixed_data)/SDEsamples]);
                plot(t_vis,mean(reshaped_demixed_data,2),'-','lineWidth',2,'color',lineColor);
                hold on;
                xlim([min(t_vis) max(t_vis)]);
                ylimVals = [-5 5];
                ylim(ylimVals);
                yticks(sort([ylimVals 0]));
                if iPCA == 1
                    if iEvent == 1
                        title({['Session ',num2str(iSession)],eventFieldnames{iEvent},['PCA ',num2str(iPCA)]});
                    elseif iEvent == coeff_event
                        title({'COEFF EVENT',eventFieldnames{iEvent},['PCA ',num2str(iPCA)]});
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
    
    set(h,'color','w');
    saveFile = ['Session',num2str(iSession,'%02d'),'_allData_',datestr(now,'yyyymmdd'),fileLabel];
    
    if doSave
        saveas(h,fullfile(savePath,saveFile),'png');
        close(h);
    end
end