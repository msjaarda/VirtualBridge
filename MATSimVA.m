% ------------------------------------------------------------------------
%                            MATSimVA
% ------------------------------------------------------------------------
% Run virtual WIM or apercu traffic over a bridge to find maximum load effects

% Initial commands
clear, clc, format long g, rng('shuffle'), close all; BaseData = table;

% Input Information --------------------

% Roadway Info
BaseData.LaneDir = {'1,1'};
% Influence Line Info
BaseData.ILs = {'Mp.Mp40'};  BaseData.ILRes = 1;  InfCase = 1;
% Analysis Info
BaseData.RunDyn = 1;   BaseData.MultipleCases = 1;
BaseData.TransILx = 0;
BaseData.TransILy = 0;
BaseData.LaneCen = 0;

BaseData.Save = 0;
BaseData.Folder = '/AGB2002A15';

FName = 'Apercu\PlatStud60m\AWIM_Jan24-20 1049.mat'; % Options
OutputFName = 'Output\PlatStud60m\Jan24-20 1049.mat';
%InfCase = 1;
%BaseData.LaneDir = {'1,1,2,2'};
%BaseData.LaneDir = {'1,1'};
% AWIM: 'Apercu\AWIM_Mar25-20 1034.mat'
% VWIM: 'WIM_Jan14 1130.mat'

BaseData.NumAnalyses = 1;
BaseData.ApercuTitle = sprintf('%s','VAWIM');
    

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

for v = 1:BaseData.MultipleCases
        
    % Load File
    load(FName)
    % Load Output File
    load(OutputFName);
    try
        [a, b] = max(OutInfo.OverMaxT.MaxLE(OutInfo.OverMaxT.InfCase == InfCase));
        SimNum = OutInfo.OverMaxT.SimNum(b);
    catch % Cover the case of MAXT (old school) rather than MaxT
        [a, b] = max(OutInfo.OverMAXT.MaxLE(OutInfo.OverMAXT.InfCase == InfCase));
        SimNum = OutInfo.OverMAXT.SimNum(b);
    end
    
    PDCx = PD(PD.SimNum == SimNum & PD.InfCase == InfCase,:);
    
       
    % CUSTOM EDIT for multiple cases
    if v == 2
        [Lanes, a, b] = unique(PDCx.FS);
        if sum(PDCx.FS == Lanes(1)) < sum(PDCx.FS == Lanes(2))
            SlowLane = Lanes(1);
        else
            SlowLane = Lanes(2);
        end
        PDCx(PDCx.GW_TOT > 44000 & PDCx.FS == SlowLane,:) = [];
    elseif v == 3
        PDCx(PDCx.GW_TOT > 44000,:) = [];
    end
    
    % Convert PDC to AllTrAx
    [PDCx, AllTrAx, TrLineUp] = WIMtoAllTrAx(PDCx,round(Inf.x(end)),Lane.Dir,BaseData.ILRes);
    
    % Round TrLineUp first row, move unrounded to fifth row
    TrLineUp(:,5) = TrLineUp(:,1); TrLineUp(:,1) = round(TrLineUp(:,1)/BaseData.ILRes);
    
    for k = 1:BaseData.NumAnalyses
        
        for t = 1:length(InfCase)
            % Subject Influence Line to Truck Axle Stream
            [MaxLE,SMaxMaxLE,DLF,BrStInd,AxonBr,FirstAxInd,FirstAx] = GetMaxLE(AllTrAx,Inf,BaseData.RunDyn,InfCase(t));
            % Record Maximums
            OverMax = [OverMax; [InfCase(t), 1, MaxLE, SMaxMaxLE, DLF, BrStInd, FirstAxInd, FirstAx]];
        end
        
        if BaseData.NumAnalyses == 1 && length(InfCase) == 1
            T = Apercu(PDCx,BaseData.ApercuTitle,Inf.x,Inf.v(:,t),BrStInd,TrLineUp,MaxLE/ESIA.Total(t),DLF,Lane.Dir,BaseData.ILRes);
        end
        
        % Delete vehicle entries from TrLineUp for re-analysis
        TrLineUp(TrLineUp(:,1) > BrStInd & TrLineUp(:,1) < BrStInd + Inf.x(end),:) = [];
        % Set Axles to zero in AllTrAx (can't delete because indices are locations)
        AllTrAx(BrStInd:BrStInd + Inf.x(end),:) = 0;
        
    end
end

% Convert Results to Table
OverMaxT = array2table(OverMax,'VariableNames',{'InfCase','Year','MaxLE','SMaxLE','MaxDLF','MaxBrStInd','MaxFirstAxInd','MaxFirstAx'});

% Get ESIA
aQ1 = 0.7; aQ2 = 0.5; aq = 0.5;
% T69 stands for SIA 269
ESIA.T69 = 1.5*(ESIA.EQ(1)*aQ1+ESIA.EQ(2)*aQ2+ESIA.Eq*aq);
% Custom
AGBSim = 1.1*9604;

% Simplify results into D
D(:,1) = OverMaxT.MaxLE(OverMaxT.Year == 1);


% Create box plot

% figure
% boxplot(D,Year)
% hold on
% plot([0 length(Year)+1],[ESIA.Total ESIA.Total],'k')
% text(1,ESIA.Total+ESIA.Total*0.05,sprintf('E_{SIA}'),'FontSize',11,'FontWeight','bold','Color','k')
% hold on
% plot([0 length(Year)+1],[AGBSim AGBSim],'k')
% text(1+5,AGBSim-ESIA.Total*0.05,'E_{SIM 99%} AGB 2002/005 with \gamma = 1.1','FontSize',11,'FontWeight','bold','Color','r')
% hold on
% plot([0 length(Year)+1],.9*[ESIA.Total ESIA.Total],'-.k')
% text(1,.9*ESIA.Total-ESIA.Total*0.05,'E_{SIA261}   [\alpha_{Q/q}] = 0.9','FontSize',11,'FontWeight','bold','Color','k')
% hold on
% plot([0 length(Year)+1],[ESIA.T69 ESIA.T69],'-.k')
% text(1+5,ESIA.T69+ESIA.Total*0.05,'E_{SIA269}   [\alpha_{Q1} = 0.7\alpha_{Q1} = 0.5, \alpha_{q} = 0.5]','FontSize',11,'FontWeight','bold','Color','k')
% ylim([0 ceil(round(ESIA.Total,-3)/10000)*10000])
% ytickformat('%g')
% xlabel('Year')
% ylabel('Moment (kNm)')
% title(sprintf('Ceneri Staion 409 Max M+ [Top %i/Year] | 40m Simple Span',BaseData.NumAnalyses))