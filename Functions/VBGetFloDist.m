function [Flo] = VBGetFloDist(FolDist,FixVars,Flo)
%GetFloDist Grabs FloDist NB: TaC means Truck after a Car (<<<car<<TRUCK)

% TaT 0
% CaT -1
% TaC 1
% CaC 2

% Assign Flo.Dist based on transition type
% TaT
Flo.Dist(Flo.Trans == 0) = FixVars.TrFront + (FolDist.TaT(1) + betarnd(FolDist.TaT(3),FolDist.TaT(4),sum(Flo.Trans == 0),1)*(FolDist.TaT(2)-FolDist.TaT(1)));
% CaT
Flo.Dist(Flo.Trans == -1) = FixVars.CarFrAxRe(1) + (FolDist.CaT(1) + betarnd(FolDist.CaT(3),FolDist.CaT(4),sum(Flo.Trans == -1),1)*(FolDist.CaT(2)-FolDist.CaT(1)));
% TaC
Flo.Dist(Flo.Trans == 1) = FixVars.CarFrAxRe(3) + FixVars.TrFront + (FolDist.TaC(1) + betarnd(FolDist.TaC(3),FolDist.TaC(4),sum(Flo.Trans == 1),1)*(FolDist.TaC(2)-FolDist.TaC(1)));
% CaC
Flo.Dist(Flo.Trans == 2) = FixVars.CarFrAxRe(1) + FixVars.CarFrAxRe(3) + (FolDist.CaC(1) + betarnd(FolDist.CaC(3),FolDist.CaC(4),sum(Flo.Trans == 2),1)*(FolDist.CaC(2)-FolDist.CaC(1)));

% Transpose
Flo.Dist = Flo.Dist';

end

