function tsLTS = filterLTS(tsBurst)
hp = 0.1; %hyperpolarization 100ms
tsLTS = tsBurst(diff(tsBurst) < hp);