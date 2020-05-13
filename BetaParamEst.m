%   This time for Beta...

% This comes from "Fitting a more complicated distribution: A Mixture of Two
% Normals" at the following: https://www.mathworks.com/help/stats/examples/fitting-custom-univariate-distributions.html

% Unsuccessfully tried adapting for beta dist.
clear,clc

%load('123TW.mat');

A = 4;
B = 3;
xx = betarnd(A,B,1000,1);
A = 7;
B = 2;
yy = betarnd(A,B,1000,1);
P = 0.1;

x = xx*(1-P)+yy*P;

hist(x,0:0.025:1);

pdf_betamixture = @(x,p,a1,a2,b1,b2) ...
                         p*betapdf(x,a1,b1) + (1-p)*betapdf(x,a2,b2);

pStart = 0.4;
a1Start = 1.2;
a2Start = 2.3;      % Needs work
b1Start = 2;   
b2Start = 2.8;      % Needs work
start = [pStart a1Start a2Start b1Start b2Start];

lb = [0 0.001 0.001 0.001 0.001];
ub = [1 1000 1000 1000 1000];

paramEsts = mle(x,'pdf',pdf_betamixture, 'start',start,'lower',lb, 'upper',ub)

%statset('mlecustom')

%options = statset('MaxIter',300, 'MaxFunEvals',600);
%paramEsts = mle(x, 'pdf',pdf_betamixture, 'start',start, ...
%                          'lower',lb, 'upper',ub, 'options',options)
                      


% All Ready                      
                      
bins = [0:0.025:1];
pdf = histc(x,bins)/(length(x));
cdf(1) = pdf(1);
for i = 2:length(pdf)
   cdf(i) = pdf(i)+cdf(i-1); 
end
h = bar(bins,pdf,'histc');

h.FaceColor = [.9 .9 .9];

xgrid = linspace(1.1*min(x),1.1*max(x),200);
pdfgrid = pdf_betamixture(xgrid,paramEsts(1),paramEsts(2),paramEsts(3),paramEsts(4),paramEsts(5));
%pdfgrid = pdf_betamixture(xgrid,pStart,a1Start,a2Start,b1Start,b2Start);

% t = betafit(x);
% xgrid = [0:0.025:1];
% pdfgrid = betacdf(xgrid,t(1),t(2));

hold on
plot(xgrid,pdfgrid,'-')
hold off
xlabel('x')
ylabel('Probability Density')



