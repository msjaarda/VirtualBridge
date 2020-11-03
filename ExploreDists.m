clear,clc

% Simulation Maximums...
load('C:\Users\sjaarda\Desktop\SwissTraffic\Output\AGB2002\Apr15-20 1339.mat')

InfCase = 22;
InfName = OutInfo.InfNames{14};

% Just the results...
Results = OutInfo.OverMaxT(OutInfo.OverMaxT.InfCase == InfCase,:);


% Top result over 15 years of stopped traffic, n = 1000 samples
histogram(Results.MaxLE)

% Not the actual N we are after!
% Let's start with daily maximums. We can gather them from Ceneri 2011 to
% 2018, one per direction makes 8*2*365 = almost n = 6000
% This is our original variable...
% Or we can go hourly... then we will have 8760...

PercentileCheck = 1.1*prctile(Results.MaxLE,99)

OutInfo.ESIM(InfCase)


% Initial Distributions
x = 0.4:0.01:1;

% Exponential
FxE = 1-6554*exp(-27.72*x);
fxE = 181676.88*exp(-27.72*x);
N = [5 10 50 100 1000 10000];
for i = 1:length(N)
    EFxE(N,:) = FxE.^(N(i));
    EfxE(N,:) = 181676.88*(N(i))*exp(-27.72*x).*(1-6554*exp(-27.72*x)).^((N(i))-1);
end
MeanEfxE = max(EfxE');

% Polynomial
FxP = 1-(0.3270./x).^(11.43);
fxP = 0.0000323093*(1./x).^(12.43);

% Bounded
FxB = 1-((1-x)./0.6911).^(16.29);
fxB = 6695.76*((1-x)).^(15.29);

figure()
plot(x,FxE)
hold on
plot(x,FxP)
plot(x,FxB)

figure()
plot(x,fxE)
hold on
plot(x,fxP)
plot(x,fxB)

figure()
hold on
plot(x,EfxE)

for N = 1:8
    x = rand(10^N,1);
    IFxE = (-1/27.72)*ln((-x+1)./6554);
    

end

