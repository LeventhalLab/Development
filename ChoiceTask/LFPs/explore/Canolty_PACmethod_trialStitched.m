% load('session_20180925_entrainmentSurrogates.mat', 'eventFieldnames')
% load('session_20180925_entrainmentSurrogates.mat', 'all_trials')
% load('session_20180925_entrainmentSurrogates.mat', 'LFPfiles_local')
% load('session_20180925_entrainmentSurrogates.mat', 'selectedLFPFiles')

savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/PAC/canoltyMethod/bySession';
doSetup = true;
doSave = true;
doPlot = true;
doDebug = false;
dbstop if error

tWindow = 0.5;
% freqList = logFreqList([2 200],11);
freqList_p = logFreqList([2 10],10);
freqList_a = logFreqList([10 200],10);
freqList = unique([freqList_p freqList_a]);

nSurr = 200;
nShuff = 10;
oversampleBy = 4;
zThresh = 5;

iSession = 0;
all_MImatrix = {};
all_shuff_MImatrix_mean = {};
all_shuff_MImatrix_pvals = {};

for iNeuron = selectedLFPFiles(2:end)'
    iSession = iSession + 1;
    disp(['Session #',num2str(iSession)]);
    if doSetup
        sevFile = LFPfiles_local{iNeuron};
        disp(sevFile);
        [~,name,~] = fileparts(sevFile);
        subjectName = name(1:5);
        curTrials = all_trials{iNeuron};
        [trialIds,allTimes] = sortTrialsBy(curTrials,'RT');
        [sevFilt,Fs,decimateFactor] = loadCompressedSEV(sevFile,[]);
        [W,all_data] = eventsLFPv2(curTrials(trialIds),sevFilt,tWindow,Fs,freqList,eventFieldnames);
        keepTrials = threshTrialData(all_data,zThresh);
        W = W(:,:,keepTrials,:);
        
        % surrogates
        trialTimeRanges = compileTrialTimeRanges(curTrials);
        takeTime = tWindow * oversampleBy;
        takeSamples = round(takeTime * Fs);
        minTime = min(trialTimeRanges(:,2));
        maxTime = max(trialTimeRanges(:,1)) - takeTime;

        data = [];
        surrLog = [];
        iSurr = 0;
        disp('Searching for out of trial times...');
        while iSurr < nSurr + 40 % add buffer for artifact removal
            % try randTs
            randTs = (maxTime-minTime) .* rand + minTime;
            % check that randTs is not in-trial
% %             if inTrial(randTs,takeTime,trialTimeRanges)
                iSurr = iSurr + 1;
                randSample = round(randTs * Fs);
                surrLog(iSurr) = randTs;
                data(:,iSurr) = sevFilt(randSample:randSample + takeSamples - 1);
%             end
        end
        disp('Done searching!');
        keepTrials = threshTrialData(data,zThresh);
        W_surr = calculateComplexScalograms_EnMasse(data(:,keepTrials(1:nSurr)),'Fs',Fs,'freqList',freqList);
        tWindow_sample = round(tWindow * Fs);
        reshapeRange = round(size(W_surr,1)/2)-tWindow_sample:round(size(W_surr,1)/2)+tWindow_sample-1;
        W_surr = W_surr(reshapeRange,:,:);
        
        MImatrix = NaN(size(W,1),numel(freqList_p),numel(freqList_a));
        shuff_MImatrix_mean = MImatrix;
        shuff_MImatrix_pvals = MImatrix;
        surr_ifA = NaN(numel(freqList_a),nSurr); % #save
        for iEvent = 1:size(W,1)
            disp(['working on event #',num2str(iEvent)]);
            for ifp = 1:numel(freqList_p)
                for ifA = 1:numel(freqList_a)
                    pIdx = find(freqList == freqList_p(ifp));
                    phase = squeeze(angle(W(iEvent,:,:,pIdx)));
                    phase = phase(:)';
                    
                    aIdx = find(freqList == freqList_a(ifA));
                    amplitude = squeeze(abs(W(iEvent,:,:,aIdx)));
                    amplitude = amplitude(:)';
                    
                    z = amplitude.*exp(1i*phase);
                    m_raw = mean(z);
                    
                    shuff_m_raw = [];
                    for iShuff = 1:nShuff
                        shuff_amplitude = squeeze(abs(W(iEvent,:,randperm(size(W,3),size(W,3)),ifA)));
                        shuff_amplitude = shuff_amplitude(:)';
                        shuff_z = shuff_amplitude.*exp(1i*phase);
                        shuff_m_raw(iShuff) = mean(shuff_z);
                    end
                    
                    if ~any(surr_ifA(ifA,:))
                        surrVals = [];
                        for iSurr = 1:nSurr
                            surrogate_amplitude = squeeze(abs(W_surr(:,randperm(nSurr,size(W,3)),ifA)));
                            surrogate_amplitude = surrogate_amplitude(:)';
                            surrVals(iSurr) = mean(surrogate_amplitude.*exp(1i*phase));
                            surrogate_m(iSurr) = abs(mean(surrogate_amplitude.*exp(1i*phase)));
                        end
                    else
                        surrogate_m = surr_ifA(ifA,:);
                    end
                        
                    [surrogate_mean,surrogate_std] = normfit(surrogate_m);
                    
                    m_norm_length = (abs(m_raw)-surrogate_mean)/surrogate_std;
                    m_norm_phase = angle(m_raw);
                    m_norm = m_norm_length*exp(1i*m_norm_phase);
                    MImatrix(iEvent,ifp,ifA) = m_norm_length;
                    
                    shuff_m_norm_length = (abs(shuff_m_raw)-surrogate_mean)./surrogate_std;
                    shuff_MImatrix_mean(iEvent,ifp,ifA) = mean(shuff_m_norm_length);
%                     shuff_MImatrix_pvals(iEvent,ifp,ifA) = sum(abs(m_norm_length) > abs(shuff_m_norm_length)) / nShuff;
                    shuff_MImatrix_pvals(iEvent,ifp,ifA) = sum(abs(m_raw) > abs(shuff_m_raw)) / nShuff;
                    
                    if doDebug
                        t = linspace(0,1,numel(amplitude));
                        h = ff(1200,700);
                        rows = 2;
                        cols = 3;

                        subplot(rows,cols,prc(cols,[1 1]));
                        yyaxis left;
                        plot(t,amplitude);
                        ylabel('amp (uV)');
                        yticks(ylim);
                        yyaxis right;
                        plot(t,phase);
                        ylabel('phase');
                        ylim([-pi,pi]);
                        yticks(sort([0,ylim]));
                        yticklabels({'-\pi','0','\pi'});
                        xlim([0 1]);
                        xticks(xlim);
                        xlabel('time (s)');
                        title({['session: ',num2str(iSession)],...
                            ['amp: ',num2str(freqList(ifA),'%2.1f'),'Hz phase: ',num2str(freqList(ifp),'%2.1f'),'Hz']});

                        subplot(rows,cols,prc(cols,[2 1]));
                        plot(t,real(z),'k-');
                        hold on;
                        plot(t,imag(z),'r-');
                        xlim([0 1]);
                        xticks(xlim);
                        legend('real[z(t)]','imag[z(t)]');
                        xlabel('time (s)');
                        ylabel('amp (uV)');

                        subplot(rows,cols,prc(cols,[1 2]));
                        plot(z,'k.');
                        maxax = round(max(abs([xlim ylim])));
                        xlim([-maxax maxax]);
                        xticks(sort([0 xlim]));
                        ylim(xlim);
                        yticks(sort([0 ylim]));
                        xlabel('real(z)');
                        ylabel('imag(z)');
                        title('z(t)');
                        grid on;

                        subplot(rows,cols,prc(cols,[2 2]));
                        plot(surrVals,'k.');
                        maxax = max(abs([xlim ylim]));
                        hold on;
                        plot(m_raw,'r*');
                        xlim([-maxax maxax]);
                        xticks(sort([0 xlim]));
                        ylim(xlim);
                        yticks(sort([0 ylim]));
                        xlabel('real(z)');
                        ylabel('imag(z)');
                        title('surrogate MIs');
                        grid on;

                        subplot(rows,cols,prc(cols,[1 3]));
                        hb = histogram(surrogate_m,20);
                        hb.FaceColor = 'none';
                        xlabel('surrogate lengths');
                        ylabel('density');
                        hold on;
                        title(['mean: ',num2str(surrogate_mean,2),', std: ',num2str(surrogate_std,2)]);
                        ln = plot(abs(m_raw),0,'r*');
                        legend(ln,'actual length');
% %                             y = normpdf(hb.BinEdges(2:end),surrogate_mean,surrogate_std);
% %                             hold on;
% %                             plot(hb.BinEdges(2:end),y,'r-');

                        subplot(rows,cols,prc(cols,[2 3]));
                        ln = plot(m_norm,'r*');
                        hold on;
                        plot([0 real(m_norm)],[0 imag(m_norm)],'k-');
                        hold on;
                        text(real(m_norm)+0.3,imag(m_norm)+0.3,{['MI (z): ',num2str(m_norm_length,2)],...
                            ['real: ',num2str(real(m_norm),2)],...
                            ['imag: ',num2str(imag(m_norm),2)]});
                        x05 = abs(norminv(0.05/numel(freqList).^2));
                        x01 = abs(norminv(0.01/numel(freqList).^2));
                        x001 = abs(norminv(0.001/numel(freqList).^2));
                        viscircles([0 0],x05);
                        text(x05*cos(pi/4.5),x05*cos(pi/4.5),'p = 0.05','color','r');
                        xlabel('real(z)');
                        ylabel('imag(z)');
                        maxax = max(abs([xlim ylim]));
                        xlim([-maxax maxax]);
                        xticks(sort([0 xlim]));
                        ylim(xlim);
                        yticks(sort([0 ylim]));
                        title('M_n_o_r_m');
                        grid on;

                        set(gcf,'color','w');
                        saveFile = ['s',num2str(iSession,'%02d'),'_tStitched_ifA',...
                            num2str(ifA,'%02d'),'_ifp',num2str(ifp,'%02d'),'_ev',num2str(iEvent),'.png'];
                         saveas(h,fullfile(savePath,'debug',saveFile));
                        close(h);
                    end
                    
                end
            end
        end
        all_MImatrix{iSession} = MImatrix;
        all_shuff_MImatrix_mean{iSession} = shuff_MImatrix_mean;
        all_shuff_MImatrix_pvals{iSession} = shuff_MImatrix_pvals;
    end
    
    if doPlot
        pLims = [0 0.001];
        zLims = [-26 26];
        rows = 4;
        cols = 7;
        h = figuree(1300,800);
        for iEvent = 1:7
            curMat = squeeze(MImatrix(iEvent,:,:));
            subplot(rows,cols,prc(cols,[1 iEvent]));
            imagesc(curMat');
            colormap(gca,jet);
            set(gca,'ydir','normal');
            caxis(zLims);
            xticks(1:numel(freqList_p));
            xticklabels(num2str(freqList_p(:),'%2.1f'));
            xtickangle(270);
            xlabel('phase (Hz)');
            yticks(1:numel(freqList_a));
            yticklabels(num2str(freqList_a(:),'%2.1f'));
            ylabel('amp (Hz)');
            set(gca,'fontsize',6);
            if iEvent == 1
                title({'mean real Z',[subjectName,' s',num2str(iSession,'%02d')],eventFieldnames{iEvent}});
            else
                title({'mean real Z',eventFieldnames{iEvent}});
            end
            if iEvent == 7
                cbAside(gca,'Z-MI','k');
            end

            % note: z = norminv(alpha/N); N = # of index values
            pMat = normcdf(curMat,'upper')*numel(freqList).^2;
            subplot(rows,cols,prc(cols,[2 iEvent]));
            imagesc(pMat');
            colormap(gca,jet);
            set(gca,'ydir','normal');
            caxis(pLims);
            xticks(1:numel(freqList_p));
            xticklabels(num2str(freqList_p(:),'%2.1f'));
            xtickangle(270);
            xlabel('phase (Hz)');
            yticks(1:numel(freqList_a));
            yticklabels(num2str(freqList_a(:),'%2.1f'));
            ylabel('amp (Hz)');
            set(gca,'fontsize',6);
            title('mean real pval');
            if iEvent == 7
                cbAside(gca,'p-value','k');
            end
            
            curMat = squeeze(shuff_MImatrix_mean(iEvent,:,:));
            subplot(rows,cols,prc(cols,[3 iEvent]));
            imagesc(curMat');
            colormap(gca,jet);
            set(gca,'ydir','normal');
            caxis(zLims);
            xticks(1:numel(freqList_p));
            xticklabels(num2str(freqList_p(:),'%2.1f'));
            xtickangle(270);
            xlabel('phase (Hz)');
            yticks(1:numel(freqList_a));
            yticklabels(num2str(freqList_a(:),'%2.1f'));
            ylabel('amp (Hz)');
            set(gca,'fontsize',6);
            title('mean shuff Z');
            if iEvent == 7
                cbAside(gca,'Z-MI','k');
            end
            
            pMat = squeeze(shuff_MImatrix_pvals(iEvent,:,:));
            subplot(rows,cols,prc(cols,[4 iEvent]));
            imagesc(pMat');
            colormap(gca,jet);
            set(gca,'ydir','normal');
            caxis(pLims);
            xticks(1:numel(freqList_p));
            xticklabels(num2str(freqList_p(:),'%2.1f'));
            xtickangle(270);
            xlabel('phase (Hz)');
            yticks(1:numel(freqList_a));
            yticklabels(num2str(freqList_a(:),'%2.1f'));
            ylabel('amp (Hz)');
            set(gca,'fontsize',6);
            title('mean shuff pval');
            if iEvent == 7
                cbAside(gca,'p-value','k');
            end
        end
        set(gcf,'color','w');
        if doSave
            saveFile = ['s',num2str(iSession,'%02d'),'_allEvent.png'];
            saveas(h,fullfile(savePath,saveFile));
            close(h);
        end
    end
end