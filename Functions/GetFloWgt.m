function [Flo] = GetFloWgt(NumTrTyp,LaneNumVeh,Flo,TrDistr)
%GETFLOWGT Summary of this function goes here

% Initialize Flow of Weights and create cell array of axle group weights for each truck
Flo.Wgt = zeros(LaneNumVeh,1); 

% Generate truck and axle weights, axle distinces
for i = 1:NumTrTyp
   Flo.Wgt(Flo.Veh == i) = DoubleBeta(TrDistr.P2(i), TrDistr.A1(i), TrDistr.B1(i), TrDistr.a1(i), TrDistr.b1(i), TrDistr.A2(i), TrDistr.B2(i), TrDistr.a2(i), TrDistr.b2(i), sum(Flo.Veh == i));
end

% Try getting Flo.Wgt from commulative density functions (exact method)

end

