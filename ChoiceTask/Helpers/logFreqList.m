function freqList = logFreqList(fpass,nFreqs)
freqList = exp(linspace(log(fpass(1)),log(fpass(2)),nFreqs));