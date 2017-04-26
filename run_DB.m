conn = establishConn;
qry = 'select * from eib_electrodes;';
T = fetch2(conn,qry,'subject name not found');


% % for iid = 1:size(T,1)
% %     qry = ['update session_electrodes set session_electrodes.eib_site = ',num2str(T.site(iid)),...
% %         ' where session_electrodes.eib_electrodes_id = ',num2str(T.id(iid))];
% %     fetch2(conn,qry,'subject name not found');
% % end
% % 
% % close(conn);