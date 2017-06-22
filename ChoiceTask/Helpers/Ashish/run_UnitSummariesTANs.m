startDir = '/Users/ashishkamath/Desktop/Research/TANs in STR Project/R0137';
% change directory as needed
textFiles = dir(fullfile(startDir,'*.txt'));

for iFile = 1:size(textFiles,1)
    fileName = fullfile(startDir,textFiles(iFile).name);
    makeUnitSummariesTANs(fileName);
end
