% Smallq: Finding the percentiles of SIA Code Parameters in real traffic
%
% Goal here is to get a sense for Q1 and Q2 as well as q1, and q2
%
% We will start with Q1 and Q2, specifically trying to find the %tile of 
% Q1 (in the code a tandem axle of 300 kN each with 1.2 m spacing), and
% Q2 (200 kN each with 1.2 m spacing, at the same point in the next lane)
% and the joint probability between.

% Initial Commands
clear, clc, close all, format long g

% Specify total traffic (all years and stations to be analyzed)
% Station Info incl. station name, number, and year
Year = 2016:2018;
BaseData.SName = 'Denges';
BaseData.StationNum = 1;
BaseData.LaneDir = {'1,1'};
BaseData.Stage2Prune = false;
BaseData.ClassOnly = false;





% We really need to do something like in MATSimWIM when we place into axle
% streams... then we need to analyze the streams side-by-side to see the relationship between q1 and q2 
x = 0;
M = [];
Mx = [];

TrTyps = [11; 12; 22; 23; 111; 11117; 1127; 12117; 122; 11127; 1128; 1138; 1238];
TrAxPerGr = [11; 12; 22; 23; 111; 1111; 112; 1211; 122; 1112; 112; 113; 123];

for i = 1:length(Year)
    
%     x = x+1;
%     load(strcat(Station,'_',num2str(i),'.mat'))
%     
%     
%     J = (PD.GW_TOT/102)./(PD.LENTH/100);
%     M = [M; mean(J) prctile(J,95) prctile(J,99) prctile(J,99.99)];
%     
%     
%     Q = PD.W1_2+PD.W2_3+PD.W3_4+PD.W4_5+PD.W5_6+PD.W6_7+PD.W7_8;
%     Q = Q + 255;
%     
%     Jx = (PD.GW_TOT/102)./(Q/100);
%     Mx = [Mx; mean(Jx) prctile(Jx,95) prctile(Jx,99) prctile(Jx,99.99)];
    
    


    load(['PrunedS1 WIM/',BaseData.SName,'/',BaseData.SName,'_',num2str(Year(i)),'.mat']);
    
    PDC = Classify(PD);
    PDC = Daytype(PDC,Year(i));
    clear('PD')
    
    % We treat each station separately.. SNum is the input for which
    Stations = unique(PDC.ZST);
    Station = Stations(BaseData.StationNum);
    PDCx = PDC(PDC.ZST == Station,:);
    clear('PDC')
    
    BaseData.ApercuTitle = sprintf('%s %s %i %i',BaseData.Type,BaseData.SName,Stations(BaseData.StationNum),Year(i));
    % Plot Titles
    BaseData.PlotTitle = sprintf('%s Staion %i Max M+ [Top %i/Year] | 40m Simple Span',BaseData.SName,Stations(BaseData.StationNum),BaseData.NumAnalyses);
    
    % Further trimming if necessary
    if BaseData.Stage2Prune
        PDCx = PruneWIM2(PDCx,0);
    end
    
    if BaseData.ClassOnly
        PDCx(PDCx.CLASS == 0,:) = [];
    end
            
    % Convert PDC to AllTrAx
    [PDCx, AllTrAx, TrLineUp] = WIMtoAllTrAx(PDCx,round(Inf.x(end)),Lane.Dir,BaseData.ILRes);
    
    % Round TrLineUp first row, move unrounded to fifth row
    TrLineUp(:,5) = TrLineUp(:,1); TrLineUp(:,1) = round(TrLineUp(:,1)/BaseData.ILRes);
    
    
    
    
    [x,y] = AxleStats(PDCx,TrAxPerGr,TrTyps,BaseData.SName,Year(i),1);
    
    
        
    J = (PDC.GW_TOT/102)./(PDC.LENTH/100);
    M = [M; mean(J) prctile(J,95) prctile(J,99) prctile(J,99.99)];
    
    
    L = PDC.W1_2+PDC.W2_3+PDC.W3_4+PDC.W4_5+PDC.W5_6+PDC.W6_7+PDC.W7_8;
    L = L + 255;
    
    Jx = (PDC.GW_TOT/102)./(L/100);
    Mx = [Mx; mean(Jx) prctile(Jx,95) prctile(Jx,99) prctile(Jx,99.99)];
    
    %PD = PD(PD.ZST == 408,:);
%     [TotDaysOpen(x), y] = size(unique(PD.JJJJMMTT));
%     [NumTrucks(x), z] = size(PD);
%     ADTT(x) = NumTrucks(x)/TotDaysOpen(x);
%     AvgWeight(x) = mean(PD.GW_TOT);
%     StdWeight(x) = std(PD.GW_TOT); 
    
end

% x = [StartY:EndY];
% plot(x,ADTT)
% 
% z = [mean(Lane1) mean(Lane2) mean(Lane3) mean(Lane4)];
% 
% bar(z)
