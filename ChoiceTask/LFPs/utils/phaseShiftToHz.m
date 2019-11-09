function hz = phaseShiftToHz(tWindow,n,phaseVal)
twin = n/(tWindow*2);
hz = (phaseVal * twin) / (2*pi);