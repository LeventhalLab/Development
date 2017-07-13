shapes = {thal_vm,thal_va,thal_vl,thal_rt};
all_colors = {'r','g','b','y'};

figuree(800,800);
for iShape = 1:numel(shapes)
    h = plot(shapes{iShape});
    h.FaceLighting = 'gouraud';
    h.AmbientStrength = 0.3;
    h.DiffuseStrength = 0.8;
    h.SpecularStrength = 0.9;
    h.SpecularExponent = 25;
%     h.BackFaceLighting = 'unlit';
    h.EdgeColor = 'none';
    h.FaceColor = all_colors{iShape};
    h.FaceAlpha = 0.3;
    hold on;
end
view(50,30);
% lightangle(-45,30)
xlabel('x - AP');
ylabel('y - ML');
zlabel('z - DV');

zlim([-8 -5]);