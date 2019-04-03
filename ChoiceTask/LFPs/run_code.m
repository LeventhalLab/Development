for iNeuron = 1:size(all_acors,1)
    data = squeeze(all_acors(iNeuron,1,:,:));
    
    if sum(isnan(data(:))) > 0
        disp(num2str(iNeuron));
        sum(isnan(data(:)))
    end
end