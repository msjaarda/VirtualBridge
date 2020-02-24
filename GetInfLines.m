function [InfLanes,InfNames,UniqInf,UniqInfs,UniqInfi,NumInfCases,Infx,Infv,ESIA] = GetInfLines(LaneData,BaseData)
% GetInfLines takes in LaneData and BaseData and rounds influence lines to
% desired refinement level, switches signs, and returns ESia as well

% if istable(LaneData)
%     
% end

% Get total number of lanes
NumLanes = max(LaneData.LaneNum(LaneData.LaneNum > 0));
% Get which lanes each line applies to - 0 means all lanes
InfLanes = LaneData.Lane(LaneData.InfNum<100); InfNames = LaneData.Name(LaneData.InfNum>0); 
% Get total number of influence lines
NumInf = max(LaneData.InfNum);

% In the end, we want each IL to have an "x" col, and a "y/value" col
% We should be able to call on them simply, or as before in the complex way
% Since lane distribution (ex. 80-20-0) actually changes the random
%   traffic, we can't have it change for each IL (should actually be input
%   in the BaseData sheet).

% UniqInf is the unique names, UniqInfs is the starting indices, UniqInfi are the actual indices
[UniqInf, UniqInfs, UniqInfi] = unique(InfNames,'stable');

% Get total number of InfCases
NumInfCases = length(UniqInf);

% Set Infx, rounded to desired refinement level (ILRes)
Infx = LaneData.x(1):BaseData.ILRes:LaneData.x(end); Infx = Infx';
% Initialize Infv
Infv = zeros(length(Infx),NumInf);

% Find starting column of Inf values in the LaneData Table
StartCol = find(strcmpi(LaneData.Properties.VariableNames,'x'));

% Initialize Maximum and Integrals (for ESIA)
MaxInfv = zeros(NumLanes,NumInfCases);
Max2Infv = zeros(NumLanes,NumInfCases);
IntInfv = zeros(NumLanes,NumInfCases);

% Before deciding to switch signs, get 
for i = 1:NumInfCases
    % Start and End of InfCase Influence Lines
    Start = StartCol+UniqInfs(i); End = StartCol+UniqInfs(i)+sum(UniqInfi == i)-1;
    % Switch signs if necessary (program works when + is the maximum LE
    % Here we assume that the overall max value is on the side with max LE
    
    % We have a problem here... if we do it this way, we have to 
    
    if abs(max(max(LaneData{:,Start}))) < abs(min(min(LaneData{:,Start})))
        LaneData{:,Start:End} = -LaneData{:,Start:End};
    end
    % Now we interpolate the influence lines and populate Infv
    Infv(:,Start-StartCol:End-StartCol) = interp1(LaneData.x,LaneData{:,Start:End},Infx);
    
    [a, k] = max(Infv(:,Start-StartCol:End-StartCol));
    
    for j = 1:End-Start + 1
        b(j) = interp1(LaneData.x,LaneData{:,Start+j-1},Infx(k(j))+0.6);
        c(j) = interp1(LaneData.x,LaneData{:,Start+j-1},Infx(k(j))-0.6);
    end
    
    aprime = max(b,c);
    
    % Decide if we go + or - 0.6... try both, take higher? make sure no error
    
    % If we give 0... we assume same IL for all lanes. If we give just
    % Shear in lane 2, for example, we assume 0 for all other lanes.
    if InfLanes(UniqInfs(i)) == 0
        MaxInfv(:,i) = repmat(aprime,NumLanes,1);       % a to aprime 20.2
    else
        MaxInfv(InfLanes(UniqInfi == i),i) = aprime';   % a to aprime 20.2
    end
end

% Initialize Integration
Integration = zeros(1,NumInf);

% Calculate + only integrals for each IL
for i = 1:NumInf
    Integration(i) = trapz(Infx(Infv(:,i)>=0),Infv(Infv(:,i)>=0,i));
end

% Assign integral values into IntInfv
for i = 1:NumInfCases
    if InfLanes(UniqInfs(i)) == 0
        IntInfv(:,i) = repmat(Integration(UniqInfs(i)),NumLanes,1);
    else
        IntInfv(InfLanes(UniqInfi == i),i) = Integration(UniqInfi == i)';
    end
end

% Do ESIA while we are here...
ESIA = zeros(1,NumInfCases);
% Define ESIA details
LaneWidth = 3; % m
Qk = zeros(NumLanes,1);
qk = 2.5*ones(NumLanes,1);
Qk(1) = 300; qk(1) = 9; % kN, kN/m2
if NumLanes > 1
    Qk(2) = 200;
end
Alpha = 1;      % Changed from 0.90 to 1 on 20.02 to better reflect AGB results

% Don't have to sort these! Just getting the worst effects...
for i = 1:NumInfCases
    %Maxv = sort(MaxInfv(:,i),'descend');
    %Intv = sort(IntInfv(:,i),'descend');
    Maxv = MaxInfv(:,i);
    Intv = IntInfv(:,i);
    ESIA(i) = 1.5*Alpha*(Maxv'*Qk*2+Intv'*qk*LaneWidth);
end
  
end