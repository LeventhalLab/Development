doPlot = false;
doSetup = false;
[uniqueLFPs,ic,ia] = unique(LFPfiles);
iBand = 2;
iEvent = 3;
plotTimes = linspace(-.25,.25,100);
cmapPath = '/Users/mattgaidica/Documents/MATLAB/LeventhalLab/Development/ChoiceTask/LFPs/utils/stoplight.jpg';
% % savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/perievent/betaPhaseResetAtTone'; 
savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/perievent/gammaPhaseResetAtTone';
plotRange = [30,40,50]; %1:numel(plotTimes)
colors = mycmap(cmapPath,numel(plotRange));
rows = 2;
cols = 7;
rlimVals = [0 20];
nBins = 10;

if doSetup
    all_thetas = {};
    for iNeuron = ic'
        sevFile = LFPfiles_local{iNeuron};
        disp(sevFile);
        curTrials = all_trials{iNeuron};
        [W,freqList,allTimes] = getW(sevFile,curTrials,eventFieldnames,freqList);
        t = linspace(-1,1,size(W,2));

        jj = 0;
        all_pval = [];
        for iTime = 1:numel(plotTimes)
            W_timeIdx = closest(t,plotTimes(iTime));
            timeData = squeeze(W(iEvent,W_timeIdx,:,iBand));
            all_pval(iTime) = circ_rtest(angle(timeData));
        end
        if doPlot
            h = figuree(1400,400);
            subplot(rows,cols,[1,9]);
            plot(plotTimes,all_pval,'k','lineWidth',2);
            hold on;
            xticks(plotTimes(plotRange));
            xlim([plotTimes(1) plotTimes(end)]);
            ax = gca;
            ax.XAxis.TickLabelFormat = '%0.3f';
            title({['unit',num2str(iNeuron,'%03d')],'\beta phase p-value at Tone'});
            xtickangle(30);
            xlabel('time (s)');
            ylabel('p');
            ylim([0 1]);
            yticks(sort([ylim,.05]));
            grid on;
        end
        for iTime = plotRange
            jj = jj + 1;
            W_timeIdx = closest(t,plotTimes(iTime));
            timeData = squeeze(W(iEvent,W_timeIdx,:,iBand));
            pval_angle = circ_rtest(angle(timeData));
            theta = circ_mean(angle(timeData));

            if doPlot
                subplot(rows,cols,[1,9]);
                plot([plotTimes(iTime) plotTimes(iTime)],[0 1],'color',colors(jj,:),'lineWidth',1.5);

                subplot(rows,cols,[3,11]);
                polarscatter(angle(timeData),allTimes,40,colors(jj,:),'filled');
                hold on;
                pax = gca;
                pax.ThetaAxisUnits = 'radians';
                rlim([0 1]);
                rticks(rlim);
                thetaticks(0:pi/2:3*pi/2);
                pax.ThetaZeroLocation = 'bottom';
                title('\beta phase x RT');

                subplot(rows,cols,prc(cols,[1,jj+4]));
                ph = polarhistogram(angle(timeData),nBins,'FaceColor',colors(jj,:));
                title({['t = ',num2str(plotTimes(iTime),'%0.3f')],['p = ',num2str(pval_angle,'%0.3f')]});
                pax = gca;
                pax.ThetaAxisUnits = 'radians';
                rlim(rlimVals);
                rticks(rlim);
                thetaticks(0:pi/2:3*pi/2);
                pax.ThetaZeroLocation = 'bottom';

                subplot(rows,cols,prc(cols,[2,jj+4]));
                bar(ph.Values,'FaceColor',colors(jj,:));
                hold on;
                xlimVals = xlim;
                placeTheta = closest(linspace(-pi,pi,nBins*100),theta)/100;
                plot([placeTheta placeTheta],rlimVals,'color',colors(jj,:),'lineWidth',1.5);
                ylim(rlimVals);
                xticks([1,numel(ph.BinEdges)/2,nBins]);
                xticklabels({'-\pi',0,'\pi'});
                title(['\theta mean: ',num2str(theta,'%1.3f')]);
            end

            all_thetas{jj,iNeuron} = angle(timeData); % capture last one
        end

        if doPlot
            set(gcf,'color','w');
            saveFile = ['unit',num2str(iNeuron,'%03d'),'_gammaPhaseResetAtTone'];
            saveas(h,fullfile(savePath,[saveFile,'.png']));
            close(h);
        end
    end
end
all_thetas = all_thetas_gamma;
theta_times = [];
theta_pretones = [];
for iNeuron = ic'
    theta_times = [theta_times all_times{iNeuron}];
    theta_pretones = [theta_pretones all_pretones{iNeuron}];
end

rows = 3;
cols = 3;
nQuant = 10;
rt_quants = linspace(0.05,.350,nQuant+1);
pretone_quants = linspace(.5,1,nQuant+1);
figuree(1200,800);
for jj = 1:3
    thetas = [];
    for iNeuron = ic'
        thetas = [thetas all_thetas{jj,iNeuron}'];
    end
    pval_angle = circ_rtest(thetas);
    subplot(rows,cols,prc(cols,[1,jj]));
    polarhistogram(thetas,50);
    pax = gca;
    pax.ThetaAxisUnits = 'radians';
    thetaticks(0:pi/2:3*pi/2);
    pax.ThetaZeroLocation = 'top';
    rlim([0 600]);
    rticks(rlim);
    title({['t = ',num2str(plotTimes(jj),'%1.3f')],['\theta mean: ',num2str(circ_mean(thetas'),'%1.3f')],...
        ['pval = ',num2str(pval_angle,'%2.2e')]});
    
    thetas = [];
    for iNeuron = ic'
        thetas = [thetas all_thetas{jj,iNeuron}'];
    end

    quant_mean = [];
    quant_std = [];
    for iQuant = 1:nQuant
        curThetas = thetas(theta_times >= rt_quants(iQuant) & theta_times < rt_quants(iQuant+1));
        quant_mean(iQuant) = circ_mean(curThetas');
        quant_std(iQuant) = circ_std(curThetas');
    end
    [rho,pval_corr] = circ_corrcl(thetas,theta_times);
    subplot(rows,cols,prc(cols,[2,jj]));
    polarscatter(quant_mean,1:numel(quant_mean),40,'k','filled');
    rticks(1:numel(quant_mean));
    rticklabels(rt_quants(1:end-1));
    rlim([-3,numel(quant_mean)]);
    pax = gca;
    pax.ThetaAxisUnits = 'radians';
    thetaticks(0:pi/2:3*pi/2);
    pax.ThetaZeroLocation = 'top';
    title({['t = ',num2str(plotTimes(plotRange(jj)),'%1.3f')],'Phase x RT',...
        ['pval (xRT) = ',num2str(pval_corr,'%2.2e'),', rho = ',num2str(rho,'%0.3f')]});

    quant_mean = [];
    quant_std = [];
    for iQuant = 1:nQuant
        curThetas = thetas(theta_pretones >= pretone_quants(iQuant) & theta_pretones < pretone_quants(iQuant+1));
        quant_mean(iQuant) = circ_mean(curThetas');
        quant_std(iQuant) = circ_std(curThetas');
    end
    [rho,pval_corr] = circ_corrcl(thetas,theta_pretones);
    subplot(rows,cols,prc(cols,[3,jj]));
    polarscatter(quant_mean,1:numel(quant_mean),40,'k','filled');
    rticks(1:numel(quant_mean));
    rticklabels(pretone_quants(1:end-1));
    rlim([-3,numel(quant_mean)]);
    pax = gca;
    pax.ThetaAxisUnits = 'radians';
    thetaticks(0:pi/2:3*pi/2);
    pax.ThetaZeroLocation = 'top';
    title({['t = ',num2str(plotTimes(plotRange(jj)),'%1.3f')],'Phase x pretone',...
        ['pval (xpretone) = ',num2str(pval_corr,'%2.2e'),', rho = ',num2str(rho,'%0.3f')]});
end
