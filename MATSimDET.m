% ------------------------------------------------------------------------
%                            MATSimDET
% ------------------------------------------------------------------------
% Run deterministic vehicles over a bridge to find maximum load effects

% Initial commands
clear, clc, format long g, rng('shuffle'), close all; BaseData = table;
addpath('./Misc/Deterministic Vehicles/')

% Input Information --------------------

% Roadway Info
BaseData.LaneDir = {'1,1'};
% Influence Line Info
BaseData.ILs = {'Mp.Mp40'};  BaseData.ILRes = 1;
% Analysis Info
BaseData.RunDyn = 0;

BaseData.NumVeh = 1000000; % use for bi or mo ...
BaseData.LaneTrDistr = {'80,20'}; % used for split, stand, exfast, exslow
BaseData.TrRate = 0; % used to distinguish Det

BaseData.TransILx = {'0'};  % used for reduced, expanded, conc
BaseData.TransILy = {'0'};
BaseData.LaneCen = {'0'};

BaseData.Save = 0;
BaseData.Folder = '/AGB2002A15';

FName = 'DetAll.mat'; % 'Det60t.mat'

BaseData.ApercuTitle = sprintf('%s','Deterministic Analysis');

% Input Complete   ---------------------

% % NOTE: Optional Input through File 
% % replace "UpdateData(BaseData,LaneData,1,1);" with..
% % "
% % Input File Name
% InputFile = 'Input/MATSimInputSimple.xlsx';
% % Read Input File
% [BaseData,LaneData,~,~] = ReadInputFile(InputFile); 
% % "
% % BaseData will be overwrote

% Obtain Influence Line Info
[Num.Lanes,Lane,LaneData,~,~] = UpdateData(BaseData,[],1,1);
[Inf,Num.InfCases,Inf.x,Inf.v,ESIA] = GetInfLines(LaneData,BaseData,Num.Lanes);

% Initialize
OverMax = [];
    
load(FName)
% Add Factors
PD{PD.GW_TOT == 60000,11:15} = 1.1*PD{PD.GW_TOT == 60000,11:15};
PD{PD.GW_TOT == 40000,11:15} = 1.5*PD{PD.GW_TOT == 40000,11:15};

PDCx = PD;

% Convert PDC to AllTrAx
[PDCx, AllTrAx, TrLineUp] = WIMtoAllTrAx(PDCx,round(Inf.x(end)),Lane.Dir,BaseData.ILRes);

% Round TrLineUp first row, move unrounded to fifth row
TrLineUp(:,5) = TrLineUp(:,1); TrLineUp(:,1) = round(TrLineUp(:,1)/BaseData.ILRes);


% Subject Influence Line to Truck Axle Stream
[MaxLE,SMaxMaxLE,DLF,BrStInd,AxonBr,FirstAxInd,FirstAx] = GetMaxLE(AllTrAx,Inf,BaseData.RunDyn,1);
% Record Maximums
OverMax = [OverMax; [1, 1, MaxLE, SMaxMaxLE, DLF, BrStInd, FirstAxInd, FirstAx]];

% Display Apercu
T = Apercu(PDCx,BaseData.ApercuTitle,Inf.x,Inf.v(:,1),BrStInd,TrLineUp,MaxLE/ESIA.Total(1),DLF,Lane.Dir,BaseData.ILRes);

% Convert Results to Table
OverMaxT = array2table(OverMax,'VariableNames',{'InfCase','Year','MaxLE','SMaxLE','MaxDLF','MaxBrStInd','MaxFirstAxInd','MaxFirstAx'});

% Get ESIA
aQ1 = 0.7; aQ2 = 0.5; aq = 0.5;
% T69 stands for SIA 269
ESIA.T69 = 1.5*(ESIA.EQ(1)*aQ1+ESIA.EQ(2)*aQ2+ESIA.Eq*aq);

% Optional save of OutInfo (used for deterministic AGB matching)
OutInfo.Name = datestr(now,'mmmdd-yy HHMMSS'); OutInfo.BaseData = BaseData;
OutInfo.ESIMS = OverMaxT.MaxLE;
OutInfo.ESIM = OverMaxT.MaxLE*1.3; % Apply DLA
OutInfo.OverMax = OverMax; OutInfo.OverMaxT = OverMaxT;
OutInfo.InfNames = Inf.Names;
OutInfo.LaneData = LaneData;

OutInfo.ESIA = []; OutInfo.PlatPct = 0; OutInfo.Mean = []; OutInfo.Std = [];

if BaseData.Save == 1
    save(['Output' BaseData.Folder '/' OutInfo.Name], 'OutInfo')
end
