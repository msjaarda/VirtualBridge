function [AllTrAx] = GetAllTrAx(TrLineUpMaster,ResIL,NumLanes)
%GetAllTrAx Find the vector of all truck axles in their positions.

% Last column is all lanes together, 1:end-1 are each lane invididually

% Round master truck line up to desired refinement level
TrLineUp = TrLineUpMaster(:,1:4);
TrLineUp(:,1) = ResIL*round(TrLineUp(:,1)/ResIL);

% % Add to avoid subscript 0 for indexing
% if TrLineUp(1,1) < ResILs
%     TrLineUp(:,1) = TrLineUp(:,1)+(ResILs-TrLineUp(1,1));
% end

% Make a separate axle stream vector for each lane, and last one for all
AllTrAx = zeros(max(TrLineUp(:,1))/(ResIL),NumLanes+1);

for i = 1:NumLanes
    A = accumarray(TrLineUp(TrLineUp(:,4)==i,1),TrLineUp(TrLineUp(:,4)==i,2));
    AllTrAx(1:length(A(ResIL:ResIL:end)),i) = A(ResIL:ResIL:end);   
end

AllTrAx(:,end) = sum(AllTrAx(:,1:end-1),2);   
            
end

