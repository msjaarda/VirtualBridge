function [LaneAvgNumVehx, TrTrTransProbx, CarCarTransProbx, Surplus, CumLaneTrDistr] = PerLaneRates(FolDist,BaseData,Num,FixVars,TrData,TrTypNumAxPerGr,NumVeh,Lane)
%PERLANERATES Computes Truck Rates and Transition Probabilities for each lane
% Platoons are too difficult, instead, we take 5% extra length and trim lane streams to match later on
% Function takes into account the bunching factor

% Should PerLaneRates take into account direction? I think so... long term at least
% Add support for more than 1 lane in each direction (all lanes still add to 100%)

% Create simpler variable names for the sake of reducing clutter
TrFront = FixVars.TrFront; CarFrAxRe = FixVars.CarFrAxRe;

% Initial estimates for TransProbs
TrTrTransProb = BaseData.TrRate*BaseData.BunchFactor;
TrCarTransProb = 1-TrTrTransProb;
CarTrTransProb = BaseData.TrRate*(1-TrTrTransProb)/(1-BaseData.TrRate);
CarCarTransProb = 1-CarTrTransProb;

% If there is only one lane, simple case with all vehicles in one lane
if Num.Lanes == 1
    LaneAvgNumVehx = NumVeh;
    
% If not, we split vehicles accross lanes, solving for the number
% of cars in each so that all lanes are the same length.
else
    
    % 1) Find the average of each following distance type
    AvgCC = FolDist.CC(1) + betastat(FolDist.CC(3),FolDist.CC(4))*(FolDist.CC(2)-FolDist.CC(1));
    AvgTT = FolDist.TT(1) + betastat(FolDist.TT(3),FolDist.TT(4))*(FolDist.TT(2)-FolDist.TT(1));
    AvgTC = FolDist.TC(1) + betastat(FolDist.TC(3),FolDist.TC(4))*(FolDist.TC(2)-FolDist.TC(1));
    AvgCT = FolDist.CT(1) + betastat(FolDist.CT(3),FolDist.CT(4))*(FolDist.CT(2)-FolDist.CT(1));
    
        % 1b) Find weighted average following distances considering the truck
    WgtAvgCC = (1-BaseData.TrRate)*CarCarTransProb*AvgCC;
    WgtAvgCT = (1-BaseData.TrRate)*CarTrTransProb*AvgCT;
    WgtAvgTC = BaseData.TrRate*TrCarTransProb*AvgTC;
    WgtAvgTT = BaseData.TrRate*TrTrTransProb*AvgTT;
    
    
    
    % 2) Find the average length of each truck type
    AvgLenTr = zeros(Num.TrTyp,1);
    for i = 1:Num.TrTyp
        AvgLenTr(i) = TrFront + AvgInterAxD(TrData.TrBetAx{i,:},TrData.TrWitAx{i,:},TrTypNumAxPerGr{i});
    end
    
        % 2b) Find weighted average truck length considering truck distribution
    WgtAvgLenTr = AvgLenTr'*TrData.TrDistr.TrDistr;
    
        % 3a) Define Upper/Lower Bounds for Relative Lengths (m/veh) (no trucks, all trucks)
    RelLenCarLane = sum(CarFrAxRe)+AvgCC;
    RelLenAllTrLane = BaseData.TrRate*WgtAvgLenTr+(1-BaseData.TrRate)*sum(CarFrAxRe)+(WgtAvgTT+WgtAvgTC+WgtAvgCT+WgtAvgCC);

    % 3b) Adjust for each actual lane (m/veh)
    RelLen = zeros(Num.Lanes,1);
    for i = 1:Num.Lanes
        RelLen(i) = RelLenCarLane + (Lane.TrDistr(i)/100)*(RelLenAllTrLane - RelLenCarLane);
    end
    % Convert to veh/m
    RelVeh = 1./RelLen;
    
    
    
    % 4) Solve for expected number vehicles per lane, and lane truck rates
    x = NumVeh/sum(RelVeh);
    LaneAvgNumVeh = x*RelVeh;
    LaneAvgNumTr = BaseData.TrRate*NumVeh*Lane.TrDistr/100;
    LaneTrRate = LaneAvgNumTr./LaneAvgNumVeh;
    % Transition probabilities totally go out the window here...
    
    TrTrTransProb = min(0.98,LaneTrRate*BaseData.BunchFactor);
    TrCarTransProb = 1-TrTrTransProb;
    CarTrTransProb = LaneTrRate.*(1-TrTrTransProb)./(1-LaneTrRate);
    CarCarTransProb = 1-CarTrTransProb;
    
    
    
    
    
    % Find total number of trucks
    NumTr = NumVeh*BaseData.TrRate;
    NumCar = NumVeh - NumTr;
    % Get the percentage of trucks in each lane, for each truck type ...
    % this is where we will input the new scheme (not .8 and .2, but
    % different values for different truck types)
    LaneTrDistr = TrData.TrDistr.TrDistr*Lane.TrDistr'/100;
    
    % Implemented to replicate AGB 2002/005 (see pg 17)
    NumAx = sum(TrData.TrWitAx{:,:} >= 0,2);
    
    if all(Lane.TrDistr == [85;15])
        AxFactor = zeros(Num.TrTyp,2);
        AxFactor(NumAx == 2 | NumAx == 3,:) = repelem([80 20],sum(NumAx == 2 | NumAx == 3),1);
        AxFactor(NumAx == 4,:) = repelem([85 15],sum(NumAx == 4),1);
        AxFactor(NumAx == 5 | NumAx == 6,:) = repelem([90 10],sum(NumAx == 5 | NumAx == 6),1);
        LaneTrDistr = TrData.TrDistr.TrDistr.*AxFactor/100;
    elseif  all(Lane.TrDistr == [96;4])
        AxFactor = zeros(Num.TrTyp,2);
        AxFactor(NumAx == 2 | NumAx == 3,:) = repelem([94 6],sum(NumAx == 2 | NumAx == 3),1);
        AxFactor(NumAx == 4,:) = repelem([97 3],sum(NumAx == 4),1);
        AxFactor(NumAx == 5 | NumAx == 6,:) = repelem([97 3],sum(NumAx == 5 | NumAx == 6),1);
        LaneTrDistr = TrData.TrDistr.TrDistr.*AxFactor/100;
    end
    
    for i = 1:size(LaneTrDistr,2)
        CS = cumsum(LaneTrDistr(:,i));
        % Normalize
        CumLaneTrDistr(:,i) = CS*1/(CS(end));
    end
    
    % Find number of trucks of each type in each lane
    TrPerLane = LaneTrDistr*NumTr;
    % Get total per lane
    LaneAvgNumTrx = sum(TrPerLane,1);
    % Expected length of trucks themselves
    ExpLenAllTr = AvgLenTr'*TrPerLane;
    
    % Estimate number of cars in each lane... start crudely
    CarDistrEst = 1/Num.Lanes*ones(1,Num.Lanes);
    LaneAvgNumCarx = NumCar*CarDistrEst;
    LaneAvgNumVehx = LaneAvgNumTrx + LaneAvgNumCarx;
    LaneTrRatex = LaneAvgNumTrx./LaneAvgNumVehx;
    
    TrTrTransProbx = min(0.98,LaneTrRatex*BaseData.BunchFactor);
    TrCarTransProbx = 1-TrTrTransProbx;
    CarTrTransProbx = LaneTrRatex.*(1-TrTrTransProbx)./(1-LaneTrRatex);
    CarCarTransProbx = 1-CarTrTransProbx;
    
    % Solve for the expected number of each transition type 
    TotAvgCC = LaneAvgNumVehx.*(1-LaneTrRatex).*CarCarTransProbx*AvgCC;
    TotAvgCT = LaneAvgNumVehx.*(1-LaneTrRatex).*CarTrTransProbx*AvgCT;
    TotAvgTC = LaneAvgNumVehx.*LaneTrRatex.*TrCarTransProbx*AvgTC;
    TotAvgTT = LaneAvgNumVehx.*LaneTrRatex.*TrTrTransProbx*AvgTT;
    
    % Expected length of cars themselves
    ExpLenAllCar = sum(CarFrAxRe)*LaneAvgNumCarx;
    % Total expected length of traffic streams 
    TotalExpLen = ExpLenAllTr + ExpLenAllCar + TotAvgCC + TotAvgCT + TotAvgTC + TotAvgTT;
     
    % Let's iterate by giving to the shortest, from the longest...
    % This works even when we have 3 lanes
    [High, IndexMax] = max(TotalExpLen);
    [Low, IndexMin] = min(TotalExpLen);
    Differ = High - Low;
    
    while Differ > 1
        
        ToTrade = Differ/(2*(sum(CarFrAxRe)+mean([AvgCC,AvgCT,AvgTC,AvgTT])));
        LaneAvgNumCarx(IndexMin) = LaneAvgNumCarx(IndexMin) + ToTrade;
        LaneAvgNumCarx(IndexMax) = LaneAvgNumCarx(IndexMax) - ToTrade;
        
        LaneAvgNumVehx = LaneAvgNumTrx + LaneAvgNumCarx;
        LaneTrRatex = LaneAvgNumTrx./LaneAvgNumVehx;
        
        TrTrTransProbx = min(0.98,LaneTrRatex*BaseData.BunchFactor);
        TrCarTransProbx = 1-TrTrTransProbx;
        CarTrTransProbx = LaneTrRatex.*(1-TrTrTransProbx)./(1-LaneTrRatex);
        CarCarTransProbx = 1-CarTrTransProbx;
        
        % Solve for the expected number of each transition type
        TotAvgCC = LaneAvgNumVehx.*(1-LaneTrRatex).*CarCarTransProbx*AvgCC;
        TotAvgCT = LaneAvgNumVehx.*(1-LaneTrRatex).*CarTrTransProbx*AvgCT;
        TotAvgTC = LaneAvgNumVehx.*LaneTrRatex.*TrCarTransProbx*AvgTC;
        TotAvgTT = LaneAvgNumVehx.*LaneTrRatex.*TrTrTransProbx*AvgTT;
        
        % Expected length of cars themselves
        ExpLenAllCar = sum(CarFrAxRe)*LaneAvgNumCarx;
        
        TotalExpLen = ExpLenAllTr + ExpLenAllCar + TotAvgCC + TotAvgCT + TotAvgTC + TotAvgTT;

        [High, IndexMax] = max(TotalExpLen);
        [Low, IndexMin] = min(TotalExpLen);
        Differ = High - Low;
        
    end
    
    % Post warnings
    if min(LaneAvgNumCarx) < 0
        fprintf("\nWarning: Truck rate is too high for this truck distribution (negative cars required)\n\n") 
    end
    
    % Check for other program warnings, initialize empty vars
    MATSimWarnings(cumsum(TrData.TrDistr.TrDistr), BaseData.BunchFactor, BaseData.RunPlat, TrTrTransProb); 
    

%     % Now that we have the TrRates and TransProbs repeat the process! It is iterative...
%     ratio = 0;
%     while abs(1-ratio) > 0.00001
%         % 1b) Find weighted average following distances considering the
%         % truck rate and the platooning rate... need them for slow and
%         % normal lane now
%         WgtAvgCC = (1-LaneTrRate).*CarCarTransProb*AvgCC;
%         WgtAvgCT = (1-LaneTrRate).*CarTrTransProb*AvgCT;
%         WgtAvgTC = LaneTrRate.*TrCarTransProb*AvgTC;
%         WgtAvgTT = LaneTrRate.*TrTrTransProb*AvgTT;
%         
%         % 3a) Define Upper/Lower Bounds for Relative Lengths (m/veh) (no trucks, all trucks)
%         RelLen = LaneTrRate*WgtAvgLenTr+(1-LaneTrRate)*sum(CarFrAxRe)+(WgtAvgTT+WgtAvgTC+WgtAvgCT+WgtAvgCC);
%         
%         % Convert to veh/m
%         RelVeh = 1./RelLen;
% 
%         % 4) Solve for expected number vehicles per lane, and lane truck rates
%         x = NumVeh/sum(RelVeh);
%         ratio = mean(LaneAvgNumVeh./(x*RelVeh));
%         LaneAvgNumVeh = x*RelVeh;
%         LaneAvgNumTr = BaseData.TrRate*NumVeh*Lane.TrDistr/100;
%         LaneTrRate = LaneAvgNumTr./LaneAvgNumVeh;
%         
%         % Still use regular formulas here for platoon lane... because
%         % swapping hasn't occured
%         TrTrTransProb = min(0.98,LaneTrRate*BaseData.BunchFactor);
%         TrCarTransProb = 1-TrTrTransProb;
%         CarTrTransProb = LaneTrRate.*(1-TrTrTransProb)./(1-LaneTrRate);
%         CarCarTransProb = 1-CarTrTransProb;
%         
%         LaneAvgNumVeh = round(LaneAvgNumVeh);
%         
%     end
end


LaneAvgNumVehx = round(LaneAvgNumVehx');

% Add surplus if we are doing platooning (too difficult to estimate)
if BaseData.RunPlat == 1
    Surplus = 1.15; 
    LaneAvgNumVehx = round(LaneAvgNumVehx*Surplus);
else
    Surplus = 1;
end

end

