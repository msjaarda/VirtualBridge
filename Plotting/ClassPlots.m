% Classification
% Takes a WIM Yearly .mat variable (PD), and adds a column with the
% classificaiton according to AGB 2002/005 with the addition of Class 23
% and 11bis.

% Legend of Vehicle Types:
% 7 = "r"
% 8 = "a"
% 9 = "bis"

clear
clc
close all
format long g

% INPUT -----------
Year = 2017;
SName = 'Ceneri';
Vehicle = 99; % for histograms
% Options include each vehicle, 0, for unclassified 99 for all
% -----------------

load(['PrunedS1 WIM/',SName,'/',SName,'_',num2str(Year),'.mat']);


% Make functions to generate data for hitograms
% Basically... try to replicate Traffic Analysis ResultViewer!
% First, define DataBase (Year, SName)
% Then, Define Vehicle Set (Start with just the classes INCLUDING non)
% We need total weight histogram including "OUT"
% We need distances between axle groups




% TODO: We can't easily add an "unclass" class, because all of the # axles
% are different, as well as the distribution of weight and distance between
% those axles... how to solve??

% Also... what to do with "light" vehicles < 6 | < 10 tonnes?



% Let the Classify function add the .CLASS column to PD
[PDC] = Classify(PD);

% Remove later an experiment what if we didn't include those under 10 tonnes?
% Under10t = PDC.GW_TOT<10000;
% PDC(Under10t,:) = [];

% Get number of trucks, NT
NT = height(PDC);

if Vehicle == 99
    TA = true(NT,1);
    NTC = NT;
else
    % Create logical of PDC with desired class
    TA = PDC.CLASS == Vehicle;
    % Get number of trucks in this class, NTC
    NTC = sum(TA);
end

% Create a histogram of total truck weight, in kN (divide kg by 102)    
range = 30:10:620;
histogram(PDC.GW_TOT(TA)/102,range);
[num, edges] = histcounts(PDC.GW_TOT(TA)/102,range);

HistoOutput = [edges(1:end-1)' num'];

% Add title
title(sprintf('Type %i Vehicles at %s %i',Vehicle,SName,Year))
xlabel('Truck Weight (kN)')
ylabel('Number of Trucks')

% A3 = PDC.AX == 9;
% Un3 = and(TA,A3);
% 
% figure(2)
% histogram(PDC.GW_TOT(Un3)/102,30:10:1100)
% 
% histogram(PDC.W1_2(Un2))


%[num, edges] = hist(j);

%hist(PDC.GW_TOT(TA)/102,100);


%ytickformat('')

    
%     [nums, mids] = hist(PDC.GW_TOT(TA)/1000,150);
%     nums = nums/NTC;
%     Between = mids>0 & mids<50;

%j = plot(mids(Between), 100*nums(Between),'LineWidth',1.5);
    %ytickformat('percentage')

% Normalize histogram to being between 0 and 1
% ma = max(PDC.GW_TOT(TA)/102);
% mi = min(PDC.GW_TOT(TA)/102);
% 
% x = ((PDC.GW_TOT(TA)/102)-mi)/(ma-mi);
% bins = 0:0.025:1;
% h = bar(bins,histc(x,bins)/(length(x)*.5),'histc');

% Supress output for now
%histogram(x,bins);

%         
%         y = fitdist(((PDC.GW_TOT(TA)/102)-mi)/(ma-mi),'beta');
%         
%         x_values = 0:0.1:1;
%         Y = pdf(y,x_values);
%         plot(x_values,Y);
    
