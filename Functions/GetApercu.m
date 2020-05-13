function [T, OverMx, AllTrAx] = GetApercu(PD,OverMAXT,NumInfCases,Inf,RunDyn,ESIA,LaneDir,ILRes)
%GETAPERCU Prepares results to be handed to WIMtoAllTrAx, then into Apercu

% Dummy year
Year = 2020;

% Initialize    
OverMax = []; 

% Create Apercu for each InfCase
for t = 1:NumInfCases
    OverM = OverMAXT(OverMAXT.InfCase == t,:);
    [MaxLE, MaxSimNum] = max(OverM.MaxLE);
    % Take only vehicles involved in governing simulation, from current InfCase
    PDx = PD(PD.SimNum == MaxSimNum & PD.InfCase == t,:);
    % Necessary for WIMtoAllTrAx
    PDC = Classify(PDx); 
    if ismember('JJJJMMTT',PDC.Properties.VariableNames)
        PDC = Daytype(PDC,Year);
    end
    % Convert PDC to AllTrAx
    % I don't think this accounts for direction!!
    [PDC, AllTrAx, TrLineUp] = WIMtoAllTrAx(PDC,round(Inf.x(end)),LaneDir,ILRes);
    % Round TrLineUp first row, move unrounded to fifth row
    TrLineUp(:,5) = TrLineUp(:,1); TrLineUp(:,1) = round(TrLineUp(:,1)/ILRes);
    
    % Subject Influence Line to Truck Axle Stream
    [MaxLEx,MaxLEStaticx,DLFx,BrStIndx,AxonBrx,FirstAxIndx,FirstAxx] = GetMaxLE(AllTrAx,Inf,RunDyn,t);
    % Record Maximums
    OverMax = [OverMax; [t, Year, MaxLEx, DLFx, BrStIndx, FirstAxIndx, FirstAxx, MaxSimNum]];
    
    T = Apercu(PDC,'Trial',Inf.x,Inf.v(:,Inf.UniqInds == t),BrStIndx,TrLineUp,MaxLEx/ESIA(t),DLFx,LaneDir,ILRes);

end

% [Delete vehicles involved in maximum case, and re-analyze]

% Convert Results to Table
OverMx = array2table(OverMax,'VariableNames',{'InfCase','Year','MaxLE','MaxDLF','MaxBrStInd','MaxFirstAxInd','MaxFirstAx','SimNum'});

% The max case... for troubleshooting
OverM(MaxSimNum,:);

end

