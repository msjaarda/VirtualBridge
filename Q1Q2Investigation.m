% ------------------------------------------------------------------------
%                            Q1Q2Investigation
% ------------------------------------------------------------------------
% Explore questions related to axle weights Q1 and Q2
% Goal is to come up with new alphaQs
% Load info from Direct WIM Axle Analyses and draw conclusions
% We have an AxleAnalysis, and a StripAnalysis

% Let's improve the output here (to access all the info quick)
% Perhaps add ClassOnly, ClassOW, and All in a loop
% Output COV, stdev, mean, 95, 98, 99, 99.9, 99.99 %tiles in table form
% In that way we can quickly get alternative to EB's memo values

% Outputs of this: Histograms showing all as well as maximums
% Consider only analyzing maximums... 

% Initial commands
clear, clc, close all, warning('off','MATLAB:table:RowsAddedExistingVars')

% ---- INPUT
AxleAnalysis = 1; 
StripAnalysis = 0;

%ClassType = 'All';
ClassType = {'All', 'Class', 'ClassOW'};
% AxleNames
ANames = {'Single', 'Tandem', 'Tridem'};
MasterT = true;

if AxleAnalysis
    
    % Load results file
    load('WIMAxles')
    % Locations and Years
    %Year = 2011:2019;
    Year = 2018;
    %FNames = fieldnames(Axles);
    FNames = {'Ceneri408', 'Ceneri409', 'Denges405', 'Denges406', 'Gotthard402', 'Oberburen415', 'Oberburen416'};
    
    for z = 1:length(ClassType)
        for q = 1:length(ANames)
            if MasterT
                Master.(ClassType{z}).(ANames{q}) = [];
            end
            Max.(ClassType{z}).(ANames{q}) = [];
            for i = 1:length(Year)
                for j = 1:length(FNames)
                    try
                        T = Axles.(FNames{j})(Year(i)-2000).(ANames{q});
                        if strcmp(ClassType{z},'Class')
                            T(T(:,end) == 0,:) = [];
                            T(T(:,end)> 39 & T(:,end) < 50,:) = [];
                        elseif strcmp(ClassType{z},'ClassOW')
                            T(T(:,end) == 0,:) = [];
                        end
                        if MasterT
                            Master.(ClassType{z}).(ANames{q}) =  [Master.(ClassType{z}).(ANames{q}); T(:,:)];
                        end
                        % Max from first column
                        [a, b] = max(T(:,1));
                        % Taken axle breakdown and class as well
                        Max.(ClassType{z}).(ANames{q}) = [Max.(ClassType{z}).(ANames{q}); T(b,:)];
                    catch
                    end
                end
            end
        end
    end
    
    % Create table with summary info
    for z = 1:length(ClassType)
        for q = 1:length(ANames)
            if q == 1
                Max.Summary.(ClassType{z}) = table();
                if MasterT
                    Master.Summary.(ClassType{z}) = table();
                end
            end
            Max.Summary.(ClassType{z}).Avg(q) = mean(Max.(ClassType{z}).(ANames{q})(:,1)/q);
            Max.Summary.(ClassType{z}).Sdev(q) = std(Max.(ClassType{z}).(ANames{q})(:,1)/q);
            Max.Summary.(ClassType{z}).COV(q) = std(Max.(ClassType{z}).(ANames{q})(:,1)/q)/(mean(Max.(ClassType{z}).(ANames{q})(:,1))/q);
            Max.Summary.(ClassType{z}).F95(q) = prctile(Max.(ClassType{z}).(ANames{q})(:,1)/q,95);
            Max.Summary.(ClassType{z}).F98(q) = prctile(Max.(ClassType{z}).(ANames{q})(:,1)/q,98);
            Max.Summary.(ClassType{z}).F99(q) = prctile(Max.(ClassType{z}).(ANames{q})(:,1)/q,99);
            
            Master.Summary.(ClassType{z}).F95(q) = prctile(Master.(ClassType{z}).(ANames{q})(:,1)/q,95);
            Master.Summary.(ClassType{z}).F98(q) = prctile(Master.(ClassType{z}).(ANames{q})(:,1)/q,98);
            Master.Summary.(ClassType{z}).F99(q) = prctile(Master.(ClassType{z}).(ANames{q})(:,1)/q,99);
            Master.Summary.(ClassType{z}).F9999(q) = prctile(Master.(ClassType{z}).(ANames{q})(:,1)/q,99.99);
            % Beyond 99 is meaningless for our Max sample size
        end
        MTriRatio(z,:) = [100*mean(Max.(ClassType{z}).Tridem(:,2)./Max.(ClassType{z}).Tridem(:,1))  100*mean(Max.(ClassType{z}).Tridem(:,3)./Max.(ClassType{z}).Tridem(:,1)) 100*mean(Max.(ClassType{z}).Tridem(:,4)./Max.(ClassType{z}).Tridem(:,1))];
        MTanRatio(z,:) = [100*mean(Max.(ClassType{z}).Tandem(:,2)./Max.(ClassType{z}).Tandem(:,1)) 100-100*mean(Max.(ClassType{z}).Tandem(:,2)./Max.(ClassType{z}).Tandem(:,1))];
    end
    
    % Optional troubleshooting histograms
%     figure
%     histogram(Master.All.Tandem(:,1),100,'normalization','pdf')
%     figure
%     histogram(Max.All.Tandem(:,1),40,'normalization','pdf')
%     figure
%     histogram(Max.All.Tandem(:,4),40,'normalization','pdf')
    
    % Text output from Master
    %fprintf('\nAverage:\t\t %.3f \n95th pctile:\t %.3f \n99th pctile:\t %.3f \n99.99th pctile:\t %.3f\n\n',...
        %prctile(Master.Tandem(:,1),50),prctile(Master.Tandem(:,1),95),prctile(Master.Tandem(:,1),99),...
        %prctile(Master.Tandem(:,1),99.99));
   
    %AxleF.Single = [prctile(Master.Single(:,1),95);prctile(Master.Single(:,1),99);prctile(Master.Single(:,1),99.99);prctile(Master.Single(:,1),98)];
    %AxleF.Tandem = [prctile(Master.Tandem(:,1),95);prctile(Master.Tandem(:,1),99);prctile(Master.Tandem(:,1),99.99);prctile(Master.Tandem(:,1),98)]./2;
    %AxleF.Tridem = [prctile(Master.Tridem(:,1),95);prctile(Master.Tridem(:,1),99);prctile(Master.Tridem(:,1),99.99);prctile(Master.Tridem(:,1),98)]./3;
    
    for z = 1:length(ClassType)
        Emact.(ClassType{z}) = Max.Summary.(ClassType{z}).F95(2);
        Beta = 4.7;
        Alpha = (1+0.7*Beta*Max.Summary.All.COV(2));
        
        % According to Annex C of SIA 269
        Edact.(ClassType{z}) = Emact.(ClassType{z})*Alpha;       % No model factor included
        AlphaQ.(ClassType{z}) = Edact.(ClassType{z})./(300*1.5); % Gamma = 1.5
            
        fprintf('\n%s\nAverage:\t\t %.3f \nStdev:\t\t\t %.3f \nCOV:\t\t\t %.2f%% \n95th pctile:\t %.2f \nAlphaQ:\t\t\t %.3f\n\n',ClassType{z},...
        Max.Summary.(ClassType{z}).Avg(2),Max.Summary.(ClassType{z}).Sdev(2),100*Max.Summary.(ClassType{z}).COV(2),Emact.(ClassType{z}),AlphaQ.(ClassType{z}));
        
    end
    
    % Must of the decrease is simply due to no DLA... (1.8 or 1.4)
    DLAr = 0.9*1/1.4; 
    
end

if StripAnalysis
    % Load results file
    load('WIMYearlyMaxQSum')
    
    % --- INPUT
    SW = 1.40;
    ClassT = "Class";
    
    dist = 0.02;
    
    figure
    scatter(YearlyMax.Width(strcmp(YearlyMax.ClassT,"All"))-dist,YearlyMax.MaxLE(strcmp(YearlyMax.ClassT,"All")),'sk','MarkerFaceColor',0.2*[1 1 1])
    hold on
    scatter(YearlyMax.Width(strcmp(YearlyMax.ClassT,"ClassOW")),YearlyMax.MaxLE(strcmp(YearlyMax.ClassT,"ClassOW")),'sk','MarkerFaceColor',0.6*[1 1 1])
    scatter(YearlyMax.Width(strcmp(YearlyMax.ClassT,"Class"))+dist,YearlyMax.MaxLE(strcmp(YearlyMax.ClassT,"Class")),'sk','MarkerFaceColor',1*[1 1 1])
    ylim([0 1000])
    xtickformat('%.1f')
    xlim([0.4 2.8])
    xticks(0.4:0.2:2.8)
    xlabel('Strip Width (m)')
    ylabel('Total Load (kN)')
    title('Yearly Maximum Loads at WIM Stations (2011-2018)')
    legend('All Vehicles','ClassifiedOW','Classified')
    
    figure
    scatter(YearlyMax.Width(strcmp(YearlyMax.ClassT,"All"))-dist,1.2*YearlyMax.MaxLE(strcmp(YearlyMax.ClassT,"All"))./YearlyMax.Width(strcmp(YearlyMax.ClassT,"All")),'sk','MarkerFaceColor',0.2*[1 1 1])
    hold on
    scatter(YearlyMax.Width(strcmp(YearlyMax.ClassT,"ClassOW"))+dist,1.2*YearlyMax.MaxLE(strcmp(YearlyMax.ClassT,"ClassOW"))./YearlyMax.Width(strcmp(YearlyMax.ClassT,"ClassOW")),'sk','MarkerFaceColor',0.6*[1 1 1])
    scatter(YearlyMax.Width(strcmp(YearlyMax.ClassT,"Class")),1.2*YearlyMax.MaxLE(strcmp(YearlyMax.ClassT,"Class"))./YearlyMax.Width(strcmp(YearlyMax.ClassT,"Class")),'sk','MarkerFaceColor',1*[1 1 1])
    ylim([0 1000])
    xtickformat('%.1f')
    xlim([0.4 2.8])
    xticks(0.4:0.2:2.8)
    xlabel('Strip Width (m)')
    ylabel('Distributed Load (kN/m) * 1.2 m')
    title('Yearly Maximum Loads at WIM Stations (2011-2018) Normalized for 1.2 m')
    legend('All Vehicles','ClassifiedOW','Classified')
    
    % Perhaps should change to 1.4 or 1.6
    % Model factor on MaxLE? not right now but should we?
    % Which YearlyMax are we using? AllAx? ClassAx?
   
    Emact = prctile(YearlyMax.MaxLE(strcmp(YearlyMax.ClassT,ClassT) & YearlyMax.Width < SW+0.01 & YearlyMax.Width > SW-0.01),95);
    MeanStrip = mean(YearlyMax.MaxLE(strcmp(YearlyMax.ClassT,ClassT) & YearlyMax.Width < SW+0.01 & YearlyMax.Width > SW-0.01));
    StdStrip = std(YearlyMax.MaxLE(strcmp(YearlyMax.ClassT,ClassT) & YearlyMax.Width < SW+0.01 & YearlyMax.Width > SW-0.01));
    v = StdStrip/MeanStrip;
    Beta = 4.7;
    Alpha = (1+0.7*Beta*v);
    
    % According to Annex C of SIA 269
    Edact = Emact*Alpha;       % No model factor included
    AlphaQ = Edact./(1000*1.5); % Gamma = 1.5
    
    fprintf('\nAverage:\t\t %.3f \nStdev:\t\t\t %.3f \nCOV:\t\t\t %.2f%% \n95th pctile:\t %.2f \nAlphaQ:\t\t\t %.3f\n\n',...
      MeanStrip,StdStrip,100*v,Emact,AlphaQ);
       
end

