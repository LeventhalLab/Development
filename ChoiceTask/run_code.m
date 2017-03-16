for ii=[5 6 7 8 9 10 11 12]
    sessions__name = ['R0142_201612',num2str(ii,'%02d'),'a'];
    sessionConf = exportSessionConfv2(sessions__name,'nasPath',nasPath);
    nexData = TDTtoNex(sessionConf);
end