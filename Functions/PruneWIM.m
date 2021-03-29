function [PD] = PruneWIM(Year,Station,SName,RD,Report,Save)
%PruneWIM This function takes raw WIM data (RD) from 1 year (that has been
%assembled using "DailytoYearly.m") and prunes it, giving back processed
%data (PD)

% Example PruneWIM(2017,408,'Ceneri',RD,1,0)

% Year/Station (string OR number), SName (string)
% Report/Save (1/0 flags)

TFileName = strcat(SName,num2str(Station),'_',num2str(Year));

MFileName = strcat(TFileName,'.mat');

if not(istable(RD))
    load(MFileName);
end


% ----- Perform Mass Pruning -----

% Code for trimming/filtering data for .trd file. Note that this step is
% not crucial since most strange vehicles will not be classified, and will
% thus be ignored (however, we still want to accuratly know # of real trucks).

% Trim/prune data by disqualifying some rows... create new PD - processed or pruned data

PD = RD;

% Use Method from ASTRA Reports... Verified useing Monte Ceneri 2017

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

% Step 5 in ASTRA Reports was originally thought to be unnecessary (no weight on axle)
% This step was added 5-16-19
% 5) Remove vehicles with missing axle weights

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

% Step 6 in ASTRA Reports is confusing (axle distance less than 60 cm?)
% This step was added 5-16-19
% 6) Remove vehicles with axle/wheelbase distances less than 60 cm

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

% Step 7 in ASTRA Reports is total vehicle weight under 65 tonnes (except mobile cranes)
% however, we want to identify mobile cranes later on... plus there may be
% other heavy vehicles we are interested in. We instead choose to remove
% those with a weight greater than 100 tonnes. The max that is really
% possible here is 96 tonne crane truck (see 3.1.4 AGB 2009/005) or a
% 9-axle 45 truck (see Veicoli Standard Compatti e Gruppi spreadsheet).
% Trucks weighing more than this need more than 9 axles, so are eliminated
% anyway.
% This step was moved 5-16-19
% 7) Eliminate Max Total Weight greater than 100 tonnes (ASTRA does 65)

OverW = PD.GW_TOT>100000;
TotOverW = sum(OverW);
PD(OverW,:) = [];

% Step 8 in ASTRA Reports is that each axle should be under 18 tonnes. We
% go 25 to be safe.
% 8) Remove vehicles with axle weights greater than 25 tonnes

for i = 14:23
    OverAW = PD.(i)>25000;
    TotOverAW = sum(OverAW);
    PD(OverAW,:) = [];
end

% 9) Remove vehicles with total lengths < 4m

UnderL = PD.LENTH<400;
TotUnderL = sum(UnderL);
PD(UnderL,:) = [];

% We perform some additional steps of our own

% The code below was found sufficient to create .trd
% files that would result in similar .trr files when compared with Glauco's
% 2012 .trd files for Ceneri (which were provided by ASTRA I think. Note
% that some of these criteria have been move above, because ASTRA also had
% it (often more restrictive)

% 1 # Axles should be 9 or less

OverAx = PD.AX>9;
TotOverAx = sum(OverAx);
PD(OverAx,:) = [];

% 2 Individual wheelbases should be less than 15 m

for i = 24:32
    
    OverWB = PD.(i)>1500;
    TotOverWB = sum(OverWB);
    PD(OverWB,:) = [];
    
end

% No need to write to txtfile right now
%writetable(PD,strcat(TFileName,'_Filtered'))

% Print removal report and save it to textfile
% Removal Report

PD.Properties.Description = strcat(sprintf('Before Pruning: %i ',height(RD)),...
    sprintf(' (1) under 3.5 tonnes: %i',TotUnderW),...
    sprintf(' (3) no length: %i',TotNoL),...
    sprintf(' (4) over 26 m long: %i',TotOverL),...
    sprintf(' (5) no axle weight: %i',TotNoAW),...
    sprintf(' (6) wheelbases under 0.60 m: %i',TotUnderWB),...
    sprintf(' (7) over 100 tonnes: %i',TotOverW),...
    sprintf(' (8) axles over 25 tonnes: %i',TotOverAW),...
    sprintf(' (9) under 4 m long: %i',TotUnderL),...
    sprintf(' () over 9 axles: %i',TotOverAx),...
    sprintf(' () wheelbases over 15 m: %i',TotOverWB),...
    sprintf('  Removed: %i',height(RD)-height(PD)));

if Report == 1
    fprintf('\nTotal Before Pruning: %i\n\n',height(RD))
    fprintf('Step 1) Vehicles removed for being under 3.5 tonnes: %i\n',TotUnderW)
    fprintf('Step 3) Vehicles removed for having no length: %i\n',TotNoL)
    fprintf('Step 4) Vehicles removed for being over 26 m long: %i\n',TotOverL)
    fprintf('Step 5) Vehicles removed for having no axle weight: %i\n',TotNoAW)
    fprintf('Step 6) Vehicles removed for having wheelbases under 0.60 m: %i\n',TotUnderWB)
    fprintf('Step 7) Vehicles removed for being over 100 tonnes: %i\n',TotOverW)
    fprintf('Step 8) Vehicles removed for having axles over 25 tonnes: %i\n',TotOverAW)
    fprintf('Step 9) Vehicles removed for being under 4 m long: %i\n',TotUnderL)
    fprintf('Vehicles removed for having over 9 axles: %i\n',TotOverAx)
    fprintf('Vehicles removed for having wheelbases over 15 m: %i\n\n',TotOverWB)
    fprintf('Total After Pruning: %i\n\n',height(PD))
    fprintf('Total Removed: %i\n\n',height(RD)-height(PD))
end

if Save == 1
    save(strcat(TFileName,'_Filtered'),'PD')
end

% Stage 2 Pruning not done here.

% % % Stage 2 Custom Pruning (two more of our own)
% % % 1. Disqualification by weight (under 6 tonnes)
% % TotUnderW = sum(PD.GW_TOT < 6000);
% % PD = PD(PD.GW_TOT > 6000,:);
% % % 2. Disqualification by Swiss10 Class (exclude 2,3,4,6,7)
% % TotSW10Ex = sum(PD.CS == 2 | PD.CS == 3 | PD.CS == 4 | PD.CS == 6 | PD.CS == 7);
% % PD = PD(PD.CS == 1 | PD.CS == 5 | PD.CS == 8 | PD.CS == 9 | PD.CS == 10,:);
% % 
% % if ReportPrune == 1
% %     fprintf('Custom Step 1) Vehicles removed for being under 6 tonnes: %i\n',TotUnderW)
% %     fprintf('Custom Step 2) Vehicles removed for being SW10 2,3,4,6,7: %i\n\n',TotSW10Ex)
% % end


end

