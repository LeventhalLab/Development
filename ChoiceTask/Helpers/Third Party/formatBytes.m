function r = formatBytes(bytes)
s = {'B', 'KB', 'MB', 'GB', 'TB'}; 
e = floor(log(bytes)/log(1024));
r = sprintf(['%.2f ',s{e+1}], (bytes/(1024^floor(e))));