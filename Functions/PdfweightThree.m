function [x, P2, A1, B1, a1, b1, A2, B2, a2, b2, a3, b3, p1, p2, mu1, mu2, mu3, sig1, sig2, sig3] = PdfweightThree(PDC,TrTyp)
%PDFWEIGHTTHREE describe

SF = 1000;

x = (PDC.GW_TOT(PDC.CLASS == TrTyp)/102)/SF;

pdf_mixture = @(x,p1,p2,mu1,mu2,mu3,sigma1,sigma2,sigma3) ...
                     p1*normpdf(x,mu1,sigma1) + p2*normpdf(x,mu2,sigma2) + (1-p1-p2)*normpdf(x,mu3,sigma3);

p1Start = .33;
p2Start = .33;
muStart = quantile(x,[.30 .50 .70]);
sigmaStart = mean(sqrt(var(x) - .25*diff(muStart).^2));

start = [p1Start p2Start muStart sigmaStart sigmaStart sigmaStart];

lb = [0 0 -Inf -Inf -Inf 0 0 0];
ub = [1 1 Inf Inf Inf Inf Inf Inf];
                      
statset('mlecustom');
options = statset('MaxIter',5000, 'MaxFunEvals',5000);

paramEsts = mle(x, 'pdf',pdf_mixture, 'start',start, ...
                          'lower',lb, 'upper',ub, 'options',options);

mu = paramEsts(3);
sig = paramEsts(6);
a1 = ((1-mu)/(sig^2)-1/mu)*mu^2;
b1 = a1*(1/mu-1);

mu = paramEsts(4);
sig = paramEsts(7);
a2 = ((1-mu)/(sig^2)-1/mu)*mu^2;
b2 = a2*(1/mu-1);

mu = paramEsts(5);
sig = paramEsts(8);
a3 = ((1-mu)/(sig^2)-1/mu)*mu^2;
b3 = a3*(1/mu-1);

P2 = 100*(1-paramEsts(1));
[A1, A2] = deal(0);
[B1, B2] = deal(1000);

paramEsts(3:8) = paramEsts(3:8)*SF;

[p1, p2, mu1, mu2, mu3, sig1, sig2, sig3] = deal(paramEsts(1),paramEsts(2),paramEsts(3),paramEsts(4),paramEsts(5),paramEsts(6),paramEsts(7),paramEsts(8));

x = x*SF;
    
end

