powerScalo_clim = [2 3.5];
plot_t_limits = [-1,1];
z_clim = [-2 2];

allCaxis = [];
densityLabels = {'all','low density','med density','high density'};
allScalogramTitles = {'ts','tsISI','tsLTS','tsPoisson'};

rootDir = '/Volumes/Tbolt_02/VM thal analysis';
cd(rootDir);

ratDirs = dir('*_spike_triggered_scalos');

numRowsPerPage = 3;

all_max_t_coeff = cell(1,2);
all_max_xcorr_coeff = cell(1,2);
all_max_t_biased = cell(1,2);
all_max_xcorr_biased = cell(1,2);
all_max_t_unbiased = cell(1,2);
all_max_xcorr_unbiased = cell(1,2);
all_max_t_raw = cell(1,2);
all_max_xcorr_raw = cell(1,2);

numValidUnits = zeros(1,2);
maxLag = 0.1;
covWin = 0.5;
sessionHist = cell(1,2);
sessionHist_z = cell(1,2);
betaTraces = cell(1,2);
betaTraces_z = cell(1,2);
numValidUnits_perSession = cell(1,2);

zlim = [-1 3];
numValidSessions = zeros(1,2);
for i_ratDir = 1 : length(ratDirs)
    
    cd(rootDir);
    
    cur_ratDir = ratDirs(i_ratDir).name;
    if ~isdir(cur_ratDir) || any(strcmp(cur_ratDir,{'.','..'}))
        continue;
    end
    
    ratID = cur_ratDir(1:5);
    cur_ratDir = fullfile(rootDir,cur_ratDir);
    cd(cur_ratDir);
    sessionDirs = dir([ratID '*']);
    
    sessionHist{i_ratDir} = zeros(1,7,size(LTShist,2));
    sessionHist_z{i_ratDir} = zeros(1,7,size(LTShist,2));
    betaTraces{i_ratDir} = zeros(1,7,length(peri_eventMetadata.t));
    betaTraces_z{i_ratDir} = zeros(1,7,length(peri_eventMetadata.t));
    numValidUnits_perSession{i_ratDir} = 0;
    for i_sessionDir = 1 : length(sessionDirs)
        cur_sessionDir = sessionDirs(i_sessionDir).name;
        cd(cur_ratDir);
        if ~isdir(cur_sessionDir) || any(strcmp(cur_sessionDir,{'.','..'}))
            continue;
        end
        
        cur_sessionDir = fullfile(cur_ratDir,cur_sessionDir);
        cd(cur_sessionDir);
        LTS_beta_corr_files = dir('*periEventBeta_correctOnly_bin025*');
        
        plotCount = 1;
        
        numValidSessions(i_ratDir) = numValidSessions(i_ratDir) + 1;
        sessionHist{i_ratDir}(numValidSessions(i_ratDir),:,:) = zeros(7,size(sessionHist{i_ratDir},3));
        sessionHist_z{i_ratDir}(numValidSessions(i_ratDir),:,:) = zeros(7,size(sessionHist_z{i_ratDir},3));
        betaTraces{i_ratDir}(numValidSessions(i_ratDir),:,:) = zeros(7,size(betaTraces{i_ratDir},3));
        betaTraces_z{i_ratDir}(numValidSessions(i_ratDir),:,:) = zeros(7,size(betaTraces_z{i_ratDir},3));
        corrData = cell(1);
        numValidFiles = 0;
        for iFile = 1 : length(LTS_beta_corr_files)
            cur_corrFile = LTS_beta_corr_files(iFile).name;
            if length(cur_corrFile) < 4;continue;end
            if strcmpi(cur_corrFile(1:2),'._'); continue; end
            if ~strcmpi(cur_corrFile(end-3:end),'.mat'); continue; end
            numValidFiles = numValidFiles + 1;
            corrData{numValidFiles} = load(cur_corrFile);
        
        end
        if numValidFiles == 0; continue; end
        periEventBeta = corrData{1}.periEventBeta;
        testLTShist = corrData{1}.LTShist;
        peri_eventMetadata = corrData{1}.peri_eventMetadata;
        numTrials = size(periEventBeta,2);
        if ~isfield(peri_eventMetadata,'binWidth'); continue; end
            
        numValidUnits(i_ratDir) = numValidUnits(i_ratDir) + numValidFiles;
        if length(numValidUnits_perSession{i_ratDir}) < numValidSessions(i_ratDir)
            numValidUnits_perSession{i_ratDir}(numValidSessions(i_ratDir)) = 0;
        end
        numValidUnits_perSession{i_ratDir}(numValidSessions(i_ratDir)) = numValidUnits_perSession{i_ratDir}(numValidSessions(i_ratDir)) + 1;
            
%         h = figure;
        h_overlay_fig = figure;
        
        sessionName = neuronName(1:15);
        neuronName = peri_eventMetadata.neuron;
        t  = peri_eventMetadata.t;
        Fs = peri_eventMetadata.Fs;
        eventList = peri_eventMetadata.eventList;
        
        tWindow = peri_eventMetadata.tWindow;
        
        net_LTShist = zeros(size(testLTShist));
        iEvent = 4;
        cur_periEventBeta = mean(squeeze(corrData{1}.periEventBeta(iEvent,:,:)));
        cur_periEventBeta_z = (cur_periEventBeta - mean(corrData{1}.periRandomBeta,1))./std(corrData{1}.periRandomBeta,0,1);
        yyaxis left
        plot(t,cur_periEventBeta_z,'color','k','linewidth',2);
        set(gca,'ylim',[-1 2.5],'xlim',[-0.5,0.5])
        hold on
        
        for iUnit = 1 : numValidFiles
            net_LTShist = net_LTShist + (corrData{iUnit}.LTShist / peri_eventMetadata.binWidth);
            periRandomLTS = corrData{iUnit}.periRandomLTS / peri_eventMetadata.binWidth;
            mean_LTShist = mean(squeeze(corrData{iUnit}.LTShist(iEvent,:,:))) / peri_eventMetadata.binWidth;
%             mean_LTShist = (mean_LTShist - mean(periRandomLTS)) ./ std(periRandomLTS,0,1);
            LTS_hist_interp = smooth(interp1(hist_t,mean_LTShist,t),50);
            
            yyaxis right
            hold on
            ind_toPlot = (LTS_hist_interp - mean(LTS_hist_interp)) / range(LTS_hist_interp);
            plot(t,ind_toPlot,'marker','none','linestyle','-');
            set(gca,'ylim',[-1 1])
            
        end
        net_LTShist = net_LTShist / numValidFiles;
        toPlot = mean(squeeze(net_LTShist(iEvent,:,:)));
        toPlot_interp = smooth(interp1(hist_t,toPlot,t),50);
        yyaxis right
        toPlot = (toPlot_interp - mean(toPlot_interp)) / range(toPlot_interp);
        plot(t,toPlot,'color','r','linewidth',2);
        
        fname = sprintf('%s_LTS_beta_xcorr_fig%03d',sessionName,peri_eventMetadata.binWidth*1000);
        subFolder = 'tsPrctlScalos';
        docName = [subFolder,'_',neuronName];
        fp = fillPage(h_overlay_fig,'margins',[0 0 2 0],'papersize',[11 9.5]);
        print(h_overlay_fig,'-opengl','-dpdf','-r200',fullfile(cur_sessionDir,fname))
        savefig(h_overlay_fig,fullfile(cur_sessionDir,fname),'compact')
        close(h_overlay_fig);
    end
    
end
            
            
%             cov_start_samp = round((peri_eventMetadata.tWindow - covWin) * Fs);
%             cov_end_samp =  cov_start_samp + round(2*covWin * Fs);
%             cov_t = linspace(-covWin,covWin,cov_end_samp-cov_start_samp+1);
%             
%             hist_t = linspace(-1,1,size(LTShist,2));
%             max_t = zeros(1,length(eventList));
%             max_xcorr = zeros(1,length(eventList));
%             
%             LTShist_fr = LTShist / (numTrials * peri_eventMetadata.binWidth);
%             temp = squeeze(sessionHist{i_ratDir}(numValidSessions(i_ratDir), :, :)) + LTShist_fr;
%             sessionHist{i_ratDir}(numValidSessions(i_ratDir), :, :) = temp;
%             periRandomLTS_fr = periRandomLTS / peri_eventMetadata.binWidth;
%             LTShist_z = (LTShist_fr - repmat(mean(periRandomLTS_fr,1),[7,1])) ./ repmat(std(periRandomLTS_fr,0,1),[7,1]);
%             temp = squeeze(sessionHist_z{i_ratDir}(numValidSessions(i_ratDir), :, :)) + LTShist_z;
%             sessionHist_z{i_ratDir}(numValidSessions(i_ratDir), :, :) = temp;
% 
%             for ii = 1 : length(eventList)
%                 subplot(2,length(eventList),ii)
%                 hold off
%                 cur_periEventBeta = mean(squeeze(periEventBeta(ii,:,:)));
%                 
% %                 temp = squeeze(betaTraces{i_ratDir}(numValidSessions, ii, :))' + cur_periEventBeta;
%                 betaTraces{i_ratDir}(numValidSessions(i_ratDir), ii, :) = cur_periEventBeta;
%                 cur_periEventBeta_z = (cur_periEventBeta - mean(periRandomBeta,1))./std(periRandomBeta,0,1);
%                 betaTraces_z{i_ratDir}(numValidSessions(i_ratDir), ii, :) = cur_periEventBeta_z;
% 
% %                 toPlot = (cur_periEventBeta(cov_start_samp:cov_end_samp)-mean(cur_periEventBeta)) / range(cur_periEventBeta);
%                 toPlot = cur_periEventBeta_z(cov_start_samp:cov_end_samp);
%                 yyaxis left
%                 plot(cov_t,toPlot)
%                 hold on
%                 set(gca,'ylim',zlim);
% %                 temp = LTShist(ii,:) * (max(toPlot)/max(LTShist(ii,:)));
% %                 plot(hist_t,LTShist(ii,:));
% %                 plot(hist_t,temp);
% %                 set(gca,'ylim',[0 100]);
% 
%                 LTS_hist_interp = interp1(hist_t,LTShist_fr(ii,:),t);
%                 LTS_hist_interp_z = interp1(hist_t,LTShist_z(ii,:),t);
% %                 LTS_hist_interp = smooth(LTS_hist_interp,100);
% %                 LTS_hist_toplot = (LTS_hist_interp(cov_start_samp:cov_end_samp) - mean(LTS_hist_interp))/range(LTS_hist_interp);
%                 
%                 temp = smooth(LTS_hist_interp,100);%LTS_hist_interp(ii,:) * (max(toPlot)/max(LTS_hist_interp(ii,:)));
%                 yyaxis right
%                 plot(cov_t,temp(cov_start_samp:cov_end_samp))
%                 set(gca,'ylim',[-3 9]);
%                 if ii == 1
%                     title(neuronName);
%                 end
% 
%                 subplot(2,length(eventList),length(eventList) + ii)
%                 
%                 LTS_xcorr_coeff_full = xcov(LTS_hist_interp_z(cov_start_samp:cov_end_samp),cur_periEventBeta_z(cov_start_samp:cov_end_samp),'coeff');
%                 LTS_xcorr_biased_full = xcov(LTS_hist_interp_z(cov_start_samp:cov_end_samp),cur_periEventBeta_z(cov_start_samp:cov_end_samp),'biased');
%                 LTS_xcorr_unbiased_full = xcov(LTS_hist_interp_z(cov_start_samp:cov_end_samp),cur_periEventBeta_z(cov_start_samp:cov_end_samp),'unbiased');
%                 LTS_xcorr_raw_full = xcov(LTS_hist_interp_z(cov_start_samp:cov_end_samp),cur_periEventBeta_z(cov_start_samp:cov_end_samp));
% 
%                 startSamp = round(length(cov_t)/2);
%                 endSamp = startSamp + length(cov_t)-1;
%                 LTS_xcorr_coeff = LTS_xcorr_coeff_full(startSamp:endSamp);
%                 LTS_xcorr_biased = LTS_xcorr_biased_full(startSamp:endSamp);
%                 LTS_xcorr_unbiased = LTS_xcorr_unbiased_full(startSamp:endSamp);
%                 LTS_xcorr_raw = LTS_xcorr_raw_full(startSamp:endSamp);
% 
%                 lagStart = round((covWin-maxLag)*Fs);
%                 lagEnd = lagStart + round(2*maxLag*Fs);
%                 max_xcorr_coeff(ii) = max(LTS_xcorr_coeff(lagStart:lagEnd));
%                 max_xcorr_biased(ii) = max(LTS_xcorr_biased(lagStart:lagEnd));
%                 max_xcorr_unbiased(ii) = max(LTS_xcorr_unbiased(lagStart:lagEnd));
%                 max_xcorr_raw(ii) = max(LTS_xcorr_raw(lagStart:lagEnd));
%                 
%                 max_t_coeff(ii) = cov_t(LTS_xcorr_coeff == max_xcorr_coeff(ii));
%                 max_t_biased(ii) = cov_t(LTS_xcorr_biased == max_xcorr_biased(ii));
%                 max_t_unbiased(ii) = cov_t(LTS_xcorr_unbiased == max_xcorr_unbiased(ii));
%                 max_t_raw(ii) = cov_t(LTS_xcorr_raw == max_xcorr_raw(ii));
%                 
%                 plot(cov_t,LTS_xcorr_coeff)
%                 title(sprintf('%0.3f',max_t_coeff(ii)),'fontsize',9)
% %                 set(gca,'xlim',[-.1,.1])
% %                 subplot(5,length(eventList),length(eventList)*2 + ii)
% %                 plot(t,LTS_xcorr_biased)
% %                 title(sprintf('%0.3f',max_t_biased(ii)),'fontsize',6)
% %                 
% %                 subplot(5,length(eventList),length(eventList)*3 + ii)
% %                 plot(t,LTS_xcorr_unbiased)
% %                 title(sprintf('%0.3f',max_t_unbiased(ii)),'fontsize',6)
% %                 
% %                 subplot(5,length(eventList),length(eventList)*4 + ii)
% %                 plot(t,LTS_xcorr_raw)
% %                 title(sprintf('%0.3f',max_t_raw(ii)),'fontsize',6)
% 
% 
%             end
%             all_max_t_coeff{i_ratDir}(numValidUnits(i_ratDir),:) = max_t_coeff;
%             all_max_xcorr_coeff{i_ratDir}(numValidUnits(i_ratDir),:) = max_xcorr_coeff;
%             all_max_t_biased{i_ratDir}(numValidUnits(i_ratDir),:) = max_t_biased;
%             all_max_xcorr_biased{i_ratDir}(numValidUnits(i_ratDir),:) = max_xcorr_biased;
%             all_max_t_unbiased{i_ratDir}(numValidUnits(i_ratDir),:) = max_t_unbiased;
%             all_max_xcorr_unbiased{i_ratDir}(numValidUnits(i_ratDir),:) = max_xcorr_unbiased;
%             all_max_t_raw{i_ratDir}(numValidUnits(i_ratDir),:) = max_t_raw;
%             all_max_xcorr_raw{i_ratDir}(numValidUnits(i_ratDir),:) = max_xcorr_raw;
%             
% %             subplot(7,2,2)
% %             max_t_string = sprintf('max corr times: %0.3f,%0.3f,%0.3f,%0.3f,%0.3f,%0.3f,%0.3f',...
% %                 max_t(1),max_t(2),max_t(3),max_t(4),max_t(5),max_t(6),max_t(7))
% %             title(max_t_string)
% 
%             
%             fname = sprintf('%s_LTS_beta_xcorr_bin%03d',neuronName,peri_eventMetadata.binWidth*1000);
%             subFolder = 'tsPrctlScalos';
%             docName = [subFolder,'_',neuronName];
%             fp = fillPage(h,'margins',[0 0 2 0],'papersize',[11 9.5]);
%             print(h,'-opengl','-dpdf','-r200',fullfile(cur_sessionDir,fname))
%             savefig(h,fullfile(cur_sessionDir,fname),'compact')
%             close(h);
% 
% %         end
%     end
%     
% end