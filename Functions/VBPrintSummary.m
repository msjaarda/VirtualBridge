function VBPrintSummary(BaseData,BatchSize,TrData,Num,VirtualWIM,Time,LaneTrDistr)
%xPRINTSUMMARY Print summary of program output
%   Detailed explanation goes here

% Number of VirtualWIM Sims
if isempty(VirtualWIM)
    fprintf('\nAnalysis Type = %s \n','Maximum Force Effect (no Virtual WIM)')
elseif BaseData.VWIM == 1 && BaseData.Analysis == 0
    fprintf('\nAnalysis Type = %s \n','Virtual WIM Only')
else
    fprintf('\nAnalysis Type = %s \n','Maximum Force Effect')
end

% Print Summary Stats to Command Window
fprintf('Total Vehicles = %.0f \n',BaseData.NumVeh)
fprintf('Truck Rate = %.2f \n',BaseData.TrRate)
fprintf('Batch Size = %.0f (%.2f%%) \n',BatchSize, 100*BatchSize/BaseData.NumVeh)
fprintf('Total Simulations = %.0f \n',BaseData.NumSims)

fprintf('\nElapsed Time = %s \n\n',Time)

end

