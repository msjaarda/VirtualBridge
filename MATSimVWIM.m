% ------------------------------------------------------------------------
%                            MATSim2019forVWIM
% ------------------------------------------------------------------------
% Run real traffic over a bridge to find maximum load effects
%       - To be used with MATSimInput spreadsheet for Inf Lines

% Initial commands
tic, clear, clc, close all, format long g, rng('shuffle'); st = now;


% Input Information
BaseData = table; 
% Station Info
BaseData.SName = 'Det';
BaseData.LaneDir = {'2,1'};
% Influence Line Info
BaseData.ILs = {'V'};  BaseData.ILRes = 0.1; 
% Analysis Info
BaseData.RunDyn = 0;

% Load VWIM File
load('Det60t.mat')

% Obtain Influence Line Info
[Num.Lanes,Lane,LaneData,~,~] = UpdateData(BaseData,[],1,1);
[Inf,Num.InfCases,Inf.x,Inf.v,ESIA] = GetInfLines(LaneData,BaseData,Num.Lanes);

% Initialize
OverMax = [];

%load(['PrunedS1 WIM/',SName,'/',SName,'_',num2str(Year(i)),'.mat']);
%load('WIM_Jan14 1130.mat');
%load('Apercu\PlatStud60m\AWIM_Jan24-20 1049.mat');
% when doing with VWIM, you need to know the sim #
%load('Output\PlatStud60m\Jan24-20 1049.mat')
% IC = 1;
% [a, b] = max(OutInfo.OverMAXT.MaxLE(OutInfo.OverMAXT.InfCase == IC));
% SN = OutInfo.OverMAXT.SimNum(b);
% PD = PD(PD.SimNum == SN & PD.InfCase == IC,:);

% Only needs to be done to WIM

% Add row for Class, Daytime, and Daycount
% PDC = Classify(PD); %PDC = Daytype(PDC,Year(i)); clear('PD')
% 
% if Stage2Prune
%     PDC = PruneWIM2(PDC,0);
% end
% 
% if ClassOnly
%     PDC(PDC.CLASS == 0,:) = [];
% end

% Convert PDC to AllTrAx
[PDC, AllTrAx, TrLineUp] = WIMtoAllTrAx(PD,round(Inf.x(end)),Lane.Dir,BaseData.ILRes);

% Round TrLineUp first row, move unrounded to fifth row
TrLineUp(:,5) = TrLineUp(:,1); TrLineUp(:,1) = round(TrLineUp(:,1)/BaseData.ILRes);
        
for t = 3
    % Subject Influence Line to Truck Axle Stream
    [MaxLE,MaxLEStatic,DLF,BrStInd,AxonBr,FirstAxInd,FirstAx] = GetMaxLE(AllTrAx,Inf,BaseData.RunDyn,t);
    % Record Maximums
    OverMax = [OverMax; [t, MaxLE, DLF, BrStInd, FirstAxInd, FirstAx]];
end


%T = Apercu(PDC,sprintf('%s',BaseData.SName),Inf.x,Inf.v(:,2),BrStInd,TrLineUp,MaxLE/ESIA.Total(t),DLF,Lane.Dir,BaseData.ILRes)
T = Apercu(PDC,sprintf('%s',BaseData.SName),Inf.x,Inf.v(:,3),BrStInd,TrLineUp,MaxLE/ESIA.Total(t),DLF,Lane.Dir,BaseData.ILRes)

%saveas(gcf,['Key Results/RealWIM on Fornaci/' SName '_' num2str(Year(i)) '_' num2str(Station)])
%saveas(gcf,['Key Results/RealWIM on Fornaci/' SName '_' num2str(Year(i)) '_' num2str(Station) '.png'])
%saveas(gcf,['Key Results/RealWIM on Fornaci/' SName '_' num2str(Year(i)) '_' num2str(Station) '.png'])


% Convert Results to Table
OverMAXT = array2table(OverMax,'VariableNames',{'InfCase','MaxLE','MaxDLF','MaxBrStInd','MaxFirstAxInd','MaxFirstAx'});

%save(['Key Results/RealWIM on Fornaci/' num2str(Station) '_MaxLEs'],'OverMAXT')

% Optional Outputs 

% figure(2)
% scatter(LowYear:HighYear,OverMAXT.MaxLE)
% hold on
% plot([LowYear HighYear],[ESIA ESIA])
% hold on
% plot([LowYear HighYear],.72*[ESIA ESIA])
% ylim([0 14000])
% xlabel('Year')
% ylabel('Moment (kNm)')
% title('Ceneri Station 408 Maximums')

%fprintf('Percent of ESIA = %.2f\n\n',MaxLE/ESIA)
