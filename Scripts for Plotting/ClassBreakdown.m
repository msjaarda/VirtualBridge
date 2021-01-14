% Classification information including breakdown of vehicles by type...
% Generates a pie chart

% Legend of Vehicle Types:
% 7 = "r"
% 8 = "a"
% 9 = "bis"

clear
clc
close all
format long g

% INPUT -----------
Year = 2017;
SName = 'Denges';

% Let the Classify function add the .CLASS column to PD
load(['PrunedS1 WIM/',SName,'/',SName,'_',num2str(Year),'.mat']);
PDC = Classify(PD);

% Try certain methods of predisqualification to see if we get better
% coverage

% Must redo last two prunings because PDC draws fresh PD w/ only Stage 1
% 1. Disqualification by weight (try under 6 or 10 tonnes)
PDC = PDC(PDC.GW_TOT > 6000,:);
% 2. Disqualification by Swiss10 Class (exclude 2,3,4,6)
% Not all years have proper Sw10 data... therefore exclude, not include
PDC(PDC.CS == 2 | PDC.CS == 3 | PDC.CS == 4 | PDC.CS == 6,:) = [];
%PDC = PDC(PDC.CS == 1 | PDC.CS == 5 | PDC.CS == 8 | PDC.CS == 9 | PDC.CS == 10,:);
% Get rid of overweight classes and class 11bis
PDC.CLASS(PDC.CLASS > 39 & PDC.CLASS < 50) = 0;
PDC.CLASS(PDC.CLASS == 119) = 0;

vector = [11 12 22 23 111 11117 1127 12117 122 11127 1128 1138 1238 0];
w = zeros(length(vector),1); x = w;

for i = 1:length(vector)
    w(i) = sum(PDC.GW_TOT(PDC.CLASS == vector(i)));
    x(i) = sum(PDC.CLASS == vector(i));
end

% Get total weight of trucks, TW
TW = sum(w);
% Get number of trucks, NT
NT = height(PDC);

% Labels with percentages (by # vehicles)
labelsn = {sprintf('[11] %.1f%%', 100*x(1)/NT)...
    sprintf('[12] %.1f%%', 100*x(2)/NT) sprintf('[22] %.1f%%', 100*x(3)/NT)...
    sprintf('[23] %.1f%%', 100*x(4)/NT) sprintf('[111] %.1f%%', 100*x(5)/NT)...
    sprintf('[111r] %.1f%%', 100*x(6)/NT) sprintf('[112r] %.1f%%', 100*x(7)/NT)...
    sprintf('[1211r] %.1f%%', 100*x(8)/NT) sprintf('[122] %.1f%%', 100*x(9)/NT)...
    sprintf('[1112r] %.1f%%', 100*x(10)/NT) sprintf('[112a] %.1f%%', 100*x(11)/NT)...
    sprintf('[113a] %.1f%%', 100*x(12)/NT) sprintf('[123a] %.1f%%', 100*x(13)/NT)... 
    sprintf('No Class %.1f%%', 100*x(14)/NT)};

% Labels with percentages (by weight)
labelsw = {sprintf('[11] %.1f%%', 100*w(1)/TW)...
    sprintf('[12] %.1f%%', 100*w(2)/TW) sprintf('[22] %.1f%%', 100*w(3)/TW)...
    sprintf('[23] %.1f%%', 100*w(4)/TW) sprintf('[111] %.1f%%', 100*w(5)/TW)...
    sprintf('[111r] %.1f%%', 100*w(6)/TW) sprintf('[112r] %.1f%%', 100*w(7)/TW)...
    sprintf('[1211r] %.1f%%', 100*w(8)/TW) sprintf('[122] %.1f%%', 100*w(9)/TW)...
    sprintf('[1112r] %.1f%%', 100*w(10)/TW) sprintf('[112a] %.1f%%', 100*w(11)/TW)...
    sprintf('[113a] %.1f%%', 100*w(12)/TW) sprintf('[123a] %.1f%%', 100*w(13)/TW)... 
    sprintf('No Class %.1f%%', 100*w(14)/TW)};


% Which ones should be highlighted?
explode = [1 1 1 1 1 1 1 1 1 1 1 1 1 1];
explode = [0 0 0 0 0 0 0 0 0 0 0 0 0 0];
%explode = x/NT < 0.03;

figure('Position',[200 200 1436 650]);

% Create pie chart
subplot(1,2,1);
h = pie(x, explode, labelsn);
th = findobj(h,'Type','Text'); % text handles
isSmall = endsWith({th.String}, '<');
title('Class Coverage by Number')

subplot(1,2,2);
h2 = pie(w, explode, labelsw);
title('Class Coverage by Weight')

COLs = [0 0 0 0 0 0 0 0 0 0 0 0 0 0];

set(gcf,'color','w');
patchHand = findobj(h, 'Type', 'Patch'); 
patchHand2 = findobj(h2, 'Type', 'Patch'); 
for i = 1:4
    patchHand(i).FaceColor = 'w';
    patchHand2(i).FaceColor = 'w';
end
for i = 5:10
    patchHand(i).FaceColor = [0.4 0.4 0.4];
    patchHand2(i).FaceColor = [0.4 0.4 0.4];
end
for i = 11:13
    patchHand(i).FaceColor = [0.7 0.7 0.7];
    patchHand2(i).FaceColor = [0.7 0.7 0.7];
end
for i = 14
    patchHand(i).FaceColor = 'k';
    patchHand2(i).FaceColor = 'k';
end

sgtitle('Denges 2017 WIM','fontweight','bold','fontsize',14);