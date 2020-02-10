function [InfLanes,InfNames,UniqInf,UniqInfs,UniqInfi,NumInfCases,Infx,Infv,IntInfv,MaxInfv] = GetInfLines(LaneData,BaseData)
%GETINFLINES

InfLanes = LaneData.Lane(LaneData.InfNum<100); InfNames = LaneData.Name(LaneData.InfNum>0); 

% New influence line procedure necessary
NumInf = max(LaneData.InfNum);
[UniqInf, UniqInfs, UniqInfi] = unique(InfNames,'stable');
% Start with the simple cases, when Lane == 0
NumInfCases = length(UniqInf);

Infx = LaneData.x(1):BaseData.ILRes:LaneData.x(end);
Infv = zeros(length(Infx),NumInf);

% Before deciding to switch signs, get 
for i = 1:NumInfCases
    
    
end





% Refine influence lines, one column for each influence line
for i = 1:NumInf
    Infv(:,i) = interp1(LaneData.x,LaneData{:,7+i},Infx);
    % Switch sign of ILs if maximum is a negative value... only if Lane = 0
    % Still need to make sure non 0 ILs have the correct sense!
    if abs(max(Infv(:,i))) < abs(min(Infv(:,i))) && InfLanes(i) == 0
        Infv(:,i) = -Infv(:,i);
    end
    % Grab Integration for Esia
    IntInfv(i) = trapz(Infx(Infv(:,i)>0),Infv(Infv(:,i)>0,i));
end

% Calculate SIA Parameters
MaxInfv = max(Infv);
  
end