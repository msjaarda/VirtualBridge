function [PDC] = Classify_FLM4(PD)
% CLASSIFY This functions takes a WIM Station's name (Station) and data
% collection year (Year), and gives back a Table variable, PDC, with an
% additional column "CLASS" to the normal WIM Table variable PD, with vehicles classes.
% PD stands for "processed data", and it means it is been through a filter
% since the RD "raw data" stage. RD variables are available in the
% PrePruning folder, but the directions have not yet been combined in that
% form.

% Classificaiton according to FLM4

% SName (string), Year (string OR number)

% This classification scheme uses numbers, not strings. Keep in mind:
% Type 1 (11)  : T1
% Type 2 (12)  : T2
% Type 3 (113) : T3
% Type 4 (112) : T4
% Type 5 (1112): T5

% NOTE: During DailytoYearly.m, we created additional table columns so that
% the variables would work with the "Traffic Analysis" program. We
% populated these columns with zeros. However, we do have data from
% those columns from PruneTRDTXTFile. So we won't delete them.

% Add a table column for Classification "CLASS"

PDC = PD;
PDC.CLASS = zeros(size(PDC,1),1);

% Classify vehicles! User must edit this code if classification
% parameters change.

% Type 1)
% Num Axles
Axles = PDC.AX == 2;
% Distance between Axles
Dist12 = PDC.W1_2 >= 300 & PDC.W1_2 < 600;
% Weight
Weight = PDC.GW_TOT >= 6000 & PDC.GW_TOT < 30000;
% Together
Type = logical(Axles.*Dist12.*Weight);
% Change table entries
PDC.CLASS(Type,:) = 1;

% Type 2)
Axles = PDC.AX == 3;
Dist12 = PDC.W1_2 >= 270 & PDC.W1_2 < 570;
Dist23 = PDC.W2_3 >= 60 & PDC.W2_3 < 240;
Weight = PDC.GW_TOT >= 7000 & PDC.GW_TOT < 45000;
Type = logical(Axles.*Dist12.*Dist23.*Weight);
PDC.CLASS(Type,:) = 2;

% Type 4)
Axles = PDC.AX == 4;
Dist12 = PDC.W1_2 >= 190 & PDC.W1_2 < 490;
Dist23 = PDC.W2_3 >= 360 & PDC.W2_3 < 860;
Dist34 = PDC.W3_4 >= 60 & PDC.W3_4 < 330;
Weight = PDC.GW_TOT >= 8000 & PDC.GW_TOT < 60000;
Type = logical(Axles.*Dist12.*Dist23.*Dist34.*Weight);
PDC.CLASS(Type,:) = 4;

% Type 3)
Axles = PDC.AX == 5;
Dist12 = PDC.W1_2 >= 170 & PDC.W1_2 < 470;
Dist23 = PDC.W2_3 >= 360 & PDC.W2_3 < 860;
Dist34 = PDC.W3_4 >= 60 & PDC.W3_4 < 280;
Dist45 = PDC.W4_5 >= 60 & PDC.W4_5 < 280;
Weight = PDC.GW_TOT >= 9000 & PDC.GW_TOT < 75000;
Type = logical(Axles.*Dist12.*Dist23.*Dist34.*Dist45.*Weight);
PDC.CLASS(Type,:) = 3; 

% Type 5)
Axles = PDC.AX == 5;
Dist12 = PDC.W1_2 >= 330 & PDC.W1_2 < 630;
Dist23 = PDC.W2_3 >= 210 & PDC.W2_3 < 510;
Dist34 = PDC.W3_4 >= 290 & PDC.W3_4 < 590;
Dist45 = PDC.W4_5 >= 60 & PDC.W4_5 < 270;
Weight = PDC.GW_TOT >= 9000 & PDC.GW_TOT < 75000;
Type = logical(Axles.*Dist12.*Dist23.*Dist34.*Dist45.*Weight);
PDC.CLASS(Type,:) = 5; 

end

