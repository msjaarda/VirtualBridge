function [Flo] = GetFloDist(FolDist,FixVars,Flo,PlatFolDist)
%GETFLODIST Grabs FloDist NB: TC means Truck, followed by a Car (<<<Truck<<Car)

% TT 0
% CT -1
% TC 1
% CC 2

% Assign Flo.Dist based on transition type
% TT
Flo.Dist(Flo.Trans == 0) = FixVars.TrFront + (FolDist.TT(1) + betarnd(FolDist.TT(3),FolDist.TT(4),sum(Flo.Trans == 0),1)*(FolDist.TT(2)-FolDist.TT(1)));
% CT
Flo.Dist(Flo.Trans == -1) = FixVars.CarFrAxRe(1) + (FolDist.CT(1) + betarnd(FolDist.CT(3),FolDist.CT(4),sum(Flo.Trans == -1),1)*(FolDist.CT(2)-FolDist.CT(1)));
% TC
Flo.Dist(Flo.Trans == 1) = FixVars.CarFrAxRe(3) + FixVars.TrFront + (FolDist.TC(1) + betarnd(FolDist.TC(3),FolDist.TC(4),sum(Flo.Trans == 1),1)*(FolDist.TC(2)-FolDist.TC(1)));
% CC
Flo.Dist(Flo.Trans == 2) = FixVars.CarFrAxRe(1) + FixVars.CarFrAxRe(3) + (FolDist.CC(1) + betarnd(FolDist.CC(3),FolDist.CC(4),sum(Flo.Trans == 2),1)*(FolDist.CC(2)-FolDist.CC(1)));

% Note that these platoonings will override whatever is above
% We have a problem here... we need to add in TrFronts, and CarFr/Re s
% Tried to FIx - should verify when we do platooning anlyses again

if isfield(Flo,'Plat')
    Flo.Dist(Flo.Plat) = PlatFolDist + FixVars.TrFront;
    Flo.Dist(Flo.PPrime & Flo.Trans == -1) = FixVars.PlatFolDistFrRe(1) + FixVars.TrFront + FixVars.CarFrAxRe(3);  % Must add in TrFront AND CarRear
    Flo.Dist(Flo.PPrime & Flo.Trans == 0) = FixVars.PlatFolDistFrRe(1) + FixVars.TrFront;  % Must add in TrFront
    Flo.Dist(Flo.PTrail & Flo.Trans == 0) = FixVars.PlatFolDistFrRe(2) + FixVars.TrFront;  % Must add in TrFront
    Flo.Dist(Flo.PTrail & Flo.Trans == 1) = FixVars.PlatFolDistFrRe(2) + FixVars.CarFrAxRe(1);  % Must add in CarFront
end

% Transpose
Flo.Dist = Flo.Dist';

end

