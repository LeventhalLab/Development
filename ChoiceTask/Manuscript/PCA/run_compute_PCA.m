for iSession = 1:numel(sessionPCA)

    all_event_coeff = [];
    all_event_explained = [];

    for iEvent = 1:size(sessionPCA(iSession).PCA_arr,1)
        covMatrix = squeeze(sessionPCA(iSession).PCA_arr(iEvent,:,:))'; % +/- SDE data x neurons
        [coeff,score,latent,~,explained,mu] = pca(covMatrix);

        % A is a matrix whose columns represent random variables and whose rows represent observations
        % C is the covariance matrix with the corresponding column variances along the diagonal.
    % %     C = cov(covMatrix);
        % find the eigenvectors and eigenvalues
    % %     [PC,V] = eig(C);
        % extract diagonal of matrix as vector
    % %     V = diag(V);
        % sort the variances in decreasing order
    % %     [~,k] = sort(-1*V);
    % %     V = V(k);
    % %     PC = PC(:,k);
        % project the original data set
    % %         signals = PC'*data;
    % %     all_event_C(iEvent,:) = C;
    % %     all_event_V(iEvent,:) = V;
        all_event_coeff(iEvent,:,:) = coeff;
        all_event_explained(iEvent,:) = explained;
    end

    sessionPCA(iSession).coeff = all_event_coeff;
    sessionPCA(iSession).explained = all_event_explained;

end