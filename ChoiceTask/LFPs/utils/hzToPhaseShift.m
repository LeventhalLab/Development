function pha = hzToPhaseShift(tWindow,n,hz)
pha = (2*pi)/(n/(tWindow*2)/hz);