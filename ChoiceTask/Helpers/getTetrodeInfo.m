function [tetrodeName,tetrodeId] = getTetrodeInfo(s)
% var string tetrodeName
% var double tetrodeId

[a,b] = regexp(s,'_T[0-9]+_');
tetrodeName = s(a+1:b-1);
tetrodeId = str2double(tetrodeName(2:end));
