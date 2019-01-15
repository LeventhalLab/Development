function workon(openArr)
    % (list) >> workon
    % (open) >> workon(1)
    % (open) >> workon([2,3,6,14])
    % (open) >> workon(1:7)
    
    limitTo = 15; % # of files
    
    workingDir = pwd;
    listing = dir('**/*.m');
    [~,idx] = sort([listing.datenum],'descend');
    
    if ~exist('openArr','var')
        clc;
        headerText = [num2str(limitTo),' MOST RECENT FILES'];
        disp(headerText);
        disp(repmat('-',[1,numel(headerText)]));
        for iFile = 1:limitTo
            disp(['[',num2str(iFile,'%02d'),'] --> ',listing(idx(iFile)).name,...
                ' (',timeAgo(listing(idx(iFile)).datenum),')']);
        end
    else
        for iFile = openArr
            open(fullfile(listing(idx(iFile)).folder,listing(idx(iFile)).name));
        end
    end
end

function str = timeAgo(dateVector)
    timeDiff = now - dateVector;
    daysAgo = timeDiff;
    if daysAgo < 1
        hoursAgo = daysAgo * 24;
        if hoursAgo < 1
            minutesAgo = hoursAgo * 60;
            if minutesAgo < 1
                str = 'now';
            else
                str = [pluralize(minutesAgo,'minute'),' ago'];
            end
        else
            str = [pluralize(hoursAgo,'hour'),' ago'];
        end
    else
        str = [pluralize(daysAgo,'day'),' ago'];
    end
end

function str = pluralize(n,str)
    if n > 1
        str = [num2str(round(n)),' ',str,'s'];
    end
end