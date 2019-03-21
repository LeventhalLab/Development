function d1new = equalVectors(d1,d2)
% d1new is the 'dimension' of d2
nd2 = numel(d2);
if isscalar(d2)
    nd2 = d2;
end
d1new = interp1(1:numel(d1),d1,linspace(1,numel(d1),nd2));