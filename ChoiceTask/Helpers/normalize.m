function scaledI=normalize(I)
    scaledI = (I-min(I(:))) ./ (max(I(:)-min(I(:))));
end