function [T, OverMx] = GetApercu(ApercuOverMax,OverMAXT,NumInfCases,Infx,Infv,InfLanes,LaneTrDistr,RunDyn,UniqInfs,UniqInfi,ESIA)
%GETAPERCU Visually display some of the more interesting results...
%   We will have to decide how (just peaks, etc).

% Dummy year
Year = 2020;
    
% Convert VirtualWIMOverMax to PD
PD = array2table(ApercuOverMax,'VariableNames',{'AllAxSpCu','AllAxLoads','AllVehNum','AllLaneNum','AllVehBeg','AllVehPlat','AllVehPSwap','AllVehTyp','AllBatchNum','AllSimNum','ZST','JJJJMMTT','T','ST','HHMMSS','FZG_NR','FS','SPEED','LENTH','CS','CSF','GW_TOT','AX','AWT01','AWT02','AWT03','AWT04','AWT05','AWT06','AWT07','AWT08','AWT09','AWT10','W1_2','W2_3','W3_4','W4_5','W5_6','W6_7','W7_8','W8_9','W9_10','InfCase','SimNum'});

OverMax = []; % Initialize

% Later adapt for t = each infcase
for t = 1:NumInfCases
    OverM = OverMAXT(OverMAXT.InfCase == t,:);
    [MaxLE, MaxInd] = max(OverM.MaxLE);
    MaxSimNum = MaxInd;
    % Take only results from governing simulation
    PDx = PD(PD.SimNum == MaxSimNum,:);
    % Take only results from current InfCase
    PDx = PDx(PDx.InfCase == t,:);
    % Necessary for WIMtoAllTrAx
    PDC = Classify(PDx); PDC = Daytype(PDC,Year);
    % Convert PDC to AllTrAx
    [PDC, AllTrAx, TrLineUp] = WIMtoAllTrAx(PDC,round(Infx(end)));
    % Round TrLineUp first row, move unrounded to fifth row
    TrLineUp(:,5) = TrLineUp(:,1); TrLineUp(:,1) = round(TrLineUp(:,1));
    

    OverM(MaxInd,:);
    
    % Subject Influence Line to Truck Axle Stream
    [MaxLEx,DLFx,BrStIndx,AxonBrx,FirstAxIndx,FirstAxx] = GetMaxLE(AllTrAx,Infv,InfLanes,LaneTrDistr,RunDyn,t,UniqInfs,UniqInfi);
    % Record Maximums
    OverMax = [OverMax; [t, Year, MaxLEx, DLFx, BrStIndx, FirstAxIndx, FirstAxx, MaxSimNum]];
    
    T = Apercu(PDC,'Trial',Infx,Infv(:,t),BrStIndx,TrLineUp,MaxLEx/ESIA(t),DLFx);
    
end

% [Delete vehicles involved in maximum case, and re-analyze]

% Convert Results to Table
OverMx = array2table(OverMax,'VariableNames',{'InfCase','Year','MaxLE','MaxDLF','MaxBrStInd','MaxFirstAxInd','MaxFirstAx','SimNum'});


end

