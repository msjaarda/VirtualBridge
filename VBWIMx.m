% ------------------------------------------------------------------------
%                            MATSimWIM
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

% Input File Name
InputFile = 'Input/MATSimWIMInput.xlsx';                    
%InfDist = 1.4;
warning('off','MATLAB:mir_warning_maybe_uninitialized_temporary')

% Read Input File
[BaseData,LaneData,~,~] = ReadInputFile(InputFile);

% Initialize variables and start row counter
MaxEvents = nan(500000,14,height(BaseData));

% Start Progress Bar
if height(BaseData) > 10
    u = StartProgBar(height(BaseData), 1, 1, 1); tic; st = now;
end

%parfor g = 1:height(BaseData)
for g = 1:height(BaseData)
    
    MaxEvents1 = nan(500000,14);
     j = 1;
     
    % Obtain Influence Line Info
    [NLanes,Lane,LaneData,~,~] = UpdateData(BaseData(g,:),[],1,1);
    [Infl,NInfCases,Infl.x,Infl.v,ESIA] = GetInfLines(LaneData,BaseData(g,:),NLanes);
    
    % Modify IL according to area to be analyzed
    % DON"T MODIFY... USE INFCAsES
    %StN = floor((max(Infl.x)/BaseData.ILRes(g))/2);
    %Infl.v(:) = 0; Infl.v(StN:StN+InfDist/BaseData.ILRes(g)-1) = 1;
    
    % Load File
    PD = load(['PrunedS1 WIM/',BaseData.SName{g},'/',BaseData.SName{g},'_',num2str(BaseData.Year(g)),'.mat']);
    
    % Classify and add Datetime
    PDC = Classify(PD.PD); PDC = AddDatetime(PDC,1);
    
    % Further trimming if necessary
    if BaseData.S2Prune(g) == 1
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
        [PDCr, AllTrAx, TrLineUp] = WIMtoAllTrAx(PDCx,4,Lane.Dir,BaseData.ILRes(g));
        
        % Make groups out of each unique day
        PDCr.Group = findgroups(dateshift(PDCr.Time,'start','day'));
        
        % Round TrLineUp first row, move unrounded to fifth row
        TrLineUp(:,5) = TrLineUp(:,1); TrLineUp(:,1) = round(TrLineUp(:,1)/BaseData.ILRes(g));
        % Expand TrLineUp to include groups
        TrLineUp(:,6) = PDCr.Group(TrLineUp(:,3));
        
        % TrLineUp [       1             2         3        4         5               6       ]
        %            AllTrAxIndex    AxleValue   Truck#   LaneID  Station(m)   Group(UniqueDay)
        
        % Perform search for maximums for each day
        for z = 1:max(PDCr.Group)
            
           % clc
            % To track progress
            % Improve tracking now that we have parfor (borrow from VBSim)
           % fprintf('\nLocation: %s\n    Year: %i\n Station: %i\n     Day: %i\n\n',BaseData.SName{g},BaseData.Year(g),Stations(w),z)
            
            % Store starting and end indices
            Starti = max(1,min(TrLineUp(TrLineUp(:,6) == z,1))-1000);
            Endi = min(max(TrLineUp(TrLineUp(:,6) == z,1)+1000),length(AllTrAx));
            
            % Subdivide AllTrAx
            AllTrAxSub = AllTrAx(Starti:Endi,:);
            
            % Don't bother running if the segment is too small
            if length(AllTrAxSub) < 10000
                continue
            end
            
            for t = 1:NInfCases
                
                
            k = 0;
            % For each analysis
            while k < BaseData.NumAnalyses(g)
                
                % Subject Influence Line to Truck Axle Stream
                [MaxLE,SMaxLE,BrStInd,~,~] = GetMaxLE(AllTrAxSub,Infl,BaseData.RunDyn(g),t);
                
                % Allow for possible BrStInd < 0
                if BrStInd < 0
                    AllTrAxSub(1:length(Infl.v),:) = 0;
                    continue
                end
                k = k+1;
                
                BrStIndx = BrStInd+Starti-1;
                
                % Possible that BrStInd wraps around (highly unlikely)
                % Cross that bridge if we ever get there!
                % Get Indices from strip length
                PossibleWrap = length(Infl.v(~isnan(Infl.v)))+BrStInd - height(AllTrAxSub);
                if PossibleWrap < 0; PossibleWrap = 0; end
                
                StripInds = BrStIndx:BrStIndx+length(Infl.v(~isnan(Infl.v)))-1-PossibleWrap; StripInds = StripInds'; %StripInds = StripInds(flip(Infl.v(~isnan(Infl.v))) == 1);
          
                %StripIndsSub = BrStInd:BrStInd+length(Inf.v)-1; StripIndsSub = StripIndsSub'; StripIndsSub = StripIndsSub(flip(Inf.v) == 1);
                TrNums = TrLineUp(TrLineUp(:,1) >= min(StripInds) & TrLineUp(:,1) <= max(StripInds),3);
                TrNumsU = unique(TrNums);
                
                % Get key info to save
                MaxLETime = PDCr.Time(TrNums(1));
                Vehs = PDCr.CLASS(TrNumsU);
                Spds = PDCr.SPEED(TrNumsU);
                Lnes = PDCr.FS(TrNumsU);
                L1Veh = numel(Vehs(Lnes == 1));
                L2Veh = numel(Vehs(Lnes == 2));
                L1Spd = mean(Spds(Lnes == 1));
                L2Spd = mean(Spds(Lnes == 2));
                % 99 is coded as empty (0 is taken by unclassified)
                if isempty(L1Veh); L1Veh = 99; end
                if isempty(L2Veh); L2Veh = 99; end
%                 if length(L1Veh) > 1; L1Veh(2) = []; end
%                 if length(L2Veh) > 1; L2Veh(2) = []; end
                if isnan(L1Spd); L1Spd = -1; end
                 if isnan(L2Spd); L2Spd = -1; end
%                 if length(L1Spd) > 1; L1Spd(2) = []; end
%                 if length(L2Spd) > 1; L2Spd(2) = []; end
                
                
                % We don't need all this L1 and L2 (could be many more
                % vehs) BUT we instead report average speed per lane, num
                % vehs per lane, and total weight per lane...
                % Total weight or weight contribution to IL? The latter...
                
                % Get ClassT (in m form for now)
                if min(Vehs) == 0
                    m = 1;
                elseif sum(Vehs > 39 & Vehs < 50) > 0
                    m = 2;
                else
                    m = 3;
                end
                
                % Optional Apercu
                if BaseData.Apercu(g) == 1
                    ApercuTitle = [BaseData.SName{g} ' ' num2str(Stations(w)) ' ' num2str(BaseData.Year(g)) ' Max'];
                    T = Apercu(PDCr,ApercuTitle,Infl.x,Infl.v(:,1),BrStIndx,TrLineUp,MaxLE/ESIA.Total(1),MaxLE/SMaxLE,Lane.Dir,BaseData.ILRes(g));
                end
                
                % Troubleshooting
                %disp([sum(AllTrAxSub(StripInds-(Starti-1),3)) MaxLE])
                L1Load = sum(AllTrAxSub(StripInds-(Starti-1),1));
                L2Load = sum(AllTrAxSub(StripInds-(Starti-1),2));
                L1Ax = sum(AllTrAxSub(StripInds-(Starti-1),1)>0);
                L2Ax = sum(AllTrAxSub(StripInds-(Starti-1),2)>0);
                
                % Save MaxEvents... add Lane 1 Veh Lane 2 Veh Num Ax ex speed?
                % Save Times and Datenums and then convert
                 MaxEvents1(j,:) = [datenum(MaxLETime), Stations(w), MaxLE, t, m, k, L1Veh, L2Veh, L1Load, L2Load, L1Ax, L2Ax, L1Spd, L2Spd];
                 j = j+1;
                
                % Prepare for next run
                % Set Axles to zero in AllTrAx (can't delete because indices are locations)
                AllTrAxSub(StripInds-(Starti-1),:) = 0;
                
            end
            
            end
            
            
        end
    end
    MaxEvents(:,:,g) = MaxEvents1;
    
    if height(BaseData) > 10
        % Update progress bar
        UpProgBar(u, st, g, 1, height(BaseData), 1)
    end
end

% Trim back

MaxEvents = reshape(permute(MaxEvents,[1 3 2]),[],14);
%MaxEvents(all(all(isnan(MaxEvents),2),3),:,:) = [];

MaxEvents(isnan(MaxEvents(:,1)),:) = [];

% Convert back to datetime !!
% Delete empty rows and convert to table
MaxEvents = array2table(MaxEvents,'VariableNames',{'Datenum', 'ZST', 'MaxLE', 'InfCase', 'm', 'DayRank', 'L1Veh', 'L2Veh', 'L1Load', 'L2Load', 'L1Ax', 'L2Ax',  'L1Sp', 'L2Sp'});
MaxEvents.Time = datetime(MaxEvents.Datenum,'ConvertFrom','datenum');
MaxEvents.Datenum = [];

% Add in the description of MaxEvents that it is for 1.4 m (justified by previous memos)
%MaxEvents.Properties.Description = '1.4 m strip length, 0.1 m ILRes';

% Add Column for All, Class, ClassOW and delete former m
MaxEvents.ClassT(MaxEvents.m == 1) = "All";
MaxEvents.ClassT(MaxEvents.m == 2) = "ClassOW";
MaxEvents.ClassT(MaxEvents.m == 3) = "Class";
MaxEvents.m = [];

% Sort it! make sure it matches no 
