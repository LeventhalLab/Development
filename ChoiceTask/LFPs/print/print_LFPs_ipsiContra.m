doDebug = false;
savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/perievent/LFP_contraIpsi';
sevFile = '';
tWindow = 1.5;
tWindow_vis = 1;
cols = 7;
rows = 4;
freqList = logFreqList([1 200],30);
ytickIds = [1 7 10 14 17 20 25 30]; % selected from freqList
ytickLabelText = freqList(ytickIds);
ytickLabelText = num2str(ytickLabelText(:),'%3.0f');
allFrames = [];
Wlength = 200;
caxisVals = [-3 3];
zThresh = 2;
decimateFactor = 16;
for iNeuron = 1:numel(LFPfiles_local)
    % only unique sev files
    if strcmp(sevFile,LFPfiles_local{iNeuron})
        continue;
    end
    sevFile = LFPfiles_local{iNeuron};
    disp(sevFile);
    [~,name,~] = fileparts(sevFile);
    subjectName = name(1:5);
    [sev,header] = read_tdt_sev(sevFile);
    sevFilt = decimate(double(sev),decimateFactor);
    Fs = header.Fs / decimateFactor;
    
    curTrials = all_trials{iNeuron};
    W = eventsLFPv2(curTrials,sevFilt,tWindow,Fs,freqList,eventFieldnames);
    [Wz_power,Wz_phase] = zScoreW(W,Wlength); % power Z-score
    t = linspace(-tWindow,tWindow,size(W,2));
    trialIdInfo = organizeTrialsById(curTrials);
    
    h = figuree(1300,600);
    caxisArr = zeros(cols,2);
    ax = [];
    for iRow = 1:2
        if iRow == 1
            ylabelText = 'Contra Power';
            useTrials = trialIdInfo.correctContra;
        else
            ylabelText = 'Ipsi Power';
            useTrials = trialIdInfo.correctIpsi;
        end
        % remove artifact trials
        [Wz_power_threshTrials,keepTrials] = removeWzTrials(Wz_power(:,:,useTrials,:),zThresh);
        Wz_phase_threshTrials = Wz_phase(:,:,useTrials(keepTrials),:);
        for iEvent = 1:cols
            % POWER CONTRA
            ax(iEvent) = subplot(rows,cols,prc(cols,[iRow,iEvent]));

            scaloData = Wz_power_threshTrials(iEvent,:,:,:);
            scaloData = squeeze(scaloData);
            
            if doDebug && iEvent == 1
                figuree(900,900);
                debug_sq = ceil(sqrt(size(scaloData,2)));
                for iTrial = 1:size(scaloData,2)
                    subplot(debug_sq,debug_sq,iTrial);
                    imagesc(t,1:numel(freqList),squeeze(scaloData(:,iTrial,:))');
                    colormap(jet);
                    xlim([-tWindow_vis tWindow_vis]);
                    xticks(sort([0 xlim]));
                    yticks(ytickIds);
                    yticklabels(ytickLabelText);
                    set(gca,'YDir','normal');
                    colormap(ax(iEvent),jet);
                    title(num2str(iTrial));
                    caxis([-5 5]);
                end
            end
            
            scaloData = mean(scaloData,2);
            scaloData = squeeze(scaloData);

            imagesc(t,1:numel(freqList),scaloData');
            hold on;
            xlim([-tWindow_vis tWindow_vis]);
            xticks(sort([0 xlim]));
            yticks(ytickIds);
            yticklabels(ytickLabelText);
            set(gca,'YDir','normal');
            colormap(ax(iEvent),jet);
% %             set(gca,'ColorScale','log');
            grid on;
            
            if iRow == 1 && iEvent == 1
                title({['u',num2str(iNeuron,'%03d')],eventFieldnames{iEvent},[num2str(numel(keepTrials)),' trials']});
            else
                title({eventFieldnames{iEvent},[num2str(numel(keepTrials)),' trials']});
            end
            
            if iEvent ==  1
                ylabel(ylabelText);
            else
                ylabel({});
            end
            
%             if iRow == 1
%                 caxisArr(iEvent,:) = caxis;
%             end
            caxis(caxisVals);
        end
        
        if iEvent == 7
            cb = colorbar('Location','east');
            cb.Ticks = caxis;
            cb.Label.String = 'z-power';
        end

%         for iEvent = 1:cols
%             subplot(ax(iEvent));
%             caxis([mean(caxisArr(:,1)) mean(caxisArr(:,2))]);
%         end
    end
    
    for iRow = 3:4
        if iRow == 3
            ylabelText = 'Contra MRL';
            useTrials = trialIdInfo.correctContra;
        else
            ylabelText = 'Ipsi MRL';
            useTrials = trialIdInfo.correctIpsi;
        end
        % remove artifact trials
        % !! this is redundant, could use same loop as above
        [Wz_power_threshTrials,keepTrials] = removeWzTrials(Wz_power(:,:,useTrials,:),zThresh);
        Wz_phase_threshTrials = Wz_phase(:,:,useTrials(keepTrials),:);
        for iEvent = 1:cols
            % POWER CONTRA
            ax(iEvent) = subplot(rows,cols,prc(cols,[iRow,iEvent]));

            scaloData = Wz_phase_threshTrials(iEvent,:,:,:);
            scaloData = squeeze(scaloData);
            scaloData = circ_r(scaloData,[],[],2);
            scaloData = mean(scaloData,2);
            scaloData = squeeze(scaloData);

            imagesc(t,1:numel(freqList),scaloData');
            hold on;
            xlim([-tWindow_vis tWindow_vis]);
            xticks(sort([0 xlim]));
            yticks(ytickIds);
            yticklabels(ytickLabelText);
            set(gca,'YDir','normal');
            cb = colormap(ax(iEvent),hot);
            caxis([0 1]);
            title(eventFieldnames{iEvent});
            if iEvent == 1
                ylabel(ylabelText);
            end
            if iEvent == 7
                cb = colorbar('Location','east');
                cb.Ticks = caxis;
                cb.Label.String = 'MRL';
            end
            grid on;
        end
    end
    set(h,'color','w');
    saveFile = ['unit_',num2str(iNeuron,'%03d'),'.png'];
    saveas(h,fullfile(savePath,saveFile));
    close(h);
end