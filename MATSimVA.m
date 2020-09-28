% ------------------------------------------------------------------------
%                            MATSimVA
% ------------------------------------------------------------------------
% Run virtual WIM or apercu traffic over a bridge to find maximum load effects
% This program should only be used with both the Output and Apercu/Virtual files
% Even though it can work for VirtualWIM, Apercu is probably the main use

% Initial commands
clear, clc, format long g, rng('shuffle'), close all;

% Input Information --------------------

InfCase = [2 6 9];        % User must know the InfCase number(s)

Folder = 'PlatoonTwinApercu';
FDate = 'Sep03-20 113250';

FName = ['Apercu\' Folder '\AWIM_' FDate '.mat']; % Options
OutputFName = ['Output\' Folder '\' FDate '.mat'];

%FName = 'VirtualWIM\Congest\WIM_May08-20 165449.mat'; % Options
%FName = 'Apercu\PlatStud60m\AWIM_Jan24-20 1049.mat'; % Options
%OutputFName = 'Output\PlatStud60m\Jan24-20 1049.mat';

% AWIM: 'Apercu\AWIM_Mar25-20 1034.mat'
% VWIM: 'WIM_Jan14 1130.mat'

% Input Complete   ---------------------

% % NOTE: Optional Input through File (see other MATSim_ files for details

% Initialize
OverMax = [];
        
% Load File
load(FName)
% Load Output File
load(OutputFName);

% If not already defined, we need to define things in terms of OutInfo
BaseData = OutInfo.BaseData;
BaseData.Save = 0;
BaseData.Folder = '/AGB2002A15';
BaseData.ApercuTitle = sprintf('%s','VAWIM');
[Num.Lanes,Lane,LaneData,~,~] = UpdateData(BaseData,[],1,1);
[Inf,Num.InfCases,Inf.x,Inf.v,ESIA] = GetInfLines(OutInfo.LaneData,BaseData,Num.Lanes);

for i = 1:length(InfCase)

try
    [a, SimNum] = max(OutInfo.OverMaxT.MaxLE(OutInfo.OverMaxT.InfCase == InfCase(i)));
catch % Cover the case of MAXT (old school) rather than MaxT
    [a, SimNum] = max(OutInfo.OverMAXT.MaxLE(OutInfo.OverMAXT.InfCase == InfCase(i)));
end
    
% There is no InfCase with VWIM
try
    PDCx = PD(PD.SimNum == SimNum & PD.InfCase == InfCase(i),:);
catch
    PDCx = PD(PD.SimNum == SimNum,:);
end
       
% Convert PDC to AllTrAx
[PDCx, AllTrAx, TrLineUp] = WIMtoAllTrAx(PDCx,round(Inf.x(end)),Lane.Dir,BaseData.ILRes);

% Round TrLineUp first row, move unrounded to fifth row
TrLineUp(:,5) = TrLineUp(:,1); TrLineUp(:,1) = round(TrLineUp(:,1)/BaseData.ILRes);
          
% Subject Influence Line to Truck Axle Stream
[MaxLE,SMaxLE,BrStInd,AxonBr] = GetMaxLE(AllTrAx,Inf,BaseData.RunDyn,InfCase(i));
%[MaxLE,SMaxMaxLE,BrStInd,AxonBr] = GetMaxLE(AllTrAx,Inf,BaseData.RunDyn,1);
% Record Maximums
OverMax = [OverMax; [InfCase(i), 1, MaxLE, SMaxLE, BrStInd]];

% Take only the influence lines that apply to the current InfCase
Infv = Inf.v(:,Inf.UniqInds == InfCase(i));
% Remove nans (added experimentally 12/02/2020.. fixed 05/03)
FirstNan = find(isnan(Infv));
if ~isempty(FirstNan)
    Infv = Infv(1:FirstNan-1,:);
    Infx = Inf.x(1:FirstNan-1,:);
end

T = Apercu(PDCx,BaseData.ApercuTitle,Infx,Infv,BrStInd,TrLineUp,MaxLE/ESIA.Total(InfCase(i)),MaxLE/SMaxLE,Lane.Dir,BaseData.ILRes);

end
               
% Convert Results to Table
OverMaxT = array2table(OverMax,'VariableNames',{'InfCase','Year','MaxLE','SMaxLE','MaxBrStInd'});
