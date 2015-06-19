function tsArr = orderAllNexTs(nexData)
% cue, nose, tone, food, foodport, houselight, go trial
eventsOfInterest = [1:14 17:28 33:36 39:40];
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

