function [AvgTrLen] = AvgInterAxD(TrBetAx,TrWitAx,NumAxpGr)
%AvgTrLen This function is similar to InterAxD, but gives the average truck
%length

NumAxGr = length(NumAxpGr);
NumAx = sum(NumAxpGr);

% Populate with constant values and zeroes for probabilistic values
AxDists = TrWitAx(1:NumAx);

InterAx = zeros(1,NumAxGr-1);

for i = 1:NumAxGr-1
   InterAx(i)  = (TrBetAx(i*4-3) + betastat(TrBetAx(i*4-1),TrBetAx(i*4))*(TrBetAx(i*4-2)-TrBetAx(i*4-3)));
end

NumAxpGrc = cumsum(NumAxpGr);

for i = 1:NumAxGr-1
    AxDists(NumAxpGrc(i)) = InterAx(i);
end

AvgTrLen = sum(AxDists);

end

