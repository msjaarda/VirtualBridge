function [BatchSize,NumBatches,FixVars,PlatPct,NumLanes,LaneTrDistr] = GetKeyVars(BaseData,TrDistr,LaneData)
%GETKEYVARS Grabs key variables

% Key cars to be manually defined right here:
FixVars.TrFront = 1.5; FixVars.CarFrAxRe = [0.9 2.6 0.8]; FixVars.PlatFolDistFrRe = [4 4];

PlatPct = TrDistr.PlatPct;
NumLanes = max(LaneData.LaneNum(LaneData.LaneNum>0)); LaneTrDistr = LaneData.LaneTrDistr(LaneData.LaneTrDistr<110);
% Define Batch Size 
K = 1:ceil(BaseData.NumVeh/2); D = [K(rem(BaseData.NumVeh,K)==0) BaseData.NumVeh];
if BaseData.NumVeh < 1000000
    BatchSize = BaseData.NumVeh;
else
    BatchSize = min(D(end-1),max(D(D<1000001))); 
end

NumBatches = BaseData.NumVeh/BatchSize;

end

