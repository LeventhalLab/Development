function [electrodeName,electrodeSite,electrodeChannels] = getElectrodeInfo(s)
% var string electrodeName
% var double electrodeId
% s = 'R0117_20160504a_T23_ch[0 0 0 104]a'
% s = 'R0142_20161208a_R0142_20161208a-1_data_ch1a'
% s = 'R0154_20170221a_R0154_20170221a-1_data_ch[1  3  5  7]a';

[a,b] = regexp(s,'_T[0-9]+');
if ~isempty(a)
    electrodeName = s(a+1:end-1);
    electrodeSite = s(a+2:b);
    startChs = strfind(s,'[');
    endChs = strfind(s,']');
    electrodeChannels = s(startChs+1:endChs-1);
    electrodeChannels = str2num(electrodeChannels);
    electrodeChannels = electrodeChannels(find(electrodeChannels ~= 0));
    return;
end

[a,b] = regexp(s,'_ch[0-9]+');
if ~isempty(a)
    electrodeSite = [];
    electrodeName = s(a+1:end-1);
    electrodeChannels = str2num(s(a+3:b));
    electrodeChannels = electrodeChannels(find(electrodeChannels ~= 0));
    return;
end

[a,b] = regexp(s,'_ch\[[0-9 +]+\]');
if ~isempty(a)
    electrodeSite = [];
    electrodeName = s(a+1:end-1);
    electrodeChannels = str2num(s(a+3:b));
    electrodeChannels = electrodeChannels(find(electrodeChannels ~= 0));
    return;
end