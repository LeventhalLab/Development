function ts = compressTs(ts,refractoryThresh)

ts = ts(diff(ts) > refractoryThresh);