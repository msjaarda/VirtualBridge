% Load info from Direct WIM Axle Analysis and draw conclusions

clear, clc, close all

% Now we must write this memo... question is, why is ClassOW < Class?!
% Look into this...

% Refigure now that we have new variables with new formats.
% Remember to get the ratio of axles between each other like Alain
% suggested
% For Axles, add maximum per year detection

% Consideration of both model factor and DLA...
% Should we add a model factor on MaxLE?

% - Fix Q1Q2Investigation to include final recommendation (notes r there)

% Folder Name
FName{1} = '/AllAxles';
FName{2} = '/ClassAxles';
%FName{3} = '/ClassOWAxles';
YMA = 1;
AGA = 0;

AxleF = table;

j = 1;
if YMA
    load(['Output' FName{j} '/' 'YearlyMaxQSum'])
end
if AGA
    load(['Output' FName{j} '/' 'AxleGroupWeights'])
end

if AGA
    % Create an information table for 56 indices
    Info = table;
    Info.Year = zeros(56,1);
    Info.SName = repmat("Ceneri",56,1);
    Info.SName(17:17+16) = "Denges";
    Info.SName(17+16:17+16+8) = "Gotthard";
    Info.SName(17+16+8:end) = "Oberburen";
    % Be sure that YearlyMax is loaded
    Info.Station = YearlyMax.Station(1:56);
    Info.Year =  YearlyMax.Year(1:56);
    
    % Allow option to select from just one station
    Ind = [1:56]';
    %Ind = find(Info.SName == 'Denges' & Info.Year == 2018);
    
    Master.Single = [];
    for i = Ind'
        Temp = Axles{i}{1};
        Master.Single =  [Master.Single; Temp];
    end
    
    Master.Tandem = [];
    MaxY = [];
    for i = Ind'
        % Load tandems and add to a master tandem
        Temp = Axles{i}{2};
        Master.Tandem =  [Master.Tandem; Temp];
        MaxY = [MaxY; max(Temp)];
    end
    
    Master.Tridem = [];
    for i = Ind'
        Temp = Axles{i}{3};
        Master.Tridem =  [Master.Tridem; Temp];
    end
    
    % Use this axle histogram to get alphaQ1!
    % Look at Prof. B's memo... and all reliability concepts
    % Include gamma = 1.4?
    % Compare to B values and F's front yearly reports.
    
    % Looks like we get different values because of the way we classify (AGB 2002/005 instead
    % of Swiss10). Still, AllAxles is the smartest way to go. It involves even the very
    % punishing occurances.
    
    %histogram(Master.Tandem,100,'normalization','pdf')
    clc
    fprintf('Average:\t\t %.3f \n95th pctile:\t %.3f \n99th pctile:\t %.3f \n99.99th pctile:\t %.3f\n\n',...
        prctile(Master.Tandem,50),prctile(Master.Tandem,95),prctile(Master.Tandem,99),...
        prctile(Master.Tandem,99.99));
    
    AxleF.Single = [prctile(Master.Single,95);prctile(Master.Single,99);prctile(Master.Single,99.99);prctile(Master.Single,98)];
    AxleF.Tandem = [prctile(Master.Tandem,95);prctile(Master.Tandem,99);prctile(Master.Tandem,99.99);prctile(Master.Tandem,98)]./2;
    AxleF.Tridem = [prctile(Master.Tridem,95);prctile(Master.Tridem,99);prctile(Master.Tridem,99.99);prctile(Master.Tridem,98)]./3;
    
end

if YMA
    dist = 0.02;
    %prctile(YearlyMax.MaxLE(YearlyMax.Width == 2),99)
    scatter(YearlyMax.Width-dist,YearlyMax.MaxLE,'sk','MarkerFaceColor',0.2*[1 1 1])
    j = 2;
    load(['Output' FName{j} '/' 'YearlyMaxQSum'])
    hold on
    scatter(YearlyMax.Width+dist,YearlyMax.MaxLE,'sk','MarkerFaceColor',0.6*[1 1 1])
%     j = 3;
%     load(['Output' FName{j} '/' 'YearlyMaxQSum'])
%     hold on
%     scatter(YearlyMax.Width+dist,YearlyMax.MaxLE,'sk','MarkerFaceColor',1*[1 1 1])
    ylim([0 1000])
    xtickformat('%.1f')
    xlim([0.4 2.8])
    xticks(0.4:0.2:2.8)
    xlabel('Strip Width (m)')
    ylabel('Total Load (kN)')
    title('Yearly Maximum Loads at WIM Stations (2011-2018)')
    legend('All Vehicles','Classified Only')
    
    figure
    hold on
    scatter(YearlyMax.Width-dist,1.2*YearlyMax.MaxLE./YearlyMax.Width,'sk','MarkerFaceColor',0.6*[1 1 1])
    j = 1;
    load(['Output' FName{j} '/' 'YearlyMaxQSum'])
    hold on
    scatter(YearlyMax.Width+dist,1.2*YearlyMax.MaxLE./YearlyMax.Width,'sk','MarkerFaceColor',0.2*[1 1 1])
    ylim([0 1000])
    xtickformat('%.1f')
    xlim([0.4 2.8])
    xticks(0.4:0.2:2.8)
    xlabel('Strip Width (m)')
    ylabel('Distributed Load (kN/m) * 1.2 m')
    title('Yearly Maximum Loads at WIM Stations (2011-2018) Normalized for 1.2 m')
    legend('Classified Only','All Vehicles')
    % also display kN/m... normalized to 1.2 to make a decision
    % keep writing memo... and do something for platooning this aft
    
end


Num = 184.8*(1.+0.7*4.7*0.0782);
NumC = 300*1.5;
Rati = 232.3/450;
DLAr = 0.9*1/1.4; % Should actually be 1.8 and not 1.4

% Which YearlyMax are we using? AllAx? ClassAx?
PCT = prctile(YearlyMax.MaxLE(YearlyMax.Width == 1.6),95);
std(YearlyMax.MaxLE(YearlyMax.Width == 1.6));
std(YearlyMax.MaxLE(YearlyMax.Width == 1.6))/mean(YearlyMax.MaxLE(YearlyMax.Width == 1.6));
595*(1+4.7*0.7*0.178);
ans/1500;
% Repeat with 1.4