% do the spike sorting, export to NEX files
% 
%%%%% Step 1: Extract on-off laser times
% select ch68 for your session
[sev,header] = ezSEV();
% find laser on/off times
thresh = 1e6;
crossings = sev > thresh;
laserOn = find(diff(crossings) > 0) / round(header.Fs); %seconds
laserOff = find(diff(crossings) < 0) / round(header.Fs); %seconds
% show you
figure;hold on;
plot(linspace(0,length(sev)/header.Fs,length(sev)),sev);
plot(laserOn,ones(1,length(laserOn))*thresh,'o');
plot(laserOff,ones(1,length(laserOff))*thresh,'x');
xlabel('time (s)');
ylabel('laser (Vo)');
title('Laser on/off (ch68)');

% are these the same? should be!
disp([num2str(length(laserOn)),' laser on epochs.']);
disp([num2str(length(laserOff)),' laser off epochs.']);
%%%%%


%%%% Step 2: Bring in spike data from NEX file
% select all your NEX files (exported from Offline Sorter)
[filenames, pathname, filterindex] = uigetfile('*.nex','Pick a file','MultiSelect', 'on');
if ~iscell(filenames)
    t = {};
    t{1} = filenames;
    filenames = t;
end
pethHalfWidth = 10; %seconds
binSize = 50;
allTs = {};
totalUnits = 1;
for iFiles=1:length(filenames)
    [nvar, names, types] = nex_info(fullfile(pathname,filenames{iFiles}));
    names = cellstr(names);
    % how many units?
    unitCount = length(cell2mat(regexp(names,'(T\d+)_(W\d+[abcdefg]$)')));
    for iUnit=1:unitCount
        pethEntries = [];
        unitName = names{iUnit};
        [n, ts] = nex_ts(fullfile(pathname,filenames{iFiles}),names{iUnit});
        for iOnOff=1:length(laserOn)
            % find timestamps centered about laserOn
            tsFitCriteria = find(ts > laserOn(iOnOff)-pethHalfWidth  & ts < laserOn(iOnOff)+pethHalfWidth);
            % subtract starting value to center ts entries
            if ~isempty(tsFitCriteria)
                pethEntries = [pethEntries ts(tsFitCriteria) - laserOn(iOnOff)];
            end
        end
        allTs{totalUnits} = {ts,unitName};
        totalUnits = totalUnits + 1;
        
        figure;
        hist(pethEntries,binSize);
        xlabel('time (s)');
        ylabel('spikes');
        title([strrep(names(iUnit),'_','-')]);
        disp(length(pethEntries));
    end
end
%%%%%
% 
% [sevPd,header] = ezSEV();
% fdata=wavefilter(sev,6);
% figure;plot(fdata)
% hold on
% plot(sevPd/100000,'r')

% allTsArr = {};
% for ii=1:length(allTs)
%     allTsArr{ii} = allTs{1,ii}{1};
% end
% figure;
% plotSpikeRaster(allTsArr,'PlotType','vertline');
% hold on;
% for ii=1:length(laserOn)
%     p = patch([laserOn(ii) laserOff(ii) laserOff(ii) laserOn(ii)],[0 0 length(allTsArr)+1 length(allTsArr)+1],'g');
%     set(p,'EdgeColor','none','FaceAlpha',0.1);
% end

for jj=1:length(allTsArr)
    targetUnit = jj;
    targetUnitSpikes = allTsArr{targetUnit};
    spikeOnCount = 0;
    timeOn = 0;
    for ii=1:length(laserOn)
        spikeOnCount = sum([spikeOnCount,...
            length(find(targetUnitSpikes > laserOn(ii) & targetUnitSpikes < laserOff(ii)))]);
        timeOn = sum([timeOn,laserOff(1)-laserOn(1)]);
    end
    timeOff = max(targetUnitSpikes)-timeOn; %estimated by last spike time
    spikeOffCount = length(targetUnitSpikes)-spikeOnCount;
    figure;
    bar([spikeOffCount/timeOff,spikeOnCount/timeOn]);
    ylabel('spikes/s');
    xlabel('laser off / laser on');
    title(['Unit ',num2str(jj)]);
end
