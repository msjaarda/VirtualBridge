function [Weight] = DoubleNormal(p, mu1, mu2, sigma1, sigma2, n)
% DoubleBeta Take in double beta curve parameters and generates truck
% weights

% P1 is in decimal form already

Weight = rand(n,1);

x = Weight < p;
y = Weight >= p;
Weight(x) = normrnd(mu1,sigma1,length(Weight(x)),1);
Weight(y) = normrnd(mu2,sigma2,length(Weight(y)),1);

end

