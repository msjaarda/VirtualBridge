function VBWarnings(TrDistCu, BunchFactor, TrTrTransProb)
%MATSIMWARNINGS Print out warnings for the MATSim Program
if (0.99999 < TrDistCu(end) && TrDistCu(end) < 1.00001)
else
   fprintf("\nWarning: Truck Distribution does not add to 1\n\n") 
end
if TrTrTransProb(1) > 0.9
    fprintf("\nWarning: You should have a lower truck rate or more even LaneTrDistr\n\n") 
end
end

