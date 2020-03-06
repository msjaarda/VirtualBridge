function [MaxLE,MaxLEStatic,DLF,BrStInd,AxonBr,FirstAxInd,FirstAx] = GetMaxLE(AllTrAx,Inf,RunDyn,InfCase)
%GETMAXLE This function computes the maximum load effect on the bridge
% It does this through convolution of the load, v, and influence, u
% v must be constructed from AllTrAx, depending on InfCase
% u is constructed from Inf.v, depending on InfCase

% AllTrAx has a column for each lane with weight in it (each lane with
% trucks, or, when cars have weight, each lane). Then, the last column of
% AllTrAx is the sum of all cols.

% If the influence line applies to all lanes, take simple AllTrAx (end col)
if Inf.Lanes(Inf.UniqStartInds(InfCase)) == 0
    TrAx = AllTrAx(:,end);
    InfLanes = 1;
% If not, take lane specific AllTrAx (all but end)
else
    TrAx = AllTrAx(:,1:end-1);
    InfLanes = Inf.Lanes(Inf.UniqInds == InfCase);
end

% Take only the influence lines that apply to the current InfCase
Infv = Inf.v(:,Inf.UniqInds == InfCase);
% Remove nans (added experimentally 12/02/2020.. fixed 05/03)
FirstNan = find(isnan(Infv));
if ~isempty(FirstNan)
    Infv = Infv(1:FirstNan-1,:);
end

% Influence ordinates for dynamic effects are simply 1
uDLF = ones(length(Infv),1);
% Get full weight on bridge for DLA
vDLF = AllTrAx(:,end);

% Compute maximum load effects
for i = 1:size(Infv,2)
    
    % Create v, and u, the vectors that will be convoluted
    v = TrAx(:,InfLanes(i));
    u = Infv(:,i);
    % Load, v, and Influence, u, convolution into R
    R(:,:,i) = conv(u,v);
     
end

% If there is more than one ifluence line, perform first sum
if size(Infv,2) > 1
    R = sum(R,3);
end

% If we want, we can include the static and dynamic results separately...
% This would add a comparison to AGB 2005

% Find MaxLE and location, StLoc
[MaxLEStatic, ~] = max(R);

% Could add other stuff here from below, if we want static location info


% If we have dynamic effects, convolute vDLF with uDLF
if RunDyn == 1
    
    % Load, v, and Influence, u, convolution into R to get Weight Result WR
    WR = conv(uDLF,vDLF);
    % Convert WeightResult into DLA using formula from Bailey
    DLFResult = 1.5-WR/3000;
    DLFResult(WR > 1500) = 1;
    DLFResult(WR < 300) = 1.4;
    
    % Multiply DLFResult by static result, R
    R = R.*DLFResult;
    
end

% Find MaxLE and location, StLoc
[MaxLE, StLoc] = max(R);

% Compute Location Info

% Get Bridge Start Index
BrStInd = StLoc-length(Infv)+1;

% Get Axles on Bridge... a little tricky because of indexing
if BrStInd-1+length(Infv) > length(AllTrAx)
    AxonBr = zeros(length(Infv),1);
    AxonBr(1:length(AllTrAx((BrStInd):end))) = AllTrAx((BrStInd):end);
elseif BrStInd < 1
    AxonBr = zeros(length(Infv),1);
    AxonBr(end-length(AllTrAx(1:(BrStInd-1)+length(Infv)))+1:end) = AllTrAx(1:(BrStInd-1)+length(Infv));
else
    AxonBr = TrAx((BrStInd):(BrStInd-1)+length(Infv),:);
end

% Find indexes for AxonBr
AxonBrInds = find(AxonBr);
FirstAxInd = BrStInd+AxonBrInds(1)-1;
FirstAx = AxonBr(AxonBrInds(1));

% We report BrStInd and not all indices, because sometimes these indices
% wrap around start and finish

% Return Dynamic Load Factor of Result
if RunDyn == 1
    DLF = DLFResult(StLoc);
else
    DLF = 1;   
end

% NB: In fact... this whole MaxLE thing doesn't care about direction at all
% Axles are just single points, at single locations, with no directions
    
end

