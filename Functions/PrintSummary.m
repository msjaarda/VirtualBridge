function PrintSummary(BaseData,BatchSize,PlatPct,TrData,Num,VirtualWIM,Time,LaneTrDistr)
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

if BaseData.RunPlat == 1
    fprintf('Slow Lane Platooning Penetration = %.3f \n',sum(PlatPct.*TrData.TrDistr.TrDistr))
    fprintf('Platoon Size = %.0f \n',BaseData.PlatSize)
    fprintf('InterPlatoon Gap (m) = %.2f \n',BaseData.PlatFolDist)
    if ~isempty(VirtualWIM)
        fprintf('Trucks in Platoons per Sim = %.0f (%.2f%% accuracy) \n',Num.Batches*sum(VirtualWIM(:,6))/(BaseData.PlatSize*BaseData.NumSims),100*Num.Batches*sum(VirtualWIM(:,6))/(BaseData.NumSims*sum(PlatPct.*TrData.TrDistr.TrDistr*BaseData.NumVeh*BaseData.TrRate*(LaneTrDistr(1)/100))))
        fprintf('Trucks Swapped per Sim = %.0f (%.3f%% of veh) \n',Num.Batches*sum(VirtualWIM(:,7))/BaseData.NumSims,100*Num.Batches*sum(VirtualWIM(:,7))/(BaseData.NumSims*BaseData.NumVeh))
    end
end
fprintf('\nElapsed Time = %s \n\n',Time)

end

