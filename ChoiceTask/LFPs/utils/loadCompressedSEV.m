function [sevFilt,Fs,decimateFactor,loadedFile] = loadCompressedSEV(sevFile,unitId)
compressor = 'x16';
% compressor = 'x16_despiked';

[filepath,name,ext] = fileparts(sevFile);
if isempty(unitId)
    compressedPath = fullfile(filepath,compressor,[name,ext,'.mat']);
else
    compressedPath = fullfile(filepath,compressor,[name,'_u',num2str(unitId,'%03d'),'.mat']);
end
S = load(compressedPath,'sevFilt','Fs','decimateFactor');

sevFilt = S.sevFilt;
Fs = S.Fs;
decimateFactor = S.decimateFactor;
loadedFile = sevFile;