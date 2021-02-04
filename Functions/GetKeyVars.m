function [BatchSize,NumBatches,FixVars,PlatPct] = GetKeyVars(BaseData,TrDistr)
%GETKEYVARS Grabs key variables

% Fixed variables are defined here
FixVars.TrFront = 1.5;
FixVars.CarFrAxRe = [0.9 2.6 0.8];
FixVars.PlatFolDistFrRe = [4 4];
FixVars.CarWgt = 0;          % Car's weight in kN

% Define maximum batch size
BatchMax = 1000001;
% Define Platoon percentage cutoff
PlatCutOff = 0.02;

% If PlatPct is in TrDistr, get it, otherwise, assign from BaseData (above certain threshold)
if ismember('PlatPct', TrDistr.Properties.VariableNames)
    PlatPct = TrDistr.PlatPct;
else
    PlatPct = BaseData.PlatRate*(TrDistr.TrDistr > PlatCutOff);
    % Just for an experiment! Change after. 29.01.2020
    PlatPct(3) = 0;
    PlatPct(4) = 0;
end

% Define batch size 
K = 1:ceil(BaseData.NumVeh/2); D = [K(rem(BaseData.NumVeh,K)==0) BaseData.NumVeh];
if BaseData.NumVeh < BatchMax
    BatchSize = BaseData.NumVeh;
else
    BatchSize = min(D(end-1),max(D(D<BatchMax+1))); 
end

% Define number of batches
NumBatches = BaseData.NumVeh/BatchSize;

end

