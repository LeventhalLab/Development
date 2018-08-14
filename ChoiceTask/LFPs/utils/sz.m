function szArr = sz(A,dims)

szArr = [];
for iDim = 1:numel(dims)
    szArr(iDim) = size(A,dims(iDim));
end