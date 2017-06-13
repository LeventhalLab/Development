function channelData = get_channelData(sessionConf,electrodeChannels)
rows = sessionConf.session_electrodes.channel == electrodeChannels;
channelData = sessionConf.session_electrodes(any(rows')',:);