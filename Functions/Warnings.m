function Warnings(TrDistCu, BunchFactor, RunPlat, TrTrTransProb)
%MATSIMWARNINGS Print out warnings for the MATSim Program
if (0.99999 < TrDistCu(end) && TrDistCu(end) < 1.00001)
else
   fprintf("\nWarning: Truck Distribution does not add to 1\n\n") 
end
if BunchFactor == 1
    if RunPlat == 1
       fprintf("\nWarning: If using Platooning, it is more realistic to also use BunchFactor\n\n") 
    end
end
if TrTrTransProb(1) > 0.9
    fprintf("\nWarning: You should have a lower truck rate or more even LaneTrDistr\n\n") 
end
% Could add warnings about - too high platooning rates... lengths of lane specific streams being off...
end

