function [idx, val] = closest(testArr,val)

tmp = abs(testArr - val);
[~, idx] = min(tmp);
val = testArr(idx);