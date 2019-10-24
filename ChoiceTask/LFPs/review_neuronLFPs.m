% load('analysisConf.mat')
% load('session_20180919_NakamuraMRL.mat', 'all_trials')

nTrials = 7;
cols = 7;
ylimVals = [-2 2]; % mV
decimateFactor = 10;
tWindow = 2;
fpass = [1 100];
freqList = logFreqList(fpass,30);
savePath = '/Users/matt/Documents/Data/ChoiceTask/LFPs/reviewLFPs';
dataPath = '/Users/matt/Documents/Data/ChoiceTask/LFPs/reviewLFPs/data';

eventFieldlabels = {'Cue','Nose In','Tone','Nose Out','Side In','Side Out','Reward'};

for iNeuron = 1%:numel(analysisConf.neurons)
    neuronName = analysisConf.neurons{iNeuron};
    disp(['--- Working on ',neuronName]);
    [electrodeName,electrodeSite,electrodeChannels] = getElectrodeInfo(neuronName);
    curTrials = all_trials{iNeuron};
    curTrialIds = [curTrials.valid] == 1;
% % % %     curTrialIds = all_trialIds{iNeuron}; % not sure where all_trialIds is made
    
    h = figuree(1300,800);
    legendText = {};
    lns = [];
    for iChannel = 1:numel(electrodeChannels)
        legendText{iChannel} = ['Ch',num2str(electrodeChannels(iChannel))];
        sevFile = analysisConf.sessionConfs{iNeuron,1}.sevFiles{electrodeChannels(iChannel)};
        
        parts = strsplit(sevFile,filesep);
        disp(parts{end});
        disp(electrodeChannels);
%         break;
        sevFile = fullfile(dataPath,parts{end});
        
        [sev,header] = read_tdt_sev(sevFile);
        sevFilt = decimate(double(sev),decimateFactor);
        Fs = header.Fs / decimateFactor;
        [allW,allLfp] = eventsLFPv2(curTrials(curTrialIds),sevFilt,tWindow,Fs,freqList,eventFieldnames);
        
        t = linspace(-tWindow,tWindow,size(allLfp,2));
        for iTrial = 1:nTrials
            for iEvent = 1:cols
                curLFP = squeeze(allLfp(iEvent,:,iTrial));
                subplot(nTrials,cols,prc(cols,[iTrial,iEvent]));
                lns(iChannel) = plot(t,curLFP / 1000);
                hold on;
                ylim(ylimVals);
                yticks(sort([0 ylimVals]));
                xlim([-tWindow,tWindow]);
                xticks(sort([0 xlim]));
                grid on;
                if iTrial == 1
                    if iEvent == 1
                        title({['uid',num2str(iNeuron,'%03d')],eventFieldlabels{iEvent}});
                    else
                        title({'',eventFieldlabels{iEvent}});
                    end
                end
                if iEvent == 1
                    ylabel({['trial ',num2str(iTrial)],'mV'});
                else
                    ylabel('mV');
                end
                if iChannel == numel(electrodeChannels) && iTrial == nTrials && iEvent == cols
                    legend(lns,legendText);
                end
            end
        end
    end
    set(gcf,'color','w');
    saveFile = ['uid',num2str(iNeuron,'%03d'),'_reviewLFP.png'];
    saveas(h,fullfile(savePath,saveFile));
    close(h);
end