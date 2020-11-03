function [x, P2, A1, B1, a1, b1, A2, B2, a2, b2, p, mu1, mu2, sig1, sig2] = Pdfweight(PDC,TrTyp)
%PDFWEIGHT describe

SF = 1000;

x = (PDC.GW_TOT(PDC.CLASS == TrTyp)/102)/SF;

pdf_mixture = @(x,p,mu1,mu2,sigma1,sigma2) ...
                     p*normpdf(x,mu1,sigma1) + (1-p)*normpdf(x,mu2,sigma2);

pStart = .5;
muStart = quantile(x,[.40 .60]);
sigmaStart = sqrt(var(x) - .25*diff(muStart).^2);

start = [pStart muStart sigmaStart sigmaStart];

lb = [0 -Inf -Inf 0 0];
ub = [1 Inf Inf Inf Inf];
                      
statset('mlecustom');
options = statset('MaxIter',5000, 'MaxFunEvals',5000);

paramEsts = mle(x, 'pdf',pdf_mixture, 'start',start, ...
                          'lower',lb, 'upper',ub, 'options',options);

mu = paramEsts(2);
sig = paramEsts(4);
a1 = ((1-mu)/(sig^2)-1/mu)*mu^2;
b1 = a1*(1/mu-1);

mu = paramEsts(3);
sig = paramEsts(5);
a2 = ((1-mu)/(sig^2)-1/mu)*mu^2;
b2 = a2*(1/mu-1);

P2 = 100*(1-paramEsts(1));
[A1, A2] = deal(0);
[B1, B2] = deal(1000);

paramEsts(2:5) = paramEsts(2:5)*SF;

[p, mu1, mu2, sig1, sig2] = deal(paramEsts(1),paramEsts(2),paramEsts(3),paramEsts(4),paramEsts(5));

x = x*SF;
    
end

