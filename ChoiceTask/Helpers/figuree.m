function h = figuree(varargin)
xpos = 0;
ypos = 0;
screensize = get(groot,'Screensize');
if isempty(varargin)
    h = figure('position',screensize);
elseif numel(varargin) == 1
    h = figure('position',[0 0 varargin{1} screensize(4)]);
elseif numel(varargin) == 2
    h = figure('position',[0 0 varargin{1} varargin{2}]);
else
    h_width = varargin{1};
    h_height = varargin{2};
    rnd1 = screensize(3) - h_width;
    rnd2 = screensize(4) - h_height;
    h = figure('position',[randi([0 rnd1]) randi([0 rnd2]) h_width h_height]);
end
