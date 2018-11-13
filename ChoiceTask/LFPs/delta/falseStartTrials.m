doSetup = true;
doSave = true;
freqList = {[1 4]}; % hilbert method
iEvent = 4;
tWindow = 1;
nPoints = 200;

if doSetup
    all_pMat = [];
    iSession = 0;
    for iNeuron = selectedLFPFiles'
        iSession = iSession + 1;
        disp(num2str(iSession));
        sevFile = LFPfiles_local{iNeuron};
        [sevFilt,Fs,decimateFactor] = loadCompressedSEV(sevFile,[]);
        curTrials = all_trials{iNeuron};
        curTrials = curTrials([curTrials(:).correct] == 1 | [curTrials(:).falseStart] == 1);

        [trialIds,allTimes] = sortTrialsBy(curTrials,'RT');
        falseTrialIds = find([curTrials(:).falseStart] == 1);
        [W,all_data] = eventsLFPv2(curTrials,sevFilt,tWindow,Fs,freqList,{eventFieldnames{iEvent}});
        tps = floor(linspace(1,size(W,2),nPoints));
        
        pMat = [];
        for iCond = 1:2
            if iCond == 1
                useTrials = trialIds;
            else
                useTrials = falseTrialIds;
            end
            for ii = 1:numel(tps)
                alpha = squeeze(angle(W(1,tps(ii),useTrials)));
                pMat(iCond,ii) = circ_rtest(alpha);
            end
        end
        all_pMat(iSession,:,:) = pMat;
        
% %         h = ff(600,300);
% %         lns = [];
% %         pThresh = .001;
% %         lineWidth = 2;
% %         t = linspace(-tWindow,tWindow,nPoints);
% %         lns(1) = plot(t,pMat(1,:),'k-','lineWidth',lineWidth);
% %         hold on;
% %         sigIds = pMat(1,:) < pThresh;
% %         if sum(sigIds) > 0
% %             plot(t(sigIds),0.5,'k*');
% %         end
% %         
% %         lns(2) = plot(t,pMat(2,:),'r-','lineWidth',lineWidth);
% %         sigIds = pMat(2,:) < pThresh;
% %         if sum(sigIds) > 0
% %             plot(t(sigIds),0.4,'r*');
% %         end
% %         ylim([0 1]);
% %         yticks(ylim);
% %         xticks([-tWindow 0 tWindow]);
% %         xlabel('time (s)');
% %         ylabel('pval');
% %         title(eventFieldnames{iEvent});
% %         legend(lns,{'success','falseStart'});
% %         legend boxoff;
        
        
        h = ff(400,400);
        for iCond = 1:2
            if iCond == 1
                useTrials = trialIds;
                color = 'k';
                textPos = 0.25;
            else
                useTrials = falseTrialIds;
                color = 'r';
                textPos = 0.55;
            end
            alpha = squeeze(angle(W(1,floor(size(W,2)/2),useTrials)));
            pval = circ_rtest(alpha);
            mu = circ_mean(alpha);
            r = circ_r(alpha);
            polarplot(alpha,ones(size(alpha)),[color,'o']);
            hold on;
            polarplot([mu mu],[0 r],color);
            text(mu,r,['p = ',num2str(pval,2),', n = ',num2str(numel(useTrials))],'color',color);
        end
        rticks([0 1]);

        set(gcf,'color','w');
        if doSave
            saveas(h,fullfile(savePath,['falseStart_deltaCirc_s',num2str(iSession,'%02d'),'.png']));
            close(h);
        end
    end
end