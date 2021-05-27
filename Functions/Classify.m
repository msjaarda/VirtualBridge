function [PDC] = Classify(PD)
% CLASSIFY This functions takes a WIM Station's name (Station) and data
% collection year (Year), and gives back a Table variable, PDC, with an
% additional column "CLASS" to the normal WIM Table variable PD, with vehicles classes.
% PD stands for "processed data", and it means it is been through a filter
% since the RD "raw data" stage. RD variables are available in the
% PrePruning folder, but the directions have not yet been combined in that
% form.

% Classificaiton according to AGB 2002/005 with the addition of Class 23
% and 11bis.

% There is the option to classify OW vehicles (see bottom)
ClassOW = true;

% SName (string), Year (string OR number)

% This classification scheme uses numbers, not strings. Keep in mind:
% Type 11:      11
% Type 11bis:   119
% Type 12:      12
% Type 22:      22
% Type 23:      23
% Type 111:     111
% Type 1111r:   11117
% Type 112r:    1127
% Type 1211r:   12117
% Type 122:     122
% Type 1112r:   11127
% Type 112a:    1128
% Type 113a:    1138
% Type 123a:    1238

% Legend of Vehicle Types:
% 7 = "r"     remorque
% 8 = "a"     articulated
% 9 = "bis"

% This classification scheme uses numbers, not strings. Keep in mind:
% Type 5 axle 60 tonne:       41          see F2.17 AGB 2002/005 cranetruck
% Type 6 axle 60 tonne:       42          see Veicoli Standard Spreadsheet
% Type 7 axle 72 tonne:       43          see Veicoli Standard Spreadsheet
% Type 8 axle 84 tonne:       44          see Veicoli Standard Spreadsheet
% Type 9 axle 96 tonne:       45          see Veicoli Standard Spreadsheet
% Type 8 axle 96 tonne:       46          see FA.8 AGB 2002/005 cranetruck

% Legend of Vehicle Types:
% 4 = "Overweight"

% Can add more HV classes here. See Excel OverWeightVehicleLibrary.xlsx

% NOTE: During DailytoYearly.m, we created additional table columns so that
% the variables would work with the "Traffic Analysis" program. We
% populated these columns with zeros. However, we do have data from
% those columns from PruneTRDTXTFile. So we won't delete them.

% Add a table column for Classification "CLASS"
PDC = PD;
PDC.CLASS = zeros(size(PDC,1),1);

% Classify vehicles! User must edit this code if classification
% parameters change.

% Type 11)
% Num Axles
Axles = PDC.AX == 2;
% Distance between Axles
Dist12 = PDC.W1_2 >= 360 & PDC.W1_2 < 720;
% Weight
Weight = PDC.GW_TOT >= 6000 & PDC.GW_TOT < 30000;
% Together
Type = logical(Axles.*Dist12.*Weight);
% Change table entries
PDC.CLASS(Type,:) = 11;

% Type 11bis)
% Axles = PDC.AX == 2;
% Dist12 = PDC.W1_2 >= 250 & PDC.W1_2 < 359;
% Weight = PDC.GW_TOT >= 3500 & PDC.GW_TOT < 30000;
% Type = logical(Axles.*Dist12.*Weight);
% PDC.CLASS(Type,:) = 119;   

% Type 12)
Axles = PDC.AX == 3;
Dist12 = PDC.W1_2 >= 360 & PDC.W1_2 < 720;
Dist23 = PDC.W2_3 >= 60 & PDC.W2_3 < 240;
Weight = PDC.GW_TOT >= 7000  & PDC.GW_TOT < 45000;
Type = logical(Axles.*Dist12.*Dist23.*Weight);
PDC.CLASS(Type,:) = 12;

% Type 22)
Axles = PDC.AX == 4;
Dist12 = PDC.W1_2 >= 60 & PDC.W1_2 < 240;
Dist23 = PDC.W2_3 >= 200 & PDC.W2_3 < 640;
Dist34 = PDC.W3_4 >= 60 & PDC.W3_4 < 240;
Weight = PDC.GW_TOT >= 8000 & PDC.GW_TOT < 60000;
Type = logical(Axles.*Dist12.*Dist23.*Dist34.*Weight);
PDC.CLASS(Type,:) = 22; 

% only do 23 if later than 2003
%if PDC.JJJJMMTT(1) > 20040000
% Changed definition slightly on 28/08/2020 as per p 31 of Fenart (AGB 685)
% Type 23)
Axles = PDC.AX == 5;
Dist12 = PDC.W1_2 >= 60 & PDC.W1_2 < 240;
Dist23 = PDC.W2_3 >= 120 & PDC.W2_3 < 500;
Dist34 = PDC.W3_4 >= 60 & PDC.W3_4 < 240;
Dist45 = PDC.W4_5 >= 60 & PDC.W4_5 < 240;
Weight = PDC.GW_TOT >= 8000 & PDC.GW_TOT < 75000;
Type = logical(Axles.*Dist12.*Dist23.*Dist34.*Dist45.*Weight);
PDC.CLASS(Type,:) = 23;
% end

% Experiment
% Axles = PDC.AX == 5;
% Dist12 = PDC.W1_2 >= 120 & PDC.W1_2 < 240;
% Dist23 = PDC.W2_3 >= 100 & PDC.W2_3 < 270;
% Dist34 = PDC.W3_4 >= 100 & PDC.W3_4 < 170;
% Dist45 = PDC.W4_5 >= 100 & PDC.W4_5 < 170;
% Weight = PDC.GW_TOT >= 8000 & PDC.GW_TOT < 75000;
% Type = logical(Axles.*Dist12.*Dist23.*Dist34.*Dist45.*Weight);
% PDC.CLASS(Type,:) = 23; 

% Axles = PDC.AX == 5;
% Dist12 = PDC.W1_2 >= 120 & PDC.W1_2 < 240;
% Dist23 = PDC.W2_3 >= 100 & PDC.W2_3 < 340;
% Dist34 = PDC.W3_4 >= 100 & PDC.W3_4 < 160;
% Dist45 = PDC.W4_5 >= 100 & PDC.W4_5 < 160;
% Weight = PDC.GW_TOT >= 8000 & PDC.GW_TOT < 75000;
% Type = logical(Axles.*Dist12.*Dist23.*Dist34.*Dist45.*Weight);
% PDC.CLASS(Type,:) = 23;

% Type 111)
Axles = PDC.AX == 3;
Dist12 = PDC.W1_2 >= 320 & PDC.W1_2 < 450;
Dist23 = PDC.W2_3 >= 360 & PDC.W2_3 < 860;
Weight = PDC.GW_TOT >= 7000  & PDC.GW_TOT < 45000;
Type = logical(Axles.*Dist12.*Dist23.*Weight);
PDC.CLASS(Type,:) = 111; 

% Type 1111r)
Axles = PDC.AX == 4;
Dist12 = PDC.W1_2 >= 360 & PDC.W1_2 < 640;
Dist23 = PDC.W2_3 >= 360 & PDC.W2_3 < 720;
Dist34 = PDC.W3_4 >= 360 & PDC.W3_4 < 640;
Weight = PDC.GW_TOT >= 8000 & PDC.GW_TOT < 60000;
Type = logical(Axles.*Dist12.*Dist23.*Dist34.*Weight);
PDC.CLASS(Type,:) = 11117; 

% Type 112r)
Axles = PDC.AX == 4;
Dist12 = PDC.W1_2 >= 450 & PDC.W1_2 < 640;
Dist23 = PDC.W2_3 >= 360 & PDC.W2_3 < 860;
Dist34 = PDC.W3_4 >= 60 & PDC.W3_4 < 240;
Weight = PDC.GW_TOT >= 8000 & PDC.GW_TOT < 60000;
Type = logical(Axles.*Dist12.*Dist23.*Dist34.*Weight);
PDC.CLASS(Type,:) = 1127;

% Type 1211r)
Axles = PDC.AX == 5;
Dist12 = PDC.W1_2 >= 360 & PDC.W1_2 < 640;
Dist23 = PDC.W2_3 >= 60 & PDC.W2_3 < 240;
Dist34 = PDC.W3_4 >= 360 & PDC.W3_4 < 640;
Dist45 = PDC.W4_5 >= 360 & PDC.W4_5 < 640;
Weight = PDC.GW_TOT >= 9000 & PDC.GW_TOT < 75000;
Type = logical(Axles.*Dist12.*Dist23.*Dist34.*Dist45.*Weight);
PDC.CLASS(Type,:) = 12117; 

% Type 122)
Axles = PDC.AX == 5;
Dist12 = PDC.W1_2 >= 360 & PDC.W1_2 < 640;
Dist23 = PDC.W2_3 >= 60 & PDC.W2_3 < 240;
Dist34 = PDC.W3_4 >= 360 & PDC.W3_4 < 860;
Dist45 = PDC.W4_5 >= 60 & PDC.W4_5 < 240;
Weight = PDC.GW_TOT >= 9000 & PDC.GW_TOT < 75000;
Type = logical(Axles.*Dist12.*Dist23.*Dist34.*Dist45.*Weight);
PDC.CLASS(Type,:) = 122; 

% Type 1112r)
Axles = PDC.AX == 5;
Dist12 = PDC.W1_2 >= 360 & PDC.W1_2 < 640;
Dist23 = PDC.W2_3 >= 360 & PDC.W2_3 < 640;
Dist34 = PDC.W3_4 >= 360 & PDC.W3_4 < 640;
Dist45 = PDC.W4_5 >= 60 & PDC.W4_5 < 240;
Weight = PDC.GW_TOT >= 9000  & PDC.GW_TOT < 75000;
Type = logical(Axles.*Dist12.*Dist23.*Dist34.*Dist45.*Weight);
PDC.CLASS(Type,:) = 11127; 

% Type 112a)
Axles = PDC.AX == 4;
Dist12 = PDC.W1_2 >= 320 & PDC.W1_2 < 450;
Dist23 = PDC.W2_3 >= 360 & PDC.W2_3 < 860;
Dist34 = PDC.W3_4 >= 60 & PDC.W3_4 < 240;
Weight = PDC.GW_TOT >= 8000 & PDC.GW_TOT < 60000;
Type = logical(Axles.*Dist12.*Dist23.*Dist34.*Weight);
PDC.CLASS(Type,:) = 1128;

% Type 113a) experiment
% Axles = PDC.AX == 5;
% Dist12 = PDC.W1_2 >= 320 & PDC.W1_2 < 450;
% Dist23 = PDC.W2_3 >= 360 & PDC.W2_3 < 760;
% Dist34 = PDC.W3_4 >= 120 & PDC.W3_4 < 220;
% Dist45 = PDC.W4_5 >= 120 & PDC.W4_5 < 220;
% Weight = PDC.GW_TOT >= 9000 & PDC.GW_TOT < 75000;
% Type = logical(Axles.*Dist12.*Dist23.*Dist34.*Dist45.*Weight);
% PDC.CLASS(Type,:) = 1138; 

% % Type 113a)
Axles = PDC.AX == 5;
Dist12 = PDC.W1_2 >= 320 & PDC.W1_2 < 450;
Dist23 = PDC.W2_3 >= 360 & PDC.W2_3 < 860;
Dist34 = PDC.W3_4 >= 60 & PDC.W3_4 < 240;
Dist45 = PDC.W4_5 >= 60 & PDC.W4_5 < 240;
Weight = PDC.GW_TOT >= 9000  & PDC.GW_TOT < 75000;
Type = logical(Axles.*Dist12.*Dist23.*Dist34.*Dist45.*Weight);
PDC.CLASS(Type,:) = 1138; 


% Type 123a)
Axles = PDC.AX == 6;
Dist12 = PDC.W1_2 >= 240 & PDC.W1_2 < 360;
Dist23 = PDC.W2_3 >= 60 & PDC.W2_3 < 240;
Dist34 = PDC.W3_4 >= 360 & PDC.W3_4 < 860;
Dist45 = PDC.W4_5 >= 60 & PDC.W4_5 < 240;
Dist56 = PDC.W5_6 >= 60 & PDC.W5_6 < 240;
Weight = PDC.GW_TOT >= 10000  & PDC.GW_TOT < 90000;
Type = logical(Axles.*Dist12.*Dist23.*Dist34.*Dist45.*Dist56.*Weight);
PDC.CLASS(Type,:) = 1238; 

if ClassOW

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

if ismember('W6_7', PDC.Properties.VariableNames)

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
    
end

if ismember('W7_8', PDC.Properties.VariableNames)
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
    
end
        
if ismember('W8_9', PDC.Properties.VariableNames)
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
end



end

