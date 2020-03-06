function [LaneAvgNumVeh, TrTrTransProb, CarCarTransProb, Surplus] = PerLaneRates(FolDist,BaseData,Num,FixVars,TrData,TrTypNumAxPerGr,NumVeh,Lane)
%PERLANERATES Computes Truck Rates and Transition Probabilities for each lane

% Detect if we have multiple lanes... if so, we reset TrRates
% and transition probabilies based on those established in 4)

% Add support for platoons!... this was too difficult, and may not have
% been possible. Instead, we take 5% extra length and trim lane streams to
% match.

% Should PerLaneRates take into account direction? I think so... long term
% at least

% Create simpler variable names for the sake of reducing clutter
TrFront = FixVars.TrFront;
CarFrAxRe = FixVars.CarFrAxRe;

% Initial estimates for TransProbs
TrTrTransProb = BaseData.TrRate*BaseData.BunchFactor;
TrCarTransProb = 1-TrTrTransProb;
CarTrTransProb = BaseData.TrRate*(1-TrTrTransProb)/(1-BaseData.TrRate);
CarCarTransProb = 1-CarTrTransProb;

% If there is only one lane, this is very simple!
if Num.Lanes == 1
    % All vehicles in the one lane...
    LaneAvgNumVeh = NumVeh;
else
    
    % Estimate number of vehicles per lane

    % 1a) Find the average of each following distance type
    AvgCC = FolDist.CC(1) + betastat(FolDist.CC(3),FolDist.CC(4))*(FolDist.CC(2)-FolDist.CC(1));
    AvgTT = FolDist.TT(1) + betastat(FolDist.TT(3),FolDist.TT(4))*(FolDist.TT(2)-FolDist.TT(1));
    AvgTC = FolDist.TC(1) + betastat(FolDist.TC(3),FolDist.TC(4))*(FolDist.TC(2)-FolDist.TC(1));
    AvgCT = FolDist.CT(1) + betastat(FolDist.CT(3),FolDist.CT(4))*(FolDist.CT(2)-FolDist.CT(1));
    
    % 1b) Find weighted average following distances considering the truck
    WgtAvgCC = (1-BaseData.TrRate)*CarCarTransProb*AvgCC;
    WgtAvgCT = (1-BaseData.TrRate)*CarTrTransProb*AvgCT;
    WgtAvgTC = BaseData.TrRate*TrCarTransProb*AvgTC;
    WgtAvgTT = BaseData.TrRate*TrTrTransProb*AvgTT;

    % 2a) Find the average length of each truck type
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

    % Now that we have the TrRates and TransProbs repeat the process! It is iterative...
    ratio = 0;
    % Initial estimates do not need to consider platooning... but now we do
    while abs(1-ratio) > 0.0001
        % 1b) Find weighted average following distances considering the
        % truck rate and the platooning rate... need them for slow and
        % normal lane now
        WgtAvgCC = (1-LaneTrRate).*CarCarTransProb*AvgCC;
        WgtAvgCT = (1-LaneTrRate).*CarTrTransProb*AvgCT;
        WgtAvgTC = LaneTrRate.*TrCarTransProb*AvgTC;
        WgtAvgTT = LaneTrRate.*TrTrTransProb*AvgTT;
        
        % 3a) Define Upper/Lower Bounds for Relative Lengths (m/veh) (no trucks, all trucks)
        RelLen = LaneTrRate*WgtAvgLenTr+(1-LaneTrRate)*sum(CarFrAxRe)+(WgtAvgTT+WgtAvgTC+WgtAvgCT+WgtAvgCC);
        
        % Convert to veh/m
        RelVeh = 1./RelLen;

        % 4) Solve for expected number vehicles per lane, and lane truck rates
        x = NumVeh/sum(RelVeh);
        ratio = mean(LaneAvgNumVeh./(x*RelVeh));
        LaneAvgNumVeh = x*RelVeh;
        LaneAvgNumTr = BaseData.TrRate*NumVeh*Lane.TrDistr/100;
        LaneTrRate = LaneAvgNumTr./LaneAvgNumVeh;
        
        % Still use regular formulas here for platoon lane... because
        % swapping hasn't occured
        TrTrTransProb = min(0.98,LaneTrRate*BaseData.BunchFactor);
        TrCarTransProb = 1-TrTrTransProb;
        CarTrTransProb = LaneTrRate.*(1-TrTrTransProb)./(1-LaneTrRate);
        CarCarTransProb = 1-CarTrTransProb;
        
        LaneAvgNumVeh = round(LaneAvgNumVeh);
        
    end
end

if BaseData.RunPlat == 1
    Surplus = 1.05; 
    LaneAvgNumVeh = round(LaneAvgNumVeh*Surplus);
else
    Surplus = 1;
end

end

