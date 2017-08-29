function CV = coeffVar(ts)
CV = std(diff(ts)) / mean(diff(ts));