function all_cv = test_zParams(all_ts,all_trials)

all_cv = [];
for iNeuron = 1:numel(all_ts)
    disp([num2str(iNeuron),'/',num2str(numel(all_ts)]));
    z = zParams(all_ts{iNeuron},all_trials{iNeuron});
    all_cv(iNeuron) = z.CV;
end