function coeffVar = coeffVar(ts)
coeffVar = std(diff(ts)) / mean(diff(ts));