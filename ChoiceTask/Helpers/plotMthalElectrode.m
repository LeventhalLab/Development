function [atlas_ims,k] = plotMthalElectrode(atlas_ims,AP,ML,DV,nasPath,dotColor,dotSize_mm)
mm_px = 269; % calibrated from atlas
if isempty(dotSize_mm)
    % dotSize = round(mm_px / 25);
    dotSize = 8;
else
    dotSize = mm_px * dotSize_mm;
end
atlas_mls = [1.4,1.9,2.4];
% [ap ml x_px y_px]
atlas_cal = [-3.2 -7.2 500.75 901;...
    -3.4 -7.2 596.5 983.75;...
    -3.6 -6.2 502.02 734.16];

% force DV to negative
if DV > 0
    DV = DV * -1;
end
if isempty(dotColor)
    dotColor = 'red';
end
if ~ischar(dotColor)
    dotColor = dotColor * 255;
end

atlas_im_paths = {fullfile(nasPath,'atlas','mthal_naku_lat1-4mm.jpg'),...
    fullfile(nasPath,'atlas','mthal_naku_lat1-9mm.jpg'),...
    fullfile(nasPath,'atlas','mthal_naku_lat2-4mm.jpg')};

if isempty(atlas_ims)
    for ii = 1:numel(atlas_im_paths)
        atlas_ims{ii} = imread(atlas_im_paths{ii});
    end
end

[~,k] = min(abs(atlas_mls - ML));
im = atlas_ims{k};

% get px location based on AP, DV
cal = atlas_cal(k,:);
rel_ap_mm = AP - cal(1);
rel_dv_mm = DV - cal(2);

rel_ap_px = rel_ap_mm * mm_px;
rel_dv_px = rel_dv_mm * mm_px;

im_dot = insertShape(im,'FilledCircle',[cal(3) - rel_ap_px,cal(4) - rel_dv_px,dotSize],'Color',dotColor,'Opacity',1);
atlas_ims{k} = im_dot;
