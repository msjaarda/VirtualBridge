clear, clc, close all

% SBF414 This script designed to replicate Simon Bailey's Figure 4.14
%        Furthermore, it gives a feel for the generalized extreme value
%        parameters that arise from using SB's fitting method
%        (Levenberg-Marqhuart algorithm) using mean of maximums, 
%        or Matlab's gevfit given the extreme values directly.

% There are two main ways to express the extreme value parameters. With
% SB's method, using W, chi, and m, we have a way of representing a family
% of extreme value parameters. Given N, the number of vehicles and "block
% size" from which extreme values are chosen, we can solve for the
% characteristic maximum value of s (traffic action effect). This
% characteristic value, wn, has a probability of exceedence of 1/N for a
% given sample of size N. From p 209 of Ang & Tang we see that among a
% population of possible largest values from samples of size N, exp(-1) or
% 36.8% will be less than wn, and ~63% will be greater.

% MATLab (also Wikipedia)
% mu    - location (equals wn)
% sigma - scale (W-wn)/m
% k     - shape (-1/m)

% wn - characteristic value (equals W-chi*W/(N^(1/m)), equals mu, peak of pdf

% SB
% W   - upper limit (equals mu-sigma/k)
% chi - position (sigma*k^2*N^k/(sigma-k*mu))
% m   - shape (-1/k)

% Select folder where results are located
%Folder_Namex = 'F414SBx';
Folder_Namex = 'SBA4';
% Get file list from folder
File_List = GetFileList(Folder_Namex);

% Plot Std & Mean of Maxes?
plot1 = false;
plot2 = false;

% For looping
n = 1000000;
Flo = 3; % 1 (1000 vph), 2 (30 kph), 3 (At-rest)

for Flo = 3

% Step through file list and convert OutInfo results to OInfo structure
for i = 1:length(File_List)
    load(['Output/' Folder_Namex '/' File_List(i).name])
    OInfo(i) = OutInfo;
    % Save FloTypes, main stats for each
    FloName{i} = OInfo(i).BaseData.Flow{:};
    Stdev(i) = std(OInfo(i).OverMax);
    Mean(i) = mean(OInfo(i).OverMax);
    N(i) = OInfo(i).BaseData.NumVeh;
end
% Clear OutInfo for clarity
clear OutInfo

% Get unique flow regimes
Uniq = unique(FloName);

% Create NameI, which is the integer version of each name
for i = 1:length(OInfo)
    [a, NameI(i)] = ismember(OInfo(i).BaseData.Flow{:},Uniq);
end

% Create function for lsqcurvefit (inside loop)
fun = @(x1,xdata)x1(1)-x1(2)*xdata.^(x1(3));
% Give function starting point
x0 = [70, 60, 0.0125];

% Std & Mean of Maxes
% For each Flo regime plot mean and stdev of maximums and fit curve
for i = 1:length(Uniq)
    
    % Get x and y data (N and mu)
    xdata = N(NameI == i)';
    ydata = Mean(NameI == i)'/1000;
    % Perform lsq curvefit just like SB to get W, k, chi
    x1 = lsqcurvefit(fun,x0,xdata,ydata);
    W(i) = x1(1);
    m(i) = -1/x1(3);
    chi(i) = x1(2)/(W(i)*gamma(1+1/m(i)));
    % Create long version to see curve shape
    xdatalong = [xdata; 10^8; 10^9; 10^10; 10^11; 10^13; 10^15; 10^18; 10^21; 10^24; 10^27; 10^31; 10^35; 10^40];
    % y-prediction uses results of lsqcurvefit
    yprdSB = W(i)-chi(i)*W(i)*xdatalong.^(-1/m(i)).*gamma(1+1/m(i));
    
    if plot1
        figure(1)
        % Scatter plot of Mean of Maximums
        scatter(N(NameI == i)',Mean(NameI == i)'/1000)
        hold on
        % Overlay prediction from curvefit
        plot(xdatalong,yprdSB,'k--','HandleVisibility','off')

        figure(2)
        % Scatter plot of Stdev of Maximums
        scatter(N(NameI == i)',Stdev(NameI == i)'/1000)
        hold on
        % Overlay 
        yprd2 = sqrt((chi(i)*W(i)./(xdata.^(1/m(i)))).^2.*(gamma(1+2/m(i))-(gamma(1+1/m(i))^2)));
        plot(xdata,yprd2,'k--','HandleVisibility','off')
    end
end

% Plot labelling for the above
if plot1
    title('Stdev of Maximums')
    xlabel('N, # vehicles')
    ylabel('M_{n} (MNm)')
    
    set(gca, 'XScale', 'log')
    
    ylim([0,2])
    xlim([10^2.5,10^7])
    
    legend(Uniq,'location','northeast')
    
    figure(1)
    title('Mean of Maximums')
    xlabel('N, # vehicles')
    ylabel('M_{n} (MNm)')
    
    ylim([0,35])
    xlim([10^2.5,10^40])
    
    legend(Uniq,'location','northwest')
    
    set(gca, 'XScale', 'log')
end

clc

% Gather Results into table format
ResSB = table(W(:),chi(:),m(:),'VariableNames',{'W', 'chi', 'm'},'RowNames',Uniq); ResSBx = ResSB;
% Copy Simon Bailey's results (different traffic... just for comparison)
ResSBx.W = flip([70.7,51.4,36.8])'; ResSBx.m = flip([78.8,60.7,65.3])'; ResSBx.chi = flip([0.889,0.898,0.952])';



for i = Flo
    figure(Flo+10)
    xdatalong = [1; 10; 100; xdata; 10^8; 10^9; 10^10; 10^11; 10^13; 10^15; 10^18; 10^21; 10^24; 10^27; 10^31; 10^35; 10^40];
    yprdSB = ResSB.W(i)-ResSB.chi(i)*ResSB.W(i)*xdatalong.^(-1/ResSB.m(i)).*gamma(1+1/ResSB.m(i));
    yprdSBx = ResSBx.W(i)-ResSBx.chi(i)*ResSBx.W(i)*xdatalong.^(-1/ResSBx.m(i)).*gamma(1+1/ResSBx.m(i));
    scatter(N(NameI == i)',Mean(NameI == i)'/1000)
    hold on
    plot(xdatalong,yprdSB,'k-','HandleVisibility','on')
    plot(xdatalong,yprdSBx,'b-','HandleVisibility','on')
%     Sensitivity of chi, position (shifts right and left)
%     yprd = ResSB.W(i)-(ResSB.chi(i)-0.3)*ResSB.W(i)*xdatalong.^(-1/ResSB.m(i)).*gamma(1+1/ResSB.m(i));
%     plot(xdatalong,yprd,'r--','HandleVisibility','off')
%     yprd = ResSB.W(i)-(ResSB.chi(i)+0.3)*ResSB.W(i)*xdatalong.^(-1/ResSB.m(i)).*gamma(1+1/ResSB.m(i));
%     plot(xdatalong,yprd,'b--','HandleVisibility','off')
%     Sensitivity of W, upper limit (controls asymptot at top)
%     yprd = (ResSB.W(i)-1)-(ResSB.chi(i))*(ResSB.W(i)-1)*xdatalong.^(-1/ResSB.m(i)).*gamma(1+1/ResSB.m(i));
%     plot(xdatalong,yprd,'b-','HandleVisibility','off')
%     yprd = (ResSB.W(i)+1)-(ResSB.chi(i))*(ResSB.W(i)+1)*xdatalong.^(-1/ResSB.m(i)).*gamma(1+1/ResSB.m(i));
%     plot(xdatalong,yprd,'r-','HandleVisibility','off')
%     Sensitivity of k, shape (higher k is a flatter ramp, lower is steeper
%     yprd = (ResSB.W(i))-(ResSB.chi(i))*(ResSB.W(i))*xdatalong.^(-1/(ResSB.m(i)+20)).*gamma(1+1/(ResSB.m(i)+20));
%     plot(xdatalong,yprd,'r-','HandleVisibility','off')
%     yprd = (ResSB.W(i))-(ResSB.chi(i))*(ResSB.W(i))*xdatalong.^(-1/(ResSB.m(i)-5)).*gamma(1+1/(ResSB.m(i)-5));
%     plot(xdatalong,yprd,'b-','HandleVisibility','off')
    title(sprintf('Mean of Maximums %s',Uniq{i}))
    xlabel('N, # vehicles')
    ylabel('M_{n} (MNm)')

    ylim([0,70])
    xlim([1,10^40])

    set(gca, 'XScale', 'log')
end

% Let us pick a scenario, say At-rest with n, Index I
for j = 1:length(OInfo)
    if strcmp(OInfo(j).BaseData.Flow{:},Uniq{i})
        if OInfo(j).BaseData.NumVeh == n
            I = j;
        end
    end
end

% Find wn for N = n
ResSB.mu = ResSB.W-ResSB.chi.*ResSB.W./(n.^(1./ResSB.m));
ResSB.sigma = (ResSB.W-ResSB.mu)./(ResSB.m);
ResSB.k = -1./(ResSB.m);
ResSBx.mu = ResSBx.W-ResSBx.chi.*ResSBx.W./(n.^(1./ResSBx.m));
ResSBx.sigma = (ResSBx.W-ResSBx.mu)./(ResSBx.m);
ResSBx.k = -1./(ResSBx.m);

% Plot actual maximum histogram (original variate is s, this is s,max)
figure()
histogram(OInfo(I).OverMax/1000,25,'normalization','pdf')

title(['s_{max}' sprintf(' Histogram %s N = %i',Uniq{i},n)])
xlabel('M_{n} (MNm)')
ylabel('PDF')
set(gca,'YTick', [])

xlim([0,35])

% Estimate generalized extreme value parameters
paramEsts = gevfit(OInfo(I).OverMax/1000);
% Put in friendly terms
GF.mu = paramEsts(3); GF.sigma = paramEsts(2); GF.k = paramEsts(1);

% Convert between MW (matlab/wikipedia) format, and SB/AT (simon bailey/ang & tang format)
GF.W = GF.mu-GF.sigma/GF.k;
GF.m = -1/GF.k;
GF.chi = (GF.sigma*GF.m*n^(-1/GF.m))/GF.W;

SB.mu = ResSB.mu(i);
SB.sigma = ResSB.sigma(i);
SB.k = ResSB.k(i);

SB.W = ResSB.W(i);
SB.chi = ResSB.chi(i);
SB.m = ResSB.m(i);

SBx.mu = ResSBx.mu(i);
SBx.sigma = ResSBx.sigma(i);
SBx.k = ResSBx.k(i);

SBx.W = ResSBx.W(i);
SBx.chi = ResSBx.chi(i);
SBx.m = ResSBx.m(i);

% Overlay PDF from fit parameters
hold on
xgrid = 0:0.05:25;
line(xgrid,gevpdf(xgrid,GF.k,GF.sigma,GF.mu),'Color','r');
% Overlay PDF from SB fit parameters (using mean of maximums)
line(xgrid,gevpdf(xgrid,SB.k,SB.sigma,SB.mu),'Color','k');
line(xgrid,gevpdf(xgrid,SBx.k,SBx.sigma,SBx.mu),'Color','b');

legend('Ceneri2017','GEVFit Matlab','SB Estimate','SB Similar')

figure(Flo+10)
hold on
yprdGF = GF.W-GF.chi*GF.W*xdatalong.^(-1/GF.m).*gamma(1+1./GF.m);
plot(xdatalong,yprdGF,'r-','HandleVisibility','on')
legend('Ceneri2017','SB Estimate','SB Similar','GEVFit Matlab')

end


% OPTIONAL EXPLORATION OF INITIAL VARIATE

if plot2
    
    % Initial variate (s) CDF
    figure()
    xd = 0:0.05:25;
    yd = 1-(1/n)*((SB.W-xd)./(SB.W-SB.mu)).^(SB.m);
    % alternatively 1-((SB.W-xd)./(SB.W*SB.chi)).^(SB.m);
    line(xd,yd)
    hold on
    % Check characteristic value
    prob = 1/n;
    p = 1-prob;
    dif = abs(yd-p);
    [c b] = min(dif); % b is index of closest match
    mucheck = xd(b);
    [mucheck SB.mu]
    
    % Derived using WolframAlpha to get PDF (only describes tail probably)
    yd3 = (SB.m*((SB.W-xd)./(SB.W*SB.chi)).^(SB.m))./(SB.W-xd);
    line(xd,yd3)
    
    load('FatigueOutput\InitialR.mat')
    figure()
    histogram(R/1000,250,'normalization','pdf')
    hold on
    line(xd,yd,'Color','k')
    line(xd,yd3,'Color','r')
    
    %title(['s_{max}' sprintf(' Histogram %s N = %i',Uniq{i},n)])
    xlabel('M_{n} (MNm)')
    %ylabel('PDF')
    %set(gca,'YTick', [])
    
    xlim([15,25])
    ylim([0,0.0005])
    
    
    % Now what we do is split the InitialR... try to make exactly 1000000!
    % Take the maximum out of every block of 4.428 entries...
    inds = [1:4:1+4427742];
    R1 = R(inds);
    inds = [2:4:1+4427742];
    R2 = R(inds);
    inds = [3:4:1+4427740];
    R3 = R(inds);
    inds = [4:4:1+4427742];
    R4 = R(inds);
    R1(end) = [];
    R2(end) = [];
    
    Rx = max([R1';R2';R3';R4']); Rx = Rx';
    
    figure()
    histogram(R1/1000,250,'normalization','pdf')
    hold on
    line(xd,yd,'Color','k')
    line(xd,yd3,'Color','r')
    
    %title(['s_{max}' sprintf(' Histogram %s N = %i',Uniq{i},n)])
    xlabel('M_{n} (MNm)')
    %ylabel('PDF')
    %set(gca,'YTick', [])
    
    xlim([15,25])
    ylim([0,0.0005])

end

% Somewhat unsatisfying... PDF doesn't match initial distribution that much
% Could be because "n" is ficticious, corresponding to each vehicle and in
% reality they work together

% Time to revisit flange example using Monte Ceneri traffic...


% Define for new n
% n = 2500000;
% 
% % Find wn for N = n
% ResSB.mu = ResSB.W-ResSB.chi.*ResSB.W./(n.^(1./ResSB.m));
% ResSB.sigma = (ResSB.W-ResSB.mu)./(ResSB.m);
% ResSB.k = -1./(ResSB.m);
% 
% SB.mu = ResSB.mu(i);
% SB.sigma = ResSB.sigma(i);
% SB.k = ResSB.k(i);
% 
% SB.W = ResSB.W(i);
% SB.chi = ResSB.chi(i);
% SB.m = ResSB.m(i);

prctile(OInfo(I).OverMax/1000,99);

