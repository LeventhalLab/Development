% dirSelNeuronsNO_type_correct
% dirSelNeuronsNO_type_incorrect

useUnits = find(dirSelNeuronsNO_type_incorrect==1 | dirSelNeuronsNO_type_incorrect==2);
[dirSelNeuronsNO_type_correct(useUnits) dirSelNeuronsNO_type_incorrect(useUnits)]

neuronCount = 0;
sameCodingCount = 0;
for iNeuron = 1:numel(analysisConf.neurons)
    if dirSelNeuronsNO_type_correct(iNeuron) ~= 0 && dirSelNeuronsNO_type_incorrect(iNeuron) ~= 0
        neuronCount = neuronCount + 1;
        if dirSelNeuronsNO_type_correct(iNeuron) == dirSelNeuronsNO_type_incorrect(iNeuron)
            sameCodingCount = sameCodingCount + 1;
        end
    end
end

neuronCount
sameCodingCount

(sameCodingCount / neuronCount) * 100