function D = getDist(z)
    x = z{1};
    y = z{2};
    D = [];

    for iFrame = 1:numel(x)-1
        p1 = [x(iFrame),y(iFrame)];
        p2 = [x(iFrame+1),y(iFrame+1)];
        D(iFrame) = sqrt((p2(1)-p1(1))^2 + (p2(2)-p1(2))^2);
    end
end