function [PDCx, AllTrAx, TrLineUp] = WIMtoAllTrAx(PDCx,SpaceSaver,LaneDir,ILRes)
% WIMTOALLTRAX Translates WIM or VWIM data into AllTrAx and TrLineUp
% Also returns PDC (in the form of PDCx) with some mods

% This function could use a lot of work
%   - Organization
%   - Runtime optimization
%   - Smart detection of decimal seconds
%   - Directional support

% We have to treat the lanes together this is the only way to preserve the 
% interaction between lanes (otherwise one lane will grow or shrink too much,
% and vehicles that are actually beside each other won't appear to be so.)

% Head describes the vehicle number... including light vehicles. It resets
% to zero randomly, so it is difficult to know actually how many vehicles
% pass by in the year. Additionally, it is not lane specific, so it is a
% little bit useless, except to estimate TR.

% Detect type of WIM file
% Determine if we have Enhanced or VWIM cases
EnhancedWIM = ismember('HH', PDCx.Properties.VariableNames);
% ApercuOverMax counts as VWIM
VWIM = ismember('SpCu', PDCx.Properties.VariableNames);
% Regular WIM is when it doesn't have the other two
RegularWIM = ~EnhancedWIM && ~VWIM;

% Clean up WIM data (if enhanced WIM file)
if EnhancedWIM
    
    % Fix PDCx.Head
    % Find indices where it resets to zero
    Q = [0; diff(PDCx.Head)];
    Q(Q < 0) = PDCx.Head(Q < 0);
    PDCx.Head = cumsum(Q);
    % Solve for TR (as an estimate)... not reported right now
    TR = height(PDCx)/PDCx.Head(end);
    
    % Fix decimal seconds
    PDCx.HH = str2double(PDCx.HH)/100;
    
    % Changes variables names to be lane specific
    PDCx.Properties.VariableNames{'HEADx'} = 'LnHead';
    PDCx.Properties.VariableNames{'GAP'} = 'LnGap';
    
    % Sort by timestamp
    PDCx = sortrows(PDCx,{'JJJJMMTT','HHMMSS','HH'});
    
elseif ~VWIM
    
    % Sort by timestamp (VWIM need not be sorted)
    PDCx = sortrows(PDCx,{'JJJJMMTT','HHMMSS'});
    
end

% For some reason adding sortrows changes the result! Legacy... hope it is fixed!

% Get Lanes
Lanes = unique(PDCx.FS);

% We notice that two vehicles can arrive at the same time in the same lane... SO 
% we can try a crude method of simply assigning vehicles that arrive at the same 
% second as others and early and late decimal value (0.15, and 0.85 for example).

% We should only do this if it is RegularWIM
if RegularWIM
    % Must be a lane-specific procedure
    for i = 1:length(Lanes)
        
        % Find indeces of the lane we are working in
        LaneInds = PDCx.FS == Lanes(i);
        DC = rand(height(PDCx(LaneInds,1)),1);
        
        % Find all locations where truck i and i - 1 arrived at the same time
        AA = [1; diff(PDCx.HHMMSS(LaneInds))];
        
        % Replace with early and late decimal values
        DC(find(AA == 0)-1) = 0.15;
        DC(AA == 0) = 0.85;
        
        PDCx.HH(LaneInds) = DC; 
    end
end

% Old Note... doesn't make sense:
% Repeat even if vehicles are in different lanes (WIM station logged one
% before the other for a reason... although they could have the same time

% We don't need this stuff if we have VWIM
if VWIM
    
    PDCx.CumDist = PDCx.SpCu;
    
    % Could add space-saver like properties here... but can't use Dist
    % For now, don't give VWIM SpaceSaver ability
    % Legacy below
%     if SpaceSaver > 0
%         PDCx.Dist(PDCx.Dist > SpaceSaver) = SpaceSaver;
%     end
    
else
    
    PDCx.TStamp = 60*60*24*(PDCx.Daycount-1) + 60*60*floor(PDCx.HHMMSS/10000) + 60*floor(rem(PDCx.HHMMSS,10000)/100) + rem(PDCx.HHMMSS,100) + PDCx.HH;
    PDCx.DeltaT = [0; diff(PDCx.TStamp)];
    PDCx.Dist = PDCx.DeltaT.*((PDCx.SPEED/100)*0.2777777777778); PDCx.Dist(1) = 1;
    
    % We can do spacesaver here since we treat all at the same time...
    if SpaceSaver > 0
        PDCx.Dist(PDCx.Dist > SpaceSaver) = SpaceSaver;
    end
    
    % Cummulative distance in axle stream
    PDCx.CumDist = cumsum(PDCx.Dist);
    
end

PDCx.LnTrSpacing = zeros(height(PDCx),1);
PDCx.LnTrBtw = zeros(height(PDCx),1);

% Some kind of filter for making sure trucks don't encroach on one
% another.. skip for VWIM
if ~VWIM
    for i = 1:length(Lanes)
        
        % Find indices of the lane we are working in
        LaneInds = PDCx.FS == Lanes(i);
        
        % Find all locations where truck i and i - 1 arrived at the same time
        AA = [0; diff(PDCx.CumDist(LaneInds))];
        
        PDCx.LnTrSpacing(LaneInds) = AA;
        PDCx.LnTrBtw(LaneInds) = AA - PDCx.LENTH(circshift(find(LaneInds == 1),1))/100;
        
    end
end

% Create wheelbase and axle load vectors
WBL = PDCx{:,strncmp(PDCx.Properties.VariableNames,'W',1)}/100;
AX = PDCx{:,strncmp(PDCx.Properties.VariableNames,'AW',2)}/102;

% Make wheelbase length cummulative
WBL = cumsum(WBL,2);

% This may be where direction matters...
for i = 1:length(Lanes)
    
    % Find indices of the lane we are working in
    LaneInds = PDCx.FS == Lanes(i);
    
    % Change the sign of the WBL for those in directin 2
    if LaneDir(i) == 2
        WBL(LaneInds,:) = -WBL(LaneInds,:);
    end
    
end

WB = [PDCx.CumDist PDCx.CumDist+WBL];

% Must eliminate useless WB values
WB(AX == 0) = 0;
T = ones(size(AX)).*(AX > 0);
TrNum = 1:size(WB,1); TrNum = TrNum';
Q = repmat(TrNum,1,size(T,2));
TrNum = Q.*T;

% What is going on here with LaneNum?!
LaneNum = PDCx.FS;
Q = repmat(LaneNum,1,size(T,2));
LaneNum = Q.*T;

x = WB'; WBv = x(:);
x = AX'; AXv = x(:);
x = TrNum'; TrNum = x(:);
x = LaneNum'; LaneNum = x(:);

% v stands for vector (not matrix)
WBv = WBv(WBv > 0);
AXv = AXv(AXv > 0);
TrNum = TrNum(TrNum > 0);
LaneNum = LaneNum(LaneNum > 0);

% Update the below
%AllLaneLineUp = [SpCu(1) AllAxLoads(2) AllVehNum(3) AllLaneNum(4)...
TrLineUp = [WBv AXv TrNum LaneNum];

% The way that the indexing and accumarray is working, we have wasted stuff
% at the start of the AllTrAx... and it is much too long (when using VWIM)

TrLineUp(:,1) = round(TrLineUp(:,1)/ILRes);

% Make a separate axle stream vector for each lane, and last one for all
AllTrAx = zeros(max(TrLineUp(:,1)),length(Lanes)+1);

for i = 1:length(Lanes)
    A = accumarray(TrLineUp(TrLineUp(:,4)==Lanes(i),1),TrLineUp(TrLineUp(:,4)==Lanes(i),2));
    AllTrAx(1:length(A(1:1:end)),i) = A(1:1:end); 
end

AllTrAx(:,end) = sum(AllTrAx(:,1:end-1),2);

% Return TrLineUp first row unrounded
TrLineUp(:,1) = WBv;

end




