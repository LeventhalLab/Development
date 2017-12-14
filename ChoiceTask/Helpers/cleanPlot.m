function cleanPlot()
% remove everything that smells like text
c = findall(gcf,'Type','text');

% set all C
if ~isempty(c)
    set(c,'visible','off')
    disp('switching text off!')
end

set(gca, 'xticklabel', []);
set(gca, 'yticklabel', []);
set(gca, 'zticklabel', []); % if they exist

title([]);