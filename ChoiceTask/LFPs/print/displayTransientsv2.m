% !! changed keepLocs to only returning peak locations (not start/finish)
% !! requires update to this code
sevFile = '';
timingField = 'RT';
iEvent = 4;
tWindow = 1;
powerScale = 50000;

for iNeuron = 1%:numel(LFPfiles_local)
    % only unique sev files
    if strcmp(sevFile,LFPfiles_local{iNeuron})
        continue;
    end
    disp(num2str(iNeuron));
    sevFile = LFPfiles_local{iNeuron};
    [~,name,~] = fileparts(sevFile);
    curTrials = all_trials{iNeuron};

%     [sev,header] = read_tdt_sev(sevFile);
%     decimateFactor = 10;
%     sevFilt = decimate(double(sev),decimateFactor);
%     clear sev;
    Fs = header.Fs / decimateFactor;
    freqList = {[8 15;15 25;25 45;1 200]};
    LFP = eventsLFPv2(curTrials,sevFilt,tWindow,Fs,freqList,eventFieldnames);
    keepLocs = dklPeakDetect(LFP(:,:,:,1:3),iEvent);
    LFP_wide = abs(LFP(:,:,:,4)).^2;
    LFP_power = abs(LFP(:,:,:,2)).^2;

    t = linspace(-1,1,size(LFP,2));
    ref_power = nanmedian(squeeze(LFP_power(1,:,:)));
    cutoffPower = mean(ref_power) * 6;
    
    figuree(1400,900);
    lns = [];
    for iTrial = 1:size(LFP,3)
        cur_power = squeeze(LFP_power(iEvent,:,iTrial));
        cur_wide = squeeze(LFP_wide(iEvent,:,iTrial))./powerScale;
        [locs,pks] = peakseek(cur_power,round(numel(cur_power)/2/100),cutoffPower);
        locsTs = (locs/numel(cur_power)*2) - 1;

        ax1 = subplot(121);
%         plot(t,cur_wide+iTrial,'-','color','k');
        hold on;
        % highlight one beta cycle as reference OR use Dan's algorithm directly
%             plot(t(curPower>cutoffPower),curLFP(curPower>cutoffPower)/powerScale+iTrial,'r-');
        plot(locsTs,cur_wide(locs)+iTrial,'rx');
        for iLoc = 1:size(keepLocs{iTrial},1)
%             idxs = keepLocs{iTrial}(iLoc,1):keepLocs{iTrial}(iLoc,3);
%             x = (idxs/numel(cur_power)*2) - 1;
%             y = cur_wide(idxs);
%             plot(x,y+iTrial,'-r');
            idxs = keepLocs{iTrial}(iLoc,2);
            x = (idxs/numel(cur_power)*2) - 1;
            y = cur_wide(idxs);
            lns = plot(x,y+iTrial,'bx');
        end
        xlim([-1 1]);
        xticks(sort([xlim,0]));
        ylim([0 size(LFP,3)+1]);
        yticks([1 size(LFP,3)]);
        ylabel('trials');
        title(['u',num2str(iNeuron,'%03d'),'Beta Transients at ',eventFieldnames{iEvent}]);
        legend(lns,{'DKL'});

        ax2 = subplot(122);
%         plot(t,(2*cur_power/max(cur_power))+iTrial,'-','color','k');
        hold on;
        plot(locsTs,(2*cur_power(locs)/max(cur_power))+iTrial,'rx');
        for iLoc = 1:size(keepLocs{iTrial},1)
%             idxs = keepLocs{iTrial}(iLoc,1):keepLocs{iTrial}(iLoc,3);
%             x = (idxs/numel(cur_power)*2) - 1;
%             y = cur_wide(idxs);
%             plot(x,y+iTrial,'-r');
            idxs = keepLocs{iTrial}(iLoc,2);
            x = (idxs/numel(cur_power)*2) - 1;
            y = (2*cur_power(idxs)/max(cur_power));
            plot(x,y+iTrial,'bx');
        end
        xlim([-1 1]);
        xticks(sort([xlim,0]));
        ylim([0 size(LFP,3)+1]);
        yticks([1 size(LFP,3)]);
        ylabel('trials');
        title(['Beta Transients, filtered']);
    end
    linkaxes([ax1,ax2],'xy')
end