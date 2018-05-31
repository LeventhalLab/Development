freqList = [20,50];
uniqueSessions = unique(analysisConf.sessionNames);
saveFolder = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/perievent/betaGammaPhaseAmp';

[uniqueLFPs,ic,ia] = unique(LFPfiles);

% % for iSession = 1%1:numel(uniqueSessions)
% %     sessionUnits = find(strcmp(analysisConf.sessionNames,uniqueSessions{iSession}) == 1);
% %     for iNeuron = 1%1:numel(sessionUnits)
% %         disp([num2str(iSession),'-',num2str(sessionUnits(iNeuron))]);
% %         sevFile = LFPfiles{iNeuron};
% %         [~,name,~] = fileparts(sevFile);
% %         subjectName = name(1:5);
% %         curTrials = all_trials{iNeuron};
% %         [W,freqList,allTimes] = getW(sevFile,curTrials,eventFieldnames,freqList);
% %     end
% % end

for iNeuron = ic'
    sevFile = LFPfiles{iNeuron};
    curTrials = all_trials{iNeuron};
    [W,freqList,allTimes] = getW(sevFile,curTrials,eventFieldnames,freqList);
    
    cols = 7;
    lineWidth = 0.5;
    c1 = repmat(.8,[1 4]);
    t = linspace(-1,1,size(W,2));
    tWindow_vis_arr = [1 0.1 0.025];
    bandLabels = {'beta','gamma'};
    for iBand = 1:2
        h = figuree(1300,900);
        for iEvent = 1:cols
            data_power_mean = [];
            data_phase_mean = [];
            for iWindow = 1:numel(tWindow_vis_arr)
                for iTrial = 1:size(W,3)
                    data = squeeze(squeeze(W(iEvent,:,iTrial,iBand)));

                    data_power = abs(data).^2;
                    data_power_mean(iTrial,:) = data_power;
                    subplot(2*numel(tWindow_vis_arr),7,prc(cols,[(iWindow*2)-1 iEvent]));
                    plot(t,data_power,'lineWidth',lineWidth,'color',c1);
                    hold on;

                    data_phase = angle(data);
                    data_phase_mean(iTrial,:) = data_phase;
                    subplot(2*numel(tWindow_vis_arr),7,prc(cols,[(iWindow*2) iEvent]));
                    plot(t,data_phase,'lineWidth',lineWidth,'color',c1);
                    hold on;
                end
                subplot(2*numel(tWindow_vis_arr),7,prc(cols,[(iWindow*2)-1 iEvent]));
                plot(t,mean(data_power_mean),'r','lineWidth',2);
                xlim([-tWindow_vis_arr(iWindow) tWindow_vis_arr(iWindow)]);
                xticks(sort([0 xlim]));
                maxy = ceil(max(mean((abs(W(5,:,:,1)).^2),3))/1000)*1000;
                ylim([0 maxy]); % max of Side In
                yticks(ylim);
                yticklabels({'0',[num2str(maxy/1000),'e3']});
                if iEvent == 1
                    title({['u',num2str(iNeuron,'%03d'),' ',bandLabels{iBand}],'power'});
                else
                    title('power');
                end
                grid on;

                subplot(2*numel(tWindow_vis_arr),7,prc(cols,[(iWindow*2) iEvent]));
                yyaxis left;
                plot(t,circ_mean(data_phase_mean));
                xlim([-tWindow_vis_arr(iWindow) tWindow_vis_arr(iWindow)]);
                xticks(sort([0 xlim]));
                ylim([-pi-(pi/4) pi+(pi/4)]);
                yticks([-pi 0 pi]);
                yticklabels({'-\pi','0','\pi'});

                yyaxis right;
                plot(t,circ_r(data_phase_mean),'lineWidth',2);
                ylim([0 0.5]);
                title('phase/MRL');
                grid on;
            end
        end
        set(h,'color','w');
        saveFile = ['unit',num2str(iNeuron,'%03d'),'_',bandLabels{iBand},'.png'];
        saveas(h,fullfile(saveFolder,saveFile));
        close(h);
    end
end