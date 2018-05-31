doVideo = false;
doPlot = false;
save_doesPhasePredictRT = {};

savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/perievent/betaGammaRTCorr';
freqList = [20,50];
plotTimes = linspace(-.1,.1,100);
bandLabels = {'\beta','\gamma'};
fontSize = 8;
cols = 7;
rows = 4;
r = 0.5;
zLims = [-8 8];
uniqueSessions = unique(analysisConf.sessionNames);
[uniqueLFPs,ic,ia] = unique(LFPfiles);

% % for iSession = 1:numel(uniqueSessions)
% %     curSession = uniqueSessions(iSession);
% %     unitIds = find(strcmp(curSession,analysisConf.sessionNames) == 1);
% % end

for iNeuron = ic'
    saveFile = ['unit',num2str(iNeuron,'%03d'),'_betaGammaRTCorr'];
    if doVideo
        newVideo = VideoWriter(fullfile(savePath,saveFile),'MPEG-4');
        newVideo.Quality = 90;
        open(newVideo);
    end
    sevFile = LFPfiles{iNeuron};
    disp(sevFile);
    curTrials = all_trials{iNeuron};
    [W,freqList,allTimes] = getW(sevFile,curTrials,eventFieldnames,freqList);
    t = linspace(-1,1,size(W,2));

    % % curSession = uniqueSessions(iSession);
    % % unitIds = find(strcmp(curSession,analysisConf.sessionNames) == 1);
    % % unitSDE = [];
    % % meanSDE = {};

    lns = [];
    all_pval_corr = {};
    all_pval_angle = {};
    all_rho = {};
    all_powerZ = {};
    all_meanSDE = {};
    for iEvent = 1:7
    % %     for iUnit = 1:numel(unitIds)
    % %         curSDE = all_SDEs_zscore{unitIds(iUnit)};
    % %         SDEarr = reshape([curSDE{:,iEvent}],[size(curSDE,1),numel(curSDE{1,1})]);
    % %         unitSDE(iUnit,:) = mean(SDEarr);
    % %     end
    % %     meanSDE{iEvent} = mean(unitSDE);

        for iBand = 1:2
            all_pval_corr{iEvent,iBand} = [];
            all_pval_angle{iEvent,iBand} = [];
            all_rho{iEvent,iBand} = [];
            all_powerZ{iEvent,iBand} = [];
            all_meanSDE{iEvent,iBand} = [];
        end
    end
    if doPlot || doVideo
        h = figuree(1400,900);
        set(h,'defaultAxesColorOrder',[[1 0 0];lines(1)]);
    end
    for iTime = 1:numel(plotTimes)
        for iBand = 1:2
            for iEvent = 1:cols
                W_timeIdx = closest(t,plotTimes(iTime));
                timeData = squeeze(W(iEvent,W_timeIdx,:,iBand));
                iRow = (iBand-1)*2 + 1;
                
                [rho,pval_corr] = circ_corrcl(angle(timeData),allTimes);
                pval_angle = circ_rtest(angle(timeData));
                theta = circ_mean(angle(timeData));

                all_pval_corr{iEvent,iBand} = [all_pval_corr{iEvent,iBand} pval_corr];
                all_pval_angle{iEvent,iBand} = [all_pval_angle{iEvent,iBand} pval_angle];
                all_rho{iEvent,iBand} = [all_rho{iEvent,iBand} rho];
                
                zData = abs(squeeze(W(1,:,:,iBand))).^2;
                zMean = mean(mean(zData));
                zStd = mean(std(zData));
                powerData = mean(abs(squeeze(W(iEvent,W_timeIdx,:,iBand))).^2);
                powerZ = (powerData - zMean) ./ zStd;
                all_powerZ{iEvent,iBand} = [all_powerZ{iEvent,iBand} powerZ];
                
                c = [0 0 0];
                if pval_corr < 0.05
                    c = [1 0 0];
                end
                
                if doVideo || (doPlot && iTime == numel(plotTimes))
                    cla(gca);
                    subplot(rows,cols,prc(cols,[iRow,iEvent]));
                    polarscatter(angle(timeData),allTimes,20,c,'filled');
                    hold on;
                    
                    polarscatter(theta,r,75,c,'filled');
                    rlim([0 r]);
                    thetaticks(0:90:270);
                    rticks(rlim);
                    pax = gca;
                    pax.ThetaAxisUnits = 'radians';
                    title({[bandLabels{iBand},' RT @ t = ',num2str(plotTimes(iTime),'%0.2f')],eventFieldnames{iEvent}});
                    pax.FontSize = fontSize;
                    hold off;
                

                    iRow = iBand * 2;
                    ax = subplot(rows,cols,prc(cols,[iRow,iEvent]));
                    yyaxis left;
                    lns(1) = plot(plotTimes(1:iTime),all_pval_angle{iEvent,iBand},':r'); % p angle only
                    hold on;
                    lns(2) = plot(plotTimes(1:iTime),all_pval_corr{iEvent,iBand},'-r'); % p corr
                    lns(3) = plot(plotTimes(1:iTime),all_rho{iEvent,iBand},'color',repmat(.5,[1,3])); % rho
                    ylabel('pval, rho');
                    ylim([0 1]);
                    yticks([0,.05,1]);

                    yyaxis right;
                    
    % %             eventSDE = meanSDE{iEvent};
    % %             t_SDE = linspace(-1,1,numel(eventSDE));
    % %             time_SDE = eventSDE(closest(t_SDE,plotTimes(iTime)));
    % %             all_meanSDE{iEvent,iBand} = [all_meanSDE{iEvent,iBand} time_SDE];
    % %             lns(5) = plot(plotTimes(1:iTime),all_meanSDE{iEvent,iBand},'-g');

                    lns(4) = plot(plotTimes(1:iTime),all_powerZ{iEvent,iBand},'-','color',lines(1));
                    ylim(zLims);
                    yticks(sort([ylim,0]));
                    ylabel('Z power');

                    xlim([plotTimes(1) plotTimes(end)]);
                    xticks(sort([xlim 0]));
                    title({['rho = ',num2str(rho,'%0.2f'),', ','pCorr = ',num2str(pval_corr,'%0.2f')],...
                        ['pAngle = ',num2str(pval_angle,'%0.2f')]});

                    grid on;
                    hold off;
                    ax.FontSize = fontSize;
                end
            end
            if doVideo || (doPlot && iTime == numel(plotTimes))
                legend(lns,{'pAngle','pCorr','rho','power'});
            end
        end
        if (doPlot && iTime == numel(plotTimes))
            set(gcf,'color','w');
            hFrame = getframe(h);
        end
        if doVideo
            drawnow;
            writeVideo(newVideo,hFrame.cdata);
        end
     
        save_doesPhasePredictRT{iNeuron}.plotTimes = plotTimes;
        save_doesPhasePredictRT{iNeuron}.all_powerZ = all_powerZ;
        save_doesPhasePredictRT{iNeuron}.all_pval_corr = all_pval_corr;
        save_doesPhasePredictRT{iNeuron}.all_pval_angle = all_pval_angle;
        save_doesPhasePredictRT{iNeuron}.all_rho = all_rho;
    end

    % save final frame
    if doPlot
        saveas(h,fullfile(savePath,[saveFile,'.png']));
        close(h);
    end
    if doVideo
        close(newVideo);
    end
end   