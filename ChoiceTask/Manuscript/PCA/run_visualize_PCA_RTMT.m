doSave = true;
doLabel = true;

sessionPCA_RT = sessionPCA_500ms_RT;
sessionPCA_MT = sessionPCA_500ms_MT;
tWindow = 2;
tWindow_vis = 0.5;
SDEsamples = tWindow_vis * 2 * 1000;
rows = 3;
cols = 2;
figx = 250;
figy = 400;
savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/PCA/perSessionAnalysis/RTMT';
coeff_event = 4;

colors = [1 0 0;0 0 1]; % red for RT, blue for MT
ylimVals = [0 9];
xlimVals = [0 0.5];

for iSession = [2,16]%1:numel(sessionPCA_RT)
    h = figuree(figx,figy);
    nPCAs = size(sessionPCA_RT(iSession).PCA_arr,2);
    nPCAs = 3; % !! manual override
    for iPCA = 1:nPCAs % !! use explained variance?
        iEvent = 4;
        modnPCAs = mod(iPCA,rows);
        curRow = mod(iPCA-1,rows)+1;
        for iRTMT = 1:2
            switch iRTMT
                case 1
                    subplot(rows,cols,prc(cols,[curRow iRTMT]));
                    sessionPCA = sessionPCA_RT;
                    allTimes = sessionPCA(iSession).RT;
                    legendText = 'RT ';
                    mainTiming = [.05,.35]; % from our paper
                case 2
                    subplot(rows,cols,prc(cols,[curRow iRTMT]));
                    sessionPCA = sessionPCA_MT;
                    allTimes = sessionPCA(iSession).MT;
                    legendText = 'MT ';
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
            lns = scatter(x,y,5,'filled','MarkerFaceColor',colors(iRTMT,:));
            hold on;
            [rho,pval] = corr(x,y);
            pMark = '';
            if pval < 0.05
                pMark = '*';
                if pval < 0.01
                    pMark = '**';
                end
            end
            legendText = [legendText,' r',num2str(rho,'%1.3f'),', ',pMark,'p',num2str(pval,'%1.3f')];
            p = polyfit(x,y,1);
            f = polyval(p,x);
            plot(x,f,'-','color',colors(iRTMT,:));
            
            ylim(ylimVals);
            yticks(unique(sort([ylimVals 0])));
            xlim(xlimVals);
            xticks(xlimVals);
            titleHeader = {''};
            if iRTMT == 1 && iPCA == 1
                titleHeader = {sessionNames_PCA{iSession}};
            end
            titleHeader = {titleHeader{:} eventFieldlabels{iEvent}};
            
            if doLabel
                xlabel([legendText,'(s)'])
                ylabel('PCxSDE max(Z)');
                lgd = legend(lns,legendText,'location','north');
                lgd.FontSize = 10;
                legend boxoff;
                title({titleHeader{:},['PC ',num2str(iPCA)]},'interpreter','none');
            else
                xlabel([]);
                ylabel([]);
                xticklabels({});
                yticklabels({});
            end
            grid on;
        end

        set(h,'color','w');
        drawnow;

        if (curRow == rows || iPCA == nPCAs) && iPCA > 1 && iRTMT == cols
            if doSave
                saveFile = ['RTMTPCA_',sessionNames_PCA{iSession}];
                if doLabel
                    saveas(h,fullfile(savePath,saveFile),'png');
                else
                    tightfig;
                    setFig('','',[1,1]);
                    print(gcf,'-painters','-depsc',fullfile(savePath,saveFile));
                end
                close(h);
            end
        end

        if curRow == rows && iPCA > 1 && iEvent == cols && iPCA ~= nPCAs
            h = figuree(figx,figy);
        end

    end
end