function nexData = TDTtoNexSR()
%
% usage:
%
%this function converts TDTtank files into a nex file
%output nexData.data with all header fields from the tsq file
%       nexData.raw represents all the fields from the raw data
%       nexData.events represents all the events that we recorded in
%       box2nex script
% plus the usual nex field: 
%       nexData.version
% 		nexData.comment 
% 		nexData.freq
% 		nexData.tbeg
% 		nexData.events
% 	    nexData.tbeg
%
% INPUTS:
%   tevName - name of the .tev file to use
%   tsqName - name of the .tsq file to use
%
% OUTPUTS:
%   none

% 
% leventhalPaths = buildLeventhalPaths(sessionConf,{'processed'});
% 
% tevInfo = dir(fullfile(leventhalPaths.rawdata,'*.tev'));
% if isempty(tevInfo)
%     error('TDTtoNex_20141204:noTevFile', ['no tev file found for session ' sessionConf.sessionName]);
% end
% if length(tevInfo) > 1
%     error('TDTtoNex_20141204:multipleTevFiles', ['more than one tev file found for session ' sessionConf.sessionName]);
% end
% tsqInfo = dir(fullfile(leventhalPaths.rawdata,'*.tsq'));
% if isempty(tsqInfo)
%     error('TDTtoNex_20141204:noTsqFile', ['no tsq file found for session ' sessionConf.sessionName]);
% end
% if length(tsqInfo) > 1
%     error('TDTtoNex_20141204:multipleTsqFiles', ['more than one tsq file found for session ' sessionConf.sessionName]);
% end
[f1,p1] = uigetfile({'*.tev'})
[f2,p2] = uigetfile({'*.tsq'})

tevName = fullfile(p1,f1);
tsqName = fullfile(p2,f2);

%store_id2 = 'Vide';
store_id = 'Wave';  % this is just an example
tev = fopen(tevName);
tsq = fopen(tsqName); fseek(tsq, 0, 'eof'); ntsq = ftell(tsq)/40; fseek(tsq, 0, 'bof');

%read from tsq
nexData.data.size      = fread(tsq, [ntsq 1], 'int32',  36); fseek(tsq,  4, 'bof');
nexData.data.type      = fread(tsq, [ntsq 1], 'int32',  36); fseek(tsq,  8, 'bof');
nexData.data.name      = fread(tsq, [ntsq 1], 'uint32', 36); fseek(tsq, 12, 'bof');
nexData.data.chan      = fread(tsq, [ntsq 1], 'ushort', 38); fseek(tsq, 14, 'bof');
nexData.data.sortcode  = fread(tsq, [ntsq 1], 'ushort', 38); fseek(tsq, 16, 'bof');
nexData.data.timestamp = fread(tsq, [ntsq 1], 'double', 32); fseek(tsq, 24, 'bof');
nexData.data.fp_loc    = fread(tsq, [ntsq 1], 'int64',  32); fseek(tsq, 24, 'bof');
nexData.data.strobe    = fread(tsq, [ntsq 1], 'double', 32); fseek(tsq, 32, 'bof');
nexData.data.format    = fread(tsq, [ntsq 1], 'int32',  36); fseek(tsq, 36, 'bof');
nexData.data.frequency = fread(tsq, [ntsq 1], 'float',  36);

% nexData2.data.size      = fread(tsq, [ntsq 1], 'int32',  36); fseek(tsq,  4, 'bof');
% nexData2.data.type      = fread(tsq, [ntsq 1], 'int32',  36); fseek(tsq,  8, 'bof');
% nexData2.data.name      = fread(tsq, [ntsq 1], 'uint32', 36); fseek(tsq, 12, 'bof');
% nexData2.data.chan      = fread(tsq, [ntsq 1], 'ushort', 38); fseek(tsq, 14, 'bof');
% nexData2.data.sortcode  = fread(tsq, [ntsq 1], 'ushort', 38); fseek(tsq, 16, 'bof');
% nexData2.data.timestamp = fread(tsq, [ntsq 1], 'double', 32); fseek(tsq, 24, 'bof');
% nexData2.data.fp_loc    = fread(tsq, [ntsq 1], 'int64',  32); fseek(tsq, 24, 'bof');
% nexData2.data.strobe    = fread(tsq, [ntsq 1], 'double', 32); fseek(tsq, 32, 'bof');
% nexData2.data.format    = fread(tsq, [ntsq 1], 'int32',  36); fseek(tsq, 36, 'bof');
% nexData2.data.frequency = fread(tsq, [ntsq 1], 'float',  36);

%typecast Store ID (such as 'Wave') to number
name = 256.^(0:3)*double(store_id)';
%name2 = 256.^(0:3)*double(store_id2)';

%row2 = (name2 == nexData2.data.name);
row = (name == nexData.data.name);

table = { 'float',  1, 'float';
'long',   1, 'int32';
'short',  2, 'short';
'byte',   4, 'schar'; }; % a look-up table

first_row = find(1==row,1);
%first_row2 = find(1==row2,1);

format = nexData.data.format(first_row)+1; % from 0-based to 1-based
%format2 = nexData.data.format(first_row2)+1; % from 0-based to 1-based

nexData.raw.format = table{format,1};
nexData.raw.sampling_rate = nexData.data.frequency(first_row);
nexData.raw.chan_info = [nexData.data.timestamp(row) nexData.data.chan(row)];

% nexData2.raw.format = table{format2,1};
% nexData2.raw.sampling_rate = nexData.data.frequency(first_row2);
% nexData2.raw.chan_info = [nexData2.data.timestamp(row2) nexData2.data.chan(row2)];

fp_loc  = nexData.data.fp_loc(row);
% fp_loc2  = nexData.data.fp_loc(row2);

nsample = (nexData.data.size(row)-10) * table{format,2};
% nsample2 = (nexData.data.size(row2)-10) * table{format2,2};

nexData.raw.sample_point = NaN(length(fp_loc),max(nsample));
% nexData2.raw.sample_point = NaN(length(fp_loc2),max(nsample2));

for n=1:length(fp_loc)
    fseek(tev,fp_loc(n),'bof');
    nexData.raw.sample_point(n,1:nsample(n)) = fread(tev,[1 nsample(n)],table{format,3});
end


%% TTL/Event Breakdown 

% %EventlineNum       TTL
% 33                    TTL1on actuator pos 1(all the way down)
% 34                    TTL1off actuator pos 1(all the way down)
% 41                    TTL2on actuator pos 2(pellet loaded but not fully extended)
% 42                    TTL2on actuator pos 2(pellet loaded but not fully extended)
% 7                     TTL3on actuator pos 3(pellet all the way up after triggered by ir)
% 8                     TTL3off actuator pos 3(pellet all the way up after triggered by ir)
% 9                     TTL4on Back IR sensor triggered
% 10                    TTL4off Back IR sensor triggered
% 43                    TTL5on Frame Triggered
% 44                    TTL5off Frame Trigger
% 25                    TTL6on GreenVideo Trigger
% 26                    TTL6on GreenVideo Trigger



linenames = {'A0','A0off','A1','A1off','A2','A2off','TTL3on','TTL3off',...
    'TTL4on','TTL4off','A5','A5off','A6','A6off','A7','A7off',...
    'B0','B0off','B1','B1off','B2','B2off','B3','B3off',...
    'TTL6on','TTL6off','B5','B5off','B6','B6off','B7','B7off',...
    'TTL1on','TTL1off','C1','C1off','C2','C2off','C3','C3off',...
    'TTL2on','TTL2off','TTL5on','TTL5off','C6','C6off','C7','C7off'};


% Set up the NEX file data structure
nexData.version = 1;
nexData.comment = 'Converted TDTtoNex. Alex Zotov, Matt Gaidica.';
nexData.freq = 24414;
nexData.tbeg = 0;
nexData.events = {}; %nb
nexData.tbeg = nexData.data.timestamp(2);
        
for ii=1:length(linenames)
   nexData.events{ii}.name= linenames{ii};
   nexData.events{ii}.timestamps = [];
end 

% for ii=1:length(linenames)
%    nexData2.events{ii}.name= linenames{ii};
%    nexData2.events{ii}.timestamps = [];
% end 
    
channelCount=ones(128,1);    
    %read bits lines to get the nex file
for i_ts = 0 : (length(nexData.raw.chan_info)-1)
    if i_ts==0
        switched_bits =  [bitget(16777215, 1:32);bitget(nexData.raw.sample_point(1), 1:32)];
        bitsDiff = switched_bits(1,:)-switched_bits(2,:);
        linesOn = find(bitsDiff==1);
        linesOff = find(bitsDiff==-1);
        if ~isempty(linesOn)
            for j=1:length(linesOn)
                nexData.events{(2*linesOn((j)))-1}.timestamps(channelCount((2*linesOn((j)))-1),1) = nexData.raw.sample_point(1)-nexData.data.timestamp(2);
                channelCount((2*linesOn((j)))-1) = channelCount((2*linesOn((j)))-1) +1;
            end
        end
    
        if ~isempty(linesOff)
            for k=1:length(linesOff)
                nexData.events{2*linesOff(k)}.timestamps(channelCount(2*linesOff(k)),1) = nexData.raw.sample_point(1)-nexData.data.timestamp(2);
                channelCount(2*linesOff(k)) = channelCount(2*linesOff(k))+1;
            end
        end
    else
        switched_bits =  [bitget(nexData.raw.sample_point(i_ts), 1:32);bitget(nexData.raw.sample_point(i_ts+1), 1:32)];
        bitsDiff = switched_bits(1,:)-switched_bits(2,:);
        linesOn = find(bitsDiff==1);
        linesOff = find(bitsDiff==-1);
        if ~isempty(linesOn)
            for j=1:length(linesOn)
                nexData.events{(2*linesOn((j)))-1}.timestamps(channelCount((2*linesOn((j)))-1),1) = nexData.raw.chan_info(i_ts+1)-nexData.data.timestamp(2);
                channelCount((2*linesOn((j)))-1) = channelCount((2*linesOn((j)))-1) +1;
            end
        end
    
        if ~isempty(linesOff)
            for k=1:length(linesOff)
                nexData.events{2*linesOff(k)}.timestamps(channelCount(2*linesOff(k)),1) = nexData.raw.chan_info(i_ts+1)-nexData.data.timestamp(2);
                channelCount(2*linesOff(k)) = channelCount(2*linesOff(k))+1;
            end
        end
    end
end

% for i_ts = 0 : (length(nexData2.raw.chan_info)-1)
%     if i_ts==0
%         switched_bits = [bitget(16777215, 1:32);bitget(nexData2.raw.sample_point(1), 1:32)];
%         bitsDiff = switched_bits(1,:)-switched_bits(2,:);
%         linesOn = find(bitsDiff==1);
%         linesOff = find(bitsDiff==-1);
%         if ~isempty(linesOn)
%             for j=1:length(linesOn)
%                 nexData2.events{(2*linesOn((j)))-1}.timestamps(channelCount((2*linesOn((j)))-1),1) = nexData2.raw.sample_point(1)-nexData.data.timestamp(2);
%                 channelCount((2*linesOn((j)))-1) = channelCount((2*linesOn((j)))-1) +1;
%             end
%         end
%     
%         if ~isempty(linesOff)
%             for k=1:length(linesOff)
%                 nexData2.events{2*linesOff(k)}.timestamps(channelCount(2*linesOff(k)),1) = nexData2.raw.sample_point(1)-nexData.data.timestamp(2);
%                 channelCount(2*linesOff(k)) = channelCount(2*linesOff(k))+1;
%             end
%         end
%     else
%         switched_bits =  [bitget(nexData2.raw.sample_point(i_ts), 1:32);bitget(nexData2.raw.sample_point(i_ts+1), 1:32)];
%         bitsDiff = switched_bits(1,:)-switched_bits(2,:);
%         linesOn = find(bitsDiff==1);
%         linesOff = find(bitsDiff==-1);
%         if ~isempty(linesOn)
%             for j=1:length(linesOn)
%                 nexData2.events{(2*linesOn((j)))-1}.timestamps(channelCount((2*linesOn((j)))-1),1) = nexData2.raw.chan_info(i_ts+1)-nexData.data.timestamp(2);
%                 channelCount((2*linesOn((j)))-1)= channelCount((2*linesOn((j)))-1) +1;
%             end
%         end
%     
%         if ~isempty(linesOff)
%             for k=1:length(linesOff)

%                 nexData2.events{2*linesOff(k)}.timestamps(channelCount(2*linesOff(k)),1) = nexData2.raw.chan_info(i_ts+1)-nexData.data.timestamp(2);
%                 channelCount(2*linesOff(k)) = channelCount(2*linesOff(k))+1;
%             end
%         end
%     end
% end

%nexData.events{47}.name = 'videoOn';
%nexData.events{48}.name = 'videoOff';
%nexData.events{47}.timestamps = nexData2.events{51}.timestamps;
%nexData.events{48}.timestamps = nexData2.events{52}.timestamps;

nexData.events = nexData.events';
nexData.tend = nexData.raw.chan_info(end,1);
filePath = uigetdir()
save([filePath,'.mat'],'nexData','-v7.3');
writeNexFile(nexData);
fclose(tev);
fclose(tsq);