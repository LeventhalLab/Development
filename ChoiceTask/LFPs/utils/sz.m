% output a variable's size using >> sz
w = whos;
findvar = clipboard('paste');
ii = strcmp({w.name},findvar);
if any(ii)
    w(ii).size
else
    disp(sprintf("\nNo variable '%s'\n",findvar));
end
clearvars('-except',w(:).name);