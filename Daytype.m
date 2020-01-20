function [PD] = Daytype(PD, Year)
% DAYTYPE This function takes in a processed data WIM table (or processed
% data with classification, PDC), and returns that same table with an extra
% column, Daytype, with days 1 through 7, 1 being Monday


% Add Daytime column for day of the week
% Figure out workdays vs non workdays
PD.Daycount = PD.JJJJMMTT-Year*10000;

% Days per month
DpM = [31 28 31 30 31 30 31 31 30 31 30 31];
% Make the exception for a leap year
if mod(Year,4) == 0
    DpM(2) = 29;
end

% Give each date a number from 0 to 364/365
counter = 100;
for i = 1:12
    PD.Daycount(PD.Daycount > 50+100*(i-1) & PD.Daycount < 100+100*i) = PD.Daycount(PD.Daycount > 50+100*(i-1) & PD.Daycount < 100+100*i) - counter;
    counter = counter + 100 - DpM(i);
end

% Simply detect Saturday and Sunday by the lowest traffic volumes
PD.Daytype = mod(PD.Daycount,7);
PD.Daytype(PD.Daytype == 0) = PD.Daytype(PD.Daytype == 0)+7;

for i = 1:7
    DayWeight(i) = sum(PD.GW_TOT(PD.Daytype == i));
end

% Sunday = b
[~, b] = min(DayWeight);

% Shift Daytime so that b = 7
Shift = 7-b;

PD.Daytype = PD.Daytype + Shift;
PD.Daytype(PD.Daytype > 7) = PD.Daytype(PD.Daytype > 7) - 7;

end