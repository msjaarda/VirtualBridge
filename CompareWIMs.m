clear, clc, hold off, close all, format long g

% File #1: Year, #, Station Name, string
%Year = 2017; SName = 'Ceneri'; 
Year = 2003; SName = 'Ceneri'; 
% File #2: Year, #, Station Name, string
%Name = 'WIM_Nov14 1419';
Year2 = 2018; SName2 = 'Ceneri';

%load(['VirtualWIM/',Name,'.mat']); PDC2 = Classify(PD);
load(['PrunedS1 WIM/',SName2,'/',SName2,'_',num2str(Year2),'.mat']); PDC2 = Classify(PD);
load(['PrunedS1 WIM/',SName,'/',SName,'_',num2str(Year),'.mat']); PDC = Classify(PD);

% Stage 2 Custom Pruning (two more of our own)
% 1. Disqualification by weight (under 6 tonnes)
PDC = PDC(PDC.GW_TOT > 6000,:);
% 2. Disqualification by Swiss10 Class (exclude 2,3,4,6)
if sum(PDC.CS == 2 | PDC.CS == 3 | PDC.CS == 4 | PDC.CS == 6) < 0.7*height(PDC)
    PDC(PDC.CS == 2 | PDC.CS == 3 | PDC.CS == 4 | PDC.CS == 6,:) = [];
end
% Get rid of overweight classes and class 11bis
PDC.CLASS(PDC.CLASS > 39 & PDC.CLASS < 50) = 0; PDC.CLASS(PDC.CLASS == 119) = 0;

TrName{1} = '11'; TrName{2} = '12'; TrName{3} = '22'; TrName{4} = '23'; TrName{5} = '111'; TrName{6} = '1111r'; TrName{7} = '112r'; 
TrName{8} = '1211r'; TrName{9} = '122'; TrName{10} = '1112r'; TrName{11} = '112a'; TrName{12} = '113a'; TrName{13} = '123a'; 
TrName = TrName';

TrTyps = [11; 12; 22; 23; 111; 11117; 1127; 12117; 122; 11127; 1128; 1138; 1238];
TrAxPerGr = [11; 12; 22; 23; 111; 1111; 112; 1211; 122; 1112; 112; 113; 123];
TrTypPri = [21; 21; 21; 21; 321; 2341; 231; 2341; 231; 2341; 321; 321; 321];

% LinFit_Excel = LinFit(PDC,TrName,TrTyps,TrAxPerGr,TrTypPri,SName,Year,PlotFits);
% Distr_Excel = Distr(PDC,TrName,TrTyps,TrAxPerGr,TrTypPri,SName,Year,PlotFits);

% Compare Weight by Axles
[STaTr,AllAx] = AxleStats(PDC,TrAxPerGr,TrTyps,SName,Year,1);
[STaTr2,AllAx2] = AxleStats(PDC2,TrAxPerGr,TrTyps,SName,Year,1);

% Compare Distances between Axles
BetAx_Excel = BetAx(PDC,TrName,TrTyps,TrAxPerGr,TrTypPri,SName,Year,1);
BetAx_Excel2 = BetAx(PDC2,TrName,TrTyps,TrAxPerGr,TrTypPri,SName,Year,1);
