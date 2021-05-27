function [PD] = ClassifyType(PD)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

IndW = find(string(PD.Properties.VariableNames) == "W1_2");

% Create the table of axel. 0: >2m ; 1: <2m, NaN: no axel 
axleTable = double(PD{:,IndW:IndW+7} < 200);
axleTable(PD{:,IndW:IndW+7} == 0) = NaN;

% Initilize the empty count of axels and count of axel per group. 
count = ones(height(axleTable),1);
countGroup = nan(size(axleTable)+[0 1]);

for j = 1:width(axleTable)
    
    % Find vehicule with current axle being seperated from the previous
    % group
    idAlone = axleTable(:,j) == 0;
    
    % Find vehicule with current axle being part of the previous group.
    idTogether = axleTable(:,j) == 1; 
    
    % If it is part of the previous group, then add 1 to the count of axle
    count(idTogether) = count(idTogether) + 1;
    
    % If new group, first write down the count of the previous group
    countGroup(idAlone,j) = count(idAlone);
    % And reinitilize the count of axel in the new group to 1
    count(idAlone) = 1;
    
end

% Add the count of the last group
countGroup(:,j+1)=count;

% Convert the count per group into the code, by using a power of 10
% corrected for the presence of nan
STR_c = nansum(countGroup .* 10.^(cumsum(~isnan(countGroup),2,'reverse')-1),2);

PD.TYPE = STR_c;

end

