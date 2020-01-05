% entrain_all_alpha 2 x 366
% load('session_20181218_highresEntrainment.mat','dirSelUnitIds','ndirSelUnitIds','primSec')
% % % % close all
% % % % ff(800,800);
% % % % for iIn = 1:2
% % % %     for iDir = 1:2
% % % %         if iDir == 1
% % % %             useUnits = dirSelUnitIds;
% % % %         else
% % % %             useUnits = ndirSelUnitIds;
% % % %         end
% % % %         allAlpha = [];
% % % %         for iUnit = 1:numel(useUnits)
% % % %             theseAlpha = entrain_all_alpha{iIn,iUnit};
% % % %             if ~isempty(theseAlpha)
% % % %                 allAlpha = [allAlpha;theseAlpha];
% % % %             end
% % % %         end
% % % %         subplot(2,2,prc(2,[iIn,iDir]));
% % % %         polarhistogram(allAlpha,linspace(-pi,pi,13));
% % % %         pval = circ_rtest(allAlpha);
% % % %         str = sprintf('iIn: %i, iDir: %i, %0.2d',iIn,iDir,pval);
% % % %         title(str);
% % % %     end
% % % % end

close all
ff(800,800);
iSurr = 1;
for iIn = 1:2
    for iDir = 1:2
        if iDir == 1
            useUnits = dirSelUnitIds;
        else
            useUnits = ndirSelUnitIds;
        end
        alpha = squeeze(entrain_mus(iSurr,iIn,useUnits,1));
        alpha(isnan(alpha)) = [];
        pval = circ_rtest(alpha);
        subplot(2,2,prc(2,[iIn,iDir]));
        polarhistogram(alpha,linspace(-pi,pi,13));
        str = sprintf('iIn: %i, iDir: %i, %0.2d',iIn,iDir,pval);
        title(str);
    end
end