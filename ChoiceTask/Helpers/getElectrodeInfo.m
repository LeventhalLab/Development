function [electrodeName,electrodeSite,electrodeChannels] = getElectrodeInfo(s)
% var string electrodeName
% var double electrodeId

[a,b] = regexp(s,'_T[0-9]+_');
electrodeName = s(a+1:b-1);
electrodeSite = str2double(electrodeName(2:end));

startChs = strfind(s,'[');
endChs = strfind(s,']');
electrodeChannels = s(startChs+1:endChs-1);
electrodeChannels = str2num(electrodeChannels);