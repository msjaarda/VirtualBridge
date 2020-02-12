function [AllLaneLineUp] = GetAllLaneLineUp(NumTrTyp,TrTyp,LaneDataDir,q,Flo,CarFrAxRe,k,v,BaseData,TrData)
%The goal here is to gather all information about what is travelling in the
%lane, in order to pass it along to the next stage, where the
%assemblelineups function can combine it with other lanes.

% Compute NumEaTrTyp
[~, ~, ic] = unique(Flo.Veh);
VehTypFreq = accumarray(ic,1);

% Get total number of axles in lanestream
TotAxNum = sum(VehTypFreq(2:end).*TrTyp.NumAx)+VehTypFreq(1)*2;

% Initialize vectors with one index for each axle
[AllAxSp, AllAxLoads] = deal(zeros(TotAxNum,1));

% Assign lane number
AllLaneNum = q*ones(TotAxNum,1);

TrTypNumAx2 = [2; TrTyp.NumAx];
FloVeh2 = Flo.Veh+1;

% Assign Vehicle Numbers
AllVehNum = repelem((1:numel(FloVeh2))',TrTypNumAx2(FloVeh2));

% Vehicles Beginnings
AllVehBeg = [true; diff(AllVehNum)>0];

% Vehicle Types
AllVehTyp = Flo.Veh(AllVehNum);

% could save the following information only if necessary
if BaseData.VWIM == 1 || BaseData.Apercu == 1
    AllAxWgt = zeros(TotAxNum,10);
    AllWB = zeros(TotAxNum,9);
    AllLen = zeros(TotAxNum,1);
end

for i = 1:NumTrTyp
    P = WeightpAx(Flo.Wgt(Flo.Veh == i),TrTyp.NumAxPerGr{i},TrTyp.Priority{i},TrTyp.LinFit{i},TrTyp.Allos{i})';
    AllAxLoads(AllVehTyp == i) = P(:);
    P2 = InterAxD(sum(Flo.Veh == i),TrData.TrBetAx{i,:},TrData.TrWitAx{i,:},TrTyp.NumAxPerGr{i})';
    AllAxSp(circshift(AllVehTyp == i,1)) = P2(:);
    % could save the following information only if necessary
    if BaseData.VWIM == 1 || BaseData.Apercu == 1
        AllAxWgt(AllVehTyp == i & AllVehBeg == 1,1:TrTyp.NumAx(i)) = P'*102;
        AllWB(AllVehTyp == i & AllVehBeg == 1,1:TrTyp.NumAx(i)) = P2'*100;
        AllLen(AllVehTyp == i & AllVehBeg == 1) = sum(P2)'*100;
    end
end

% Add FloDist values between vehicles (truck rears included already in AxDists)
AllAxSp(AllVehBeg == 1) = AllAxSp(AllVehBeg == 1) + Flo.Dist;
% NB: index i spacings represents spacing BEFORE axle i (but AxDists' incides were for the one after, hence the shift)
AllAxSp(AllAxSp == 0) = CarFrAxRe(2); AllAxSp(1) = 0;

% Trim length (just in case we ended with a truck, which would give an extra index corresponding to truck rear)
if length(AllAxSp) > length(AllAxLoads)
    AllAxSp(end) = [];
end

% Get Cumulative Spacing
AllAxSpCu = cumsum(AllAxSp);

% END OF ESSENTIALS... NOW DEPENDS ON VWIM... should we trim to only
% include trucks now already??

if BaseData.VWIM == 1 || BaseData.Apercu == 1

    [AllGW, AllNumAx, AllZeros] = deal(zeros(TotAxNum,1));
    
    AllBatchNum = k*ones(TotAxNum,1);
    AllSimNum = v*ones(TotAxNum,1);
     
    AllDir = LaneDataDir(q)*ones(TotAxNum,1);
    
    AllVehPlat = Flo.Plat(AllVehNum);
    AllVehPSwap = Flo.Swap(AllVehNum);
    
    % Populate All Axle Loads and All Axle Spacings vector using AllVehTyp
    for i = 1:NumTrTyp     
        AllGW(AllVehTyp == i & AllVehBeg == 1) = Flo.Wgt(Flo.Veh == i)*102;
        AllNumAx(AllVehTyp == i & AllVehBeg == 1) = TrTyp.NumAx(i);
    end

end

% Create a master, lane specific, vehlinup

%    AllLaneLineUp = [AllAxSpCu AllAxLoads AllVehNum AllLaneNum AllVehBeg AllVehPlat AllVehPSwap AllVehTyp AllBatchNum AllSimNum AllDir AllZeros AllZeros AllZeros AllZeros AllZeros AllLaneNum AllZeros AllLen AllZeros AllZeros AllGW AllNumAx AllAxWgt AllWB];
%                         1         2           3        4          5         6           7         8           9         10       11      12       13       14       15       16        17       18      19       20       21     22       23     24      42 
% Save in final massive matrix
if BaseData.VWIM == 1 || BaseData.Apercu == 1
    AllLaneLineUp = [AllAxSpCu AllAxLoads AllVehNum AllLaneNum AllVehBeg AllVehPlat AllVehPSwap AllVehTyp AllBatchNum AllSimNum AllDir AllZeros AllZeros AllZeros AllZeros AllZeros AllLaneNum AllZeros AllLen AllZeros AllZeros AllGW AllNumAx AllAxWgt AllWB];
else
    AllLaneLineUp = [AllAxSpCu AllAxLoads AllVehNum AllLaneNum AllVehBeg];
end


end

