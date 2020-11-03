function [AxDists] = InterAxD(Num,Tb,Tw,NumAxpGr)
%InterAxD This function takes in a number of parameters and gives a vector
%of interaxle distances for a vehicle

NumAxGr = length(NumAxpGr);
NumAx = sum(NumAxpGr);

%AxDists = zeros(Num,NumAx+1);
% For simplicity, and since each truck has a front length of 1.5m, we add
% this to the FloDist instead (anytime a truck front is involved - TT/TC
%AxDists = zeros(Num,NumAx);

%AxDists(:,1) = Tw(1);
%AxDists(:,NumAx+1) = Tw(NumAx+1);
AxDists = repmat(Tw(1:NumAx),Num,1);
%AxDists(:,NumAx) = Tw(1:NumAx);

% for i = 1:NumAx-1
%     if Tw(i) ~= 0
%         AxDists(:,i) = Tw(i);
%     end    
% end

InterAx = zeros(Num,NumAxGr-1);

for i = 1:NumAxGr-1
   InterAx(:,i)  = (Tb(i*4-3) + betarnd(Tb(i*4-1),Tb(i*4),Num,1)*(Tb(i*4-2)-Tb(i*4-3)));
end

NumAxpGrc = cumsum(NumAxpGr);

for i = 1:NumAxGr-1
    AxDists(:,NumAxpGrc(i)) = InterAx(:,i);
    %AxDists(:,NumAxpGrc(i)+1) = InterAx(:,i);
end

end

