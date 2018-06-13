savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/perievent/LFP_contraIpsi';
sevFile = '';
tWindow = 1;
cols = 7;
rows = 4;
freqList = logFreqList([3.5 200],30);
ytickIds = [1 7 10 14 17 20 25 30]; % selected from freqList
ytickLabelText = freqList(ytickIds);
ytickLabelText = num2str(ytickLabelText(:),'%3.0f');
allFrames = [];
for iNeuron = 1:numel(LFPfiles_local)
    % only unique sev files
    if strcmp(sevFile,LFPfiles_local{iNeuron})
        continue;
    end
    sevFile = LFPfiles_local{iNeuron};
    [~,name,~] = fileparts(sevFile);
    subjectName = name(1:5);
    curTrials = all_trials{iNeuron};
    W = getW(sevFile,curTrials,eventFieldnames,freqList,'');
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
        for iEvent = 1:cols
            % POWER CONTRA
            ax(iEvent) = subplot(rows,cols,prc(cols,[iRow,iEvent]));

            scaloData = W(iEvent,:,useTrials,:);
            scaloData = squeeze(scaloData);
            scaloData = abs(scaloData).^2;
            scaloData = mean(scaloData,2);
            scaloData = squeeze(scaloData);

            imagesc(t,1:numel(freqList),scaloData');
            hold on;
            xlim([-tWindow tWindow]);
            xticks(sort([0 xlim]));
            yticks(ytickIds);
            yticklabels(ytickLabelText);
            set(gca,'YDir','normal');
            colormap(ax(iEvent),jet);
            set(gca,'ColorScale','log');
            grid on;
            
            if iRow == 1 && iEvent == 1
                title({['u',num2str(iNeuron,'%03d')],eventFieldnames{iEvent}});
            else
                title(eventFieldnames{iEvent});
            end
            
            if iEvent ==  1
                ylabel(ylabelText);
            else
                ylabel({});
            end
            
            if iRow == 1
                caxisArr(iEvent,:) = caxis;
            end
        end

        for iEvent = 1:cols
            subplot(ax(iEvent));
            caxis([mean(caxisArr(:,1)) mean(caxisArr(:,2))]);
        end
    end
    
    for iRow = 3:4
        if iRow == 1
            ylabelText = 'Contra MRL';
            useTrials = trialIdInfo.correctContra;
        else
            ylabelText = 'Ipsi MRL';
            useTrials = trialIdInfo.correctIpsi;
        end
        for iEvent = 1:cols
            % POWER CONTRA
            ax(iEvent) = subplot(rows,cols,prc(cols,[iRow,iEvent]));

            scaloData = W(iEvent,:,useTrials,:);
            scaloData = squeeze(scaloData);
            scaloData = circ_r(angle(scaloData),[],[],2);
            scaloData = mean(scaloData,2);
            scaloData = squeeze(scaloData);

            imagesc(t,1:numel(freqList),scaloData');
            hold on;
            xlim([-tWindow tWindow]);
            xticks(sort([0 xlim]));
            ylabel(ylabelText);
            yticks(ytickIds);
            yticklabels(ytickLabelText);
            set(gca,'YDir','normal');
            colormap(ax(iEvent),hot);
            caxis([0 1]);
            title(eventFieldnames{iEvent});
            grid on;
        end
    end
    set(h,'color','w');
    saveFile = ['unit_',num2str(iNeuron,'%03d'),'.png'];
    saveas(h,fullfile(savePath,saveFile));
    close(h);
end