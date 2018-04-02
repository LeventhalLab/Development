% figuree(1200,300);

covMatrix = [];
for iNeuron = 1:numel(nexStruct.neurons)
    ts = nexStruct.neurons{iNeuron,1}.timestamps;
    s = spikeDensityEstimate(ts);
    sZ = (s - mean(s)) / std(s);
    covMatrix(1:numel(sZ),iNeuron) = sZ;
end
        
% A is a matrix whose columns represent random variables and whose rows represent observations
% C is the covariance matrix with the corresponding column variances along the diagonal.
C = cov(covMatrix);
% find the eigenvectors and eigenvalues
[PC, V] = eig(C);
% extract diagonal of matrix as vector
V = diag(V);
% sort the variances in decreasing order
[~,k] = sort(-1*V);
V = V(k);
PC = PC(:,k);