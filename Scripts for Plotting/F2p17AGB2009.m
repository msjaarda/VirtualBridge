% Figure 2.17 of AGB 2009/005
clear, clc, close all

% First we need to load in and combine all files
% Then we set about trying to identify 5 and 6 axle 12t/axle 60 t and 72 t

Year = 2018;
SName{1} = 'Ceneri'; SName{2} = 'Denges'; SName{3} = 'Gotthard';
SName{4} = 'Oberburen'; %SName{5} = 'Schafisheim'; SName{6} = 'StMaurice';

PDC = [];
for i = 1:length(SName)
    load(['PrunedS1 WIM/',SName{i},'/',SName{i},'_',num2str(Year),'.mat']);
    PDC = [PDC; PD];
end
clear PD;
PDC.CLASS = zeros(size(PDC,1),1);

% Try to identify vehicles
FL = 160; FH = 320;
BL = 100; BH = 220;
Div = 100; % Could be set to 102 for more accuracy (but TM did 100 we think)

% Type 41) 60 tonne crane truck from F2.17 of AGB 2002/005
% Num Axles
Axles = PDC.AX == 5;
% Distance between Axles
Dist12 = PDC.W1_2 >= 160 & PDC.W1_2 < 300;
Dist23 = PDC.W2_3 >= BL & PDC.W2_3 < BH;
Dist34 = PDC.W3_4 >= BL & PDC.W3_4 < BH;
Dist45 = PDC.W4_5 >= BL & PDC.W4_5 < BH;
Over9 = PDC.AWT01 > 9000 & PDC.AWT02 > 9000 & PDC.AWT03 > 9000 & PDC.AWT04 > 9000 & PDC.AWT05 > 9000;
% Weight
Weight = PDC.GW_TOT >= 50000 & PDC.GW_TOT < 90000;
% Together
Type = logical(Axles.*Dist12.*Dist23.*Dist34.*Dist45.*Weight.*Over9);
% Change table entries
PDC.CLASS(Type,:) = 41;

% Using Type 47 because types 41-46 are taken (see Classify)
% Type 47) 73 tonne crane truck from F2.17 of AGB 2009/005
% Num Axles
Axles = PDC.AX == 6;
% Distance between Axles
Dist12 = PDC.W1_2 >= 100 & PDC.W1_2 < 400;
Dist23 = PDC.W2_3 >= BL & PDC.W2_3 < BH;
Dist34 = PDC.W3_4 >= 100 & PDC.W3_4 < 400;
Dist45 = PDC.W4_5 >= BL & PDC.W4_5 < BH;
Dist56 = PDC.W5_6 >= BL & PDC.W5_6 < BH;
Over9 = PDC.AWT01 > 9000 & PDC.AWT02 > 9000 & PDC.AWT03 > 9000 & PDC.AWT04 > 9000 & PDC.AWT05 & PDC.AWT06 > 9000;
% Weight
Weight = PDC.GW_TOT >= 60000 & PDC.GW_TOT < 100000;
% Together
Type = logical(Axles.*Dist12.*Dist23.*Dist34.*Dist45.*Dist56.*Weight.*Over9);
% Change table entries
PDC.CLASS(Type,:) = 47;

FontSize = 10;
FontCo = 'k';

T(1) = 41; T(2) = 47;
range{1}= 500:10:900;  range{2} = 600:10:1000;
min(1) = 50000; min(2) = 60000;

for i = 1:length(T)
    figure
    histogram(PDC.GW_TOT(PDC.CLASS == T(i))/Div,range{i},'Normalization','pdf','FaceColor',[0.5 0.5 0.5],'LineWidth',1);
    N = sum(PDC.CLASS == T(i) & PDC.GW_TOT > min(i));
    Mean = mean(PDC.GW_TOT(PDC.CLASS == T(i) & PDC.GW_TOT > min(i))/Div);
    Stdev = std(PDC.GW_TOT(PDC.CLASS == T(i) & PDC.GW_TOT > min(i))/Div);
    f95 = prctile(PDC.GW_TOT(PDC.CLASS == T(i) & PDC.GW_TOT > min(i))/Div,95);
    f99 = prctile(PDC.GW_TOT(PDC.CLASS == T(i) & PDC.GW_TOT > min(i))/Div,99);
    hold on
    c = ylim;
    b = xlim;
    % Put statistics onto histogram
    text(b(2)-150,c(2)*13/16,sprintf('N'),'FontSize',FontSize,'Color',FontCo)
    text(b(2)-150,c(2)*12/16,sprintf('Mean'),'FontSize',FontSize,'Color',FontCo)
    text(b(2)-150,c(2)*11/16,sprintf('Stdev'),'FontSize',FontSize,'Color',FontCo)
    text(b(2)-150,c(2)*10/16,sprintf('F_{95}'),'FontSize',FontSize,'Color',FontCo)
    text(b(2)-150,c(2)*9/16,sprintf('F_{99}'),'FontSize',FontSize,'Color',FontCo)
    text(b(2)-100,c(2)*13/16,sprintf('= %i',N),'FontSize',FontSize,'Color',FontCo)
    text(b(2)-100,c(2)*12/16,sprintf('= %.1f kN',Mean),'FontSize',FontSize,'Color',FontCo)
    text(b(2)-100,c(2)*11/16,sprintf('= %.1f kN',Stdev),'FontSize',FontSize,'Color',FontCo)
    text(b(2)-100,c(2)*10/16,sprintf('= %.1f kN',f95),'FontSize',FontSize,'Color',FontCo)
    text(b(2)-100,c(2)*9/16,sprintf('= %.1f kN',f99),'FontSize',FontSize,'Color',FontCo)
    
    yticks([]);  
    ylabel('PDF')
    xlabel('Total Weight (kN)')
end

