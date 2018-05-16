neuronCount = 0;
posNeg = [];
for iNeuron = 1:numel(unitEvents)
    if ismember(iNeuron,removeUnits)
        continue;
    end
    neuronCount = neuronCount + 1;
    cur_unitEvents = unitEvents{iNeuron};
    if ~isempty(cur_unitEvents.maxz)
        if cur_unitEvents.maxz(cur_unitEvents.class(1)) > 0
            posNeg(iNeuron) = 1;
        else
            posNeg(iNeuron) = -1;
        end
    end
end

posUnits = numel(find(posNeg == 1));
negUnits = numel(find(posNeg == -1));
disp(['pos Z units: ',num2str(posUnits)]);
disp(['neg Z units: ',num2str(negUnits)]);
disp([num2str(posUnits/neuronCount),' based on pos Z-score']);