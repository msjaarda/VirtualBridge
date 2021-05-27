function [PD] = PruneWIMwClassify(SName,RD,Report,Save)
%PruneWIM This function takes raw data (RD) from one station (that has been
%assembled using "DailytoYearlyWIMComplete.m") and prunes it, 
%giving back processed data (PD)

% Example PruneWIM('Ceneri',RD,1,0)
% SName (string), Report/Save (1/0 flags)

% File Name
MFileName = strcat(SName,'.mat');

% Option to load RD if you want (give a non-table to the function)
if not(istable(RD))
    load(strcat('Raw WIM\',MFileName));
end

% ----- Perform Mass Pruning -----

% Trim/prune data by disqualifying some rows... create new PD - processed or pruned data
PD = RD;

% Use Method from ASTRA Reports

% 1) Remove vehicles under 3.5 tonnes

UnderW = PD.GW_TOT<3500;
TotUnderW = sum(UnderW);
PD(UnderW,:) = [];

% Step 2 in ASTRA Reports is not a real step

% 3) Remove vehicles with no lengths

NoL = PD.LENTH<1;
TotNoL = sum(NoL);
PD(NoL,:) = [];

% 4) Remove vehicles with lengths over 26m

OverL = PD.LENTH>2600;
TotOverL = sum(OverL);
PD(OverL,:) = [];

% 5) Remove vehicles with missing axle weights

% Get column names starting with AWT
InAxs = contains(PD.Properties.VariableNames, 'AWT');

% Ugly but fast
NoAW = PD.AX == 1 |...
    PD.AX == 2 & (PD.AWT01<1 | PD.AWT02<1 | PD.AWT03>1 | PD.AWT04>1 | PD.AWT05>1 | PD.AWT06>1 | PD.AWT07>1 | PD.AWT08>1 | PD.AWT09>1) |...
    PD.AX == 3 & (PD.AWT01<1 | PD.AWT02<1 | PD.AWT03<1 | PD.AWT04>1 | PD.AWT05>1 | PD.AWT06>1 | PD.AWT07>1 | PD.AWT08>1 | PD.AWT09>1) |...
    PD.AX == 4 & (PD.AWT01<1 | PD.AWT02<1 | PD.AWT03<1 | PD.AWT04<1 | PD.AWT05>1 | PD.AWT06>1 | PD.AWT07>1 | PD.AWT08>1 | PD.AWT09>1) |...
    PD.AX == 5 & (PD.AWT01<1 | PD.AWT02<1 | PD.AWT03<1 | PD.AWT04<1 | PD.AWT05<1 | PD.AWT06>1 | PD.AWT07>1 | PD.AWT08>1 | PD.AWT09>1) |...
    PD.AX == 6 & (PD.AWT01<1 | PD.AWT02<1 | PD.AWT03<1 | PD.AWT04<1 | PD.AWT05<1 | PD.AWT06<1 | PD.AWT07>1 | PD.AWT08>1 | PD.AWT09>1) |...
    PD.AX == 7 & (PD.AWT01<1 | PD.AWT02<1 | PD.AWT03<1 | PD.AWT04<1 | PD.AWT05<1 | PD.AWT06<1 | PD.AWT07<1 | PD.AWT08>1 | PD.AWT09>1) |...
    PD.AX == 8 & (PD.AWT01<1 | PD.AWT02<1 | PD.AWT03<1 | PD.AWT04<1 | PD.AWT05<1 | PD.AWT06<1 | PD.AWT07<1 | PD.AWT08<1 | PD.AWT09>1) |...
    PD.AX == 9 & (PD.AWT01<1 | PD.AWT02<1 | PD.AWT03<1 | PD.AWT04<1 | PD.AWT05<1 | PD.AWT06<1 | PD.AWT07<1 | PD.AWT08<1 | PD.AWT09<1);
TotNoAW = sum(NoAW);
PD(NoAW,:) = [];

% 6) Remove vehicles with axle/wheelbase distances less than 60 cm

% Get column names starting with AWT
InWbs = logical(contains(PD.Properties.VariableNames, 'W').*contains(PD.Properties.VariableNames, '_'));
InWbs(find(string(PD.Properties.VariableNames) == 'GW_TOT')) = 0;

% Ugly but fast
UnderWB = PD.AX == 1 |...
    PD.AX == 2 & (PD.W1_2<60 | PD.W2_3>1 | PD.W3_4>1 | PD.W4_5>1 | PD.W5_6>1 | PD.W6_7>1 | PD.W7_8>1 | PD.W8_9>1) |...
    PD.AX == 3 & (PD.W1_2<60 | PD.W2_3<60 | PD.W3_4>1 | PD.W4_5>1 | PD.W5_6>1 | PD.W6_7>1 | PD.W7_8>1 | PD.W8_9>1) |...
    PD.AX == 4 & (PD.W1_2<60 | PD.W2_3<60 | PD.W3_4<60 | PD.W4_5>1 | PD.W5_6>1 | PD.W6_7>1 | PD.W7_8>1 | PD.W8_9>1) |...
    PD.AX == 5 & (PD.W1_2<60 | PD.W2_3<60 | PD.W3_4<60 | PD.W4_5<60 | PD.W5_6>1 | PD.W6_7>1 | PD.W7_8>1 | PD.W8_9>1) |...
    PD.AX == 6 & (PD.W1_2<60 | PD.W2_3<60 | PD.W3_4<60 | PD.W4_5<60 | PD.W5_6<60 | PD.W6_7>1 | PD.W7_8>1 | PD.W8_9>1) |...
    PD.AX == 7 & (PD.W1_2<60 | PD.W2_3<60 | PD.W3_4<60 | PD.W4_5<60 | PD.W5_6<60 | PD.W6_7<60 | PD.W7_8>1 | PD.W8_9>1) |...
    PD.AX == 8 & (PD.W1_2<60 | PD.W2_3<60 | PD.W3_4<60 | PD.W4_5<60 | PD.W5_6<60 | PD.W6_7<60 | PD.W7_8<60 | PD.W8_9>1) |...
    PD.AX == 9 & (PD.W1_2<60 | PD.W2_3<60 | PD.W3_4<60 | PD.W4_5<60 | PD.W5_6<60 | PD.W6_7<60 | PD.W7_8<60 | PD.W8_9<60);  
TotUnderWB = sum(UnderWB);
PD(UnderWB,:) = [];

% 7) Eliminate Max Total Weight greater than 100 tonnes (ASTRA does 65)

OverW = PD.GW_TOT>100000;
TotOverW = sum(OverW);
PD(OverW,:) = [];

% 8) Remove vehicles with axle weights greater than 25 tonnes (ASTRA does 18)

OverAW = sum(PD{:,InAxs} > 25000,2)>0;
TotOverAW = sum(OverAW);
PD(OverAW,:) = [];

% 9) Remove vehicles with total lengths < 4m

UnderL = PD.LENTH<400;
TotUnderL = sum(UnderL);
PD(UnderL,:) = [];

% We perform some additional steps of our own ----------------------------

% A # Axles should be 9 or less

OverAx = PD.AX>9;
TotOverAx = sum(OverAx);
PD(OverAx,:) = [];

% B Individual wheelbases should be less than 15 m

OverWB = sum(PD{:,InWbs} > 1500,2)>0;
TotOverWB = sum(OverWB);
PD(OverWB,:) = [];

% Removal Report
if Report == 1
    fprintf('\n%s Total Before Pruning: %i\n\n',SName,height(RD))
    fprintf('Step 1) Vehicles removed for being under 3.5 tonnes:           %i\n',TotUnderW)
    fprintf('Step 3) Vehicles removed for having no length:                 %i\n',TotNoL)
    fprintf('Step 4) Vehicles removed for being over 26 m long:             %i\n',TotOverL)
    fprintf('Step 5) Vehicles removed for having no axle weight:            %i\n',TotNoAW)
    fprintf('Step 6) Vehicles removed for having wheelbases under 0.60 m:   %i\n',TotUnderWB)
    fprintf('Step 7) Vehicles removed for being over 100 tonnes:            %i\n',TotOverW)
    fprintf('Step 8) Vehicles removed for having axles over 25 tonnes:      %i\n',TotOverAW)
    fprintf('Step 9) Vehicles removed for being under 4 m long:             %i\n',TotUnderL)
    fprintf('Step A) Vehicles removed for having over 9 axles:              %i\n',TotOverAx)
    fprintf('Step B) Vehicles removed for having wheelbases over 15 m:      %i\n\n',TotOverWB)
    fprintf('Total After Pruning: %i\n\n',height(PD))
    fprintf('Total Removed: %i (%.1f%%)\n\n',height(RD)-height(PD),100*(height(RD)-height(PD))/height(RD))
end
% Put Removal Report into table description
PD.Properties.Description = strcat(sprintf('Before Pruning: %i ',height(RD)),...
    sprintf(' (1) under 3.5 tonnes: %i',TotUnderW),...
    sprintf(' (3) no length: %i',TotNoL),...
    sprintf(' (4) over 26 m long: %i',TotOverL),...
    sprintf(' (5) no axle weight: %i',TotNoAW),...
    sprintf(' (6) wheelbases under 0.60 m: %i',TotUnderWB),...
    sprintf(' (7) over 100 tonnes: %i',TotOverW),...
    sprintf(' (8) axles over 25 tonnes: %i',TotOverAW),...
    sprintf(' (9) under 4 m long: %i',TotUnderL),...
    sprintf(' (A) over 9 axles: %i',TotOverAx),...
    sprintf(' (B) wheelbases over 15 m: %i',TotOverWB),...
    sprintf('  Removed: %i',height(RD)-height(PD)));

% ClassifySimple and Classify before saving
PD = ClassifyType(PD);
PD = Classify(PD);

if Save == 1
    % Save
    save(strcat('Pruned WIM\',SName),'PD','-v7.3')
end

% Don't do anyting with COUNTID... not reliable enough

% Save a smaller version without axle weights and wheelbase lengths



end