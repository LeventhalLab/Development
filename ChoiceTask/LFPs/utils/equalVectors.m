function d1new = equalVectors(d1,d2)
% d1new is the length of d2
d1new = interp1(1:numel(d1),d1,linspace(1,numel(d1),numel(d2)));