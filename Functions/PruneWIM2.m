function [PDC] = PruneWIM2(PDC,Report)
%PRUNEWIM2

OriginalL = height(PDC);

% 1) Remove vehicles under 6 tonnes

UnderW = PDC.GW_TOT<6000;
TotUnderW = sum(UnderW);
PDC(UnderW,:) = [];

% 2) Disqualification by Swiss10 Class (exclude 2,3,4,6)

WrongC = PDC.CS == 2 | PDC.CS == 3 | PDC.CS == 4 | PDC.CS == 6;
TotWrongC = sum(WrongC);
% Only do the disqualification if we actually have SW10 Classification
if sum(WrongC) < 0.7*height(PDC)
    PDC(WrongC,:) = [];
end

% Get rid of overweight classes and class 11bis right now
%PDC.CLASS(PDC.CLASS > 39 & PDC.CLASS < 50) = 0; 
%PDC.CLASS(PDC.CLASS == 119) = 0;

if Report == 1
    fprintf('\nTotal Before Pruning Stage 2: %i\n\n',OriginalL)
    fprintf('Step 1) Vehicles removed for being under 6 tonnes: %i\n',TotUnderW)
    fprintf('Step 2) Vehicles removed for being SW10 Class 2, 3, 4, or 6: %i\n',TotWrongC)
    fprintf('Total After Pruning: %i\n\n',height(PDC))
    fprintf('Total Removed: %i\n\n',OriginalL-height(PDC))
end

end

