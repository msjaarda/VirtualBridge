% ------------------------------------------------------------------------
%                            MATSimWIM
% ------------------------------------------------------------------------
% Run real traffic over a bridge to find maximum load effects
% Used with Virtual or Real WIM results

% Initial commands
clear, clc, format long g, rng('shuffle'), close all; BaseData = table;

% Input Information --------------------

% NOTE USED
% Type
BaseData.Type = 'NWIM';
                        
% Necessary Inputs
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
BaseData.InfSurf = 0;    

BaseData.LaneDir = {'1,1'};

% Station Info incl. station name, number, and year
Year = 2016:2018;
BaseData.SName = 'Denges';
BaseData.StationNum = 1;
BaseData.NumAnalyses = 10;
BaseData.Stage2Prune = false;
BaseData.ClassOnly = false;

% Input Complete   ---------------------

% % NOTE: Optional Input through File 
% % replace "UpdateData(BaseData,LaneData,1,1);" with..
% % "
% % Input File Name
% InputFile = 'Input/MATSimWIMInput.xlsx';
% % Read Input File
% [BaseData,LaneData,~,~] = ReadInputFile(InputFile); 
% % "
% % BaseData will be overwrote
BaseData.MultipleCases = 1;
BaseData.Type = 'NWIM';
                        
% Obtain Influence Line Info
[Num.Lanes,Lane,LaneData,~,~] = UpdateData(BaseData,[],1,1);
[Inf,Num.InfCases,Inf.x,Inf.v,ESIA] = GetInfLines(LaneData,BaseData,Num.Lanes);

% Initialize
OverMax = [];

for v = 1:BaseData.MultipleCases

    for i = 1:length(Year)
        
        % Load File
            load(['PrunedS1 WIM/',BaseData.SName,'/',BaseData.SName,'_',num2str(Year(i)),'.mat']);


        % Add row for Class, Daytime, and Daycount
        PDC = Classify(PD);
        PDC = Daytype(PDC,Year(i));
        clear('PD')
        
        % We treat each station separately.. SNum is the input for which
        Stations = unique(PDC.ZST);
        Station = Stations(BaseData.StationNum);
        PDCx = PDC(PDC.ZST == Station,:);
        clear('PDC')
        
        BaseData.ApercuTitle = sprintf('%s %s %i %i',BaseData.Type,BaseData.SName,Stations(BaseData.StationNum),Year(i));
        % Plot Titles
        BaseData.PlotTitle = sprintf('%s Staion %i Max M+ [Top %i/Year] | 40m Simple Span',BaseData.SName,Stations(BaseData.StationNum),BaseData.NumAnalyses);
        
        % Further trimming if necessary
        if BaseData.Stage2Prune
            PDCx = PruneWIM2(PDCx,0);
        end
        
        if BaseData.ClassOnly
            PDCx(PDCx.CLASS == 0,:) = [];
        end

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
                [MaxLE,SMaxLE,BrStInd,AxonBr,~] = GetMaxLE(AllTrAx,Inf,BaseData.RunDyn,InfCase(t));
                % Record Maximums
                OverMax = [OverMax; [InfCase(t), Year(i), MaxLE, SMaxLE, BrStInd]];
            end
            
            if BaseData.NumAnalyses == 1 && length(InfCase) == 1
                T = Apercu(PDCx,BaseData.ApercuTitle,Inf.x,Inf.v(:,t),BrStInd,TrLineUp,MaxLE/ESIA.Total(t),MaxLE/SMaxLE,Lane.Dir,BaseData.ILRes);
            end
            
            % Delete vehicle entries from TrLineUp for re-analysis
            TrLineUp(TrLineUp(:,1) > BrStInd & TrLineUp(:,1) < BrStInd + Inf.x(end),:) = [];
            % Set Axles to zero in AllTrAx (can't delete because indices are locations)
            AllTrAx(BrStInd:BrStInd + Inf.x(end),:) = 0;
            
        end
    end
end

% Convert Results to Table
OverMaxT = array2table(OverMax,'VariableNames',{'InfCase','Year','MaxLE','SMaxLE','MaxBrStInd'});

% Get ESIA
aQ1 = 0.7; aQ2 = 0.5; aq = 0.5;
% T69 stands for SIA 269
ESIA.T69 = 1.5*(ESIA.EQ(1)*aQ1+ESIA.EQ(2)*aQ2+ESIA.Eq*aq);
% Custom
AGBSim = 1.1*9604;

% Simplify results into D
for i = 1:length(Year)
    D(:,i) = OverMaxT.MaxLE(OverMaxT.Year == Year(i));
end

% Create plot if multiple years involved
if length(Year) > 1
    xwidth = [Year(1)-1 Year(end)+1];
    figure
    YearsforD = repmat(Year,BaseData.NumAnalyses,1);
    Dx = D(1:BaseData.NumAnalyses,:);
    scatter(YearsforD(:)-0.15,Dx(:),'sk','MarkerFaceColor',0.2*[1 1 1])
    hold on
%     Dx = D(BaseData.NumAnalyses+1:BaseData.NumAnalyses*2,:);
%     scatter(YearsforD(:),Dx(:),'sk','MarkerFaceColor',0.6*[1 1 1])
%     hold on
%     Dx = D(BaseData.NumAnalyses*2+1:BaseData.NumAnalyses*3,:);
%     scatter(YearsforD(:)+0.15,Dx(:),'sk','MarkerFaceColor',1*[1 1 1])
%     hold on
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
    title(BaseData.PlotTitle)
    legend('Raw Traffic','Only < 44 tonnes in 2nd Lane','Only < 44 tonnes')
end

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



