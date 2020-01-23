% This script loads a daily .log traffic stream and summarizes behaviour of
% Car-Truck following interactions

clear
clc
close all
format long g

% TODO: Deal with trucks at start or end of stream

% Load daily .log file with traffic stream from counting station
load('Counting Flow\CH289April2019')

WD = not(isweekend(rdm.Day));
rd = rdm(WD,:);

% Choose a direction a redefine rd
Dir1 = rd.Lane == 1;% | rd.Lane == 2;
rd = rd(Dir1,:);

% OPTIONAL: Take only a certain speed
rd = rd(rd.Speed < 30,:);

% Swiss10 Classes 10, 9, 8, and 1 represent trucks
L = rd.SwissT == 10 | rd.SwissT == 9 | rd.SwissT == 8 | rd.SwissT == 1 | rd.SwissT == 7;

L(1) = 0;
L(end) = 0;

% Computer total vehicles in stream
TotalVehicles = length(L);
% Compute total trucks in stream
TotalTrucks = sum(L);

% Add while look to allow for max
% F is the number of trucks following each other
index = 0;

for F = 1:100
    
    count(F) = 0;
    ft = 0;
    
    % Step through the logical matrix of truck (1) vs car (0)
    for i = 1:TotalVehicles-F-2
        % check if sequence matches
        if sum(L(i:i+F+1) == [0 ones(1,F) 0]') == F+2
            % if sequence matches... add a counter
            count(F) = count(F)+1;
            if F ~= 1
                % if sequence matches calculate average InterVehicleDist
                ft(count(F)) = mean(rd.IVT(i+2:i+F));
                index = i;
                %fd(count) = ft(count)*average(rd.Speed(i+2:i+F));
            end
        end
    end
    
    followtime(F) = mean(ft);
    %followdist(F) = average(fd);
    
    check = 1:F;
    if sum(check.*count) == TotalTrucks
        break
    end
    
end

% Summary

fprintf('\nTotal Vehicles \t\t= %i\n',TotalVehicles)
fprintf('Total Trucks \t\t= %i (%.2f%%)\n\n',TotalTrucks,100*TotalTrucks/TotalVehicles)

for i = 1:length(count)
    if i == length(count)
        fprintf('%i CAR %sCAR (%.2f%%)\n\n',count(i),repmat('T ',1,i),100*i*count(i)/TotalTrucks)
        tc(i) = (100*i*count(i)/TotalTrucks)*1/i;
    else
        fprintf('%i CAR %sCAR (%.2f%%)\n',count(i),repmat('T ',1,i),100*i*count(i)/TotalTrucks)
        tc(i) = (100*i*count(i)/TotalTrucks)*1/i;
    end
end


%TC = 100*count(1)/TotalTrucks+0.5*;
TC = sum(tc)/100;
TT = 1 - TC;

countx = 0;

for i = 1:TotalVehicles-1
    if L(i) == 0
        if L(i+1) == 1
            countx = countx+1;
        end
    end
end

TotalCars = TotalVehicles - TotalTrucks;
CT = countx/TotalCars;
CC = 1-CT;

%count = 0;

% Confirmation of TT, TC

% % for i = 1:TotalVehicles-1
% %     if L(i) == 1
% %         if L(i+1) == 0
% %             count = count+1;
% %         end
% %     end
% % end
% % 
% % TCx = count/TotalTrucks;
% % TTx = 1-TCx;

% A few questions: ok we get TC,TT,  CT,CC probabilities
% these are for the whole day... should we choose the worst hour?
% should we combine results from many weekdays for statistical sig?
% how can we validate the model in a way that is non-confirmatory?
%
% The point of this modelling part is to determine stream of traffic
% and just to decide truck vs car...
% We then need more information for the model including:
% statistical parameters for following distances
% statistical parameters for Trucks (weights, wheelbases, axles, type etc)
%

% We need to account for traffic direction...
% We need to account for which lane we are in...
% We do that now...

