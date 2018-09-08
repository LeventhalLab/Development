function [sevFilt,Fs,decimateFactor,loadedFile] = loadCompressedSEV(sevFile)
compressor = 'x16';

[filepath,name,ext] = fileparts(sevFile);
compressedPath = fullfile(filepath,compressor,[name,ext,'.mat']);
S = load(compressedPath,'sevFilt','Fs','decimateFactor');

sevFilt = S.sevFilt;
Fs = S.Fs;
decimateFactor = S.decimateFactor;
loadedFile = sevFile;