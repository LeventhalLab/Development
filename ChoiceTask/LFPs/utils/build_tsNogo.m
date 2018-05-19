all_tsNogo = {};
for iFile = 1:numel(LFPfiles)
    sevFile = LFPfiles{iFile};
    disp(sevFile);
    all_tsNogo{iFile} = detectArtifacts(sevFile);
end