% session08 - R0142_20161210a has Tone and Nose Out units with good Coeffs
iSession = 8;
unitRange = 189:212; % see heatmap images
coeffs = squeeze(sessionPCA_500ms(iSession).coeff(4,:,:));

unitClasses = primSec(unitRange,1);
toneUnits = find(unitClasses == 3)
noseOutUnits = find(unitClasses == 4)