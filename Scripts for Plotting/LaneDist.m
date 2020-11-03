% make a plot of lane distributions over the years
clear
clc
close all
format long g

%Dates = StartY:EndY;
Dates = 2017;
%Station = {'Ceneri' 'Denges' 'Oberburen'};
SName = 'Ceneri';
x = 0;
PlotType = 'LaneDist';   % Options are 'LaneDist' or 'Weight'

   
for i = Dates
    
    x = x+1;
    load(['PrunedS1 WIM/',SName,'/',SName,'_',num2str(i),'.mat'])
    [TotDaysOpen(x), y] = size(unique(PD.JJJJMMTT));
    [NumTrucks(x), z] = size(PD);
    ADTT(x) = NumTrucks(x)/TotDaysOpen(x);
    AvgWeight(x) = mean(PD.GW_TOT);
    StdWeight(x) = std(PD.GW_TOT);
    Lane = PD.FS == 4;
    Lane1(x) = sum(Lane);
    Lane = PD.FS == 3;
    Lane2(x) = sum(Lane);
%     Lane = PD.FS == 3;
%     Lane3(x) = sum(Lane);
%     Lane = PD.FS == 4;
%     Lane4(x) = sum(Lane);
    
    Lane2P(x) = Lane2(x)/(Lane1(x) + Lane2(x));
%     Lane3P(x) = Lane3(x)/(Lane3(x) + Lane4(x)); 

end

x = Dates;
y = 100*Lane2P;

j = plot(x, y,'LineWidth',1.5);
ytickformat('percentage')
hold on
% y = 100*Lane3P;
% j = plot(x, y,'LineWidth',1.5);
    
title('Lane Distribution at WIM Stations')
xlabel('Year')
ylabel('Percentage of Trucks in Fast Lane')

hold off