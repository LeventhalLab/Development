function [adjrsqaure_mat,rmse_mat,timing_mat,actualIdx_mat,rt_reciprobit] = fitReciprobit(all_rt)
rt_reciprobit = sort(all_rt(all_rt > 0)); % can't fit -Inf

iRow = 1;
iCol = 1;

% % adjrsqaure_mat = zeros(numel(rt));
% % rmse_mat = zeros(numel(rt));
for ii = 1:10:numel(rt_reciprobit)
    for jj = ii:10:numel(rt_reciprobit)
        disp(num2str(jj));
        if ii == jj; continue; end
%         adjrsqaure_mat(ii,jj) = 1;
        rtMs = rt_reciprobit(ii:jj) * 1000;
        rtinv  = 1./rtMs;
        x = -1./sort((rtMs)); % multiply by -1 to mirror abscissa
        n = numel(rtinv) + 1; % number of data points
        y = pa_probit((1:n)./n); % cumulative probability for every data point converted to probit scale
        y = y(1:end-1);
        [f,gof] =  fit(x',y','poly1'); % can't fit Inf
        adjrsqaure_mat(iRow,iCol) = gof.adjrsquare;
        rmse_mat(iRow,iCol) = gof.rmse;
        timing_mat(iRow,iCol) = (max(rtMs) - min(rtMs)) / 1000;
        actualIdx_mat{iRow,iCol} = [ii,jj];
        iCol = iCol + 1;
    end
    iCol = 1;
    iRow = iRow + 1;
end

figure;
imagesc(adjrsqaure_mat);
colormap jet;
title('adjrsqaure_mat');
colorbar;

figure;
imagesc(timing_mat);
colormap jet;
title('timing_mat');
colorbar;

figure;
imagesc(rmse_mat);
colormap jet;
title('rmse_mat');
colorbar;

[max_val,max_idx] = max(adjrsqaure_mat(:))
[r,c]=ind2sub(size(adjrsqaure_mat),max_idx)