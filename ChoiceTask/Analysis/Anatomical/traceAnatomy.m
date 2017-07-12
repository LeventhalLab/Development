close all;

dommpx = false;
mmpx = 270;

imSources = {'/Volumes/RecordingsLeventhal2/ChoiceTask/atlas/mthal_naku_lat0-9mm.jpg',...
    '/Volumes/RecordingsLeventhal2/ChoiceTask/atlas/mthal_naku_lat1-4mm.jpg',...
    '/Volumes/RecordingsLeventhal2/ChoiceTask/atlas/mthal_naku_lat1-9mm.jpg',...
    '/Volumes/RecordingsLeventhal2/ChoiceTask/atlas/mthal_naku_lat2-4mm.jpg'};

% imSources = {'/Volumes/RecordingsLeventhal2/ChoiceTask/atlas/mthal_naku_lat1-4mm.jpg',...
%     '/Volumes/RecordingsLeventhal2/ChoiceTask/atlas/mthal_naku_lat1-9mm.jpg'};

atlas_mls = [0.9,1.4,1.9,2.4];
% top left corner true AP,DV
atlas_cal = [-1.2,-3.65;-1.2,-3.65;-1,-3.45;-1.5,-3.4];

shps = [];
all_xmm = [];
all_ymm = [];
all_zmm = [];
h1 = figure;
for iSource = 1:numel(imSources)
    imSource = imread(imSources{iSource});
    imshow(imSource);
    if dommpx
        disp('Click 2 points that equal 1 mm...');
        [xs,ys] = ginput(2);
        mmpx = pdist([xs ys]); % pixels in 1 mm
    end
    h = imfreehand;
    mask = h.createMask();
    [y,x] = find(mask);
    if numel(x) > 1000
        xmm = atlas_cal(iSource,1) - (x / mmpx);
        ymm = atlas_cal(iSource,2) - (y / mmpx); % flip dir of y from imshow
        zmm = repmat(atlas_mls(iSource),[numel(ymm) 1]);
        all_xmm = [all_xmm;xmm];
        all_ymm = [all_ymm;ymm];
        all_zmm = [all_zmm;zmm];
    end
end
shp = alphaShape(all_xmm,all_zmm,all_ymm,Inf);
close(h1);