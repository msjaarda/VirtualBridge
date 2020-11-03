% Figure 2.17 of AGB 2009/005
clear, clc, close all

% First we need to load in and combine all files
% Then we set about trying to identify 5 and 6 axle 12t/axle 60 t and 72 t

% NEXT STEPS: TRY OTHER PLOTS FROM the below (particularly SName 5 and 6...
% to see if we have the same data set as TM did. Could also try going from
% RAW WIM, but actually we see we have none for these...

% Add in Static output to OutInfo for comparison in AGBPlots

Year = 2009;
SName{1} = 'Schafisheim'; SName{2} = 'StMaurice';

for i = 1:length(SName)
    load(['PrunedS1 WIM/',SName{i},'/',SName{i},'_',num2str(Year),'.mat']);
    
    PDC = Classify(PD);

FontSize = 10;
FontCo = 'k';
Div = 100;

T = 122;
figure

range = 250:10:600;
histogram(PDC.GW_TOT(PDC.CLASS == T)/Div,range,'Normalization','pdf');
title(sprintf('%s Type %i',SName{i},T));
N = sum(PDC.CLASS == T);
Mean = mean(PDC.GW_TOT(PDC.CLASS == T)/Div);
Stdev = std(PDC.GW_TOT(PDC.CLASS == T)/Div);
f95 = prctile(PDC.GW_TOT(PDC.CLASS == T)/Div,95);
f99 = prctile(PDC.GW_TOT(PDC.CLASS == T)/Div,99);
hold on
ylim([0 0.01]);
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

ytickformat('percentage');
%yticks(0:0.005:0.01); %xticks(500:10:900)
% Set axis limits


T = 1138;
figure

range = 250:10:600;
histogram(PDC.GW_TOT(PDC.CLASS == T)/Div,range,'Normalization','pdf');
title(sprintf('%s Type %i',SName{i},T));
N = sum(PDC.CLASS == T);
Mean = mean(PDC.GW_TOT(PDC.CLASS == T)/Div);
Stdev = std(PDC.GW_TOT(PDC.CLASS == T)/Div);
f95 = prctile(PDC.GW_TOT(PDC.CLASS == T)/Div,95);
f99 = prctile(PDC.GW_TOT(PDC.CLASS == T)/Div,99);
hold on
ylim([0 0.01]);
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

ytickformat('percentage');
%yticks(0:0.005:0.01); %xticks(600:10:1000)

T = 23;
figure

range = 250:10:600;
histogram(PDC.GW_TOT(PDC.CLASS == T)/Div,range,'Normalization','pdf');
title(sprintf('%s Type %i',SName{i},T));
N = sum(PDC.CLASS == T & PDC.GW_TOT > 25000);
Mean = mean(PDC.GW_TOT(PDC.CLASS == T  & PDC.GW_TOT > 25000)/Div);
Stdev = std(PDC.GW_TOT(PDC.CLASS == T  & PDC.GW_TOT > 25000)/Div);
f95 = prctile(PDC.GW_TOT(PDC.CLASS == T  & PDC.GW_TOT > 25000)/Div,95);
f99 = prctile(PDC.GW_TOT(PDC.CLASS == T  & PDC.GW_TOT > 25000)/Div,99);
hold on
ylim([0 0.015]);
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

ytickformat('percentage');

end
