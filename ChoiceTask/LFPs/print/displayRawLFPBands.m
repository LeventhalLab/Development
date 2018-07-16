savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/reviewBands';
doSave = false;

sevFile = '';
timingField = 'RT';
iEvent = 4;
tWindow = 1;
powerScale_wide = 200;
powerScale_lfp = 2000;
freqList = {[0.5 200;1 4;8 12;13 30;40 80]};
rows = 4;
cols = 2;
Wlength = 400;
decimateFactor = 20;

for iNeuron = 1:numel(LFPfiles_local)
    % only unique sev files
    if strcmp(sevFile,LFPfiles_local{iNeuron})
        continue;
    end
    disp(num2str(iNeuron));
    sevFile = LFPfiles_local{iNeuron};
    [~,name,~] = fileparts(sevFile);

%     [sev,header] = read_tdt_sev(sevFile);
%     sevFilt = decimate(double(sev),decimateFactor);
%     Fs = header.Fs / decimateFactor;
%     clear sev;
%     
%     curTrials = all_trials{iNeuron};
%     [trialIds,allTimes] = sortTrialsBy(curTrials,timingField);
%     W = eventsLFPv2(curTrials(trialIds),sevDec,[1,3],Fs,freqList,eventFieldnames);
    Wz = zScoreW(W,Wlength);
    
    ax = [];
    h = figuree(1400,900);
    for iBand = 1:size(freqList{:},1)
        if iBand == 1
            ax(iBand) = subplot(rows,cols,[1 4]);
        else
            ax(iBand) = subplot(rows,cols,iBand+3);
        end
        
        refLFP = real(squeeze(W(1,:,:,iBand)));
        refMean = mean2(refLFP);
        refStd = mean(std(refLFP));
        
        for iTrial = 1:size(W,3)
            LFP = (real(squeeze(W(iEvent,:,iTrial,iBand))) - refMean) ./ refStd;
            plot(linspace(-tWindow,tWindow,numel(LFP)),LFP/2+iTrial,'k-');
            hold on;
        end
        xlim([-1 1]);
        xticks(sort([xlim,0]));
        xlabel('time (s)');
        ylim([0 size(W,3)+1]);
        yticks([1 size(W,3)]);
        ylabel('trials (successful)');
        
        if iBand == 1
            title({['u',num2str(iNeuron,'%03d'),' wideband at ',eventFieldnames{iEvent}]...
                [num2str(freqList{1}(iBand,1)),' - ',num2str(freqList{1}(iBand,2)),' Hz']});
        else
            title([num2str(freqList{1}(iBand,1)),' - ',num2str(freqList{1}(iBand,2)),' Hz']);
        end
        grid on
    end
    
    linkaxes(ax,'xy')
    set(gcf,'color','w');
    
    if doSave
        saveas(h,fullfile(savePath,[num2str(iNeuron,'%03d'),'_reviewBands.png']));
        close(h);
    end
end