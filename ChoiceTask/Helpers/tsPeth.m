function tsPeth = tsPeth(ts,tsCenter,tsWindow)
tsPeth = [];
if ~isempty(ts)
    tsPeth = ts(ts < tsCenter + tsWindow & ts >= tsCenter - tsWindow)' - tsCenter;
end