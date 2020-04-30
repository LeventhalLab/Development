for ii = 1:numel(analysisConf.sessionConfs)
    electrodes = analysisConf.sessionConfs{ii,1}.session_electrodes;
    if ismember(17,electrodes.channel)
        disp(ii);
    end
end