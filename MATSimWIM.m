% ------------------------------------------------------------------------
%                            MATSim2019forWIM
% ------------------------------------------------------------------------
% Run real traffic over a bridge to find maximum load effects
%       - To be used with MATSimInput spreadsheet for Inf Lines
%       - Can be used for both VWIM and WIM


% Could add the main bits into a function? Reference the same fcn [V]WIM?

% Initial commands
tic, clear, clc, close all, format long g, rng('shuffle'); st = now;

% The bottom line is that we need BaseData and LaneData
% If VWIM this has to match the output file
% We need a name for our plot(s)
% We need to know if we want to do Stage2Prune or ClassOnly
% We need a WIM or a VWIM file
% If the file is WIM this involves SName and the Year
% If the file is VWIM this involes InfCase and SimNum




% Input File Name
FolderName = 'PlatStud60m';
OutFileName = ;
%InputFile = 'Input/MATSimInputx.xlsx';
%InputFile = 'Input/PlatStud60m/MATSimInputPlatStudSS60Base.xlsx';
InputFile = ['Input/' FolderName '/' MATSimInputPlatStudSS60Base.xlsx';

% Read simulation data from Input File
[BaseData,LaneData,~,~] = ReadInputFile(InputFile); OverMax = [];

% Get Influence Line Details
[InfLanes,InfNames,UniqInf,UniqInfs,UniqInfi,Num.InfCases,Infx,Infv,IntInfv,MaxInfv] = GetInfLines(LaneData,BaseData);

% WIM File
SName = 'Platooning Investigation'; Stage2Prune = false; ClassOnly = false; Year = 2020;

for i = 1:length(Year)

% Load WIM File [OR VWIM File]
%load(['PrunedS1 WIM/',SName,'/',SName,'_',num2str(Year(i)),'.mat']);
%load('WIM_Jan14 1130.mat');
load('Apercu\PlatStud60m\AWIM_Jan24-20 1049.mat');
% when doing with VWIM, you need to know the sim #
load('Output\PlatStud60m\Jan24-20 1049.mat')
IC = 1;
[a, b] = max(OutInfo.OverMAXT.MaxLE(OutInfo.OverMAXT.InfCase == IC));
SN = OutInfo.OverMAXT.SimNum(b);
PD = PD(PD.SimNum == SN & PD.InfCase == IC,:);

% Only needs to be done to WIM

% Add row for Class, Daytime, and Daycount
PDC = Classify(PD); PDC = Daytype(PDC,Year(i)); clear('PD')

% We treat each station separately [edit Stations(1) to Stations(2)]
Stations = unique(PDC.ZST); Station = Stations(1);

PDCx = PDC(PDC.ZST == Station,:); clear('PDC')

if Stage2Prune
    PDCx = PruneWIM2(PDCx,0);
end

if ClassOnly
    PDCx(PDCx.CLASS == 0,:) = [];
end

% Convert PDC to AllTrAx
[PDCx, AllTrAx, TrLineUp] = WIMtoAllTrAx(PDCx,round(Infx(end)));

% Round TrLineUp first row, move unrounded to fifth row
TrLineUp(:,5) = TrLineUp(:,1); TrLineUp(:,1) = round(TrLineUp(:,1));
        
for t = IC
    % Subject Influence Line to Truck Axle Stream
    [MaxLE,DLF,BrStInd,AxonBr,FirstAxInd,FirstAx] = GetMaxLE(AllTrAx,Infv,InfLanes,[80 20],BaseData.RunDyn,t,UniqInfs,UniqInfi);
    % Record Maximums
    OverMax = [OverMax; [t, Year(i), MaxLE, DLF, BrStInd, FirstAxInd, FirstAx]];
end

% [Delete vehicles involved in maximum case, and re-analyze]


% Get simulation time
Time = GetSimTime();

% Get ESIA from function
ESIA = GetESia(IntInfv,MaxInfv,InfLanes,UniqInfs);

T = Apercu(PDCx,[SName],Infx,Infv(:,IC),BrStInd,TrLineUp,MaxLE/ESIA(IC),DLF);
%T = Apercu(PDCx,[num2str(Year(i)) ' ' SName ' Station ' num2str(Station)],Infx,Infv,BrStInd,TrLineUp,MaxLE/ESIA(1),DLF);

%saveas(gcf,['Key Results/RealWIM on Fornaci/' SName '_' num2str(Year(i)) '_' num2str(Station)])
%saveas(gcf,['Key Results/RealWIM on Fornaci/' SName '_' num2str(Year(i)) '_' num2str(Station) '.png'])
saveas(gcf,['Key Results/RealWIM on Fornaci/' SName '_' num2str(Year(i)) '_' num2str(Station) '.png'])

end

% Convert Results to Table
OverMAXT = array2table(OverMax,'VariableNames',{'InfCase','Year','MaxLE','MaxDLF','MaxBrStInd','MaxFirstAxInd','MaxFirstAx'});

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
