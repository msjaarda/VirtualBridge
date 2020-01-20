function [FloWgt] = GetFloWgt(NumTrTyp,LaneNumVeh,FloVeh,TrDistr)
%GETFLOWGT Summary of this function goes here

% Initialize Flow of Weights and create cell array of axle group weights for each truck
FloWgt = zeros(LaneNumVeh,1); 

% Generate truck and axle weights, axle distinces
for i = 1:NumTrTyp
   FloWgt(FloVeh == i) = DoubleBeta(TrDistr.P2(i), TrDistr.A1(i), TrDistr.B1(i), TrDistr.a1(i), TrDistr.b1(i), TrDistr.A2(i), TrDistr.B2(i), TrDistr.a2(i), TrDistr.b2(i), sum(FloVeh == i));
end

% Try getting FloWgt from commulative density functions (exact method)

end

