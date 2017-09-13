function unitClass_thresh = unitClassByThresh(unitEvents,zThresh)

unitClass_thresh = [];
for iUnit = 1:numel(unitEvents)
    unitClass_thresh(iUnit) = NaN;
    if ~isempty(unitEvents{iUnit}.class)
        if unitEvents{iUnit}.maxz(unitEvents{iUnit}.class(1)) >= zThresh
            unitClass_thresh(iUnit) = unitEvents{iUnit}.class(1);
        end
    end
end