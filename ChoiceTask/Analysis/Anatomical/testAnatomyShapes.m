function shapeId = testAnatomyShapes(shapes,ML,AP,DV)
% shapes = {thal_vm,thal_va,thal_vl};
if DV > 0
    DV = -DV;
end
shapeId = 0;
for iShape = 1:numel(shapes)
    tf = inShape(shapes{iShape},AP,ML,DV);
    if tf
        shapeId = iShape;
        break;
    end
end