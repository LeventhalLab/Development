function [eventNames] = nexs_getEvents(nexStruct)
eventNames = {};
if(isfield(nexStruct,'events'))
    eventNames = cell(length(nexStruct.events),1);
    for ii=1:length(nexStruct.events)
        eventNames{ii} = nexStruct.events{ii}.name;
    end
end