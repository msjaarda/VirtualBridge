% Trend Finder

clear
clc
close all
format long g

% The goal is to compare trends from available WIM data to see
% a) trends in # trucks over time
% b) trends in average weight of trucks over time
% c) trends in 99 weight percentile?
% d) trends in 99 axle weight percentile?

% we can also comment on lane distribution
% start with a) and b)
% all this needs to be adjusted for how many days the station was open for
% that year, etc.

StartY = 2003;
EndY = 2018;
Station = 'Ceneri';
x = 0;

for i = StartY:EndY
    
    x = x+1;
    load(strcat(Station,'_',num2str(i),'.mat'))
    %PD = PD(PD.ZST == 408,:);
    [TotDaysOpen(x), y] = size(unique(PD.JJJJMMTT));
    [NumTrucks(x), z] = size(PD);
    ADTT(x) = NumTrucks(x)/TotDaysOpen(x);
    AvgWeight(x) = mean(PD.GW_TOT);
    StdWeight(x) = std(PD.GW_TOT); 
    Lane = PD.FS == 1;
    Lane1(x) = sum(Lane);
    Lane = PD.FS == 2;
    Lane2(x) = sum(Lane);
    Lane = PD.FS == 3;
    Lane3(x) = sum(Lane);
    Lane = PD.FS == 4;
    Lane4(x) = sum(Lane);
    
end

x = [StartY:EndY];
plot(x,ADTT)

z = [mean(Lane1) mean(Lane2) mean(Lane3) mean(Lane4)];

bar(z)
