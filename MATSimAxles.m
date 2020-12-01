% ------------------------------------------------------------------------
%                            MATSimAxles
% ------------------------------------------------------------------------
% Generate a summary of maximum effects on a strip length
% Purpose is to study Q1+Q2, in that way this script is a sister to
% AxleStatsBasic, which focusses on Q1 on its own. Both have live scripts
% which load vars and perform analyses.
% AxleStatsBasic >> Q1 Investigation
% MATSimAxles    >> Q1Q2 Investigation

 % Initial commands
clear, clc, format long g, rng('shuffle'), close all;

% Notes
% - Add new stations to existing variables manually (load together and cat)
% - Remember that we are limited to 25t - larger getts tossed by S1Prune
% - Make sure ClassOW is set to true inside Classify.m and no 11bis

% Input Information --------------------
                      
% Traffic Info
Year = 2011:2019; % Also have 2010 WIMEnhanced for Ceneri and Oberburen
%Year = 2012;
SName = {'Ceneri', 'Denges', 'Gotthard', 'Oberburen'};
%SName = {'Oberburen'};
%InfDist = 0.6:0.2:2.6; % Strip width
InfDist = 1.4;
    
% Toggles
ApercuT = 0;
Stage2Prune = true;

% Input Complete   ---------------------

% Initialize variables and start row counter
YearlyMax = nan(500000,6); j = 1;

% For each strip length to be analyzed
for u = 1:length(InfDist)
    
    % Initialize BaseData
    BaseData = table;
    % Roadway Info
    BaseData.TransILx = 0; BaseData.TransILy = 0; BaseData.LaneCen = 0;
    BaseData.StationNum = 1;
    % IL Info
    BaseData.ILs = {'Axle'};  
    BaseData.ILRes = 0.1;   % Do not change right now
    % Analysis Info
    BaseData.RunDyn = 0;
    BaseData.Stage2Prune = Stage2Prune;
    % New stretegy - do it 10 times per day. Detect if ClassOW or UnClass are included and code as such
    BaseData.NumAnalyses = 10;

    % For each station to be analyzed
    for r = 1:length(SName)
        
        % Adjust direction for Gotthard
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
            
            % Classify and add Datetime
            PDC = Classify(PD.PD); PDC = AddDatetime(PDC,1);
            
            % Further trimming if necessary
            if BaseData.Stage2Prune
                PDC = PruneWIM2(PDC,0);
            end
            
            % We treat each station separately
            Stations = unique(PDC.ZST);
        
            % For each station
            for w = 1:length(Stations)
                
                % Take only stations w
                PDCx = PDC(PDC.ZST == Stations(w),:);
                
                % Convert PDC to AllTrAx - Spacesave at 4 (plus min 26 = 30)
                [PDCr, AllTrAx, TrLineUp] = WIMtoAllTrAx(PDCx(PDCx.Group == z,:),4,Lane.Dir,BaseData.ILRes);

                % Make groups out of each unique day
                PDCr.Group = findgroups(dateshift(PDCr.Time,'start','day'));
                
                % Expand TrLineUp
                TrLineUp(:,6) = PDCr.Group(TrLineUp(:,3));
                
                % TrLineUp [       1             2         3        4         5            6            7           8         9       ]
                %            AllTrAxIndex    AxleValue   Truck#   LaneID  Station(m) StationDiff(m) SingleFlag TridemFlag TandemFlag
                
                % Perform search for maximums for each day
                for z = 1:max(PDCx.Group)
                    
                    

                    
                    % Lets try doing WIMtoAllTrAx just once per ZST
                    % We beef up TrLineUp so we don't need to go into PDCr
                    % We modify AllTrAx each time, taking only the section
                    % corresponding to our Group (unique day).
                    % We track the indices to be able to get the true
                    % AllTrAx Index for plugging into TrLineUp
                    
                    
                    
                    
                    % Think about instead of doing WIMtoAllTrAx each z loop
                    % instead grabbing the relavent rows of AllTrAx each
                    % time...why not add a Time col to TrLineUp? this way
                    % we would not need to go back and modify PDC. We could
                    % also consider outputting truck class and lane stats
                    % to the final output variable
                    
                    
                    
                    
                    
                    PDCx = PDCr;
                    
                    
                    
                    
                    % Don't bother running if the week is too small
                    if length(AllTrAx) < 1000
                        %YearlyMax = [YearlyMax; [Year(i), Station, 0, InfDist(u), PDCr.Semaine(1)]];
                        continue
                    end
                    
                    % Round TrLineUp first row, move unrounded to fifth row
                    TrLineUp(:,5) = TrLineUp(:,1); TrLineUp(:,1) = round(TrLineUp(:,1)/BaseData.ILRes);
                    
                    % Lets beep up TrLineUp so that we don't need to keep
                    % dipping into PDC?
                    
                    
                    % For each analysis
                    for k = 1:BaseData.NumAnalyses
                        
                        % Subject Influence Line to Truck Axle Stream
                        [MaxLE,SMaxLE,BrStInd,AxonBr,~] = GetMaxLE(AllTrAx,Inf,BaseData.RunDyn,1);
                        
                        % What if we want to know when it happened??
                        % Not just the date... we can use TrLineUp to link!
                        % We have BrStInd... this is the index (AllTrAx) for the
                        % start of the bridge. We convert to
                        
                        % Put a try statement in case BrStInd wraps around
                        % (highly unlikely)
                        %try
                        IND = BrStInd:BrStInd+length(Inf.v)-1; IND = IND';
                        IND = IND(Inf.v == 1);
                        Sample = TrLineUp(TrLineUp >= min(IND) & TrLineUp <= max(IND),3);
                        %catch
                        %Sample = randi(max(TrLineUp),1);
                        %end
                        MaxLETime = PDCr.Time(Sample(1));
                        Vehs = PDCr.CLASS(Sample);
                        
                        if min(Vehs) == 0
                            m = 1;
                        elseif sum(Vehs > 39 & Vehs < 50) > 0
                            m = 2;
                        else
                            m = 3;
                        end
                        

                        

                        
                        if ApercuT
                            BaseData.ApercuTitle = [SName{r} ' ' num2str(Station) ' ' num2str(Year(i)) ' Max'];
                            T = Apercu(PDCr,BaseData.ApercuTitle,Inf.x,Inf.v(:,1),BrStInd,TrLineUp,MaxLE/ESIA.Total(1),MaxLE/SMaxLE,Lane.Dir,BaseData.ILRes);
                        end
                        
                        % Just make sure we also delete from PDC for proper
                        % time/class recognition...
                        
                        % Should we only do WIMtoAllTrAxOnce?
                        
                        % % Delete vehicle entries from TrLineUp for re-analysis
                        %TrLineUp(TrLineUp(:,1) > BrStInd & TrLineUp(:,1) < BrStInd + Inf.x(end),:) = [];
                        
                        % Do we even need to delete from TrLineUp? I don't
                        % think so!!
                        
                        % Set Axles to zero in AllTrAx (can't delete because indices are locations)
                        AllTrAx(BrStInd:BrStInd + Inf.x(end),:) = 0;
                        
                    end
                    
                    % Might have to keep track of datetimes
                    YearlyMax(j,:) = [Year(i), Station, round(MaxLE,3), InfDist(u), m, datenum(MaxLETime)];
                    j = j+1;
                    
                end              
            end
        end
    end
end

% Add Column for All, Class, ClassOW
% Convert back to datetime !!
YearlyMax = array2table(YearlyMax,'VariableNames',{'Year', 'ZST', 'MaxLE', 'Width', 'Time', 'm'});

WeeklyMaxx = YearlyMax;
WeeklyMaxx(isnan(WeeklyMaxx.Year),:) = [];

%WeeklyMax.m = num2str(WeeklyMax.m);

%WeeklyMax.Properties.VariableNames = {'Year'  'Station'  'MaxLE'  'Width'  'Week'  'ClassT'};

WeeklyMaxx.ClassT(WeeklyMaxx.m == 1) = "All";
WeeklyMaxx.ClassT(WeeklyMaxx.m == 2) = "ClassOW";
WeeklyMaxx.ClassT(WeeklyMaxx.m == 3) = "Class";

WeeklyMaxx.m = [];

% 30-11-2020
% We want to eliminate the difference between Class, ClassOW, and All.
% We should compute the calculation of the distance between vehicles with
% all vehicles involved (no deletions), and THEN filter based on class.
% This should take care of the problem.
% Furthermore, we will recreate the variable as DailyMax with a Time stamp
% variable, so as to make it easy to use Findgroups and Splitapply to get
% Weekly and Yearly Maxes.
