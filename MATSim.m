% ------------------------------------------------------------------------
%                              MATSim2019
% ------------------------------------------------------------------------
% Simulate traffic over a bridge to find maximum load effects
%       - To be used with MATSimInput spreadsheet or folder containing
%       - Platooning only supported in Lane 1
%       - Whole number resolution supported (minimum 1m)

clear, clc, close all, format long g, rng('shuffle'); % Initial commands

% Input File or Folder Name 
InputF = 'MATSimInputFigure4p3rNEW.xlsx'; Folder_Name = '/AGB';

% Read in simulation data
[BaseData,LaneData,TrData,FolDist] = ReadInputFile(['Input/' InputF]);

% We now have complex input (each excel tab), and simple input (just Base
% and Lane). Complex will just be for 1-offs (not batch), although simple
% can also be used for 1-offs. This maintains backwards compatibility.

% We can think about implementing same for LaneData... more complicated.

% Next step is to implement transverse and run it for platooning case
% (shouldn't be hard... no change of code required, just factors
% applied to ILs)

% Finally, we can replicate AGB charts, both for Box beams and bi-poutres,
% now that we will have transverse working.

% Next step to try deterministic vehicles?

for g = 1:height(BaseData)

% if ismember('LaneTrDistr', BaseData.Properties.VariableNames)
%     LaneTrDistr =  cellfun(@str2num,split(BaseData.LaneTrDistr{g},','));
%     Direction =  cellfun(@str2num,split(BaseData.Direction{g},','));
%     Num.Lanes = length(LaneTrDistr);
% end

if ismember('Traffic', BaseData.Properties.VariableNames)
    load('TrLib.mat')
    TrData = TrLib.(BaseData.Traffic{g});
end

% Get key variables from imported data
[BatchSize,Num.Batches,FixVars,PlatPct,Num.Lanes,LaneTrDistr] = GetKeyVars(BaseData(g,:),TrData.TrDistr,LaneData);

% Get Influence Line Details
[InfLanes,InfNames,UniqInf,UniqInfs,UniqInfi,Num.InfCases,Infx,Infv,ESIA] = GetInfLines(LaneData,BaseData(g,:));

% % Intervention
% load('InfLib.mat')
% %Infx = InfLib.x;
% %Infv = InfLib.c80_60_80mn;
% Infx = InfLib.x(1:21);
% Infv = InfLib{1:21,2:3};
% InfNames{1} = 'Mp';
% InfNames{2} = 'V';

% Define truck type specific properties
[Num.TrTyp,TrDistCu,TrTyp] = GetTrPpties(TrData);

% Get Per Lane Rates include TRs and TransProbs
[LaneNumVeh, TrTrTransProb, CarCarTransProb, Surplus] = PerLaneRates(FolDist,BaseData(g,:),Num.TrTyp,FixVars.TrFront,TrData,TrTyp.NumAxPerGr,FixVars.CarFrAxRe,Num.Lanes,BatchSize,LaneTrDistr);

% Check for program warnings, initialize empty vars
MATSimWarnings(TrDistCu, BaseData.BunchFactor(g), BaseData.RunPlat(g), TrTrTransProb); VirtualWIM = []; OverMax = []; ApercuOverMax = [];

% Initialize parpool if necessary and initialize progress bar
if BaseData.Parallel(g) > 0, gcp; clc; end, m = StartProgBar(BaseData.NumSims(g), Num.Batches, g, height(BaseData)); tic; st = now;

parfor (v = 1:BaseData.NumSims(g), BaseData.Parallel(g)*100)
%for v = 1:BaseData.NumSims(g)  
    
    AllLaneLineUp = cell(Num.Lanes,1); ApercuMax = [];
    % Initialize variables outside of batch simulation loop
    [MaxVec, Maxk, MaxDLF, MaxBrStInd, MaxFirstAxInd, MaxFirstAx] = deal(zeros(1,Num.InfCases));
            
    for k = 1:Num.Batches
        
        % ----- START OF RANDOM TRAFFIC GENERATION -----
          
        for q = 1:Num.Lanes
            
            if LaneTrDistr(q) ~= 0

                % 1) Get flow of Cars (0s) and Trucks (#s 1 to Num.TrTyp)
                [Flo.Veh, Flo.Trans] = GetFloVeh(LaneNumVeh,TrTrTransProb,CarCarTransProb,BaseData.BunchFactor(g),q,Num.TrTyp,TrDistCu);
                
                % 2) Get Truck / Axle Weights (kN) and Inter-Axle Distances (m)
                Flo.Wgt = GetFloWgt(Num.TrTyp,LaneNumVeh(q),Flo.Veh,TrData.TrDistr);
                
                % 2bis) Modify Flos for Platooning
                Flo = SwapforPlatoons(Flo,BaseData.RunPlat(g),q,Num.TrTyp,BaseData.PlatSize(g),PlatPct,TrData.TrDistr,BatchSize,Surplus,BaseData.TrRate(g),LaneTrDistr);
                
                % 3) Get Intervehicle Distances (mm) according to Simon Bailey NB: TC means Truck, followed by a Car (<<<Truck<<Car)
                Flo.Dist = GetFloDist(FolDist,FixVars,Flo.Trans,Flo.Plat,Flo.PPrime,Flo.PTrail,BaseData.PlatFolDist(g));
                
                % 4) Assemble Axle Loads and Axle Spacings vectors - populate Axle Weights (kN) and Inter-Axle Distances (m) within
                AllLaneLineUp{q} = GetAllLaneLineUp(Num.TrTyp,TrTyp,LaneData.Direction,q,Flo,FixVars.CarFrAxRe,k,v,BaseData(g,:),TrData);
                
            end
            
        end % END OF LANE SPECIFIC TRAFFIC GENERATION
        
        % Assemble lane specific data and sort by axle position
        TrLineUpMaster = AssembleLineUps(AllLaneLineUp,BatchSize,Num.Lanes,LaneData,BaseData(g,:));
        
        % Log Virtual WIM if necessary. Virtual WIM takes only first axle row for each truck, is cummulative...
        if BaseData.VWIM(g) == 1 || BaseData.Apercu(g) == 1
            VirtualWIM = [VirtualWIM; TrLineUpMaster(TrLineUpMaster(:,5)>0,:)];
        end
        
        % ----- END OF RANDOM TRAFFIC GENERATION -----
        % ----- START OF LOAD EFFECT CALCULATION -----
        
        if BaseData.Analysis(g) == 1
            [AllTrAx] = GetAllTrAx(TrLineUpMaster,BaseData.ILRes(g),Num.Lanes);
            for t = 1:Num.InfCases
                % 5) Subject Influence Line to Truck Axle Stream, lane specific influence line procedure included in GetMaxLE
                [MaxLE,DLF,BrStInd,AxonBr,FirstAxInd,FirstAx] = GetMaxLE(AllTrAx,Infv,InfLanes,LaneTrDistr,BaseData.RunDyn(g),t,UniqInfs,UniqInfi);
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
        UpProgBar(m, st, v, k, BaseData.NumSims(g), Num.Batches)
       
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
OverMax = sortrows(OverMax); OverMax = OverMax(:,3); OverMax = reshape(OverMax,BaseData.NumSims(g),Num.InfCases);

% Duplicate if only 1 Sim to avoid statistical errors
if BaseData.NumSims(g) == 1
    OverMax = [OverMax; OverMax];
end

% Get ESIM and Ratio
ESIM = 1.1*prctile(OverMax,99); Ratio = ESIM./ESIA;

% Print Summary Stats to Command Window
PrintSummary(BaseData(g,:),BatchSize,PlatPct,TrData,Num,VirtualWIM,Time,LaneTrDistr)

% Create folders where there are none
CreateFolders(Folder_Name)

TName = datestr(now,'mmmdd-yy HHMM');

% Write results to a file (put into function)
if BaseData.Save(g) == 1
    %SaveSummary(strcat('Output', Folder_Name, '/MSOut', File_List(g).name(12:end-5),'_',TName, '.xlsx'),BaseData(g,:),BatchSize,PlatPct,TrData,VirtualWIM,Time,UniqInf,FolDist,LaneData,ESIM,OverMax,LaneTrDistr);
    SaveSummary(TName,strcat('Output', Folder_Name, '/MATSimOutput', InputF(12:end-5),'.xlsx'),TrData,BaseData(g,:),Time,UniqInf,FolDist,LaneData,ESIM,ESIA,Ratio,OverMax);
end

% Convert VirtualWIMs to tables and save if necessary
if BaseData.VWIM(g) == 1
    PD = array2table(VirtualWIM,'VariableNames',{'AllAxSpCu','AllAxLoads','AllVehNum','AllLaneNum','AllVehBeg','AllVehPlat','AllVehPSwap','AllVehTyp','AllBatchNum','AllSimNum','ZST','JJJJMMTT','T','ST','HHMMSS','FZG_NR','FS','SPEED','LENTH','CS','CSF','GW_TOT','AX','AWT01','AWT02','AWT03','AWT04','AWT05','AWT06','AWT07','AWT08','AWT09','AWT10','W1_2','W2_3','W3_4','W4_5','W5_6','W6_7','W7_8','W8_9','W9_10'});
    save(['VirtualWIM' Folder_Name '/WIM_' TName], 'PD')
end

% Covert Apercus to tables and save if necessary
if BaseData.Apercu(g) == 1
    PD = array2table(ApercuOverMax,'VariableNames',{'AllAxSpCu','AllAxLoads','AllVehNum','AllLaneNum','AllVehBeg','AllVehPlat','AllVehPSwap','AllVehTyp','AllBatchNum','AllSimNum','ZST','JJJJMMTT','T','ST','HHMMSS','FZG_NR','FS','SPEED','LENTH','CS','CSF','GW_TOT','AX','AWT01','AWT02','AWT03','AWT04','AWT05','AWT06','AWT07','AWT08','AWT09','AWT10','W1_2','W2_3','W3_4','W4_5','W5_6','W6_7','W7_8','W8_9','W9_10','InfCase','SimNum'});
    save(['Apercu' Folder_Name '/AWIM_' TName], 'PD')
end

% Save structure variable with essential simulation information
OutInfo.Name = TName;
OutInfo.BaseData = BaseData(g,:);
OutInfo.ESIA = ESIA;
OutInfo.ESIM = ESIM;
OutInfo.Mean = mean(OverMax);
OutInfo.Std = std(OverMax);
OutInfo.OverMax = OverMax;
OutInfo.OverMAXT = OverMAXT;
OutInfo.InfNames = InfNames;
OutInfo.PlatPct = max(PlatPct);
OutInfo.LaneData = LaneData;

save(['Output' Folder_Name '/' OutInfo.Name], 'OutInfo')

end

% Run Apercu to see critical case
if BaseData.Apercu(g) == 1
    [T, OverMx] = GetApercu(ApercuOverMax,OverMAXT,Num.InfCases,Infx,Infv,InfLanes,LaneTrDistr,BaseData.RunDyn(g),UniqInfs,UniqInfi,ESIA);
end



