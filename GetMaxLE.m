function [MaxLE,DLF,BrStInd,AxonBr,FirstAxInd,FirstAx] = GetMaxLE(AllTrAx,Infv,InfLanes,LaneTrDistr,RunDyn,t,UniqInfs,UniqInfi)
%GETMAXLE This function computes the maximum load effect on the bridge
%   The function takes in a stream of axle loads, in the form of a matrix
%   with column 1 being the locations, and column 2 being the loads at
%   those locations. It also takes in an influence line. The stream of axle
%   loads and the influence line shall both be

%   Function can also handle receiving more than one influence line in, and
%   AllTrAx having more columns than 1.

% Allow function to make its own inference about one or more inflns

% If the influence line applies to all lanes, take simple AllTrAx (end col)
% If not, take lane specific AllTrAx (all but end)



if InfLanes(UniqInfs(t)) == 0
    AllTrAx = AllTrAx(:,end);
    InfLanes = 1;
else
    AllTrAx = AllTrAx(:,1:end-1);
    InfLanes = InfLanes(UniqInfi == t);
end

Infv = Infv(:,UniqInfi == t);
Infv = Infv(~isnan(Infv));    % Added experimentally 12/02/2020

% if length(Infv) > 55            % Added experimentally 12/02/2020
%     RunDyn = 0; 
% end

uDLF = ones(length(Infv),1);

% First, we establish how many influence lines we are given... NumLaneLines
[~, NumLaneLines] = size(Infv);

AllTrAxFW = sum(AllTrAx,2);

for j = 1:NumLaneLines
    
    if LaneTrDistr(InfLanes(j)) > 0
        
        v = AllTrAx(:,InfLanes(j));
        u = Infv(:,j);
        R(:,:,j) = conv(u,v);
            
    end
    
end

if NumLaneLines > 1
    R = sum(R,3);
end

if RunDyn == 1
    
    vDLF = AllTrAxFW;
    WeightResult = conv(uDLF,vDLF);
    % Convert WeightResult into DLA
    DLFResult = 1.5-WeightResult/3000;
    DLFResult(WeightResult > 1500) = 1;
    DLFResult(WeightResult < 300) = 1.4;

    R = R.*DLFResult;
    
end

[MaxLE, StLoc] = max(R);

BrStInd = StLoc-length(Infv)+1;
%BrStInd = StLoc-length(Infv)+2;

if BrStInd-1+length(Infv) > length(AllTrAx)
    AxonBr = zeros(length(Infv),1);
    AxonBr(1:length(AllTrAx((BrStInd):end))) = AllTrAx((BrStInd):end);
elseif BrStInd < 1
    AxonBr = zeros(length(Infv),1);
    AxonBr(end-length(AllTrAx(1:(BrStInd-1)+length(Infv)))+1:end) = AllTrAx(1:(BrStInd-1)+length(Infv));
else
    AxonBr = AllTrAx((BrStInd):(BrStInd-1)+length(Infv));
end

AxonBrInds = find(AxonBr);
FirstAxInd = BrStInd+AxonBrInds(1)-1;
FirstAx = AxonBr(AxonBrInds(1));

% if FirstAxInd > length(AllTrAx)
%     FirstAxInd = FirstAxInd-length(AllTrAx);
% end

if RunDyn == 1
    DLF = DLFResult(StLoc);
else
    DLF = 1;   
end

    
end

