function [PD] = VBClassify(PD)
% VBCLASSIFY Performs AGB Classification on PD and gives back PDC - the
% same table but with TYPE and CLASS added. Type is a simple method that
% works anywhere (and helps with OW vehicle classification). Written by RN.

% Type only uses 2 m as the threshold of within a group or not

% ---------------- TYPE START -------------------

IndW = find(string(PD.Properties.VariableNames) == "W1_2");

% Create the table of axel. 0: >2m ; 1: <2m, NaN: no axel 
axleTable = double(PD{:,IndW:IndW+7} < 200);
axleTable(PD{:,IndW:IndW+7} == 0) = NaN;

% Initilize the empty count of axels and count of axel per group. 
count = ones(height(axleTable),1);
countGroup = nan(size(axleTable)+[0 1]);

for j = 1:width(axleTable)
    
    % Find vehicule with current axle being seperated from the previous
    % group
    idAlone = axleTable(:,j) == 0;
    
    % Find vehicule with current axle being part of the previous group.
    idTogether = axleTable(:,j) == 1; 
    
    % If it is part of the previous group, then add 1 to the count of axle
    count(idTogether) = count(idTogether) + 1;
    
    % If new group, first write down the count of the previous group
    countGroup(idAlone,j) = count(idAlone);
    % And reinitilize the count of axel in the new group to 1
    count(idAlone) = 1;
    
end

% Add the count of the last group
countGroup(:,j+1)=count;

% Convert the count per group into the code, by using a power of 10
% corrected for the presence of nan
STR_c = nansum(countGroup .* 10.^(cumsum(~isnan(countGroup),2,'reverse')-1),2);

PD.TYPE = STR_c;

% ---------------- TYPE DONE -------------------

% Classificaiton according to AGB 2002/005 with the addition of Class 23.

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
% 7 = "r"
% 8 = "a"
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
% See SwissWIMData.xlsx OW Vehicles Tab

% Just for displaying class, such as in Apercu
TrTyps = [0; 11; 119; 12; 22; 23; 111; 11117; 1127; 12117; 122; 11127; 1128; 1138; 1238; 41; 42; 43; 44; 45; 46; 47; 48; 49];
TrNames = ["NC" "11" "11bis" "12" "22" "23" "111" "1111r" "112r" "1211r" "122" "11112r" "112a" "113a" "123a"...
    "60t Crane" "6ax 60t" "7ax 72t" "8ax 84t" "9ax 96t" "96t Crane" "Libherr 132" "Libherr 15" "84t AT7"];


% --------------- CLASS START ------------------

% Add a table column for Classification "CLASS"
PD.CLASS = zeros(size(PD,1),1);

% Type 11)
% Num Axles
Axles = PD.AX == 2;
% Distance between Axles
Dist12 = PD.W1_2 >= 360 & PD.W1_2 < 720;
% Weight
Weight = PD.GW_TOT >= 6000 & PD.GW_TOT < 30000;
% Together
Type = logical(Axles.*Dist12.*Weight);
% Change table entries
PD.CLASS(Type,:) = 11; 

% Type 12)
Axles = PD.AX == 3;
Dist12 = PD.W1_2 >= 360 & PD.W1_2 < 720;
Dist23 = PD.W2_3 >= 60 & PD.W2_3 < 240;
Weight = PD.GW_TOT >= 7000 & PD.GW_TOT < 45000;
Type = logical(Axles.*Dist12.*Dist23.*Weight);
PD.CLASS(Type,:) = 12;

% Type 22)
Axles = PD.AX == 4;
Dist12 = PD.W1_2 >= 60 & PD.W1_2 < 240;
Dist23 = PD.W2_3 >= 200 & PD.W2_3 < 640;
Dist34 = PD.W3_4 >= 60 & PD.W3_4 < 240;
Weight = PD.GW_TOT >= 8000 & PD.GW_TOT < 60000;
Type = logical(Axles.*Dist12.*Dist23.*Dist34.*Weight);
PD.CLASS(Type,:) = 22; 

% Type 23)
Axles = PD.AX == 5;
Dist12 = PD.W1_2 >= 60 & PD.W1_2 < 240;
Dist23 = PD.W2_3 >= 120 & PD.W2_3 < 500;
Dist34 = PD.W3_4 >= 60 & PD.W3_4 < 240;
Dist45 = PD.W4_5 >= 60 & PD.W4_5 < 240;
Weight = PD.GW_TOT >= 8000 & PD.GW_TOT < 75000;
Type = logical(Axles.*Dist12.*Dist23.*Dist34.*Dist45.*Weight);
PD.CLASS(Type,:) = 23;

% Type 111)
Axles = PD.AX == 3;
Dist12 = PD.W1_2 >= 320 & PD.W1_2 < 450;
Dist23 = PD.W2_3 >= 360 & PD.W2_3 < 860;
Weight = PD.GW_TOT >= 7000 & PD.GW_TOT < 45000;
Type = logical(Axles.*Dist12.*Dist23.*Weight);
PD.CLASS(Type,:) = 111; 

% Type 1111r)
Axles = PD.AX == 4;
Dist12 = PD.W1_2 >= 360 & PD.W1_2 < 640;
Dist23 = PD.W2_3 >= 360 & PD.W2_3 < 720;
Dist34 = PD.W3_4 >= 360 & PD.W3_4 < 640;
Weight = PD.GW_TOT >= 8000 & PD.GW_TOT < 60000;
Type = logical(Axles.*Dist12.*Dist23.*Dist34.*Weight);
PD.CLASS(Type,:) = 11117; 

% Type 112r)
Axles = PD.AX == 4;
Dist12 = PD.W1_2 >= 450 & PD.W1_2 < 640;
Dist23 = PD.W2_3 >= 360 & PD.W2_3 < 860;
Dist34 = PD.W3_4 >= 60 & PD.W3_4 < 240;
Weight = PD.GW_TOT >= 8000 & PD.GW_TOT < 60000;
Type = logical(Axles.*Dist12.*Dist23.*Dist34.*Weight);
PD.CLASS(Type,:) = 1127;

% Type 1211r)
Axles = PD.AX == 5;
Dist12 = PD.W1_2 >= 360 & PD.W1_2 < 640;
Dist23 = PD.W2_3 >= 60 & PD.W2_3 < 240;
Dist34 = PD.W3_4 >= 360 & PD.W3_4 < 640;
Dist45 = PD.W4_5 >= 360 & PD.W4_5 < 640;
Weight = PD.GW_TOT >= 9000 & PD.GW_TOT < 75000;
Type = logical(Axles.*Dist12.*Dist23.*Dist34.*Dist45.*Weight);
PD.CLASS(Type,:) = 12117; 

% Type 122)
Axles = PD.AX == 5;
Dist12 = PD.W1_2 >= 360 & PD.W1_2 < 640;
Dist23 = PD.W2_3 >= 60 & PD.W2_3 < 240;
Dist34 = PD.W3_4 >= 360 & PD.W3_4 < 860;
Dist45 = PD.W4_5 >= 60 & PD.W4_5 < 240;
Weight = PD.GW_TOT >= 9000 & PD.GW_TOT < 75000;
Type = logical(Axles.*Dist12.*Dist23.*Dist34.*Dist45.*Weight);
PD.CLASS(Type,:) = 122; 

% Type 1112r)
Axles = PD.AX == 5;
Dist12 = PD.W1_2 >= 360 & PD.W1_2 < 640;
Dist23 = PD.W2_3 >= 360 & PD.W2_3 < 640;
Dist34 = PD.W3_4 >= 360 & PD.W3_4 < 640;
Dist45 = PD.W4_5 >= 60 & PD.W4_5 < 240;
Weight = PD.GW_TOT >= 9000 & PD.GW_TOT < 75000;
Type = logical(Axles.*Dist12.*Dist23.*Dist34.*Dist45.*Weight);
PD.CLASS(Type,:) = 11127; 

% Type 112a)
Axles = PD.AX == 4;
Dist12 = PD.W1_2 >= 320 & PD.W1_2 < 450;
Dist23 = PD.W2_3 >= 360 & PD.W2_3 < 860;
Dist34 = PD.W3_4 >= 60 & PD.W3_4 < 240;
Weight = PD.GW_TOT >= 8000 & PD.GW_TOT < 60000;
Type = logical(Axles.*Dist12.*Dist23.*Dist34.*Weight);
PD.CLASS(Type,:) = 1128;

% Type 113a)
Axles = PD.AX == 5;
Dist12 = PD.W1_2 >= 320 & PD.W1_2 < 450;
Dist23 = PD.W2_3 >= 360 & PD.W2_3 < 860;
Dist34 = PD.W3_4 >= 60 & PD.W3_4 < 240;
Dist45 = PD.W4_5 >= 60 & PD.W4_5 < 240;
Weight = PD.GW_TOT >= 9000 & PD.GW_TOT < 75000;
Type = logical(Axles.*Dist12.*Dist23.*Dist34.*Dist45.*Weight);
PD.CLASS(Type,:) = 1138; 

% Type 123a)
Axles = PD.AX == 6;
Dist12 = PD.W1_2 >= 240 & PD.W1_2 < 360;
Dist23 = PD.W2_3 >= 60 & PD.W2_3 < 240;
Dist34 = PD.W3_4 >= 360 & PD.W3_4 < 860;
Dist45 = PD.W4_5 >= 60 & PD.W4_5 < 240;
Dist56 = PD.W5_6 >= 60 & PD.W5_6 < 240;
Weight = PD.GW_TOT >= 10000 & PD.GW_TOT < 90000;
Type = logical(Axles.*Dist12.*Dist23.*Dist34.*Dist45.*Dist56.*Weight);
PD.CLASS(Type,:) = 1238; 

% --------------- CLASS DONE ------------------

% --------------- CLASS OW START ------------------

% Type 41) 60 tonne crane truck from F2.17 of AGB 2002/005
% Unclassified
UnClass = PD.CLASS == 0;
% Code is 14
RType = PD.TYPE == 14;
% Distance between Axles
Dist12 = PD.W1_2 < 300;
% Weight
Weight = PD.GW_TOT >= 50000 & PD.GW_TOT < 100000;
% Together
Type = logical(UnClass.*RType.*Dist12.*Weight);
% Change table entries
PD.CLASS(Type,:) = 41;

% Type 46) 96 tonne crane truck from FA.8 AGB 2002/005
UnClass = PD.CLASS == 0;
RType = PD.TYPE == 332;
Dist34 = PD.W3_4 < 360;
Dist67 = PD.W6_7 < 300;
Weight = PD.GW_TOT >= 70000 & PD.GW_TOT < 100000;
Type = logical(UnClass.*RType.*Dist34.*Dist67.*Weight);
PD.CLASS(Type,:) = 46;

% Type 42) 60 tonne crane truck from Veicoli Standard Spreadsheet
UnClass = PD.CLASS == 0;
Axles = PD.AX == 6;
Dist12 = PD.W1_2 < 240;
Dist23 = PD.W2_3 < 240;
Dist34 = PD.W3_4 >= 300 & PD.W3_4 < 500;
Dist45 = PD.W4_5 < 200;
Dist56 = PD.W5_6 < 200;
Weight = PD.GW_TOT >= 50000 & PD.GW_TOT < 100000;
Type = logical(UnClass.*Axles.*Dist12.*Dist23.*Dist34.*Dist45.*Dist56.*Weight);
PD.CLASS(Type,:) = 42;

% Type 43) 72 tonne crane truck from Veicoli Standard Spreadsheet
UnClass = PD.CLASS == 0;
RType = PD.TYPE == 34;
Dist34 = PD.W3_4 >= 400 & PD.W3_4 < 600;
Weight = PD.GW_TOT >= 50000 & PD.GW_TOT < 100000;
Type = logical(UnClass.*RType.*Dist34.*Weight);
PD.CLASS(Type,:) = 43;

% Type 44) 84 tonne crane truck from Veicoli Standard Spreadsheet
UnClass = PD.CLASS == 0;
RType = PD.TYPE == 44;
Dist45 = PD.W4_5 >= 440 & PD.W4_5 < 740;
Weight = PD.GW_TOT >= 60000 & PD.GW_TOT < 100000;
Type = logical(UnClass.*RType.*Dist45.*Weight);
PD.CLASS(Type,:) = 44;
        
% Type 45) 96 tonne crane truck from Veicoli Standard Spreadsheet
UnClass = PD.CLASS == 0;
Axles = PD.AX == 9;
Dist12 = PD.W1_2 < 240;
Dist23 = PD.W2_3 < 200;
Dist34 = PD.W3_4 < 200;
Dist45 = PD.W4_5 >= 440 & PD.W4_5 < 740;
Dist56 = PD.W5_6 < 200;
Dist67 = PD.W6_7 < 200;
Dist78 = PD.W7_8 < 200;
Dist89 = PD.W8_9 < 200;
Weight = PD.GW_TOT >= 70000 & PD.GW_TOT < 100000;
Type = logical(UnClass.*Axles.*Dist12.*Dist23.*Dist34.*Dist45.*Dist56.*Dist67.*Dist78.*Dist89.*Weight);
PD.CLASS(Type,:) = 45;

% Type 47) 84 tonne crane truck from Veicoli Standard Spreadsheet
UnClass = PD.CLASS == 0;
RType = PD.TYPE == 132;
Dist12 = PD.W1_2 < 320;
Dist45 = PD.W4_5 < 300;
Weight = PD.GW_TOT >= 50000 & PD.GW_TOT < 100000;
Type = logical(UnClass.*RType.*Dist12.*Dist45.*Weight);
PD.CLASS(Type,:) = 47;

% Type 48) 84 tonne crane truck from Veicoli Standard Spreadsheet
UnClass = PD.CLASS == 0;
RType = PD.TYPE == 15;
Dist12 = PD.W1_2 < 340;
Weight = PD.GW_TOT >= 50000 & PD.GW_TOT < 100000;
Type = logical(UnClass.*RType.*Dist12.*Weight);
PD.CLASS(Type,:) = 48;

% Type 49) 84 tonne crane truck from Veicoli Standard Spreadsheet
UnClass = PD.CLASS == 0;
RType = PD.TYPE == 25;
Dist23 = PD.W2_3 < 300;
Weight = PD.GW_TOT >= 60000 & PD.GW_TOT < 100000;
Type = logical(UnClass.*RType.*Dist23.*Weight);
PD.CLASS(Type,:) = 49;

% --------------- CLASS OW DONE ------------------

end
