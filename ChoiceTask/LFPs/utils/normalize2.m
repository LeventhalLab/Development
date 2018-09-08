function scaledI=normalize2(I,A)
    % normalize I to A
    scaledI = (I-min(I(:))) ./ (max(A(:)-min(A(:))));
end