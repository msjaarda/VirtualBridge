clear
clc
close all
format long g

StartY = 2015;
EndY = 2018;
SName = 'Ceneri';
x = 0;
M = [];
Mx = [];

for i = 2017%EndY:-1:StartY
    
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
    
    
    x = x+1;
    load(['PrunedS1 WIM/',SName,'/',SName,'_',num2str(i),'.mat']);
    PDC = Classify(PD);
    
    
    J = (PDC.GW_TOT/102)./(PDC.LENTH/100);
    M = [M; mean(J) prctile(J,95) prctile(J,99) prctile(J,99.99)];
    
    
    Q = PDC.W1_2+PDC.W2_3+PDC.W3_4+PDC.W4_5+PDC.W5_6+PDC.W6_7+PDC.W7_8;
    Q = Q + 255;
    
    Jx = (PDC.GW_TOT/102)./(Q/100);
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
