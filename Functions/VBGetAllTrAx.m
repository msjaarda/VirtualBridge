function [AllTrAx] = VBGetAllTrAx(AxLineUp,ILRes,Lane,FixVars)
%GetAllTrAx Find the vector of all truck axles in their positions.
% AllTrAx has a column for each lane with weight in it (each lane with
% trucks, or, when cars have weight, each lane). Then, the last column of
% AllTrAx is the sum of all cols.

% AxLineUp has [AxSpCu AxLoads LaneAxVehNum AxLaneNum AxVehNum]
%                 1       2         3           4         5

% Get NumLanes
NumLanes = size(Lane.TrDistr,1);

% Get NumLoadedLanes
if FixVars.CarWgt> 0
    NumLoadedLanes = NumLanes;
else
    NumLoadedLanes = sum(Lane.TrDistr > 0);
    LoadedLanesInds = find(Lane.TrDistr > 0);
end

% Round master truck line up to desired refinement level
TrLineUp = AxLineUp(:,1:4);
TrLineUp(:,1) = round(TrLineUp(:,1)/ILRes);

% Add to avoid subscript 0 for indexing
if TrLineUp(1,1) < ILRes
    TrLineUp(:,1) = TrLineUp(:,1)+(ILRes-TrLineUp(1,1));
end

% Initialize AllTrAx *NumLanes changed from NumLoadedLanes 8.4.2020 to fix
% bug involving lane dependant actions when Lane.TrDist = 0 for one or more
% lanes
AllTrAx = zeros(max(TrLineUp(:,1)),NumLanes);

% May need to use NumLoadedLanes and LoadedLanesInds in more places
for i = 1:NumLoadedLanes
    A = accumarray(TrLineUp(TrLineUp(:,4) == LoadedLanesInds(i),1),TrLineUp(TrLineUp(:,4) == LoadedLanesInds(i),2));
    AllTrAx(1:length(A),i) = A;    
end
            
end

