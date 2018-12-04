function pstring = pstar(pval)
if pval < .001
    pstring = '***';
elseif pval < .01
    pstring = '**';
elseif pval < .05
    pstring = '*';
else
    pstring = 'N.S.';
end