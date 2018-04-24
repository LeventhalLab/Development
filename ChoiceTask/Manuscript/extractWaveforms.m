function [waveforms,sameWire,wireLabels] = extractWaveforms(analysisConf,all_ts)
    % waveforms: m units x n mean waveform data points (+/- 2 ms, in uV)
    % sameWire: m units x n wires, where units on same wire are logical 1
    % wireLabels: 1 x n wires, string/name for each wire
    
    disp('!!! This function needs to handle the last neuron for sameWire');
    error('comment this, and manually enter the last neuron for now');
    % in our case (366 neurons) row 366, col 58 == 1
    waveforms = [];
    sameWire = [];
    
    subjects__name = '';
    wireLabels = {};
    startNeuron = 1;
    for iNeuron = 1:numel(analysisConf.neurons)
        neuronName = analysisConf.neurons{iNeuron};
        disp(['Working on ',neuronName]);

        % unique wires
        [electrodeName,electrodeSite,electrodeChannels] = getElectrodeInfo(neuronName);
        sessionConf = analysisConf.sessionConfs{iNeuron};
        if strcmp(subjects__name,sessionConf.subjects__name) == 0 || iNeuron == numel(analysisConf.neurons)
            if ~isempty(subjects__name)
                [C,ia,ic] = unique(subjectElectrodes);
                wireLabels = {wireLabels{:} C{:}};
                prototype = zeros(numel(analysisConf.neurons),numel(unique(ic)));
                endNeuron = iNeuron - 1;
                for iElectrode = 1:numel(unique(ic))
                    prototype(startNeuron:endNeuron,iElectrode) = ic == iElectrode;
                end
                if isempty(sameWire)
                    sameWire = prototype;
                else
                    sameWire = [sameWire prototype];
                end
                startNeuron = iNeuron;
            end
            subjects__name = sessionConf.subjects__name;
            subjectElectrodes = {};
            electrodeCount = 0;
        end
        electrodeCount = electrodeCount + 1;
        subjectElectrodes{electrodeCount} = electrodeName;

        % waveforms
        ts = all_ts{iNeuron};
        meanWaveforms = [];
        for iChannel = 1:numel(electrodeChannels)
            sevFile = sessionConf.sevFiles{electrodeChannels(iChannel)};
            if ~ismac
                sevFile = convertForWindows(sevFile);
            end
            [meanWaveform, upperStd, lowerStd, windowSize] = aveWaveform(ts,sevFile);
            meanWaveforms(iChannel,:) = meanWaveform;
        end
        if size(meanWaveforms,1) > 1
            waveforms(iNeuron,:) = mean(meanWaveforms);
        else
            waveforms(iNeuron,:) = meanWaveforms;
        end
    end
    
    sameWire = logical(sameWire);
    
    % scrap code
    if false
        figure;
        imagesc(sameWire)
        colormap(bone);
        ylabel('unit');
        xlabel('wire');
        set(gcf,'color','w');
        
        figure;
        for iWaveform = 1:size(waveforms,1)
            subplot(20,20,iWaveform);
            plot(waveforms(iWaveform,:));
            xticklabels({});
            yticklabels({});
        end
        set(gcf,'color','w');
        
        save('sameWires','waveforms','sameWire','wireLabels');
    end
end

function sevFile = convertForWindows(sevFile)
    C = strsplit(sevFile,'/');
    sevFile = fullfile('\\172.20.138.142\RecordingsLeventhal2',C{4:end});
end