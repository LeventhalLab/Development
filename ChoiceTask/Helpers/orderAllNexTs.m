function tsArr = orderAllNexTs(nexData)
% cue, nose, tone, food, foodport, houselight
eventsOfInterest = [1:14 17:28]; % gotrial 39:40, what does this do?
tsCount = 1;
for ii=1:length(nexData.events)
    if ismember(ii,eventsOfInterest)
        for jj=1:length(nexData.events{ii,1}.timestamps)
            tsArr(tsCount,:) = [ii nexData.events{ii,1}.timestamps(jj)];
            tsCount = tsCount + 1;
        end
    end
end
tsArr = sortrows(tsArr,2);

