function [Weight] = DoubleBeta(P2, A1, B1, a1, b1, A2, B2, a2, b2, n)
% DoubleBeta Take in double beta curve parameters and generates truck
% weights

Weight = rand(n,1);

x = Weight < P2/100;
y = Weight >= P2/100;
Weight(y) = (A1 + betarnd(a1,b1,length(Weight(y)),1)*(B1-A1));
Weight(x) = (A2 + betarnd(a2,b2,length(Weight(x)),1)*(B2-A2));

end

