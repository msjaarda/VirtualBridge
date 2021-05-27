function [T, OverMx, AllTrAx] = VBGetApercu(PD,OverMaxT,NumInfCases,ILData,RunDyn,ESIA,LaneDir,ILRes)
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
    % Convert PDC to AllTrAx (no SpaceSaver necessary)
    [PDC, AllTrAx, TrLineUp] = VBWIMtoAllTrAx(PDC,0,LaneDir,ILRes);
    % Round TrLineUp first row, move unrounded to fifth row
    TrLineUp(:,5) = TrLineUp(:,1); TrLineUp(:,1) = round(TrLineUp(:,1)/ILRes);
    
    % Subject Influence Line to Truck Axle Stream
    [MaxLEx,DLFx,BrStIndx,~] = VBGetMaxLE(AllTrAx,ILData.v{t},RunDyn);
    % Record Maximums
    OverMax = [OverMax; [t, MaxLEx, BrStIndx, MaxSimNum]];
    
    T = VBApercu(PDC,'',ILData,t,BrStIndx,TrLineUp,MaxLEx/ESIA(t),DLFx,LaneDir,ILRes);
            
end

% Convert Results to Table
OverMx = array2table(OverMax,'VariableNames',{'InfCase','MaxLE','BrStInd','SimNum'});

end

