function [all_trials,all_ts] = compileCT(analysisConf)
% The minimum viable product compiled in a 'sandbox' to keep things clean

% --- analysisConf
% nasPath = '/Volumes/RecordingsLeventhal2/ChoiceTask';
% analysisConf = exportAnalysisConfv2('R0088',nasPath);

% --- reference
% pretone = centerIn -> tone
% RT = cue -> centerOut
% MT = centerOut -> sideIn

all_trials = {};
all_ts = {};

for iNeuron = 1:size(analysisConf.neurons,1)
    neuronName = analysisConf.neurons{iNeuron};
    % only load different sessions
    if ~exist('sessionConf','var') || ~strcmp(sessionConf.sessions__name,analysisConf.sessionConfs{iNeuron})
        sessionConf = analysisConf.sessionConfs{iNeuron};
        % load nexStruct.. I don't love using 'load'
        nexMatFile = [sessionConf.leventhalPaths.nex,'.mat'];
        if exist(nexMatFile,'file')
            load(nexMatFile);
        else
            error('No NEX .mat file');
        end
    end
    
    logFile = getLogPath(sessionConf.leventhalPaths.rawdata);
    logData = readLogData(logFile);
    if strcmp(neuronName(1:5),'R0154')
        nexStruct = fixMissingEvents(logData,nexStruct);
    end
    trials = createTrialsStruct_simpleChoice(logData,nexStruct);
    [~,name,~] = fileparts(nexMatFile);
    % load timestamps for neuron
    for iNexNeurons = 1:length(nexStruct.neurons)
        if strcmp(nexStruct.neurons{iNexNeurons}.name,analysisConf.neurons{iNeuron})
            disp([name,'~> ts ~> ',nexStruct.neurons{iNexNeurons}.name]);
            ts = nexStruct.neurons{iNexNeurons}.timestamps;
        end
    end
    
    all_trials{iNeuron} = trials;
    all_ts{iNeuron} = ts;
end