function [MaxLE,DLF,BrStInd,R] = VBGetMaxLE(AllTrAx,IL,RunDyn)
%GETMAXLE This function computes the maximum load effect on the bridge
% It does this through convolution of the load, v, and influence, u
% v must be constructed from AllTrAx, depending on InfCase
% u is constructed from Inf.v, depending on InfCase

% AllTrAx has a column for each lane with weight in it (each lane with
% trucks, or, when cars have weight, each lane).

% Influence ordinates for dynamic effects are simply 1
uDLF = ones(length(IL),1);
% Get full weight on bridge for DLA
%vDLF = AllTrAx(:,end); place directly inside!

% Preallocate R
Rx = zeros(size(AllTrAx,1)+size(IL,1)-1,size(IL,2));

% When you do conv(u,v) it is u moving accross v (order doesn't matter)
% it uses "edge padding" when no shape is specified. Instead we could do
% "same" or "valid" which reduces the number of results. It seems like it is flipped 
% before the convolution happens, but actually it goes in order. 
% But this is why we flip in Apercu ! https://ch.mathworks.com/help/matlab/ref/conv.html

% Compute maximum load effects
for i = 1:size(IL,2)
    % Only Convolute lanes with loads
    if any(AllTrAx(:,i))
        Rx(:,i) = conv(IL(:,i),AllTrAx(:,i));
    end
end

% If there is more than one influence line, perform first sum
if size(IL,2) > 1
    R = sum(Rx,2);
else
    R = Rx;
end

% Find MaxLE and location, StLoc
% [StaticMaxLE, ~] = max(R);

% Could add other stuff here from below, if we want static location info

% If we have dynamic effects, convolute vDLF with uDLF
if RunDyn == 1
    
    % Load, v, and Influence, u, convolution into R to get Weight Result WR
    WR = conv(uDLF,sum(AllTrAx,2));
    % Convert WeightResult into DLA using formula from Bailey
    DLFResult = 1.5-WR/3000;
    DLFResult(WR > 1500) = 1;
    DLFResult(WR < 300) = 1.4;
    
    % Multiply DLFResult by static result, R
    RDyn = R.*DLFResult;
    [MaxLE, MaxLoc] = max(RDyn);
    DLF = DLFResult(MaxLoc);
    % Find MaxLE and location, StLoc, this R is what we use for fatigue! Represents the stress History
    R = RDyn;
else
    % Find MaxLE and location, StLoc, this R is what we use for fatigue! Represents the stress History
    [MaxLE, MaxLoc] = max(R);
    DLF = 1;
end

% Could also just report StLoc, given that BrStInd is embroilled in the
% padding debacle! Might be smart to output clearly DMaxLE, DMaxLoc, DR, SMaxLe, SMaxLoc, SR

% Compute Location Info - Get Bridge Start Index
BrStInd = MaxLoc-length(IL)+1;

% Important code below to get AxOnBr... need to use logic in other spots
% try
%     AxOnBr = sum(AllTrAx(BrStInd:BrStInd+length(IL)-1,:),2);
% catch % zero padding needed
%     % Padding needed depends on length of influence line
%     PadLen = length(IL)-1;
%     % Add padding on either side
%     AllTrAx = [zeros(PadLen,size(AllTrAx,2)); AllTrAx; zeros(PadLen,size(AllTrAx,2))];
%     % Compute BrStInd considering padding (BrStIndP)
%     BrStIndP = BrStInd + PadLen;
%     AxOnBr = sum(AllTrAx(BrStIndP:BrStIndP+length(IL)-1,:),2);
% end

% For troubleshooting
% % Find indexes for AxonBr
% AxonBrInds = find(AxOnBr);
% % Find (but not reported)
% FirstAxInd = BrStInd+AxonBrInds(1)-1;
% FirstAx = AxOnBr(AxonBrInds(1));

% NB: In fact... this whole MaxLE thing doesn't care about direction at all
% Axles are just single points, at single locations, with no directions...
% Response: Yes but it matters for Apercu! And for looking up afterwards
% what was responsible
    
end

