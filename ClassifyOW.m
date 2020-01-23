% Similar to Classify (function)... keep this for OW investigations
% Used to create overweight vehicles memo for tessin project (Oct 19')

clear
close all
format long g

Station = 'Ceneri';
Year = 2018;

% NOTE that this version of Classify only involves overweight (OW)
% vehicles. It should be run separate from Classify

% This classification scheme uses numbers, not strings. Keep in mind:
% Type 5 axle 60 tonne:       41          see F2.17 AGB 2002/005 cranetruck
% Type 6 axle 60 tonne:       42          see Veicoli Standard Spreadsheet
% Type 7 axle 72 tonne:       43          see Veicoli Standard Spreadsheet
% Type 8 axle 84 tonne:       44          see Veicoli Standard Spreadsheet
% Type 9 axle 96 tonne:       45          see Veicoli Standard Spreadsheet
% Type 8 axle 96 tonne:       46          see FA.8 AGB 2002/005 cranetruck

% Legned of Vehicle Types:
% 4 = "Overweight"

% Load PD variable
load(strcat(Station,'_',num2str(Year),'.mat'))

% We should only do this if the vehicle is not already classified!
% Therefore, we call "Classify" within this...
PDC = Classify(Station,Year);

% Do a very basic filtering to remove vehicles with any wheelbases greater
% than 6.5 meters.
L = PDC.GW_TOT > 50000 & (PDC.W1_2 > 650 | PDC.W2_3 > 650 | PDC.W3_4 > 650 | PDC.W4_5 > 650 | PDC.W5_6 > 650 | PDC.W6_7 > 650 | PDC.W7_8 > 650 | PDC.W8_9 > 650);
%sum(L)
PDC(L,:) = [];
L = PDC.GW_TOT > 50000 & (PDC.W1_2 > 610 | PDC.W2_3 > 610 | PDC.W3_4 > 610 | PDC.W4_5 > 610 | PDC.W5_6 > 610 | PDC.W6_7 > 610 | PDC.W7_8 > 610 | PDC.W8_9 > 610);
%sum(L)

% Gather initial unclassified info for output to excel

% [total number | # unclassified]
Weight = PDC.GW_TOT >= 50000 & PDC.GW_TOT < 65000;
SummaryMatrix(1,:) = [sum(Weight) sum(PDC.CLASS(Weight) == 0)/sum(Weight)];
Weight = PDC.GW_TOT >= 65000 & PDC.GW_TOT < 78000;
SummaryMatrix(2,:) = [sum(Weight) sum(PDC.CLASS(Weight) == 0)/sum(Weight)];
Weight = PDC.GW_TOT >= 78000 & PDC.GW_TOT < 90000;
SummaryMatrix(3,:) = [sum(Weight) sum(PDC.CLASS(Weight) == 0)/sum(Weight)];
Weight = PDC.GW_TOT >= 90000 & PDC.GW_TOT < 100000;
SummaryMatrix(4,:) = [sum(Weight) sum(PDC.CLASS(Weight) == 0)/sum(Weight)];

% User must edit this code if classification parameters change.

% Type 41) 60 tonne crane truck from F2.17 of AGB 2002/005
% This could have overlap with Type 23, so don't expect too many
% Unclassified
UnClass = PDC.CLASS == 0;
% Num Axles
Axles = PDC.AX == 5;
% Distance between Axles
Dist12 = PDC.W1_2 >= 100 & PDC.W1_2 < 360;
Dist23 = PDC.W2_3 >= 60 & PDC.W2_3 < 240;
Dist34 = PDC.W3_4 >= 60 & PDC.W3_4 < 240;
Dist45 = PDC.W4_5 >= 60 & PDC.W4_5 < 240;
% Weight
%Weight = PDC.GW_TOT >= 50000 & PDC.GW_TOT < 65000;
Weight = PDC.GW_TOT >= 50000 & PDC.GW_TOT < 100000;
% Together
Type = logical(UnClass.*Axles.*Dist12.*Dist23.*Dist34.*Dist45.*Weight);
% Change table entries
PDC.CLASS(Type,:) = 41;

% Type 42) 60 tonne crane truck from Veicoli Standard Spreadsheet
UnClass = PDC.CLASS == 0;
Axles = PDC.AX == 6;
Dist12 = PDC.W1_2 >= 80 & PDC.W1_2 < 340;
Dist23 = PDC.W2_3 >= 80 & PDC.W2_3 < 340;
Dist34 = PDC.W3_4 >= 240 & PDC.W3_4 < 540;
Dist45 = PDC.W4_5 >= 60 & PDC.W4_5 < 240;
Dist56 = PDC.W5_6 >= 60 & PDC.W5_6 < 240;
%Weight = PDC.GW_TOT >= 50000 & PDC.GW_TOT < 65000;
Weight = PDC.GW_TOT >= 50000 & PDC.GW_TOT < 100000;
Type = logical(UnClass.*Axles.*Dist12.*Dist23.*Dist34.*Dist45.*Dist56.*Weight);
PDC.CLASS(Type,:) = 42;

% Type 43) 72 tonne crane truck from Veicoli Standard Spreadsheet
UnClass = PDC.CLASS == 0;
Axles = PDC.AX == 7;
Dist12 = PDC.W1_2 >= 80 & PDC.W1_2 < 340;
Dist23 = PDC.W2_3 >= 80 & PDC.W2_3 < 340;
Dist34 = PDC.W3_4 >= 340 & PDC.W3_4 < 640;
Dist45 = PDC.W4_5 >= 60 & PDC.W4_5 < 240;
Dist56 = PDC.W5_6 >= 60 & PDC.W5_6 < 240;
Dist67 = PDC.W6_7 >= 60 & PDC.W6_7 < 240;
%Weight = PDC.GW_TOT >= 65000 & PDC.GW_TOT < 78000;
Weight = PDC.GW_TOT >= 50000 & PDC.GW_TOT < 100000;
Type = logical(UnClass.*Axles.*Dist12.*Dist23.*Dist34.*Dist45.*Dist56.*Dist67.*Weight);
PDC.CLASS(Type,:) = 43;

% Type 44) 84 tonne crane truck from Veicoli Standard Spreadsheet
UnClass = PDC.CLASS == 0;
Axles = PDC.AX == 8;
Dist12 = PDC.W1_2 >= 80 & PDC.W1_2 < 340;
Dist23 = PDC.W2_3 >= 80 & PDC.W2_3 < 340;
Dist34 = PDC.W3_4 >= 80 & PDC.W3_4 < 340;
Dist45 = PDC.W4_5 >= 440 & PDC.W4_5 < 740;
Dist56 = PDC.W5_6 >= 60 & PDC.W5_6 < 240;
Dist67 = PDC.W6_7 >= 60 & PDC.W6_7 < 240;
Dist78 = PDC.W7_8 >= 60 & PDC.W7_8 < 240;
%Weight = PDC.GW_TOT >= 78000 & PDC.GW_TOT < 90000;
Weight = PDC.GW_TOT >= 50000 & PDC.GW_TOT < 100000;
Type = logical(UnClass.*Axles.*Dist12.*Dist23.*Dist34.*Dist45.*Dist56.*Dist67.*Dist78.*Weight);
PDC.CLASS(Type,:) = 44;

% Type 45) 96 tonne crane truck from Veicoli Standard Spreadsheet
UnClass = PDC.CLASS == 0;
Axles = PDC.AX == 9;
Dist12 = PDC.W1_2 >= 80 & PDC.W1_2 < 340;
Dist23 = PDC.W2_3 >= 60 & PDC.W2_3 < 340;
Dist34 = PDC.W3_4 >= 60 & PDC.W3_4 < 340;
Dist45 = PDC.W4_5 >= 440 & PDC.W4_5 < 740;
Dist56 = PDC.W5_6 >= 60 & PDC.W5_6 < 240;
Dist67 = PDC.W6_7 >= 60 & PDC.W6_7 < 240;
Dist78 = PDC.W7_8 >= 60 & PDC.W7_8 < 240;
Dist89 = PDC.W8_9 >= 60 & PDC.W8_9 < 240;
%Weight = PDC.GW_TOT >= 90000 & PDC.GW_TOT < 100000;
Weight = PDC.GW_TOT >= 50000 & PDC.GW_TOT < 100000;
Type = logical(UnClass.*Axles.*Dist12.*Dist23.*Dist34.*Dist45.*Dist56.*Dist67.*Dist78.*Dist89.*Weight);
PDC.CLASS(Type,:) = 45;

% Type 46) 96 tonne crane truck from FA.8 AGB 2002/005 
UnClass = PDC.CLASS == 0;
Axles = PDC.AX == 8;
Dist12 = PDC.W1_2 >= 60 & PDC.W1_2 < 340;
Dist23 = PDC.W2_3 >= 60 & PDC.W2_3 < 340;
Dist34 = PDC.W3_4 >= 100 & PDC.W3_4 < 360;
Dist45 = PDC.W4_5 >= 60 & PDC.W4_5 < 340;
Dist56 = PDC.W5_6 >= 60 & PDC.W5_6 < 340;
Dist67 = PDC.W6_7 >= 80 & PDC.W6_7 < 350;
Dist78 = PDC.W7_8 >= 60 & PDC.W7_8 < 340;
%Weight = PDC.GW_TOT >= 90000 & PDC.GW_TOT < 100000;
Weight = PDC.GW_TOT >= 50000 & PDC.GW_TOT < 100000;
Type = logical(UnClass.*Axles.*Dist12.*Dist23.*Dist34.*Dist45.*Dist56.*Dist67.*Dist78.*Weight);
PDC.CLASS(Type,:) = 46;

%aftewards, check how many in each weight range actually got classified
Weight = PDC.GW_TOT >= 50000 & PDC.GW_TOT < 65000;
fprintf('Number and Percent Unclassified from 50t-65t: %.0f, %.1f \n',sum(Weight),100*sum(PDC.CLASS(Weight) == 0)/sum(Weight))
Weight = PDC.GW_TOT >= 65000 & PDC.GW_TOT < 78000;
fprintf('Number and Percent Unclassified from 65t-78t: %.0f, %.1f \n',sum(Weight),100*sum(PDC.CLASS(Weight) == 0)/sum(Weight))
Weight = PDC.GW_TOT >= 78000 & PDC.GW_TOT < 90000;
fprintf('Number and Percent Unclassified from 78t-90t: %.0f, %.1f \n',sum(Weight),100*sum(PDC.CLASS(Weight) == 0)/sum(Weight))
Weight = PDC.GW_TOT >= 90000 & PDC.GW_TOT < 100000;
fprintf('Number and Percent Unclassified from 90t-100t: %.0f, %.1f \n',sum(Weight),100*sum(PDC.CLASS(Weight) == 0)/sum(Weight))

fprintf('\nNumber of Special Vehicles with 5 and 6 axles (60): %.0f, %.1f \n',sum(PDC.CLASS == 41 |PDC.CLASS == 42),mean(PDC.GW_TOT(PDC.CLASS == 41 |PDC.CLASS == 42))/1000)
fprintf('Number of Special Vehicles with 7 axles (72): %.0f, %.1f \n',sum(PDC.CLASS == 43),mean(PDC.GW_TOT(PDC.CLASS == 43))/1000)
fprintf('Number of Special Vehicles with 8 axles (84): %.0f, %.1f \n',sum(PDC.CLASS == 44),mean(PDC.GW_TOT(PDC.CLASS == 44))/1000)
fprintf('Number of Special Vehicles with 8 or 9 axles (96): %.0f, %.1f \n\n',sum(PDC.CLASS == 45 |PDC.CLASS == 46),mean(PDC.GW_TOT(PDC.CLASS == 45 |PDC.CLASS == 46))/1000)

SummaryMatrixT(1,1) = sum(PDC.CLASS == 41);
SummaryMatrixT(1,2) = mean(PDC.GW_TOT(PDC.CLASS == 41))/1000;
SummaryMatrixT(2,1) = sum(PDC.CLASS == 42);
SummaryMatrixT(2,2) = mean(PDC.GW_TOT(PDC.CLASS == 42))/1000;
SummaryMatrixT(3,1) = sum(PDC.CLASS == 43);
SummaryMatrixT(3,2) = mean(PDC.GW_TOT(PDC.CLASS == 43))/1000;
SummaryMatrixT(4,1) = sum(PDC.CLASS == 44);
SummaryMatrixT(4,2) = mean(PDC.GW_TOT(PDC.CLASS == 44))/1000;
SummaryMatrixT(5,1) = sum(PDC.CLASS == 45);
SummaryMatrixT(5,2) = mean(PDC.GW_TOT(PDC.CLASS == 45))/1000;
SummaryMatrixT(6,1) = sum(PDC.CLASS == 46);
SummaryMatrixT(6,2) = mean(PDC.GW_TOT(PDC.CLASS == 46))/1000;

% for output to excel

% [total number | # unclassified previously | # unclassified now] for each
% [total number | # unclassified]
Weight = PDC.GW_TOT >= 50000 & PDC.GW_TOT < 65000;
SummaryMatrix(1,3) = sum(PDC.CLASS(Weight) == 0)/sum(Weight);
Weight = PDC.GW_TOT >= 65000 & PDC.GW_TOT < 78000;
SummaryMatrix(2,3) = sum(PDC.CLASS(Weight) == 0)/sum(Weight);
Weight = PDC.GW_TOT >= 78000 & PDC.GW_TOT < 90000;
SummaryMatrix(3,3) = sum(PDC.CLASS(Weight) == 0)/sum(Weight);
Weight = PDC.GW_TOT >= 90000 & PDC.GW_TOT < 100000;
SummaryMatrix(4,3) = sum(PDC.CLASS(Weight) == 0)/sum(Weight);


writematrix(SummaryMatrix,'Overloaded Vehicles.xlsx','Range','C3');
writematrix(SummaryMatrixT,'Overloaded Vehicles.xlsx','Range','H3');