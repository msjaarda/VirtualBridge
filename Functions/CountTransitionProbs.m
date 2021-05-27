function T = CountTransitionProbs(VarName,Lane,Condition,W5,Hist,Print)
%COUNTTRANSITIONPROBS This script loads a daily .log traffic stream and summarizes behaviour of
% Car-Truck following interactions (transition probabilities)
% as well as following distances if need be

% Load file with traffic stream from counting station
load(VarName)
rd = rd(rd.Lane == Lane,:);

try
    p = num2str(rd.d);
    Year = str2num([repmat('20',length(p),1) p(:,end-1:end)]);
    Month = str2num(p(:,end-3:end-2));
    Day = str2num(p(:,1:end-4));
    rd.Time = datetime(Year,Month,Day,rd.h,rd.m,rd.s,rd.ms);
catch
     rd.Time = datetime(year(rd.Day),month(rd.Day),day(rd.Day),hour(rd.Time),minute(rd.Time),second(rd.Time));
end

if strcmp(Condition,'Free Flow')
    rd = rd(rd.Speed > 80,:);
end

% WD = not(isweekend(rdm.Day));
% rd = rdm(WD,:);

%WD = not(isweekend(rdm.Day));
%rd = rdm(WD,:);
% OPTIONAL: Take only a certain speed
%rd = rd(rd.Speed < 30,:);

% Swiss10 Classes 10, 9, 8, and 1 represent trucks
%L = rd.SwissT == 10 | rd.SwissT == 9 | rd.SwissT == 8 | rd.SwissT == 1 | rd.SwissT == 7 | rd.SwissT == 5;

% Swiss10 Classes 10, 9, 8, and 1 represent trucks
if W5 == true
    L = rd.SwissT == 10 | rd.SwissT == 9 | rd.SwissT == 8 | rd.SwissT == 1 | rd.SwissT == 5;
else
    L = rd.SwissT == 10 | rd.SwissT == 9 | rd.SwissT == 8 | rd.SwissT == 1;
end

L(1) = 0; L(end-1) = 0; L(end) = 0;

%1234 TtCtTcCc NB: TC means Truck, followed by a Car (<<<Truck<<Car)
Fol = zeros(length(L),2);
for i = 2:length(L)
    if L(i) == 1 && L(i-1) == 1
        Fol(i,1) = 1;
    elseif L(i) == 0 && L(i-1) == 1
        Fol(i,1) = 2;
    elseif  L(i) == 1 && L(i-1) == 0
        Fol(i,1) = 3;
    else
        Fol(i,1) = 4;
    end    
end

% Compute total vehicles in stream
TotalVehicles = length(L);
% Compute total trucks in stream
TotalTrucks = sum(L);

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

% Get patterns

for i = 1:length(count)
    if i == length(count)
        if Print
            fprintf('%i CAR %sCAR (%.2f%%)\n\n',count(i),repmat('T ',1,i),100*i*count(i)/TotalTrucks)
        end
        tc(i) = (100*i*count(i)/TotalTrucks)*1/i;
    else
        if Print
            fprintf('%i CAR %sCAR (%.2f%%)\n',count(i),repmat('T ',1,i),100*i*count(i)/TotalTrucks)
        end
        tc(i) = (100*i*count(i)/TotalTrucks)*1/i;
    end
end

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
countx = 0;

for i = 1:TotalVehicles-1
    if L(i) == 1
        if L(i+1) == 0
            countx = countx+1;
        end
    end
end

TCx = countx/TotalTrucks;
TTx = 1-TCx;

Fol(:,2) = rd.Speed*0.27778.*rd.IVT;

if Hist
    % Show Histogram
    histogram(Fol(Fol(:,2)<60,2),100)
    hold on
    histogram(Fol(Fol(:,2)<60 & Fol(:,1) == 1,2),100)
    histogram(Fol(Fol(:,2)<60 & Fol(:,1) == 2,2),100)
    histogram(Fol(Fol(:,2)<60 & Fol(:,1) == 3,2),100)
    histogram(Fol(Fol(:,2)<60 & Fol(:,1) == 4,2),100)
    
    histogram(Fol(Fol(:,2)<60 & Fol(:,1) == 1,2),100)
    histogram(Fol(Fol(:,2)<60 & Fol(:,1) == 2,2),100)
    histogram(Fol(Fol(:,2)<60 & Fol(:,1) == 3,2),100)
    histogram(Fol(Fol(:,2)<60 & Fol(:,1) == 4,2),100)
    
    xlabel('Following Distance (m)')
    ylabel('Number of Vehicles')
    title('Following Distances of Vehicles')
end

if Print
    % Print Summary
    fprintf('\nTotal Vehicles \t\t= %i\n',TotalVehicles)
    fprintf('Total Trucks \t\t= %i (%.2f%%)\n',TotalTrucks,100*TotalTrucks/TotalVehicles)
    fprintf('Truck-Truck \t\t= %.2f%%\n',TT*100)
    fprintf('Mean Speed \t\t\t= %.2f\n',mean(rd.Speed))
    fprintf('Vehicles < 10 kph \t= %.2f%%\n',100*sum(rd.Speed < 10)/TotalVehicles)
    fprintf('Lane \t\t\t\t= %i\n\n',Lane)
end

MeanSpeed = mean(rd.Speed);
TrRate = TotalTrucks/TotalVehicles;
Ratio = TT/TrRate;
NumVeh = TotalVehicles;
NumTr = TotalTrucks;
try
    Date = datestr(rd.Time(1));
catch
    Date = "Unknown";
end
VehUnder10 = sum(rd.Speed < 10)/TotalVehicles;

T = array2table([Ratio,TrRate,TT,MeanSpeed,Lane,NumVeh,NumTr,VehUnder10],'VariableNames',...
    {'Ratio','TrRate','TT','MeanSpeed','Lane','NumVeh','NumTr','U10'});
T.Condition = string(Condition);
T.Date = string(Date);

end

