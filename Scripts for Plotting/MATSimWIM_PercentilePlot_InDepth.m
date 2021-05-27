% ------------------------------------------------------------------------
%                            MATSimWIM
% ------------------------------------------------------------------------
% Run real traffic over a bridge to find maximum load effects

% Initial commands
clear, clc, format long g, rng('shuffle'), close all; BaseData = table;

% Input Information --------------------

% Type
BaseData.Type = 'NWIM'; % Normal

% Analysis Info
BaseData.RunDyn = 1;
BaseData.TransILx = 0;
BaseData.TransILy = 0;
BaseData.LaneCen = 0;
BaseData.Save = 0;
BaseData.Folder = '/AGBValidation';
BaseData.NumAnalyses = 6;
BaseData.Stage2Prune = false;
BaseData.ClassOnly = true;
BaseData.OnlyUnder44 = true;

% Influence Line Info
BaseData.LaneDir = {'1,1'};
BaseData.ILs = {'Mp.Mp30'};  BaseData.ILRes = 0.1;  InfCase = 1;
% Span from Influence Line Name
Span = str2double(BaseData.ILs{1}(end-1:end));

% Station Info
Year = 2011:2018;
BaseData.SName = 'Denges';
BaseData.StationNum1 = 1;
BaseData.StationNum2 = 2;
 
% Input Complete   ---------------------

% Obtain Influence Line Info
[Num.Lanes,Lane,LaneData,~,~] = UpdateData(BaseData,[],1,1);
[Inf,Num.InfCases,Inf.x,Inf.v,ESIA] = GetInfLines(LaneData,BaseData,Num.Lanes);

% Initialize
OverMax = [];

for v = 1:3

    for i = 1:length(Year)
        
%         if v == 1
%             BaseData.StationNum = 1;     
%         else
%             BaseData.StationNum = 2;
%         end
        
        % Load File
        load(['PrunedS1 WIM/',BaseData.SName,'/',BaseData.SName,'_',num2str(Year(i)),'.mat']);
        
        % Add row for Class, Daytime, and Daycount
        PDC = Classify(PD);
        PDC = Daytype(PDC,Year(i));
        clear('PD')

        % We treat each station separately.. SNum is the input for which
        Stations = unique(PDC.ZST);
        Station = Stations(BaseData.StationNum1);
        PDCx1 = PDC(PDC.ZST == Station,:);
        Station = Stations(BaseData.StationNum2);
        PDCx = [PDC(PDC.ZST == Station,:);  PDCx1];
        clear('PDC')

        BaseData.ApercuTitle = sprintf('%s %s %i %i',BaseData.Type,BaseData.SName,Stations(BaseData.StationNum1),Year(i));
        % Plot Titles
        BaseData.PlotTitle = sprintf('Max M+ [Top %i/Year] | %im Simple Span',BaseData.NumAnalyses,Span);

        % Further trimming if necessary
        if BaseData.Stage2Prune
            PDCx = PruneWIM2(PDCx,1);
        end
        if BaseData.ClassOnly
            PDCx(PDCx.CLASS == 0,:) = [];
        end
        if BaseData.OnlyUnder44
            PDCx(PDCx.GW_TOT > 44000,:) = [];
        end
        
        if v == 1
            PDCx = PDCx(PDCx.SPEED < 3000,:);
        elseif v == 2
            PDCx = PDCx(PDCx.SPEED > 3000 & PDCx.SPEED < 6000 ,:);
        else
            PDCx = PDCx(PDCx.SPEED > 6000,:);
        end

        % We must create a filter to remove unrealistic scenarios
        % Such as two vehicles too close together based on each's speed
        % The first requirement should simply be a max closeness...
        % This ended up being solved by ClassOnly
        
        % Convert PDC to AllTrAx
        [PDCx, AllTrAx, TrLineUp] = WIMtoAllTrAx(PDCx,round(Inf.x(length(Inf.v(~isnan(Inf.v))))),Lane.Dir,BaseData.ILRes);
        
        % Round TrLineUp first row, move unrounded to fifth row
        TrLineUp(:,5) = TrLineUp(:,1); TrLineUp(:,1) = round(TrLineUp(:,1)/BaseData.ILRes);       

        for k = 1:BaseData.NumAnalyses
            
            for t = 1:length(InfCase)
                % Subject Influence Line to Truck Axle Stream
                [MaxLE,SMaxLE,BrStInd,AxonBr,~] = GetMaxLE(AllTrAx,Inf,BaseData.RunDyn,InfCase(t));
                % Record Maximums
                OverMax = [OverMax; [InfCase(t), Year(i), MaxLE, SMaxLE, BrStInd]];
            end
            
            if BaseData.NumAnalyses < 6 && length(InfCase) == 1
                T = Apercu(PDCx,BaseData.ApercuTitle,Inf.x,Inf.v(:,t),BrStInd,TrLineUp,MaxLE/ESIA.Total(t),MaxLE/SMaxLE,Lane.Dir,BaseData.ILRes);
            end
            
            % Delete vehicle entries from TrLineUp for re-analysis
            BrEnInd = BrStInd + Inf.x(length(Inf.v(~isnan(Inf.v))))/BaseData.ILRes;
            TrLineUp(TrLineUp(:,1) > BrStInd & TrLineUp(:,1) < BrEnInd,:) = [];
            % Set Axles to zero in AllTrAx (can't delete because indices are locations)
            AllTrAx(BrStInd:BrEnInd,:) = 0;
            
        end
    end
end

% Convert Results to Table
OverMaxT = array2table(OverMax,'VariableNames',{'InfCase','Year','MaxLE','SMaxLE','MaxBrStInd'});

% Get ESIA
aQ1 = 0.7; aQ2 = 0.5; aq = 0.5;
% T69 stands for SIA 269
ESIA.T69 = 1.5*(ESIA.EQ(1)*aQ1+ESIA.EQ(2)*aQ2+ESIA.Eq*aq);

% Load Results from AGB Simulations
load('Output\AGB2002\Apr15-20 1537.mat') % 85-15
%load('Output\AGB2002\Apr15-20 1443.mat') % 96-04

% Ninety-ninth percentile value from simulations
Nnp = prctile(OutInfo.OverMax(:,Span/10),99);
% Get AGBSimulation
AGBSim = 1.1*Nnp;   

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
    Dx = D(BaseData.NumAnalyses+1:BaseData.NumAnalyses*2,:);
    scatter(YearsforD(:),Dx(:),'sk','MarkerFaceColor',0.6*[1 1 1])
    hold on
    Dx = D(BaseData.NumAnalyses*2+1:BaseData.NumAnalyses*3,:);
    scatter(YearsforD(:)+0.15,Dx(:),'sk','MarkerFaceColor',1*[1 1 1])
    hold on
    plot(xwidth,[ESIA.Total ESIA.Total],'k')
    text(Year(1),ESIA.Total+ESIA.Total*0.05,sprintf('E_{SIA}'),'FontSize',11,'FontWeight','bold','Color','k')
    hold on
    plot(xwidth,[AGBSim AGBSim],'r')
    text(Year(1),AGBSim+ESIA.Total*0.1,'E_{SIM 99%} AGB 2002/005 with \gamma = 1.1','FontSize',11,'FontWeight','bold','Color','r')
    hold on
    plot(xwidth,.9*[ESIA.Total ESIA.Total],'-.k')
    text(Year(1),.9*ESIA.Total-ESIA.Total*0.05,'E_{SIA261}   [\alpha_{Q1/Q2/q} = 0.9]','FontSize',11,'FontWeight','bold','Color','k')
    hold on
    plot(xwidth,[ESIA.T69 ESIA.T69],'-.k')
    text(Year(1),ESIA.T69+ESIA.Total*0.05,'E_{SIA269}   [\alpha_{Q1} = 0.7, \alpha_{Q2} = 0.5, \alpha_{q} = 0.5]','FontSize',11,'FontWeight','bold','Color','k')
    ylim([0 ceil(round(ESIA.Total,-3)/10000)*10000])
    %ylim([0 12000])
    ytickformat('%g')
    xlim(xwidth)
    xlabel('Year')
    ylabel('Moment (kNm)')
    title(BaseData.PlotTitle)
    legend('Denges < 30 kph','Denges 30-60 kph','Denges > 60 kph')
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

% Optional save of OutInfo (used for deterministic AGB matching)
if strcmp(BaseData.Type,'DWIM')
    
    OutInfo.Name = datestr(now,'mmmdd-yy HHMMSS'); OutInfo.BaseData = BaseData;
    OutInfo.ESIMS = OverMaxT.MaxLE;
    OutInfo.ESIM = OverMaxT.MaxLE*1.3;
    OutInfo.OverMax = OverMax; OutInfo.OverMaxT = OverMaxT;
    OutInfo.InfNames = Inf.Names;
    OutInfo.LaneData = LaneData;
    
    OutInfo.ESIA = []; OutInfo.PlatPct = 0; OutInfo.Mean = []; OutInfo.Std = [];
    
    if BaseData.Save == 1
        save(['Output' BaseData.Folder '/' OutInfo.Name], 'OutInfo')
    end
    
end

MD = mean(D);
OM = max(MD);

Pctile = Revpctile(OutInfo.OverMax(:,Span/10),OM);