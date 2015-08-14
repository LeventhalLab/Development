function [neuronID,neuronCh] = getNeuronID(sessionConf, whichNeuron)
    if whichNeuron(1) == 'T'
        tetrodeNum = str2num(whichNeuron(2:3)) ;
        tetrodeChannels = sessionConf.validMasks.*sessionConf.chMap(:,2:end);
        tetrodeIdx = find(tetrodeChannels(tetrodeNum,:)>0);
        neuronCh = sessionConf.chMap(tetrodeNum,tetrodeIdx(1)+1) 
    else
        neuronCh = str2num(whichNeuron(1:3))
    end
    neuronID = [sessionConf.sessionName '_' whichNeuron]
end