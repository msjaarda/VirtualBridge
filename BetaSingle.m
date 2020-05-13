clear,clc

A = 4;
B = 3;
x = betarnd(A,B,1000,1);

bins = 0:0.025:1;

xbinned = histc(x,bins);

pdf = histc(x,bins)/length(x);

cdf(1) = pdf(1);
for i = 2:length(pdf)
   cdf(i) = pdf(i)+cdf(i-1); 
end

h = bar(bins,cdf,'histc');

PD = betafit(x);

xgrid = bins;
pdfgrid = betapdf(xgrid,PD(1),PD(2));
cdfgrid = betacdf(xgrid,PD(1),PD(2));

hold on
plot(xgrid,cdfgrid,'-')
hold off
xlabel('x')
ylabel('Probability Density')
