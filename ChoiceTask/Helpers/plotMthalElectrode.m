function im_dot = plotMthalElectrode(AP,ML,DV,nasPath)
mm_px = 269; % calibrated from atlas
dotSize = round(mm_px / 15);
% force DV to negative
if DV > 0
    DV = DV * -1;
end
atlas_ims = {fullfile(nasPath,'atlas','mthal_naku_lat1-4mm.jpg'),...
    fullfile(nasPath,'atlas','mthal_naku_lat1-9mm.jpg'),...
    fullfile(nasPath,'atlas','mthal_naku_lat2-4mm.jpg')};
atlas_mls = [1.4,1.9,2.4];
% [ap ml x_px y_px]
atlas_cal = [-3.2 -7.2 500.75 901;...
    -3.4 -7.2 596.5 983.75;...
    -3.6 -6.2 502.02 734.16];

% find ML slice
[v,k] = min(abs(atlas_mls - ML));
atlas_im = atlas_ims{k};
im = imread(atlas_im);

% get px location based on AP, DV
cal = atlas_cal(k,:);
rel_ap_mm = AP - cal(1);
rel_dv_mm = DV - cal(2);

rel_ap_px = rel_ap_mm * mm_px;
rel_dv_px = rel_dv_mm * mm_px;

im_dot = insertShape(im,'FilledCircle',[cal(3) - rel_ap_px,cal(4) - rel_dv_px,dotSize],'Color','red');
imshow(im_dot);

