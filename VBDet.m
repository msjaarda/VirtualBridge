% ------------------------------------------------------------------------
%                            VBDet
% ------------------------------------------------------------------------
% Run deterministic vehicles over a bridge to find maximum load effects

% Initial commands
clear, clc, format long g, rng('shuffle'), close all; BaseData = table;

% Input Information --------------------

% Roadway Info
BaseData.LaneDir = {'1,2'};
% Influence Line Info
BaseData.ILs = {'AGBBox.Mp.S30'};  BaseData.ILRes = 0.1;
% Analysis Info
BaseData.RunDyn = 0; % 1.3 added manually
% Analysis Type
BaseData.AnalysisType = "Det";

BaseData.Save = 0;
BaseData.Folder = '/AGBDet';

FName = 'VB60t.mat'; % 'Det60t.mat'
load(FName)

BaseData.ApercuTitle = sprintf('%s','Deterministic Analysis');

% Input Complete   ---------------------

% Obtain Influence Line Info
[Num,Lane,ILData,~,~,ESIA] = VBUpdateData(BaseData);

% Initialize
OverMax = [];

InAxs = contains(PDC.Properties.VariableNames, 'AWT');

% Apply Factors according to AGB 2002/005 (1.1 and 1.5)
PDC{PDC.GW_TOT == 60000,InAxs} = 1.1*PDC{PDC.GW_TOT == 60000,InAxs};
PDC{PDC.GW_TOT == 40000,InAxs} = 1.5*PDC{PDC.GW_TOT == 40000,InAxs};
PDCx = PDC;

% Convert PDC to AllTrAx
[PDCx, AllTrAx, TrLineUp] = VBWIMtoAllTrAx(PDCx,0,Lane.Dir,BaseData.ILRes);

% Round TrLineUp first row, move unrounded to fifth row
TrLineUp(:,5) = TrLineUp(:,1); TrLineUp(:,1) = round(TrLineUp(:,1)/BaseData.ILRes);

for t = 1:Num.InfCases

    % Subject Influence Line to Truck Axle Stream
    [MaxLE,DLF,BrStInd,R] = VBGetMaxLE(AllTrAx,ILData.v{t},BaseData.RunDyn);
    % Record Maximums
    % Add AGB 1.3 DLF
    OverMax = [OverMax; [t, 1.3*MaxLE, 1.3, BrStInd]];

end

% Display Apercu
T = VBApercu(PDCx,BaseData.ApercuTitle,ILData,1,BrStInd,TrLineUp,1.3*MaxLE/ESIA.Total(1),1.3,Lane.Dir,BaseData.ILRes);

% Convert Results to Table
OverMaxT = array2table(OverMax,'VariableNames',{'InfCase','MaxLE','DLF','BrStInd'});

% Get ESIA
aQ1 = 0.7; aQ2 = 0.5; aq = 0.5;
% T69 stands for SIA 269
ESIA.T69 = 1.5*(ESIA.EQ(1)*aQ1+ESIA.EQ(2)*aQ2+ESIA.Eq*aq);

% Optional save of OutInfo (used for deterministic AGB matching)
OutInfo.Name = datestr(now,'mmmdd-yy HHMMSS'); OutInfo.BaseData = BaseData;
OutInfo.ESIM = OverMaxT.MaxLE;
OutInfo.OverMax = OverMax; OutInfo.OverMaxT = OverMaxT;
OutInfo.ILData = ILData; OutInfo.ESIA = ESIA;

if BaseData.Save == 1
    save(['Output' BaseData.Folder '/' OutInfo.Name], 'OutInfo')
end
