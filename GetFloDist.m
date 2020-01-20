function [FloDist] = GetFloDist(FolDist,FixVars,FloTrans,FloPlat,FloPPrime,FloPTrail,PlatFolDist)
%GETFLODIST Grabs key variables NB: TC means Truck, followed by a Car (<<<Truck<<Car)

% TtCtTcCc becomes CtTtTcCc

FloDist(FloTrans == 0) = FixVars.TrFront + (FolDist.TT(1) + betarnd(FolDist.TT(3),FolDist.TT(4),sum(FloTrans == 0),1)*(FolDist.TT(2)-FolDist.TT(1)));
FloDist(FloTrans == -1) = FixVars.CarFrAxRe(1) + (FolDist.CT(1) + betarnd(FolDist.CT(3),FolDist.CT(4),sum(FloTrans == -1),1)*(FolDist.CT(2)-FolDist.CT(1)));
FloDist(FloTrans == 1) = FixVars.CarFrAxRe(3) + FixVars.TrFront + (FolDist.TC(1) + betarnd(FolDist.TC(3),FolDist.TC(4),sum(FloTrans == 1),1)*(FolDist.TC(2)-FolDist.TC(1)));
FloDist(FloTrans == 2) = FixVars.CarFrAxRe(1) + FixVars.CarFrAxRe(3) + (FolDist.CC(1) + betarnd(FolDist.CC(3),FolDist.CC(4),sum(FloTrans == 2),1)*(FolDist.CC(2)-FolDist.CC(1)));
% Note that 5, 6, 8 will override above
FloDist(FloPlat) = PlatFolDist;
FloDist(FloPPrime) = FixVars.PlatFolDistFrRe(1);
FloDist(FloPTrail) = FixVars.PlatFolDistFrRe(2);

FloDist = FloDist';

end

