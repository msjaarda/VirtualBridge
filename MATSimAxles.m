% ------------------------------------------------------------------------
%                            MATSimAxles
% ------------------------------------------------------------------------
% Generate WIMYearlyMaxQSum - a summary of maximum effects on a strip width

 % Initial commands
clear, clc, format long g, rng('shuffle'), close all; 
warning('off','MATLAB:mir_warning_maybe_uninitialized_temporary')

% NOTES
% - Always remember that we are limited to 25t - larger gets tossed by P1

% We can observe a phenomenon where including the ClassOW can sometimes
% decrease the results. This is because of rounding. See 2nd to last
% note, and code to solve for which vehicles were involved.

% Input Information --------------------
                      
% Traffic Info
Year = 2011:2019; % Also have 2010 WIMEnhanced for Ceneri and Oberburen
%Year = 2012;
SName = {'Ceneri', 'Denges', 'Gotthard', 'Oberburen'};
%SName = {'Oberburen'};
%InfDist = 0.6:0.2:2.6; % Strip width
InfDist = 1.4;%:0.2:2.6;

% Option to load Traffic Info from output of "SpecialVehicleMaxEvents"
% - The purpose was to provide RH and Pad with Apercu of cases where
% Overweight vehicles contributed to larger effects than standard traffic
%load('ClassOWApercu');
%{'Ceneri408', 'Ceneri409', 'Denges405', 'Denges406', 'Gotthard402', 'Oberburen415', 'Oberburen416'};
    

ApercuT = 0;
SaveT = 0; 

% All
% Class
% ClassOW

% Initialize variables
YearlyMax = nan(500000,6);
j = 1;

%for p = 1:length(

% For each length of area to be analyzed, optional parfor
for u = 1:length(InfDist)
    
    % Initialize BaseData (keep inside parfor)
    BaseData = table;
    % Roadway Info
    BaseData.TransILx = 0; BaseData.TransILy = 0; BaseData.LaneCen = 0;
    BaseData.StationNum = 1;
    
    BaseData.Stage2Prune = true;
    ClassOnly = [0 1 1];
    ClassOW = [0 0 1];
    
    BaseData.ILs = {'Axle'};  
    BaseData.ILRes = 0.1;   % Do not change right now
    
    % Analysis Info
    BaseData.RunDyn = 0;
    BaseData.MultipleCases = 1;
    BaseData.NumAnalyses = 1;
   
    
    % Input Complete   ---------------------
        
    % For each station to be analyzed
    for r = 1:length(SName)
        
        if strcmp(SName{r},'Gotthard')
            BaseData.LaneDir = {'1,2'};
        else
            BaseData.LaneDir = {'1,1'};
        end
        
        % Obtain Influence Line Info
        [NLanes,Lane,LaneData,~,~] = UpdateData(BaseData,[],1,1);
        [Inf,NInfCases,Inf.x,Inf.v,ESIA] = GetInfLines(LaneData,BaseData,NLanes);
        % Modify IL according to area to be analyzed
        StN = floor((max(Inf.x)/BaseData.ILRes)/2);
        Inf.v(:) = 0; Inf.v(StN:StN+InfDist(u)/BaseData.ILRes-1) = 1;
        
        % For each year to be analyzed
        for i = 1:length(Year)
            
            % Load File
            PD = load(['PrunedS1 WIM/',SName{r},'/',SName{r},'_',num2str(Year(i)),'.mat']);
            
            % Add col for Class, Daytime, and Daycount
            PD = Classify(PD.PD);  PD = Daytype(PD,Year(i));
            
            % Add col for week
            PD.Semaine = ceil(PD.Daycount/7);
            
            % We treat each station separately..
            Stations = unique(PD.ZST);
        
            % For each station
            for w = 1:length(Stations)
                
                Station = Stations(w);
                
                PDCy = PD(PD.ZST == Station,:);
                
                % Further trimming if necessary
                if BaseData.Stage2Prune
                    PDCy = PruneWIM2(PDCy,0);
                end
                
                for m = 1:3
                    
                    PDCx = PDCy;
                        
                    if ClassOnly(m) == 1
                        PDCx.CLASS(PDCx.CLASS == 119) = 0;
                        PDCx(PDCx.CLASS == 0,:) = [];
                        if ClassOW(m) == 1
                            PDCx.CLASS(PDCx.CLASS > 39 & PDCx.CLASS < 50) = 0;
                            PDCx(PDCx.CLASS == 0,:) = [];
                        end
                    end
                    
                    Weeks = unique(PDCx.Semaine);
                    
                    for z = 1:length(Weeks)
                        
                        PDCz = PDCx(PDCx.Semaine == Weeks(z),:);
                    
                    % Convert PDC to AllTrAx (must be greater than 0 to actually Spacesave! Decide on spacesave... should be < 80 I think)
                    [PDCr, AllTrAx, TrLineUp] = WIMtoAllTrAx(PDCz,4,Lane.Dir,BaseData.ILRes);
                    
                    if length(AllTrAx) < 1000
                        %YearlyMax = [YearlyMax; [Year(i), Station, 0, InfDist(u), PDCr.Semaine(1)]];
                        continue
                    end
                    
                    % Round TrLineUp first row, move unrounded to fifth row
                    TrLineUp(:,5) = TrLineUp(:,1); TrLineUp(:,1) = round(TrLineUp(:,1)/BaseData.ILRes);
                    
                    %OverMax = [];
                    BaseData.ApercuTitle = [SName{r} ' ' num2str(Station) ' ' num2str(Year(i)) ' Max'];
                    
                    % Atm, just one analysis per year stored in YearlyMax
                    for k = 1:BaseData.NumAnalyses
                        
                        % Subject Influence Line to Truck Axle Stream
                        [MaxLE,SMaxLE,BrStInd,AxonBr] = GetMaxLE(AllTrAx,Inf,BaseData.RunDyn,1);
                        % % Record Maximums
                        %OverMax = [OverMax; [1, Year(i), MaxLE, SMaxLE, BrStInd]];
                        
                        % See second to last note for an explanation of the
                        % below... it tried to flag cases where ClassOW has
                        % a maximum that actually includes OW vehicles.
                        % Code not ready to run.
%                         S = TrLineUp(find(TrLineUp(:,1)>min(BrStInd+find(Inf.v>0)) & TrLineUp(:,1)<max(BrStInd+find(Inf.v>0))),:);
%                         
%                         AO = PDCr.CLASS(unique(S(:,3)));
%                         
%                         if m == 2
%                             if isempty(find(AO > 39 & AO < 50))
%                                 TG = 0;
%                                 MaxLEr = MaxLE;
%                             else
%                                 TG = 1
%                             end
%                         end

                        if ApercuT
                            T = Apercu(PDCr,BaseData.ApercuTitle,Inf.x,Inf.v(:,1),BrStInd,TrLineUp,MaxLE/ESIA.Total(1),MaxLE/SMaxLE,Lane.Dir,BaseData.ILRes);
                        end
                        
                        % % Delete vehicle entries from TrLineUp for re-analysis
                        %TrLineUp(TrLineUp(:,1) > BrStInd & TrLineUp(:,1) < BrStInd + Inf.x(end),:) = [];
                        % % Set Axles to zero in AllTrAx (can't delete because indices are locations)
                        %AllTrAx(BrStInd:BrStInd + Inf.x(end),:) = 0;
                        
                    end
                    
                    YearlyMax(j,:) = [Year(i), Station, round(MaxLE,3), InfDist(u), PDCr.Semaine(1), m];
                    j = j+1;
                    
                    end

                end
                
            end
        end
    end
end

% Add Column for All, Class, ClassOW
YearlyMax = array2table(YearlyMax,'VariableNames',{'Year', 'Station', 'MaxLE', 'Width', 'Week', 'm'});

%YearlyMax.ClassT = ;

% Must adapt this for including weeks...
%YearlyMax.ClassT = repmat(["All"; "ClassOW"; "Class"],height(YearlyMax)/3,1);
% Delete entries where one of them is 0 (not enough data)
%YearlyMax(YearlyMax.MaxLE == 0,:


% % Make sure All is always equal or greater than the other 2
% % This is to account for rounding errors
% Q = [YearlyMax.MaxLE(YearlyMax.ClassT == "All"),YearlyMax.MaxLE(YearlyMax.ClassT == "ClassOW"),YearlyMax.MaxLE(YearlyMax.ClassT == "Class")];
% T = max(Q');
% T = T';
% YearlyMax.MaxLE(YearlyMax.ClassT == "All") = T;
% Q = [YearlyMax.MaxLE(YearlyMax.ClassT == "ClassOW"),YearlyMax.MaxLE(YearlyMax.ClassT == "Class")];
% T = max(Q');
% T = T';
% YearlyMax.MaxLE(YearlyMax.ClassT == "ClassOW") = T;
% 
% % The above solves some issues, but it is still possible that ClassOW is
% % falsely larger than Class. IndicesRerun are the cases to investigate if
% % it is desired.
% IndicesRerun = find(YearlyMax.MaxLE(YearlyMax.ClassT == "ClassOW")./YearlyMax.MaxLE(YearlyMax.ClassT == "Class") > 1)*3;



WeeklyMaxx = YearlyMax;
WeeklyMaxx(isnan(WeeklyMaxx.Year),:) = [];

%WeeklyMax.m = num2str(WeeklyMax.m);

%WeeklyMax.Properties.VariableNames = {'Year'  'Station'  'MaxLE'  'Width'  'Week'  'ClassT'};

WeeklyMaxx.ClassT(WeeklyMaxx.m == 1) = "All";
WeeklyMaxx.ClassT(WeeklyMaxx.m == 2) = "ClassOW";
WeeklyMaxx.ClassT(WeeklyMaxx.m == 3) = "Class";

WeeklyMaxx.m = [];

WeeklyMax = sortrows(WeeklyMax,[1 2 5 6]);

for i = height(WeeklyMax):-3:5
    if ~strcmp(WeeklyMax.ClassT(i),"ClassOW")
        disp(i)
        break
    end
end

WeeklyMax(i,:) = [];

% Optional Save
if SaveT
    save('WIMWeeklyMaxQSum','YearlyMax');
end

