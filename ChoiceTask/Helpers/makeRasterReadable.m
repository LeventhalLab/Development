function data=makeRasterReadable(data,n)
for ii=1:size(data,1)
    if numel(data{ii,1}) > n
        data{ii,1} = randsample(data{ii,1},n);
    end
end