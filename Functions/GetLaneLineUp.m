function [Flo, LaneAxLineUp, LaneVehLineUp, TableNames] = GetLaneLineUp(TrTyp,LaneDir,q,Flo,FixVars,k,v,BaseData,TrData)
%GETALLLANELINEUP The goal here is to gather all information about what is 
%travelling in the lane, in order to pass it along to the next stage,
%where the AssembleLineUps function can combine it with other lanes.
% This function returns Flo, in a form that could be reduced to disclude
% vehicles. LaneAx has a row for each Ax, and LaneVeh has a for for each
% Veh. TableNames can be used later when LaneVehLineUp is coverted to Table.

% To declutter code
CarFrAxRe = FixVars.CarFrAxRe;
CarWgt = FixVars.CarWgt;
NumTrTyp = length(TrTyp.DistCu);

% Flo.Dist already includes TrFronts, CarFrs, and CarRes
% Only TrEnds aren't included yet...

% If CarWgt == 0, we can disclude cars going forward
if CarWgt == 0
    % Add InterAx Dists to Flo.Dist for cars
    
    % 1) Add car axle spacing to Flo.Dist (OK to modify directly b/c Flo not returned anyways)
    Flo.Dist(Flo.Veh == 0) = Flo.Dist(Flo.Veh == 0) + CarFrAxRe(2);
 
    % 2) Add a counter of how many cars are in front of each truck
    A = find(Flo.Veh > 0);
    B = Flo.Veh > 0;
    Flo.CarsInfront = [A(1)-1; diff(A)-1];   % Number of Cars infront of each truck, *could put A(1)-1 OR 0
    
    % 3) Construct new distances between trucks modify Flo.Dist (modify Flo.Veh and Flo.Wgt as well
    Flo.Veh = Flo.Veh(B);
    Flo.Wgt = Flo.Wgt(B);
    if BaseData.RunPlat == 1
        Flo.Plat = Flo.Plat(B);
        Flo.Swap = Flo.Swap(B);
    end
    
    SumDist = cumsum(Flo.Dist);
    B = SumDist(A);
    Flo.Dist = [B(1); diff(B)];            % *Could put B(1) or 0
    
    % Compute VehTypFreq -- the problem with accumarray is the last value if it is too low
    VehTypFreq = zeros(NumTrTyp,1);
    AC = accumarray(Flo.Veh,1);
    VehTypFreq(1:length(AC)) = AC;
    % Get total number of axles and vehicles in lanestream
    TotAxNum = sum(VehTypFreq.*TrTyp.NumAx);
    TotVehNum = sum(VehTypFreq);
    
    % Identical w/ cars or not
    % Initialize vectors with one index for each axle
    [LaneAxSp, LaneAxLoads] = deal(zeros(TotAxNum,1));
    % Assign lane number
    LaneAxLaneNum = q*ones(TotAxNum,1);
    
    % Assign Vehicle Numbers
    LaneAxVehNum = repelem((1:numel(Flo.Veh))',TrTyp.NumAx(Flo.Veh));

else
    
    % Make Cars have a subscript of 1 to use accumarray
    FloVeh2 = Flo.Veh+1;
    TrTypNumAx2 = [2; TrTyp.NumAx];
    
    % Compute VehTypFreq -- the problem with accumarray is the last value if it is too low
    VehTypFreq = zeros(NumTrTyp+1,1);
    AC = accumarray(FloVeh2,1);
    VehTypFreq(1:length(AC)) = AC;
    
    % Get total number of axles and vehicles in lanestream
    TotAxNum = sum(VehTypFreq(2:end).*TrTyp.NumAx)+VehTypFreq(1)*2;
    TotVehNum = sum(VehTypFreq);
    
    % Identical w/ cars or not
    % Initialize vectors with one index for each axle
    [LaneAxSp, LaneAxLoads] = deal(zeros(TotAxNum,1));
    % Assign lane number
    LaneAxLaneNum = q*ones(TotAxNum,1);
    
    % Assign Vehicle Numbers
    LaneAxVehNum = repelem((1:numel(FloVeh2))',TrTypNumAx2(FloVeh2));

end

% Vehicles Beginnings
LaneAxVehBeg = [true; diff(LaneAxVehNum)>0];

% Vehicle Types
LaneAxVehTyp = Flo.Veh(LaneAxVehNum);

% Note that we only save Veh information if we have to
% Initialize Variables
if BaseData.VWIM == 1 || BaseData.Apercu == 1
    LaneAxWgt = zeros(TotVehNum,max(TrTyp.NumAx));
    LaneWB = zeros(TotVehNum,max(TrTyp.NumAx)-1);
    LaneLen = zeros(TotVehNum,1);
end

for i = 1:NumTrTyp
    % Get the weight of each axle
    P = WeightpAx(Flo.Wgt(Flo.Veh == i),TrTyp.NumAxPerGr{i},TrTyp.Priority{i},TrTyp.LinFit{i},TrTyp.Allos{i})';
    % Place weights vertically after each other, into AxLoads (already kN)
    LaneAxLoads(LaneAxVehTyp == i) = P(:);
    % Get the distance between each axle
    P2 = InterAxD(sum(Flo.Veh == i),TrData.TrBetAx{i,:},TrData.TrWitAx{i,:},TrTyp.NumAxPerGr{i})';
    % Place distances vertically after each other, into AxSp (already mm)
    % Must use circshift because AxDist index i represents spacing AFTER axle i, and we want BEFORE
%     LaneAxSp(circshift(LaneAxVehTyp == i,1)) = P2(:);
%     LaneAxSpx(circshift(LaneAxVehTyp == i,1)) = P2(:);
%     LaneAxSpxx(LaneAxVehTyp == i) = P2(:);
    
    LaneAxSp(LaneAxVehTyp == i) = P2(:);
   
    % Save the following information only if necessary
    if BaseData.VWIM == 1 || BaseData.Apercu == 1
        LaneAxWgt(Flo.Veh == i,1:TrTyp.NumAx(i)) = P'*102;                % Convert to kg
        LaneWB(Flo.Veh == i,1:TrTyp.NumAx(i)-1) = P2(1:end-1,:)'*100;     % Convert to cm
        %LaneLen(Flo.Veh == i) = FixVars.TrFront + sum(P2)'*100;           % Convert to cm
        % Caught by LM... forgot to multiply TrFront to cm
        LaneLen(Flo.Veh == i) = FixVars.TrFront*100 + sum(P2)'*100;           % Convert to cm
    end
    % This P and P2 procedure are not effected by removing cars
end

LaneAxSp = circshift(LaneAxSp,1);

% Add FloDist values between vehicles (truck rears included already from AxDists)
LaneAxSp(LaneAxVehBeg == 1) = LaneAxSp(LaneAxVehBeg == 1) + Flo.Dist;
% If we still have cars, add car axles (we don't need if statement b/c
% LaneAsSp = 0 only when cars are included
if ~CarWgt == 0
    LaneAxSp(LaneAxSp == 0) = CarFrAxRe(2); LaneAxSp(1) = 0; 
end
%LaneAxSp(1) = 0;       % Optional, see *'ed notes above

% Trim length (just in case we ended with a truck, which would give an extra index corresponding to truck rear)
if length(LaneAxSp) > length(LaneAxLoads)
    LaneAxSp(end) = [];
end

% Get Cumulative Spacing
LaneAxSpCu = cumsum(LaneAxSp);

if LaneDir(q) == 2
    LaneAxSpCu = LaneAxSpCu(end,1) - LaneAxSpCu + 5;
%     X = [diff(LaneAxVehBeg); 1];
%     X(X < 0) = 0;
%     LaneAxVehBeg = X;
end

% LaneLineUp with one row per weighted axle
LaneAxLineUp = [LaneAxSpCu LaneAxLoads LaneAxVehNum LaneAxLaneNum LaneAxVehBeg];

% Let's flip LaneAxLineUp here? 
% if LaneDir(q) == 2
%     
%     X = LaneAxLineUp;
%     X(:,6) = X(end,1) + 5 - X(:,1);
%     X(:,7) = [diff(X(:,5)); 1];
%     X(X(:,7)<0,7) = 0;
%     
%     LaneAxLineUp(:,1) = X(:,6);
%     LaneAxLineUp(:,5) = X(:,7);
%     
%     LaneAxSpCu = LaneAxLineUp(:,1);
%     LaneAxVehBeg = LaneAxLineUp(:,5);
% end




% END OF ESSENTIALS
% NOW Pass on more rich info, but only one row per veh LaneVehLineUp

% Initialize
LaneVehLineUp = [];
TableNames = [];

% Richer info needed for either VIM or Apercu
if BaseData.VWIM == 1 || BaseData.Apercu == 1
    
    if CarWgt == 0
        LaneNumAx = TrTyp.NumAx(Flo.Veh);
    else
        LaneNumAx = TrTypNumAx2(FloVeh2);
    end
    
    LaneAxVehBeg = logical(LaneAxVehBeg);
    
    % LaneVehLineUp
    LaneVehLineUp = [LaneAxSpCu(LaneAxVehBeg) LaneAxVehNum(LaneAxVehBeg) LaneAxVehTyp(LaneAxVehBeg) LaneAxLaneNum(LaneAxVehBeg)...
        LaneDir(q)*ones(TotVehNum,1) k*ones(TotVehNum,1) v*ones(TotVehNum,1) LaneLen Flo.Wgt*102 LaneNumAx LaneAxWgt LaneWB];
    
%     LaneVehLineUp = [LaneAxSpCu(LaneAxVehBeg) LaneAxVehNum(LaneAxVehBeg) LaneAxVehTyp(LaneAxVehBeg) LaneAxLaneNum(LaneAxVehBeg)...
%         LaneDir(q)*ones(TotVehNum,1) k*ones(TotVehNum,1) v*ones(TotVehNum,1) LaneLen Flo.Wgt*102 LaneNumAx LaneAxWgt LaneWB];
    
    AWNames = cell(1,size(LaneAxWgt,2));
    WBNames = cell(1,size(LaneAxWgt,2)-1);
    for i = 1:size(LaneAxWgt,2)
        AWNames{i} = sprintf('AWT%i',i);
        if i < size(LaneAxWgt,2)
            WBNames{i} = sprintf('W%i_%i',i,i+1);
        end
    end
    
    % Get Table Names (Fix for dynamic axle count) START HERE!
    TableNames = {'SpCu','LaneVehNum','VehTyp','FS','Dir','BatchNum','SimNum','LENTH','GW_TOT','AX'};
    TableNames = [TableNames AWNames WBNames];
    
    % If no cars, add column for 'CarsInfront'
    if CarWgt == 0
        LaneVehLineUp = [LaneVehLineUp Flo.CarsInfront];
        TableNames{end+1} = 'CarsInfront';
    end

    % If we have plaoons, add Platooning specific columns
    if BaseData.RunPlat == 1
        LaneVehLineUp = [LaneVehLineUp Flo.Plat Flo.Swap];
        TableNames{end+1} = 'AllVehPlat';
        TableNames{end+1} = 'AllVehPSwap';
    end
    
end

end

