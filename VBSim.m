% ------------------------------------------------------------------------
%                              VBSim
% ------------------------------------------------------------------------
% Simulate traffic over a bridge to find maximum load effects

% Initializing commands
clear, clc, close all, format long g, rng('shuffle');

% Input File
InputFile = 'VBSimInputPDx.xlsx';

% Read in simulation data
BaseData = VBReadInputFile(['Input/' InputFile]);

% Each row of BaseData represents one analysis
for g = 1:height(BaseData)

    % Update analysis data for current row of BaseData
    [Num,Lane,ILData,TrData,FolDist,ESIA] = VBUpdateData(BaseData(g,:));
    
    % Get key variables from imported data
    [BatchSize,Num.Batches,FixVars] = VBGetKeyVars(BaseData(g,:),TrData.TrDistr);
      
    % Define truck type specific properties
    [Num.TrTyp,TrTyp,VWIMCols] = VBGetTrPpties(TrData,FixVars);
    
    % Get Per Lane Rates including TRs and TransProbs
    [Lane, TransPrTaT, TransPrCaC] = VBPerLaneRates(FolDist,BaseData(g,:),Num,FixVars,TrData,TrTyp,BatchSize,Lane);
    
    % Initialize empty vars
    [VirtualWIM, OverMax, ApercuOverMax] = deal([]);
    
    % Initialize parpool if necessary and initialize progress bar
    if BaseData.Parallel(g) > 0, gcp; clc; end, 
    m = StartProgBar(BaseData.NumSims(g), Num.Batches, g, height(BaseData)); tic; st = now;
    
    %parfor (v = 1:BaseData.NumSims(g), BaseData.Parallel(g)*100)
    for v = 1:BaseData.NumSims(g)
        
        % Initialize variables outside of batch simulation loop
        LaneAxLineUp = cell(Num.Lanes,1); LaneVehLineUp = cell(Num.Lanes,1); ApercuMax = [];
        [SimMaxLE, SimDLF, Simk, SimBrStInd, SimDamage] = deal(zeros(1,Num.InfCases));
        
        for k = 1:Num.Batches
            
            % ----- START OF RANDOM TRAFFIC GENERATION -----
            
            for q = 1:Num.Lanes
                
                if Lane.TrDistr(q) ~= 0 || FixVars.CarWgt > 0
                    
                    % Flo.Veh/Trans | Get Flow of Cars (0s) and Trucks (#s 1 to Num.TrTyp)
                    Flo = GetFloVeh(Lane.NumVeh,TransPrTaT,TransPrCaC,BaseData.BunchFactor(g),q,Lane.DistCu(:,q));
                    
                    % Flo.Wgt | Get Truck / Axle Weights (kN)
                    Flo = GetFloWgt(Num.TrTyp,Lane.NumVeh(q),Flo,TrData.TrDistr);
                    
                    % Flo.Dist | Get Intervehicle Distances (m) TaC is the Truck after a (<<<car<<TRUCK)
                    Flo = VBGetFloDist(FolDist,FixVars,Flo);
                    
                    % Assemble Axle Loads and Axle Spacings vectors - populate Axle Weights (kN) and Inter-Axle Distances (m) within
                    [Flo, LaneAxLineUp{q}, LaneVehLineUp{q}] = VBGetLaneLineUp(TrTyp,Lane.Dir,q,Flo,FixVars,k,v,BaseData(g,:),TrData);
                    
                end
                
            end % END OF LANE SPECIFIC TRAFFIC GENERATION
            
            % Assemble lane specific data, flip for direction, sort by axle position
            [AxLineUp, VehLineUp] = VBAssembleLineUps(LaneAxLineUp,LaneVehLineUp,BatchSize,Num.Lanes,BaseData(g,:),Lane.Dir,FixVars);
            
            % Log Virtual WIM if necessary
            if BaseData.VWIM(g) == 1
                VirtualWIM = [VirtualWIM; VehLineUp];
            end
            
            % ----- END OF RANDOM TRAFFIC GENERATION -----
            % ----- START OF LOAD EFFECT CALCULATION -----
            
            if BaseData.Analysis(g) == 1
                AllTrAx = VBGetAllTrAx(AxLineUp,BaseData.ILRes(g),Lane,FixVars);
                for t = 1:Num.InfCases
                    
                    % Subject Influence Line to Axle Stream                    
                    [MaxLE,DLF,BrStInd,R] = VBGetMaxLE(AllTrAx,ILData.v{t},BaseData.RunDyn(g));
                    
                    % Fatigue, Calculate Fatigue Damage using Rainflow
                    if BaseData.RunFat(g) == 1
                        SimDamage(t) = VBGetFatigueDamage(R,BaseData.FatScale(g),BaseData.FatCat(g),SimDamage(t));
                    end
                    
                    % Update Simulation Maximums if they are exceeded (and record batch  #)
                    if MaxLE > SimMaxLE(t)
                        [SimMaxLE(t),SimDLF(t),Simk(t),SimBrStInd(t)] = VBUpMaxes(MaxLE,DLF,k,BrStInd);
                        % Save results for Apercu
                        if BaseData.Apercu(g) == 1
                            % We do +- 20 to make sure we get them all
                            ApercuMax{t} = VehLineUp(VehLineUp(:,1)>(BrStInd*BaseData.ILRes(g) - 20) & VehLineUp(:,1)<((BrStInd + length(ILData.v{t}))*BaseData.ILRes(g) + 20),:);
                        end
                    end
                end
            end
            
            % ----- END OF LOAD EFFECT CALCULATION -----
            
            % Update progress bar
            UpProgBar(m, st, v, k, BaseData.NumSims(g), Num.Batches)
            
        end % END OF TRAFFIC BATCH
        
        % Log overall maximum cases into OverMax and ApercuOverMax if necessary
        for i = 1:Num.InfCases
            OverMax = [OverMax; [i, v, Simk(i), SimMaxLE(i), SimDLF(i), SimBrStInd(i), SimDamage(t)]];
            % Save VWIM to ApercuOverMax, and add column for InfCase
            if BaseData.Apercu(g) == 1
                ApercuOverMax = [ApercuOverMax; [ApercuMax{i}, repmat(i,size(ApercuMax{i},1),1)]];
            end
        end
        
    end % END OF SIMULATION
    
    % Get simulation time
    Time = GetSimTime();
    
    % In the future could add InfCaseName
    OverMaxT = array2table(OverMax,'VariableNames',{'InfCase','SimNum','BatchNum','MaxLE','DLF','BrStInd','MaxDamage'});
    
    % Reshape OverMax results for output
    OverMax = sortrows(OverMax); OverMax = OverMax(:,4);
    OverMax = reshape(OverMax,BaseData.NumSims(g),Num.InfCases);
    
    % Duplicate if only 1 Sim to avoid statistical errors
    if BaseData.NumSims(g) == 1
        OverMax = [OverMax; OverMax];
    end
    
    % Get ESIM and Ratio
    ESIM = 1.1*prctile(OverMax,99); Ratio = ESIM./ESIA.Total;
    
    % Print Summary Stats to Command Window
    VBPrintSummary(BaseData(g,:),BatchSize,TrData,Num,VirtualWIM,Time,Lane.TrDistr)
    
    % Create folders where there are none
    CreateFolders(BaseData.Folder{g},BaseData.VWIM(g),BaseData.Apercu(g),BaseData.Save(g))
    
    TName = datestr(now,'mmmdd-yy HHMMSS');
    
    % Convert VirtualWIM to Table and save if necessary
    if BaseData.VWIM(g) == 1
        PD = array2table(VirtualWIM,'VariableNames',VWIMCols);
        save(['VirtualWIM' BaseData.Folder{g} '/WIM_' TName], 'PD')
    end
    
    % Covert Apercu to Table and save if necessary
    if BaseData.Apercu(g) == 1
        PD = array2table(ApercuOverMax,'VariableNames',[VWIMCols 'InfCase']);
        save(['Apercu' BaseData.Folder{g} '/AWIM_' TName], 'PD')
    end
    
    % Save structure variable with essential simulation information
    OutInfo.Name = TName; OutInfo.BaseData = BaseData(g,:);
    OutInfo.ESIA = ESIA; OutInfo.ESIM = ESIM;
    OutInfo.OverMax = OverMax; OutInfo.OverMaxT = OverMaxT;
    OutInfo.ILData = ILData;
    
    if BaseData.Save(g) == 1
        save(['Output' BaseData.Folder{g} '/' OutInfo.Name], 'OutInfo')
    end
    
end

% Run Apercu to see critical case... does all IL given for the last row of BaseData
if BaseData.Apercu(g) == 1
    [T, OverMx, AllTrAxx] = VBGetApercu(PD,OverMaxT,Num.InfCases,ILData,BaseData.RunDyn(g),ESIA.Total,Lane.Dir,BaseData.ILRes(g));
end

