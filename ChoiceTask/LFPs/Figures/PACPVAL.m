% PACPVAL
% from /Users/mattgaidica/Documents/MATLAB/LeventhalLab/Development/ChoiceTask/LFPs/explore/CanoltyPAC_trialStitched_print.m
if ~exist('MImatrix')
    load('20190416_PACPVAL');
end

close all

figPath = '/Users/mattgaidica/Box Sync/Leventhal Lab/Manuscripts/Mthal LFPs/Figures';
subplotMargins = [.03 .01];

doSave = true;

h = figuree(1200,285);
pThresh = 0.05; % alpha
SE = strel('sphere',1);
zThresh = -norminv(pThresh/(30*30));
pxThresh = 1;
lineWidth = 0.5;
zLims = [0 13];
rows = 2;
cols = numel(eventFieldnames_wFake);

for iEvent = 1:cols
    curMat = squeeze(MImatrix(iEvent,:,:));
    subplot_tight(rows,cols,prc(cols,[1 iEvent]),subplotMargins);
    imagesc(curMat,'AlphaData',~isnan(curMat));
    hold on;
    colormap(gca,jet);
    set(gca,'ydir','normal');
    caxis(zLims);
    xticks([]);
    yticks([]);
    
    % note: z = norminv(alpha/N); N = # of index values
    % %         pMat = normcdf(curMat,'upper')*numel(freqList).^2;
    pMat_thresh = curMat > zThresh;
    pMat_dilated = imdilate(pMat_thresh,SE);
    pMat_filled = imfill(pMat_dilated,'holes');
    B = bwboundaries(pMat_filled);
    stats = regionprops(pMat_thresh,'MajorAxisLength','MinorAxisLength');
    for k = 1:length(B)
        if stats(k).MajorAxisLength > pxThresh && stats(k).MinorAxisLength > pxThresh
            b = B{k};
            % -/+ for x,y was added to fix eps export alignment issue
            plot(b(:,2)-1,b(:,1)+1,'r','linewidth',lineWidth);
        end
    end
    
    curMat = squeeze(shuff_MImatrix_mean(iEvent,:,:));
    subplot_tight(rows,cols,prc(cols,[2 iEvent]),subplotMargins);
    imagesc(curMat,'AlphaData',~isnan(curMat));
    hold on;
    colormap(gca,jet);
    set(gca,'ydir','normal');
    caxis(zLims);
    xticks([]);
    yticks([]);
    
    %         pMat = 1 - squeeze(shuff_MImatrix_pvals(iEvent,:,:));
    pMat_thresh = curMat > zThresh;
    pMat_dilated = imdilate(pMat_thresh,SE);
    pMat_filled = imfill(pMat_thresh,'holes');
    B = bwboundaries(pMat_filled);
    stats = regionprops(pMat_thresh,'MajorAxisLength','MinorAxisLength');
    for k = 1:length(B)
        if stats(k).MajorAxisLength > pxThresh && stats(k).MinorAxisLength > pxThresh
            b = B{k};
            % -/+ for x,y was added to fix eps export alignment issue
            plot(b(:,2)-1,b(:,1)+1,'r','linewidth',lineWidth);
        end
    end
end

tightfig;
set(gcf,'color','w');
if doSave
    setFig('','',[2,1.75]);
    print(gcf,'-painters','-depsc',fullfile(figPath,'PACPVAL.eps'));
    close(h);
end
