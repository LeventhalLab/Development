savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/transientLFPevents/rawLFP_DKLvJones';
doSave = true;

sevFile = '';
timingField = 'RT';
iEvent = 4;
tWindow = 1;
powerScale_wide = 200;
powerScale_lfp = 2000;
medianMult = 6;
decimateFactor = 10;

for iNeuron = 1:numel(LFPfiles_local)
    % only unique sev files
    if strcmp(sevFile,LFPfiles_local{iNeuron})
        continue;
    end
    disp(num2str(iNeuron));
    sevFile = LFPfiles_local{iNeuron};
    [~,name,~] = fileparts(sevFile);
    curTrials = all_trials{iNeuron};
    [trialIds,allTimes] = sortTrialsBy(curTrials,timingField);

    [sev,header] = read_tdt_sev(sevFile);
    sevFilt = decimate(double(sev),decimateFactor);
    clear sev;
    
    Fs = header.Fs / decimateFactor;
    freqList = {[8 15;15 25;25 45;1 200]};
    LFP = eventsLFPv2(curTrials(trialIds),sevFilt,tWindow,Fs,freqList,eventFieldnames);
    [locs_dkl,locs_jones] = lfpPeakDetect(LFP(:,:,:,1:3),iEvent,medianMult);
    LFP_wide = real(LFP(:,:,:,4));
    LFP_power = abs(LFP(:,:,:,2)).^2;

    t = linspace(-1,1,size(LFP,2));
    ms20 = round((size(LFP,2) / 2) / 50); % 10 ms
    ref_power = nanmedian(squeeze(LFP_power(1,:,:)));
    cutoffPower = (mean(ref_power) * 6) / powerScale_lfp;
    
    h = figuree(1400,900);
    lns = [];
    for iTrial = 1:size(LFP,3)
        cur_power = squeeze(LFP_power(iEvent,:,iTrial)) ./ powerScale_lfp;
        cur_wide = squeeze(LFP_wide(iEvent,:,iTrial)) ./ powerScale_wide;

% %         ax1 = subplot(121);
        plot(t,cur_wide+iTrial,'-','color','k');
        hold on;
        % !! REPLACE with true LFP not envelope
        %either define window criteria or just highlight peri-20ms
        for iLoc = 1:numel(locs_dkl{iTrial})
            idxsStart = max([locs_dkl{iTrial}(iLoc) - ms20 1]);
            idxsEnd = min([locs_dkl{iTrial}(iLoc) + ms20 numel(cur_wide)]);
            idxs = idxsStart:idxsEnd;
            x = (idxs/numel(cur_wide)*2) - 1;
            y = cur_wide(idxs);
            lns(1) = plot(x,y+iTrial,'-r','lineWidth',1.5);
        end
        for iLoc = 1:numel(locs_jones{iTrial})
            idxsStart = max([locs_jones{iTrial}(iLoc) - ms20 1]);
            idxsEnd = min([locs_jones{iTrial}(iLoc) + ms20 numel(cur_wide)]);
            idxs = idxsStart:idxsEnd;
            x = (idxs/numel(cur_wide)*2) - 1;
            y = cur_wide(idxs);
            lns(2) = plot(x,y+iTrial,':g','lineWidth',1.5);
        end

% %         ax2 = subplot(122);
% %         plot(t,cur_power+iTrial,'-','color','k');
% %         hold on;
% %         for iLoc = 1:numel(locs_dkl{iTrial})
% %             idxsStart = max([locs_dkl{iTrial}(iLoc) - ms10 1]);
% %             idxsEnd = min([locs_dkl{iTrial}(iLoc) + ms10 numel(cur_wide)]);
% %             idxs = idxsStart:idxsEnd;
% %             x = (idxs/numel(cur_power)*2) - 1;
% %             y = cur_power(idxs);
% %             lns(1) = plot(x,y+iTrial,'-r','lineWidth',1.5);
% %         end
% %         for iLoc = 1:numel(locs_jones{iTrial})
% %             idxsStart = max([locs_jones{iTrial}(iLoc) - ms10 1]);
% %             idxsEnd = min([locs_jones{iTrial}(iLoc) + ms10 numel(cur_wide)]);
% %             idxs = idxsStart:idxsEnd;
% %             x = (idxs/numel(cur_power)*2) - 1;
% %             y = cur_power(idxs);
% %             lns(1) = plot(x,y+iTrial,':b','lineWidth',1.5);
% %         end
% %         xlim([-1 1]);
% %         xticks(sort([xlim,0]));
% %         ylim([0 size(LFP,3)+1]);
% %         yticks([1 size(LFP,3)]);
% %         ylabel('trials');
% %         title(['Beta Power Envelope']);
    end
    xlim([-1 1]);
    xticks(sort([xlim,0]));
    xlabel('time (s)');
    ylim([0 size(LFP,3)+1]);
    yticks([1 size(LFP,3)]);
    ylabel('trials (successful)');
    title(['u',num2str(iNeuron,'%03d'),' \beta-transients at ',eventFieldnames{iEvent}]);
    legend(lns,{'DKL','Jones'});
% %     linkaxes([ax1,ax2],'xy')
    set(gcf,'color','w');
    tightfig;
    pause(5);
    if doSave
        saveas(h,fullfile(savePath,[num2str(iNeuron,'%03d'),'_rawLFP_DKLvJones.png']));
        close(h);
    end
end