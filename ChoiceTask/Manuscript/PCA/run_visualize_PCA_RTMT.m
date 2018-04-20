doSave = true;

sessionPCA_RT = sessionPCA_500ms_RT;
sessionPCA_MT = sessionPCA_500ms_MT;
tWindow = 2;
tWindow_vis = 0.5;
SDEsamples = tWindow_vis * 2 * 1000;
rows = 3;
cols = 7;
figx = 1300;
figy = 800;
savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/PCA/perSessionAnalysis/RTMT';
coeff_event = 4;

colors = [1 0 0;0 0 1]; % red for RT, blue for MT
ylimVals = [0 8];
xlimVals = [0 0.5];

for iSession = 1:numel(sessionPCA_RT)
    h = figuree(figx,figy);
    nPCAs = size(sessionPCA_RT(iSession).PCA_arr,2);
    nPCAs = 3; % !! manual override
    for iPCA = 1:nPCAs % !! use explained variance?
        for iEvent = 1:cols
            modnPCAs = mod(iPCA,rows);
            curRow = mod(iPCA-1,rows)+1;
            subplot(rows,cols,prc(cols,[curRow iEvent]));
            legendText = {};
            lns = [];
            for iRTMT = 1:2
                switch iRTMT
                    case 1
                        sessionPCA = sessionPCA_RT;
                        allTimes = sessionPCA(iSession).RT;
                        legendText{iRTMT} = 'RT ';
                        mainTiming = [.05,.35]; % from our paper
                    case 2
                        sessionPCA = sessionPCA_MT;
                        allTimes = sessionPCA(iSession).MT;
                        legendText{iRTMT} = 'MT ';
                        mainTiming = [0,.4]; % from our paper
                end
                useTrials = find(allTimes >= mainTiming(1) & allTimes < mainTiming(2));
                covMatrix = squeeze(sessionPCA(iSession).PCA_arr(iEvent,:,:))';
                if coeff_event == 0
                    coeff = squeeze(sessionPCA(iSession).coeff(iEvent,:,:)); % NOTE COEFF SOURCE
                else
                    coeff = squeeze(sessionPCA(iSession).coeff(coeff_event,:,:));
                end
                pca_data = covMatrix * coeff;
                demixed_data = pca_data(:,iPCA);
                reshaped_demixed_data = reshape(demixed_data,[SDEsamples numel(demixed_data)/SDEsamples]);
                event_maxZ = max(reshaped_demixed_data);
                
                x = allTimes(useTrials)';
                y = event_maxZ(useTrials)';
                scatter(x,y,5,'filled','MarkerFaceColor',colors(iRTMT,:));
                hold on;
                [rho,pval] = corr(x,y);
                pMark = '';
                if pval < 0.05
                    pMark = '*';
                    if pval < 0.01
                        pMark = '**';
                    end
                end
                legendText{iRTMT} = [legendText{iRTMT},'r',num2str(rho,'%1.3f'),' ',pMark,'p',num2str(pval,'%1.3f')];
                p = polyfit(x,y,1);
                f = polyval(p,x);
                lns(iRTMT) = plot(x,f,'-','color',colors(iRTMT,:));
            end
            
            xlabel('trial timing (s)')
            ylabel('PCxSDE max(Z)');
            ylim(ylimVals);
            yticks(unique(sort([ylimVals 0])));
            xlim(xlimVals);
            xticks(xlimVals);
            legend(lns,legendText,'location','southoutside');
            legend boxoff;
            grid on;
            
            titleHeader = {};
            if curRow == 1
                if iEvent == 1
                    titleHeader = {sessionNames{iSession}};
                end
                titleHeader = {titleHeader{:} eventFieldlabels{iEvent}};
            end
            title({titleHeader{:},['PC ',num2str(iPCA)]},'interpreter','none');
            set(h,'color','w');
            drawnow;
            
            if (curRow == rows || iPCA == nPCAs) && iPCA > 1 && iEvent == cols
                tightfig;
                if doSave
                    saveFile = ['Session',num2str(iSession,'%02d'),'_',datestr(now,'yyyymmdd'),'_PCA',num2str(iPCA-rows+1),'-',num2str(iPCA)];
                    saveas(h,fullfile(savePath,saveFile),'png');
                    close(h);
                end
            end
            
            if curRow == rows && iPCA > 1 && iEvent == cols && iPCA ~= nPCAs
                h = figuree(figx,figy);
            end
        end
    end
end