function [Damage] = GetFatigueDamage(R,ScalingFactor,CAT)
%GETFATIGUEDAMAGE
% Calculates fatigue damage using rainflow method from a given stress history, R

R = R/ScalingFactor;

n2 = 2E6; s2 = CAT;                                 % 2 is C (Class Value)
n1 = 1E4; s1 = (s2^(3)*n2/n1)^(1/3);                % 1 is leftmost
n3 = 5E6; s3 = (s2^(3)*n2/n3)^(1/3); % = 0.737*s2;  % 3 is D (Knee Point)
n4 = 1E8; s4 = (s3^(5)*n3/n4)^(1/5); % = 0.549*s3;  % 4 is L (Cutoff)
n5 = 1E10; s5 = s4;                                 % 5 is rightmost

[c,hist,edges,rmm,idx] = rainflow(R);
T = array2table(c,'VariableNames',{'Count','Range','Mean','Start','End'});

% Calculate damage from R
% Take each cycle... count half cycles as full cycles... and compute damage
% Start by assuming FAT80
% Initialize with zeros
T.Life = zeros(height(T),1);
% Assume m = 3
T.Life = s2^3*n2./(T.Range.^3);
% Assume k = 5 for those that exceed kneepoint
T.Life(T.Life > n3) = s3^5*n3./(T.Range(T.Life > n3).^5);
% Take care of those exceeding cutoff
T.Life(T.Life > n4) = Inf;
T.Damage = T.Count.*T.Range./T.Life;

Damage = sum(T.Damage);

end

