function [T, OverMx, AllTrAx] = GetApercu(PD,OverMaxT,NumInfCases,Inf,RunDyn,ESIA,LaneDir,ILRes)
%GETAPERCU Prepares results to be handed to WIMtoAllTrAx, then into Apercu

% Dummy year
Year = 2020;

% Initialize    
OverMax = []; 

% Create Apercu for each InfCase
for t = 1:NumInfCases
    OverM = OverMaxT(OverMaxT.InfCase == t,:);
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
    [MaxLEx,SMaxLEx,BrStIndx,AxonBrx,~] = GetMaxLE(AllTrAx,Inf,RunDyn,t);
    % Record Maximums
    OverMax = [OverMax; [t, Year, MaxLEx, BrStIndx, MaxSimNum]];
    
    % Take only the influence lines that apply to the current InfCase
    Infv = Inf.v(:,Inf.UniqInds == t);
    % Remove nans (added experimentally 12/02/2020.. fixed 05/03)
    FirstNan = find(isnan(Infv));
    if ~isempty(FirstNan)
        Infv = Infv(1:FirstNan-1,:);
        Infx = Inf.x(1:FirstNan-1,:);
    end
    
    T = Apercu(PDC,'Trial',Infx,Infv,BrStIndx,TrLineUp,MaxLEx/ESIA(t),MaxLEx/SMaxLEx,LaneDir,ILRes);
    %T = Apercu(PDC,'Trial',Infx,Infv(:,Inf.UniqInds == t),BrStIndx,TrLineUp,MaxLEx/ESIA(t),MaxLEx/SMaxLEx,LaneDir,ILRes);
    
    %T = Apercu(PDCx,BaseData.ApercuTitle,Infx,Infv,BrStInd,TrLineUp,MaxLE/ESIA.Total(InfCase(t)),MaxLEx/SMaxLEx,Lane.Dir,BaseData.ILRes);
            
end

% [Delete vehicles involved in maximum case, and re-analyze]

% Convert Results to Table
OverMx = array2table(OverMax,'VariableNames',{'InfCase','Year','MaxLE','MaxBrStInd','SimNum'});

% The max case... for troubleshooting
OverM(MaxSimNum,:);

end

