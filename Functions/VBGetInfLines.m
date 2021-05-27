function [Inf,NumInfCases,Infx,Infv,ESIA] = VBGetInfLines(LaneData,BaseData,NumLanes)
%Takes in LaneData, BaseData, and NumLanes and rounds influence lines to
% desired refinement level, switches signs for worst effect, and returns ESIA

% Get which lanes each line applies to - 0 means all lanes
Inf.Lanes = LaneData.Lane(LaneData.InfNum<100); Inf.Names = LaneData.Name(LaneData.InfNum>0); 
% Get total number of influence lines
NumInf = max(LaneData.InfNum);

% Inf.UniqNames is the unique names, Inf.UniqStartInds is the starting indices, Inf.UniqInds are the actual indices
[Inf.UniqNames, Inf.UniqStartInds, Inf.UniqInds] = unique(Inf.Names,'stable');

% Get total number of InfCases
NumInfCases = length(Inf.UniqNames);

% Set Infx, rounded to desired refinement level (ILRes)
Infx = LaneData.x(1):BaseData.ILRes:LaneData.x(end); Infx = Infx';
% Initialize Infv
Infv = zeros(length(Infx),NumInf);

% Find starting column of Inf values in the LaneData Table
StartCol = find(strcmpi(LaneData.Properties.VariableNames,'x'));

% Initialize Maximum and Integrals (for ESIA)
MaxInfv = zeros(NumLanes,NumInfCases);
IntInfv = zeros(NumLanes,NumInfCases);

% Before deciding to switch signs, get 
for i = 1:NumInfCases
    % Start and End Indices of of InfCase (Influence Lines are grouped)
    Start = StartCol+Inf.UniqStartInds(i); End = StartCol+Inf.UniqStartInds(i)+sum(Inf.UniqInds == i)-1;
    % Switch signs if necessary (program works when + is the maximum LE)
    % Here we assume that the overall max value is on the side with max LE
    
    % NOTE: We only consider the first lane when decided if we should flip
    % Normally we have the most trucks in this lane, so it makes sense.
    
    % Switch signs of all ILs associated with InfCase together if warranted
    if abs(max(max(LaneData{:,Start}))) < abs(min(min(LaneData{:,Start})))
        LaneData{:,Start:End} = -LaneData{:,Start:End};
    end
    % Now we interpolate the influence lines and populate Infv (Infx
    % already set with desired ILRes)
    Infv(:,Start-StartCol:End-StartCol) = interp1(LaneData.x,LaneData{:,Start:End},Infx);
    
    % Find max Influence line value index, k
    [~, k] = max(Infv(:,Start-StartCol:End-StartCol));
    
    clear b, clear c
    
    % Interpolate around influence lines to figure out next biggest max
    for j = 1:End-Start + 1
        % In case we are already at the start or end (can't interpolate
        % less or more)
        if k == 1 | k == length(Infv)
            b(j) = interp1(LaneData.x,LaneData{:,Start+j-1},Infx(k(j)));
            c(j) = interp1(LaneData.x,LaneData{:,Start+j-1},Infx(k(j)));
        % Normal procedure
        else
            b(j) = interp1(LaneData.x,LaneData{:,Start+j-1},Infx(k(j))+0.6);
            c(j) = interp1(LaneData.x,LaneData{:,Start+j-1},Infx(k(j))-0.6);
        end
    end
    
    aprime = max(b,c);
    
    % Decide if we go + or - 0.6... try both, take higher? make sure no error
    
    % If we give 0 in the Lane column of LaneData... we assume same IL for all lanes. 
    % If we give only Shear in lane 2, for example, we assume 0 for all other lanes.
    if Inf.Lanes(Inf.UniqStartInds(i)) == 0
        MaxInfv(:,i) = repmat(aprime,NumLanes,1);       % a to aprime 20.2
    else
        MaxInfv(Inf.Lanes(Inf.UniqInds == i),i) = aprime';   % a to aprime 20.2
    end
end

% Initialize Integration (each influence line)
Integration = zeros(1,NumInf);
% Calculate + only integrals for each IL
for i = 1:NumInf
    Integration(i) = trapz(Infx(Infv(:,i)>=0),Infv(Infv(:,i)>=0,i));
end

% Assign integral values into IntInfv (each InfCase)
for i = 1:NumInfCases
    if Inf.Lanes(Inf.UniqStartInds(i)) == 0
        IntInfv(:,i) = repmat(Integration(Inf.UniqStartInds(i)),NumLanes,1);
    else
        IntInfv(Inf.Lanes(Inf.UniqInds == i),i) = Integration(Inf.UniqInds == i)';
    end
end

% Get all ESIA values
ESIA.Total = zeros(1,NumInfCases);
% Define ESIA details
LaneWidth = 3; % meters, hard coded
% Initialize concentrated loads, Qk
Qk = zeros(NumLanes,1);
% Distributed loads
qk = 2.5*ones(NumLanes,1);
Qk(1) = 300; qk(1) = 9; % kN, kN/m2
% If there is more than 1 lane, the second lanes has 200 kN loads
if NumLanes > 1
    Qk(2) = 200;
end
Alpha = 1;      % Changed from 0.90 to 1 on 20.02 to better reflect AGB results

% On 25.03.2021 Matt and Lucas used LucasInfluenceLine to show that this
% method underpredicts ESIA for twin girder bridges because in Lucas' code he
% shifts the point loads Q1 and Q2 to the edge, and I do not. TM did the
% same as Lucas.

% Calculate ESIA for each InfCase
for i = 1:NumInfCases
    Maxv = MaxInfv(:,i);
    Intv = IntInfv(:,i);
    ESIA.Total(i) = 1.5*Alpha*(Maxv'*Qk*2+Intv'*qk*LaneWidth);
    ESIA.EQ(:,i) = Maxv.*Qk*2;
    ESIA.Eq(i) = Intv'*qk*LaneWidth;
end
  
end