% ------------------------------------------------------------------------
%                            MATSim2019 4 [V]WIM
% ------------------------------------------------------------------------
% Run real traffic over a bridge to find maximum load effects
%       - To be used with MATSimInput spreadsheet (BaseData and LaneData)
%       - Can be used for both WIM and VWIM
%       - Works with BoxPlot if necessary

% Could add the main bits into a function? Reference the same fcn [V]WIM?

% Initial commands
tic, clear, clc, format long g, rng('shuffle'), close all; st = now;

% We need BaseData and LaneData
% If VWIM this has to match the output file

% We need a name for our plot(s)
% We need to know if we want to do Stage2Prune or ClassOnly
% We need a WIM or a VWIM file

% If the file is WIM this involves BaseData.SName and the Year
% If the file is VWIM this involes InfCase and SimNum

% Input Information
BaseData = table; 
% Station Info
BaseData.SName = 'Ceneri';  BaseData.SNum = 2;   Year = 2003:2018;
BaseData.LaneDir = {'1,1'};
% Influence Line Info
BaseData.ILs = {'Mp40'};  BaseData.ILRes = 1; 
% Analysis Info
BaseData.RunDyn = 1;  BaseData.NumAnalyses = 10;
% Stage 2 Pruning, Classified Vehicles Only on/off
BaseData.Stage2Prune = false; BaseData.ClassOnly = false; 

% % Optional Input through File NOTE: replace UpdateData(BaseData,LaneData,1,1);
% % Input File Name
% InputFile = 'Input/MATSimInputSimple.xlsx';
% % Read Input File
% [BaseData,LaneData,~,~] = ReadInputFile(InputFile); 

% Obtain Influence Line Info
[Num.Lanes,Lane,LaneData,~,~] = UpdateData(BaseData,[],1,1);
[Inf,Num.InfCases,Inf.x,Inf.v,ESIA] = GetInfLines(LaneData,BaseData,Num.Lanes);

% Initialize
OverMax = [];

for v = 1:3
    
    D = [];

for i = 1:length(Year)

    % Load WIM File [OR VWIM File]
    load(['PrunedS1 WIM/',BaseData.SName,'/',BaseData.SName,'_',num2str(Year(i)),'.mat']);
    %load('WIM_Jan14 1130.mat');
    %load('Apercu\PlatStud60m\AWIM_Jan24-20 1049.mat');
    % when doing with VWIM, you need to know the sim #
    %load('Output\PlatStud60m\Jan24-20 1049.mat')
    %IC = 1;
    %[a, b] = max(OutInfo.OverMAXT.MaxLE(OutInfo.OverMAXT.InfCase == IC));
    %SN = OutInfo.OverMAXT.SimNum(b);
    %PD = PD(PD.SimNum == SN & PD.InfCase == IC,:);
    
    % Only needs to be done to WIM
    
    % Add row for Class, Daytime, and Daycount
    PDC = Classify(PD); PDC = Daytype(PDC,Year(i)); clear('PD')
    
    % We treat each station separately.. SNum is the input for which
    Stations = unique(PDC.ZST); Station = Stations(BaseData.SNum);
    
    % Take only the vehicles from the desired station
    PDCx = PDC(PDC.ZST == Station,:); clear('PDC')
    
    % Further trimming
    if BaseData.Stage2Prune
        PDCx = PruneWIM2(PDCx,0);
    end
    
    if BaseData.ClassOnly
        PDCx(PDCx.CLASS == 0,:) = [];
    end
    
    
    % Custom Edits
    if v == 2
    PDCx(PDCx.GW_TOT > 44000 & PDCx.FS == 2,:) = [];
    elseif v == 3
    PDCx(PDCx.GW_TOT > 44000,:) = [];
    end
    
    % Convert PDC to AllTrAx
    [PDCx, AllTrAx, TrLineUp] = WIMtoAllTrAx(PDCx,round(Inf.x(end)),Lane.Dir,BaseData.ILRes);
    
    % Round TrLineUp first row, move unrounded to fifth row
    TrLineUp(:,5) = TrLineUp(:,1); TrLineUp(:,1) = round(TrLineUp(:,1)/BaseData.ILRes);
    
    for k = 1:BaseData.NumAnalyses
        
        for t = 1
            % Subject Influence Line to Truck Axle Stream
            [MaxLE,MaxLEStatic,DLF,BrStInd,AxonBr,FirstAxInd,FirstAx] = GetMaxLE(AllTrAx,Inf,BaseData.RunDyn,t);
            % Record Maximums
            OverMax = [OverMax; [t, Year(i), MaxLE, DLF, BrStInd, FirstAxInd, FirstAx]];
        end
        
        if BaseData.NumAnalyses == 1
            T = Apercu(PDCx,sprintf('%s %i',BaseData.SName,Stations(BaseData.SNum)),Inf.x,Inf.v(:,t),BrStInd,TrLineUp,MaxLE/ESIA.Total(t),DLF,Lane.Dir,BaseData.ILRes);
        end
        
        % Delete vehicle entries from TrLineUp for re-analysis
        TrLineUp(TrLineUp(:,1) > BrStInd & TrLineUp(:,1) < BrStInd + Inf.x(end),:) = [];
        % Set Axles to zero in AllTrAx (can't delete because indices are locations)
        AllTrAx(BrStInd:BrStInd + Inf.x(end),:) = 0;
        
    end
end

end

% Convert Results to Table
OverMAXT = array2table(OverMax,'VariableNames',{'InfCase','Year','MaxLE','MaxDLF','MaxBrStInd','MaxFirstAxInd','MaxFirstAx'});

% Create box plot array
for i = 1:length(Year)
    D(:,i) = OverMAXT.MaxLE(OverMAXT.Year == Year(i));
end

aQ1 = 0.7;
aQ2 = 0.5;
aq = 0.5;

ESIA.T69 = 1.5*(ESIA.EQ(1)*aQ1+ESIA.EQ(2)*aQ2+ESIA.Eq*aq);

AGBSim = 1.1*9604;

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

xwidth = [Year(1)-1 Year(end)+1];


figure
YearsforD = repmat(Year,BaseData.NumAnalyses,1);
Dx = D(1:10,:);
scatter(YearsforD(:)-0.15,Dx(:),'sk','MarkerFaceColor',0.2*[1 1 1])
hold on
Dx = D(11:20,:);
scatter(YearsforD(:),Dx(:),'sk','MarkerFaceColor',0.6*[1 1 1])
hold on
Dx = D(21:30,:);
scatter(YearsforD(:)+0.15,Dx(:),'sk','MarkerFaceColor',1*[1 1 1])
hold on
plot(xwidth,[ESIA.Total ESIA.Total],'k')
text(Year(1),ESIA.Total+ESIA.Total*0.05,sprintf('E_{SIA}'),'FontSize',11,'FontWeight','bold','Color','k')
hold on
plot(xwidth,[AGBSim AGBSim],'r')
text(Year(1),AGBSim-ESIA.Total*0.2,'E_{SIM 99%} AGB 2002/005 with \gamma = 1.1','FontSize',11,'FontWeight','bold','Color','r')
hold on
plot(xwidth,.9*[ESIA.Total ESIA.Total],'-.k')
text(Year(1),.9*ESIA.Total-ESIA.Total*0.05,'E_{SIA261}   [\alpha_{Q1/Q2/q} = 0.9]','FontSize',11,'FontWeight','bold','Color','k')
hold on
plot(xwidth,[ESIA.T69 ESIA.T69],'-.k')
text(Year(1),ESIA.T69+ESIA.Total*0.05,'E_{SIA269}   [\alpha_{Q1} = 0.7, \alpha_{Q2} = 0.5, \alpha_{q} = 0.5]','FontSize',11,'FontWeight','bold','Color','k')
ylim([0 ceil(round(ESIA.Total,-3)/10000)*10000])
ytickformat('%g')
xlim(xwidth)
xlabel('Year')
ylabel('Moment (kNm)')
title(sprintf('Ceneri Staion 409 Max M+ [Top %i/Year] | 40m Simple Span',BaseData.NumAnalyses))
legend('Raw Traffic','Only < 44 tonnes in 2nd Lane','Only < 44 tonnes')



