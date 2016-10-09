function [tetrodeName,tetrodeId,tetrodeChs] = getTetrodeInfo(s)
% var string tetrodeName
% var double tetrodeId

[a,b] = regexp(s,'_T[0-9]+_');
tetrodeName = s(a+1:b-1);
tetrodeId = str2double(tetrodeName(2:end));

startChs = strfind(s,'[');
endChs = strfind(s,']');
tetrodeChs = s(startChs:endChs);
tetrodeChs = num2str(tetrodeChs);