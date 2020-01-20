% ------------------------------------------------------------------------
%                              MATSim2019
% ------------------------------------------------------------------------
% Simulate traffic over a bridge to find maximum load effects
%       - To be used with MATSimInput spreadsheet
%       - Platooning only supported in Lane 1
%       - Whole number resolution supported (minimum 1m) (improve?)
%       - Improve output and directional support

% Initial commands
tic, clear, clc, close all, format long g, rng('shuffle'); st = now;

% Input File or Folder Name
InputF = 'Input/MATSimInputx.xlsx';  
%InputF = 'Input/PlatStud'; 
File_List = dir(InputF);

if File_List(1).isdir
    File_List(1:2) = [];  Folder_Name = InputF(6:end);
else
    Folder_Name = '';
end

for g = 1:length(File_List)

% Read simulation data from Input File
[BaseData,LaneData,TrData,FolDist] = ReadInputFile(['Input' Folder_Name '/' File_List(g).name]);

% Get key variables from imported data
[BatchSize,Num.Batches,FixVars,PlatPct,Num.Lanes,LaneTrDistr] = GetKeyVars(BaseData,TrData.TrDistr,LaneData);

% Get Influence Line Details
[InfLanes,InfNames,UniqInf,UniqInfs,UniqInfi,Num.InfCases,Infx,Infv,IntInfv,MaxInfv] = GetInfLines(LaneData,BaseData);

% Define truck type specific properties
[Num.TrTyp,TrDistCu,TrTyp] = GetTrPpties(TrData);

% Get Per Lane Rates include TRs and TransProbs
[LaneNumVeh, TrTrTransProb, CarCarTransProb, Surplus] = PerLaneRates(FolDist,BaseData,Num.TrTyp,FixVars.TrFront,TrData,TrTyp.NumAxPerGr,FixVars.CarFrAxRe,Num.Lanes,BatchSize,LaneTrDistr);

% Check for program warnings, initialize empty vars
MATSimWarnings(TrDistCu, BaseData.BunchFactor, BaseData.RunPlat); VirtualWIM = []; OverMax = []; ApercuOverMax = [];

% Initialize parpool if necessary and initialize progress bar
if BaseData.Parallel > 0, gcp; clc; end, m = StartProgBar(BaseData.NumSims, Num.Batches);

parfor (v = 1:BaseData.NumSims, BaseData.Parallel*100)
%for v = 1:BaseData.NumSims  
    
    AllLaneLineUp = cell(Num.Lanes,1); ApercuMax = [];
    % Initialize variables outside of batch simulation loop
    [MaxVec, Maxk, MaxDLF, MaxBrStInd, MaxFirstAxInd, MaxFirstAx] = deal(zeros(1,Num.InfCases));
            
    for k = 1:Num.Batches
        
        % ----- START OF RANDOM TRAFFIC GENERATION -----
          
        for q = 1:Num.Lanes
            
            if LaneTrDistr(q) ~= 0

                % 1) Get flow of Cars (0s) and Trucks (#s 1 to Num.TrTyp)
                [Flo.Veh, Flo.Trans] = GetFloVeh(LaneNumVeh,TrTrTransProb,CarCarTransProb,BaseData.BunchFactor,q,Num.TrTyp,TrDistCu);
                
                % 2) Get Truck / Axle Weights (kN) and Inter-Axle Distances (m)
                Flo.Wgt = GetFloWgt(Num.TrTyp,LaneNumVeh(q),Flo.Veh,TrData.TrDistr);
                
                % 2bis) Modify Flos for Platooning
                Flo = SwapforPlatoons(Flo,BaseData.RunPlat,q,Num.TrTyp,BaseData.PlatSize,PlatPct,TrData.TrDistr,BatchSize,Surplus,BaseData.TrRate,LaneTrDistr);
                
                % 3) Get Intervehicle Distances (mm) according to Simon Bailey NB: TC means Truck, followed by a Car (<<<Truck<<Car)
                Flo.Dist = GetFloDist(FolDist,FixVars,Flo.Trans,Flo.Plat,Flo.PPrime,Flo.PTrail,BaseData.PlatFolDist);
                
                % 4) Assemble Axle Loads and Axle Spacings vectors - populate Axle Weights (kN) and Inter-Axle Distances (m) within
                AllLaneLineUp{q} = GetAllLaneLineUp(Num.TrTyp,TrTyp,LaneData.Direction,q,Flo,FixVars.CarFrAxRe,k,v,BaseData,TrData);
                
            end
            
        end % END OF LANE SPECIFIC TRAFFIC GENERATION
        
        % Assemble lane specific data and sort by axle position
        TrLineUpMaster = AssembleLineUps(AllLaneLineUp,BaseData.RunPlat,BatchSize,Num.Lanes,LaneData,BaseData);
        
        % Log Virtual WIM if necessary. Virtual WIM takes only first axle row for each truck, is cummulative...
        if BaseData.VWIM == 1 || BaseData.Apercu == 1
            VirtualWIM = [VirtualWIM; TrLineUpMaster(TrLineUpMaster(:,5)>0,:)];
        end
        
        % ----- END OF RANDOM TRAFFIC GENERATION -----
        % ----- START OF LOAD EFFECT CALCULATION -----
        
        if BaseData.Analysis == 1
            [AllTrAx] = GetAllTrAx(TrLineUpMaster,BaseData.ILRes,Num.Lanes);
            for t = 1:Num.InfCases
                % 5) Subject Influence Line to Truck Axle Stream, lane specific influence line procedure included in GetMaxLE
                [MaxLE,DLF,BrStInd,AxonBr,FirstAxInd,FirstAx] = GetMaxLE(AllTrAx,Infv,InfLanes,LaneTrDistr,BaseData.RunDyn,t,UniqInfs,UniqInfi);
                % Update Maximums if they are exceeded
                if MaxLE > MaxVec(t)
                    [MaxVec(t),Maxk(t),MaxDLF(t),MaxBrStInd(t),MaxFirstAxInd(t),MaxFirstAx(t)] = UpMaxes(MaxLE,k,DLF,BrStInd,FirstAxInd,FirstAx);            
                    % Save results for Apercu
                    ApercuMax{t} = TrLineUpMaster(TrLineUpMaster(:,5)>0 & TrLineUpMaster(:,1)>(BrStInd - 10) & TrLineUpMaster(:,1)<(BrStInd + Infx(end) + 10),:);
                end
            end 
        end
        
        % ----- END OF LOAD EFFECT CALCULATION -----
        
        % Update progress bar
        UpProgBar(m, st, v, k, BaseData.NumSims, Num.Batches)
       
    end % END OF TRAFFIC BATCH

    % Log overall maximum cases into OverMax and 
    for i = 1:Num.InfCases
        OverMax = [OverMax; [i, v, MaxVec(i), Maxk(i), MaxDLF(i), MaxBrStInd(i), MaxFirstAxInd(i), MaxFirstAx(i)]];
        ApercuOverMax = [ApercuOverMax; [ApercuMax{i}, repmat(i,size(ApercuMax{i},1),1), repmat(v,size(ApercuMax{i},1),1)]]; 
    end
       
end % END OF SIMULATION

% Get simulation time
[Time] = GetSimTime();

% In the future could add InfCaseName
OverMAXT = array2table(OverMax,'VariableNames',{'InfCase','SimNum','MaxLE','BatchNum','MaxDLF','MaxBrStInd','MaxFirstAxInd','MaxFirstAx'});

% Reshape OverMax results for output
OverMax = sortrows(OverMax); OverMax = OverMax(:,3); OverMax = reshape(OverMax,BaseData.NumSims,Num.InfCases);

% Duplicate if only 1 Sim to avoid statistical errors
if BaseData.NumSims == 1
    OverMax = [OverMax; OverMax];
end

% Get ESIM and ESIA (from function)
ESIM = 1.1*prctile(OverMax,99);
ESIA = GetESia(IntInfv,MaxInfv,InfLanes,UniqInfs); Ratio = ESIM./ESIA; Ratio(Ratio > 10) = 0;

% Print Summary Stats to Command Window
PrintSummary(BaseData,BatchSize,PlatPct,TrData,Num,VirtualWIM,Time,LaneTrDistr)

% Create folders where there are none
CreateFolders(Folder_Name)

% Write results to a file (put into function)
if BaseData.Save == 1
    SaveSummary([Folder_Name '/' File_List(g).name],BaseData,BatchSize,PlatPct,TrData,VirtualWIM,Time,UniqInf,FolDist,LaneData,ESIM,OverMax,LaneTrDistr)
end

% Convert VirtualWIMs to tables and save if necessary
if BaseData.VWIM == 1
    PD = array2table(VirtualWIM,'VariableNames',{'AllAxSpCu','AllAxLoads','AllVehNum','AllLaneNum','AllVehBeg','AllVehPlat','AllVehPSwap','AllVehTyp','AllBatchNum','AllSimNum','ZST','JJJJMMTT','T','ST','HHMMSS','FZG_NR','FS','SPEED','LENTH','CS','CSF','GW_TOT','AX','AWT01','AWT02','AWT03','AWT04','AWT05','AWT06','AWT07','AWT08','AWT09','AWT10','W1_2','W2_3','W3_4','W4_5','W5_6','W6_7','W7_8','W8_9','W9_10'});
    save(['VirtualWIM' Folder_Name '/WIM_' datestr(now,'mmmdd HHMM')], 'PD')
end

% Covert Apercus to tables and save if necessary
if BaseData.Apercu == 1
    PD = array2table(ApercuOverMax,'VariableNames',{'AllAxSpCu','AllAxLoads','AllVehNum','AllLaneNum','AllVehBeg','AllVehPlat','AllVehPSwap','AllVehTyp','AllBatchNum','AllSimNum','ZST','JJJJMMTT','T','ST','HHMMSS','FZG_NR','FS','SPEED','LENTH','CS','CSF','GW_TOT','AX','AWT01','AWT02','AWT03','AWT04','AWT05','AWT06','AWT07','AWT08','AWT09','AWT10','W1_2','W2_3','W3_4','W4_5','W5_6','W6_7','W7_8','W8_9','W9_10','InfCase','SimNum'});
    save(['Apercu' Folder_Name '/AWIM_' datestr(now,'mmmdd HHMM')], 'PD')
end

end

% Thoughts... we can't post process the results of batches on our own. We
% need the help of matlab. We should save certain variables, so that we can
% load them again for quick generation of charts comparing analysis results
% together. Could re-read excel files back in if necessary.

% Each file generated should have its own unique name (date + time stamp)

% Simple Steps
% - Save OverMAXT in Apercu folder (OMT_Jan16 1815)
% - Save one other variable which is a Struct
%       - Name (Jan16 1815)
%       - Keyvars Traffic Loc
%       - Keyvars All BaseData Vars (14)
%       - Keyvars Results (mean)
%       - Keyvars Results (stdev)
%       - Keyvars Results (ESIA)
%       - Keyvars Results (ESIM)

% We can recreate this variable in post for the 3 completed analyses
% Then test out on a new one (logical next after Jan16 1912)

% Also rerun MC WIMs for Tessin Bridges to compare

% Next big step after doing what is above and below...
% Add in the ability to have big trucks have a different lane dist
% Then rerun and confirm AGB 2005/002

% We should also put the below into a function
if BaseData.Apercu == 1
    
    % Convert VirtualWIMOverMax to PD
    PD = array2table(ApercuOverMax,'VariableNames',{'AllAxSpCu','AllAxLoads','AllVehNum','AllLaneNum','AllVehBeg','AllVehPlat','AllVehPSwap','AllVehTyp','AllBatchNum','AllSimNum','ZST','JJJJMMTT','T','ST','HHMMSS','FZG_NR','FS','SPEED','LENTH','CS','CSF','GW_TOT','AX','AWT01','AWT02','AWT03','AWT04','AWT05','AWT06','AWT07','AWT08','AWT09','AWT10','W1_2','W2_3','W3_4','W4_5','W5_6','W6_7','W7_8','W8_9','W9_10','InfCase','SimNum'});
    % Take only results from governing simulation
    PD = PD(PD.SimNum == BaseData.NumSims,:); PD = PD(PD.SimNum == 160 & PD.InfCase == 1,:);
    OverMaxxx = []; % Initialize
    % Necessary for WIMtoAllTrAx
    PDC = Classify(PD); PDC = Daytype(PDC,2015);
    % Convert PDC to AllTrAx
    [PDC, AllTrAx, TrLineUp] = WIMtoAllTrAx(PDC,100);
    % Round TrLineUp first row, move unrounded to fifth row
    TrLineUp(:,5) = TrLineUp(:,1); TrLineUp(:,1) = round(TrLineUp(:,1));
    
    % Later adaprt for t = each infcase
    for t = 1
        % Subject Influence Line to Truck Axle Stream
        [MaxLEx,DLFx,BrStIndx,AxonBrx,FirstAxIndx,FirstAxx] = GetMaxLE(AllTrAx,Infv,InfLanes,[80 20],BaseData.RunDyn,t,UniqInfs,UniqInfi);
        % Record Maximums
        OverMaxxx = [OverMaxxx; [t, 2015, MaxLEx, DLFx, BrStIndx, FirstAxIndx, FirstAxx]];
    end
    
    % [Delete vehicles involved in maximum case, and re-analyze]
    
    % Convert Results to Table
    OverMAXTx = array2table(OverMaxxx,'VariableNames',{'InfCase','Year','MaxLE','MaxDLF','MaxBrStInd','MaxFirstAxInd','MaxFirstAx'});
    
    % Get ESIA from function
    ESIAx = GetESia(IntInfv,MaxInfv,InfLanes,UniqInfs);
    
    T = Apercu(PDC,'Trial',Infx,Infv(:,1),BrStIndx,TrLineUp,MaxLEx/ESIAx(1),DLFx);
    %T = Apercu(PDC,'Trial',Infx,Infv,BrStIndx,TrLineUp,MaxLEx/ESIAx,DLFx);
end
