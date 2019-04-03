doSave = true;
dataPath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/datastore/xcorr';
savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/datastore/xcorr/figs';
xcorrFiles = dir(fullfile(dataPath,'*.mat'));

useFreqs = [6;17;22;29];
freqLabels = {'\delta','\beta','\gamma_L','\gamma_H'};
rows = size(useFreqs,1);
cols = 3;
colors = {lines(size(useFreqs,1)),lines(size(useFreqs,1))*.3};
pThresh = 0.05;
ylimVals_left = [-0.5 0.5];
ylimVals_right = [-0.1 0.1];
tlag = linspace(-tXcorr,tXcorr,numel(lag));
condLabels = {'allUnits','dirSel','ndirSel'};

for iFile = 1:numel(xcorrFiles)
    h = ff(900,800);
    load(fullfile(xcorrFiles(iFile).folder,xcorrFiles(iFile).name));
    iNeuron = str2num(xcorrFiles(iFile).name(end-6:end-4));
    for iDir = 1:3
        for iFreq = 1:size(useFreqs,1)
            for iIn = 1:2
                data = squeeze(acors(iIn,:,useFreqs(iFreq),:));
                subplot(rows,cols,prc(cols,[iFreq,iDir]));
                yyaxis left;
                plot(tlag,data,'-','color',[colors{iIn}(iFreq,:) 0.2]);
                hold on;
                ylim(ylimVals_left);
                yticks(sort([0,ylim]));
                yyaxis right;
                plot(tlag,mean(data),'-','color',colors{iIn}(iFreq,:),'linewidth',2);
                hold on;
                ylim(ylimVals_right);
                yticks(sort([0,ylim]));
            end
            xlim([min(tlag) max(tlag)]);
            xticks(sort([0,xlim]));
            if iFreq == size(useFreqs,1)
                xlabel('spike lags LFP (s)');
            end
%             ylim(ylimVals);
%             yticks(sort([0,ylim]));
            ylabel('mean xcorr');
            if iFreq == 1
                title({condLabels{iDir},freqLabels{iFreq}});
            else
                title(freqLabels{iFreq});
            end
            grid on;
        end
    end
    addNote(h,['iNeuron: ',num2str(iNeuron)]);
    set(gcf,'color','w');
    if doSave
        saveas(h,fullfile(savePath,['xcorr_u',num2str(iNeuron,'%03d'),'.png']));
        close(h);
    end
end