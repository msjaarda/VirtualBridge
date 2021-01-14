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
%Year = 2017;
SName = {'Ceneri', 'Denges', 'Gotthard', 'Oberburen'};
%SName = {'Ceneri'};
%InfDist = 0.6:0.2:2.6; % Strip width
InfDist = 1.4;
    
% Toggles
ApercuT = 0;
Stage2Prune = true;

% Input Complete   ---------------------

% Initialize variables and start row counter
MaxEvents = nan(500000,13); j = 1;

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
                
                % SOMEHOW THIS AFFECTS THE RESULTS
                % Find dominant and weak lanes and recode as 1, 2, respectively
                PDCx.FS = PDCx.FS + 3;
                [C,ia,ic] = unique(PDCx.FS);
                a_counts = accumarray(ic,1); [~, b] = max(a_counts); [~, c] = min(a_counts);
                DomL = C(b); WeakL = C(c);
                PDCx.FS(PDCx.FS == DomL) = 1;
                PDCx.FS(PDCx.FS == WeakL) = 2;
                
                % Convert PDC to AllTrAx - Spacesave at 4 (plus min 26 = 30)
                [PDCr, AllTrAx, TrLineUp] = WIMtoAllTrAx(PDCx,4,Lane.Dir,BaseData.ILRes);

                % Make groups out of each unique day
                PDCr.Group = findgroups(dateshift(PDCr.Time,'start','day'));
                
                % Round TrLineUp first row, move unrounded to fifth row
                TrLineUp(:,5) = TrLineUp(:,1); TrLineUp(:,1) = round(TrLineUp(:,1)/BaseData.ILRes);
                % Expand TrLineUp to include groups
                TrLineUp(:,6) = PDCr.Group(TrLineUp(:,3));
                
                % TrLineUp [       1             2         3        4         5               6       ]
                %            AllTrAxIndex    AxleValue   Truck#   LaneID  Station(m)   Group(UniqueDay)
                
                % Perform search for maximums for each day
                for z = 1:max(PDCr.Group)
                    
                    clc
                    % To track progress
                    fprintf('\nLocation: %s\n    Year: %i\n     Day: %i\n\n',SName{r},Year(i),z)
            
                    % Store starting and end indices
                    Starti = max(0,min(TrLineUp(TrLineUp(:,6) == z,1))-300);
                    Endi = min(max(TrLineUp(TrLineUp(:,6) == z,1)+300),length(AllTrAx));
                    
                    % Subdivide AllTrAx
                    AllTrAxSub = AllTrAx(Starti:Endi,:);

                    % Don't bother running if the segment is too small
                    if length(AllTrAxSub) < 2000
                        continue
                    end
                    
                    k = 0;
                    % For each analysis
                    while k < BaseData.NumAnalyses
                        
                        % Subject Influence Line to Truck Axle Stream
                        [MaxLE,SMaxLE,BrStInd,~,~] = GetMaxLE(AllTrAxSub,Inf,BaseData.RunDyn,1);
                        
                        % Allow for possible BrStInd < 0
                        if BrStInd < 0
                            AllTrAxSub(1:length(Inf.v),:) = 0;
                            continue
                        end
                        k = k+1;
                        
                        BrStIndx = BrStInd+Starti-1;
                        
                        % Possible that BrStInd wraps around (highly unlikely)
                        % Cross that bridge if we ever get there!
                        % Get Indices from strip length
                        StripInds = BrStIndx:BrStIndx+length(Inf.v)-1; StripInds = StripInds'; StripInds = StripInds(flip(Inf.v) == 1);
                        %StripIndsSub = BrStInd:BrStInd+length(Inf.v)-1; StripIndsSub = StripIndsSub'; StripIndsSub = StripIndsSub(flip(Inf.v) == 1);
                        TrNums = TrLineUp(TrLineUp(:,1) >= min(StripInds) & TrLineUp(:,1) <= max(StripInds),3);
                        TrNumsU = unique(TrNums);
                        
                        % Get key info to save
                        MaxLETime = PDCr.Time(TrNums(1));
                        Vehs = PDCr.CLASS(TrNumsU);
                        Spds = PDCr.SPEED(TrNumsU);
                        Lnes = PDCr.FS(TrNumsU);
                        L1Veh = Vehs(Lnes == 1);
                        L2Veh = Vehs(Lnes == 2);
                        L1Spd = Spds(Lnes == 1);
                        L2Spd = Spds(Lnes == 2);
                        % 99 is coded as empty (0 is taken by unclassified)
                        if isempty(L1Veh); L1Veh = 99; end
                        if isempty(L2Veh); L2Veh = 99; end
                        if length(L1Veh) > 1; L1Veh(2) = []; end
                        if length(L2Veh) > 1; L2Veh(2) = []; end
                        if isempty(L1Spd); L1Spd = -1; end
                        if isempty(L2Spd); L2Spd = -1; end
                        if length(L1Spd) > 1; L1Spd(2) = []; end
                        if length(L2Spd) > 1; L2Spd(2) = []; end
                        
                        % Get ClassT (in m form for now)
                        if min(Vehs) == 0
                            m = 1;
                        elseif sum(Vehs > 39 & Vehs < 50) > 0
                            m = 2;
                        else
                            m = 3;
                        end
                        
                        % Optional Apercu
                        if ApercuT
                            BaseData.ApercuTitle = [SName{r} ' ' num2str(Stations(w)) ' ' num2str(Year(i)) ' Max'];
                            T = Apercu(PDCr,BaseData.ApercuTitle,Inf.x,Inf.v(:,1),BrStIndx,TrLineUp,MaxLE/ESIA.Total(1),MaxLE/SMaxLE,Lane.Dir,BaseData.ILRes);
                        end
                        
                        % Troubleshooting
                        %disp([sum(AllTrAxSub(StripInds-(Starti-1),3)) MaxLE])
                        L1Load = sum(AllTrAxSub(StripInds-(Starti-1),1));
                        L2Load = sum(AllTrAxSub(StripInds-(Starti-1),2));
                        L1Ax = sum(AllTrAxSub(StripInds-(Starti-1),1)>0);
                        L2Ax = sum(AllTrAxSub(StripInds-(Starti-1),2)>0);
                        
                        % Save MaxEvents... add Lane 1 Veh Lane 2 Veh Num Ax ex speed?
                        % Save Times and Datenums and then convert
                        MaxEvents(j,:) = [datenum(MaxLETime), Stations(w), MaxLE, m, k, L1Veh, L2Veh, L1Load, L2Load, L1Ax, L2Ax, L1Spd, L2Spd];
                        j = j+1;
                        
                        % Prepare for next run
                        % Set Axles to zero in AllTrAx (can't delete because indices are locations)
                        AllTrAxSub(StripInds-(Starti-1),:) = 0;
                        
                    end
                end              
            end
        end
    end
end


% Convert back to datetime !!
% Delete empty rows and convert to table
MaxEvents(isnan(MaxEvents(:,1)),:) = [];
MaxEvents = array2table(MaxEvents,'VariableNames',{'Datenum', 'ZST', 'MaxLE', 'm', 'DayRank', 'L1Veh', 'L2Veh', 'L1Load', 'L2Load', 'L1Ax', 'L2Ax',  'L1Sp', 'L2Sp'});
MaxEvents.Time = datetime(MaxEvents.Datenum,'ConvertFrom','datenum');
MaxEvents.Datenum = [];

% Add in the description of MaxEvents that it is for 1.4 m (justified by previous memos)
MaxEvents.Properties.Description = '1.4 m strip length, 0.1 m ILRes';

% Add Column for All, Class, ClassOW and delete former m
MaxEvents.ClassT(MaxEvents.m == 1) = "All";
MaxEvents.ClassT(MaxEvents.m == 2) = "ClassOW";
MaxEvents.ClassT(MaxEvents.m == 3) = "Class";
MaxEvents.m = [];


