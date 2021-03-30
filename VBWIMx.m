% ------------------------------------------------------------------------
%                            VBWIM
% ------------------------------------------------------------------------
% Generate a summary of maximum effects on bridges from real WIM
% This has a sister live script which loads the var and perform analyses.
% VBWIM         >> q Investigation

 % Initial commands
clear, clc, format long g, rng('shuffle'), close all;
warning('off','MATLAB:mir_warning_maybe_uninitialized_temporary')

% Notes
% - Add new stations to existing variables manually (load together and cat)
% - Make sure ClassOW is set to true inside Classify.m and no 11bis

% Input File Name
InputFile = 'Input/MATSimWIMInput.xlsx';

% Read Input File
[BaseData,LaneData,~,~] = ReadInputFile(InputFile);

% Initialize variables and start row counter
MaxEvents = nan(400000,14,height(BaseData));

% Start Progress Bar
if height(BaseData) > 10
    u = StartProgBar(height(BaseData), 1, 1, 1); tic; st = now;
end

parfor g = 1:height(BaseData)
%for g = 1:height(BaseData)
    
    MaxEvents1 = nan(400000,14);
    j = 1;
     
    % Obtain Influence Line Info
    [NLanes,Lane,LaneData,~,~] = UpdateData(BaseData(g,:),[],1,1);
    [Infl,NInfCases,Infl.x,Infl.v,ESIA] = GetInfLines(LaneData,BaseData(g,:),NLanes);
    
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
            
            if height(BaseData) < 10
                clc
                fprintf('\nLocation: %s\n    Year: %i\n Station: %i\n     Day: %i\n\n',BaseData.SName{g},BaseData.Year(g),Stations(w),z)
            end
            
            % Store starting and end indices
            Starti = max(1,min(TrLineUp(TrLineUp(:,6) == z,1))-1000);
            Endi = min(max(TrLineUp(TrLineUp(:,6) == z,1)+1000),length(AllTrAx));
            
            % Subdivide AllTrAx
            AllTrAxSub = AllTrAx(Starti:Endi,:);
            
            % Don't bother running if the segment is too small
            if length(AllTrAxSub) < 10000 | sum(AllTrAxSub,'all') == 0
                continue
            end
            
            % For each influence case
            for t = 1:NInfCases
                
                k = 0;
                % For each analysis
                while k < BaseData.NumAnalyses(g) & sum(AllTrAxSub,'all') > 0
                    
                    % Subject Influence Line to Truck Axle Stream
                    [MaxLE,SMaxLE,BrStIndSub,AxonBr,~] = GetMaxLE(AllTrAxSub,Infl,BaseData.RunDyn(g),t);
                    
                    % Get length of bridge in number of indices
                    BrLengthInds = length(Infl.v(~isnan(Infl.v(:,t)),t));
                    
                    % Wrapping issues - check if BrStIndSub is less than or
                    % equal to zero OR BrStIndSub + BrLengthInds - 1
                    % exceeds the size of AllTrAxSub
                    % Not necessarily a problem, for example if BrStInd
                    % still works with the parents AllTrAx
                    % Right now we opt to ignore the edge cases... see note
                    % in GetMaxLE (CAPS). Must solve later on...
                    if BrStIndSub < 1
                        AllTrAxSub(1:BrStIndSub + BrLengthInds - 1,:) = 0;
                        continue
                    elseif BrStIndSub + BrLengthInds - 1 > height(AllTrAxSub)
                        AllTrAxSub(BrStIndSub:end,:) = 0;
                        continue
                    end
                    
                    % Adjust BrStInd for AllTrAx instead of sub
                    BrStInd = BrStIndSub+Starti-1;
                    
                    % CHECKS
                    % This should be equal
                    isequal(AllTrAxSub(BrStIndSub:BrStIndSub + BrLengthInds - 1)',AxonBr);
                    % As should this
                    isequal(AllTrAx(BrStInd:BrStInd + BrLengthInds -1)',AxonBr);
                    % This should equal when no DLF
                    % See if this is only the case with symmetrical ILs...
                    % Shouldn't really work without flipping otherwise! YUP
                    sum(AxonBr .* flip(Infl.v(~isnan(Infl.v(:,t)),t)));
                    
                    % Allow for possible BrStInd < 0
%                     if BrStIndSub <= 0
%                         AllTrAxSub(1:length(Infl.v),:) = 0;
%                         continue
%                     end
                    
                    k = k+1;
% 
%                     % Possible that BrStInd wraps around
%                     % Cross that bridge if we ever get there!
%                     % Get Indices from strip length
%                     PossibleWrap = length(Infl.v(~isnan(Infl.v))) + BrStIndSub - height(AllTrAxSub);
%                     if PossibleWrap < 0
%                         PossibleWrap = 0;
%                     end
                    
                    StripInds = BrStInd:BrStInd + BrLengthInds -1; StripInds = StripInds';
                    
                    
                    
                    % Get Truck Numbers and unique ones)
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
                    if isnan(L1Spd); L1Spd = -1; end
                    if isnan(L2Spd); L2Spd = -1; end
                    
                    % Get ClassT (in m form for now, convert later)
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
                        T = Apercu(PDCr,ApercuTitle,Infl.x,Infl.v(:,1),BrStInd,TrLineUp,MaxLE/ESIA.Total(1),MaxLE/SMaxLE,Lane.Dir,BaseData.ILRes(g));
                    end
                    
                    % Troubleshooting
                    L1Load = sum(AllTrAxSub(StripInds-(Starti-1),1));
                    L2Load = sum(AllTrAxSub(StripInds-(Starti-1),2));
                    L1Ax = sum(AllTrAxSub(StripInds-(Starti-1),1)>0);
                    L2Ax = sum(AllTrAxSub(StripInds-(Starti-1),2)>0);
                    
                    % Save MaxEvents... save times as Datenums and then convert
                    MaxEvents1(j,:) = [datenum(MaxLETime), Stations(w), MaxLE, t, m, k, L1Veh, L2Veh, L1Load, L2Load, L1Ax, L2Ax, L1Spd, L2Spd];
                    j = j+1;
                    
                    % Prepare for next run
                    % Set Axles to zero in AllTrAx (can't delete because indices are locations)
                    AllTrAxSub(StripInds-(Starti-1),:) = 0;
                    
                end
            end
        end
    end
    
    % Place results inside larger result
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
