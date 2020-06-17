% Classification information including breakdown of vehicles by type...
% Generates a pie chart

clear
clc
close all
format long g

% INPUT -----------
Year = 2018;
SName = 'A16';

% Let the Classify function add the .CLASS column to PD
load(['PrunedS1 WIM/',SName,'/',SName,'_',num2str(Year),'.mat']);
PDC = Classify_FLM4(PD);

% Try certain methods of predisqualification to see if we get better
% coverage

% Must redo last two prunings because PDC draws fresh PD w/ only Stage 1
% 1. Disqualification by weight (try under 6 or 10 tonnes)
PDC = PDC(PDC.GW_TOT > 6000,:);
% 2. Disqualification by Swiss10 Class (exclude 2,3,4,6)
% Note all years have proper Sw10 data... therefore exclude, not include
PDC(PDC.CS == 2 | PDC.CS == 3 | PDC.CS == 4 | PDC.CS == 6,:) = [];
%PDC = PDC(PDC.CS == 1 | PDC.CS == 5 | PDC.CS == 8 | PDC.CS == 9 | PDC.CS == 10,:);

vector = [1 2 3 4 5];
w = zeros(length(vector),1); x = w;

for i = 1:length(vector)
    w(i) = sum(PDC.GW_TOT(PDC.CLASS == vector(i)));
    x(i) = sum(PDC.CLASS == vector(i));
end

% Get total weight of trucks, TW
TW = sum(w);
% Get number of trucks, NT
%NT = height(PDC);
NT = sum(x);

% Labels with percentages (by # vehicles)
labelsn = {sprintf('[T1] %.1f%%', 100*x(1)/NT)...
    sprintf('[T2] %.1f%%', 100*x(2)/NT) sprintf('[T3] %.1f%%', 100*x(3)/NT)...
    sprintf('[T4] %.1f%%', 100*x(4)/NT) sprintf('[T5] %.1f%%', 100*x(5)/NT)};%...
    %sprintf('No Class %.1f%%', 100*x(6)/NT)};

% Labels with percentages (by weight)
labelsw = {sprintf('[T1] %.1f%%', 100*w(1)/TW)...
    sprintf('[T2] %.1f%%', 100*w(2)/TW) sprintf('[T3] %.1f%%', 100*w(3)/TW)...
    sprintf('[T4] %.1f%%', 100*w(4)/TW) sprintf('[T5] %.1f%%', 100*w(5)/TW)};%...
    %sprintf('No Class %.1f%%', 100*w(6)/TW)};


% Which ones should be highlighted?
%explode = [1 1 1 1 1 1];
explode = [0 0 0 0 0];

% Create pie chart
subplot(1,2,1);
pie(x, explode, labelsn);
title('Class Coverage by Number')

subplot(1,2,2);
pie(w, explode, labelsw);
title('Class Coverage by Weight')
