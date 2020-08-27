% ------------------------------------------------------------------------
%                            MATSimAxles
% ------------------------------------------------------------------------
% Run real traffic over a bridge to find maximum load effects

% Initial commands
clear, clc, format long g, rng('shuffle'), close all; BaseData = table;

% Input Information --------------------
                      
% Roadway Info
BaseData.LaneDir = {'1,1'};
BaseData.TransILx = 0; BaseData.TransILy = 0; BaseData.LaneCen = 0;
% Traffic Info
Year = 2015;
BaseData.SName = 'Ceneri';
BaseData.StationNum = 1;
BaseData.Stage2Prune = false;
BaseData.ClassOnly = true;
% Influence Line Info
BaseData.ILs = {'Axle'};  
BaseData.ILRes = 0.2;
% Analysis Info
BaseData.RunDyn = 0;
BaseData.MultipleCases = 1;
BaseData.Save = 0; BaseData.Folder = '/Axles';
BaseData.NumAnalyses = 1;

% Input Complete   ---------------------

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
        PDC = Classify(PD);  PDC = Daytype(PDC,Year(i));
        clear('PD')
        
        % We treat each station separately.. SNum is the input for which
        Stations = unique(PDC.ZST);
        Station = Stations(BaseData.StationNum);
        PDCx = PDC(PDC.ZST == Station,:);
        clear('PDC')
        
        % Apercu Title
        BaseData.ApercuTitle = sprintf('%s %s %i %i','NWIM',BaseData.SName,Stations(BaseData.StationNum),Year(i));
        % Plot Title
        BaseData.PlotTitle = sprintf('%s Staion %i Max M+ [Top %i/Year] | 40m Simple Span',BaseData.SName,Stations(BaseData.StationNum),BaseData.NumAnalyses);
        
        % Further trimming if necessary
        if BaseData.Stage2Prune
            PDCx = PruneWIM2(PDCx,0);
        end
        if BaseData.ClassOnly
            PDCx(PDCx.CLASS == 0,:) = [];
        end    
              
        % Convert PDC to AllTrAx (edited space between to be 4 m... still
        % 26 m inside WIMtoAllTrAx to account for Max Length of Veh, must be greater than 0 to actually Spacesave!)
        [PDCx, AllTrAx, TrLineUp] = WIMtoAllTrAx(PDCx,4,Lane.Dir,BaseData.ILRes);
        
        % Round TrLineUp first row, move unrounded to fifth row
        TrLineUp(:,5) = TrLineUp(:,1); TrLineUp(:,1) = round(TrLineUp(:,1)/BaseData.ILRes);
        
        
        % Goal here is to get a sense for Q1 and Q2 as well as q1, and q2
        %
        % We will start with Q1 and Q2, specifically trying to find the %tile of
        % Q1 (in the code a tandem axle of 300 kN each with 1.2 m spacing), and
        % Q2 (200 kN each with 1.2 m spacing, at the same point in the next lane)
        % and the joint probability between. (Note code has alphaQ = 0.9)

        % Write some code to generate a tandem axle combined weight
        % histogram for the critical lane, and then move to conditional
        % probability for the second lane tandems.
        
        % Let's identify TANDEMS in TrLineUp first
        % First calculate space between axles
        TrLineUp(:,6) = [10; diff(TrLineUp(:,5))];
        % Then identify if part of the same vehicle (0s)
        TrLineUp(:,7) = [0; diff(TrLineUp(:,3))];
        % Eligible? Spacing must be < 1.2 and same vehicle (0)
        TrLineUp(:,8) = TrLineUp(:,6) < 2.4 & TrLineUp(:,7) == 0;% & TrLineUp(:,2) > 30;
        % TANDEM if 0 1 0 pattern
        TrLineUp(:,9) = [0; diff(TrLineUp(:,8))];
        TrLineUp(:,10) = [diff(TrLineUp(:,8)); 0]*-1;
        % TANDEMS in 11
        TrLineUp(:,11) = TrLineUp(:,8) == 1 & TrLineUp(:,9) == 1 & TrLineUp(:,10) == 1;
        % AA is first of tandem
        AA = TrLineUp(:,11) == 1;
        % AAA is second
        AAA = [diff(AA); 0];
        Tandem = TrLineUp(AA == 1,2);
        Tandem(:,2) = TrLineUp(AAA == 1,2);
        
        Tandem(:,3) = Tandem(:,1) + Tandem(:,2);
        Dist = Tandem(:,1)./Tandem(:,2);
        %mean(Dist)
        %mean(Tandem(:,1))
        %mean(Tandem(:,2))
        histogram(Tandem(:,3),100,'normalization','pdf')
        %prctile(Tandem(:,3),99)

        TrTyps = [11; 12; 22; 23; 111; 11117; 1127; 12117; 122; 11127; 1128; 1138; 1238];
        TrAxPerGr = [11; 12; 22; 23; 111; 1111; 112; 1211; 122; 1112; 112; 113; 123];
        
        [STaTr,AllAx] = AxleStats(PDCx,TrAxPerGr,TrTyps,BaseData.SName,Year,1);
        %prctile(STaTr{2},99.99)
        
        hold on
        subplot(2,2,2)
        histogram(Tandem(:,3),'BinWidth',2.5,'normalization','pdf')
        
        % Search through AllTrAx
        % If we are using 0.2 m ILRes, add vector in chunks of 12 (2.4 m)
        for j = 1:12
            for m = 0:11
                try
                    L(:,j,m+1) = AllTrAx(j+m:12:end,3);
                catch
                    try
                        L(:,j,m+1) = [AllTrAx(j+m:12:end,3); 0];
                    catch
                        L(:,j,m+1) = [AllTrAx(j+m:12:end,3); 0; 0];
                    end
                end
                %T(m+1) = sum(L(:,:,m+1));
            end
            T(:,j) = sum(L(:,:,j),2);
        end   

        TopM = max(max(T))
        
        % This value, TopM, represents the most force (kN) found in a given
        % 2.4 m strip of the vehicle line up.
        
        
        % NEW IDEAS: 
        % - Apercu the results of TopM (generate BrStInd from AllTrAx index position
        % - Make the IL 2.4m wide (could have the same result?)
        % - Make sure this can be done for all years/locations efficiently
        % - Make plots showing the width taken (0.5-2.4m) and corresponding
        % load (kN or kN/m) it might show jumps where tandems, tridems fit
        % - Do this class only and all... 
        % - Tie the yearly maximums to a return period...
        % - Revisit Prof. B's memo
        % - Always remember that we are limited to 25t - larger getts tossed
        
        
        

        for k = 1:BaseData.NumAnalyses
            
            % Subject Influence Line to Truck Axle Stream
            [MaxLE,SMaxMaxLE,DLF,BrStInd,AxonBr,FirstAxInd,FirstAx] = GetMaxLE(AllTrAx,Inf,BaseData.RunDyn,1);
            % Record Maximums
            OverMax = [OverMax; [1, Year(i), MaxLE, SMaxMaxLE, DLF, BrStInd, FirstAxInd, FirstAx]];
            
            if BaseData.NumAnalyses == 1
                T = Apercu(PDCx,BaseData.ApercuTitle,Inf.x,Inf.v(:,1),BrStInd,TrLineUp,MaxLE/ESIA.Total(1),DLF,Lane.Dir,BaseData.ILRes);
            end
            
            % Delete vehicle entries from TrLineUp for re-analysis
            TrLineUp(TrLineUp(:,1) > BrStInd & TrLineUp(:,1) < BrStInd + Inf.x(end),:) = [];
            % Set Axles to zero in AllTrAx (can't delete because indices are locations)
            AllTrAx(BrStInd:BrStInd + Inf.x(end),:) = 0;
            
        end
    end
end

% Convert Results to Table
OverMaxT = array2table(OverMax,'VariableNames',{'InfCase','Year','MaxLE','SMaxLE','MaxDLF','MaxBrStInd','MaxFirstAxInd','MaxFirstAx'});

% Get ESIA
aQ1 = 0.7; aQ2 = 0.5; aq = 0.5;
% T69 stands for SIA 269
ESIA.T69 = 1.5*(ESIA.EQ(1)*aQ1+ESIA.EQ(2)*aQ2+ESIA.Eq*aq);
% Custom (input number from AGBS results)
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
    legend('Raw Traffic')
end

% % LEFTOVER FROM SMALLQ
% 
% % Smallq: Finding the percentiles of SIA Code Parameters in real traffic
% %
% % Goal here is to get a sense for Q1 and Q2 as well as q1, and q2
% %
% % We will start with Q1 and Q2, specifically trying to find the %tile of 
% % Q1 (in the code a tandem axle of 300 kN each with 1.2 m spacing), and
% % Q2 (200 kN each with 1.2 m spacing, at the same point in the next lane)
% % and the joint probability between.
% 
% % Initial Commands
% clear, clc, close all, format long g
% 
% % Specify total traffic (all years and stations to be analyzed)
% % Station Info incl. station name, number, and year
% Year = 2016:2018;
% BaseData.SName = 'Denges';
% BaseData.StationNum = 1;
% BaseData.LaneDir = {'1,1'};
% BaseData.Stage2Prune = false;
% BaseData.ClassOnly = false;
% 
% 
% 
% 
% 
% % We really need to do something like in MATSimWIM when we place into axle
% % streams... then we need to analyze the streams side-by-side to see the relationship between q1 and q2 
% x = 0;
% M = [];
% Mx = [];
% 
% TrTyps = [11; 12; 22; 23; 111; 11117; 1127; 12117; 122; 11127; 1128; 1138; 1238];
% TrAxPerGr = [11; 12; 22; 23; 111; 1111; 112; 1211; 122; 1112; 112; 113; 123];
% 
% for i = 1:length(Year)
%     
% %     x = x+1;
% %     load(strcat(Station,'_',num2str(i),'.mat'))
% %     
% %     
% %     J = (PD.GW_TOT/102)./(PD.LENTH/100);
% %     M = [M; mean(J) prctile(J,95) prctile(J,99) prctile(J,99.99)];
% %     
% %     
% %     Q = PD.W1_2+PD.W2_3+PD.W3_4+PD.W4_5+PD.W5_6+PD.W6_7+PD.W7_8;
% %     Q = Q + 255;
% %     
% %     Jx = (PD.GW_TOT/102)./(Q/100);
% %     Mx = [Mx; mean(Jx) prctile(Jx,95) prctile(Jx,99) prctile(Jx,99.99)];
%     
%     
% 
% 
%     load(['PrunedS1 WIM/',BaseData.SName,'/',BaseData.SName,'_',num2str(Year(i)),'.mat']);
%     
%     PDC = Classify(PD);
%     PDC = Daytype(PDC,Year(i));
%     clear('PD')
%     
%     % We treat each station separately.. SNum is the input for which
%     Stations = unique(PDC.ZST);
%     Station = Stations(BaseData.StationNum);
%     PDCx = PDC(PDC.ZST == Station,:);
%     clear('PDC')
%     
%     BaseData.ApercuTitle = sprintf('%s %s %i %i',BaseData.Type,BaseData.SName,Stations(BaseData.StationNum),Year(i));
%     % Plot Titles
%     BaseData.PlotTitle = sprintf('%s Staion %i Max M+ [Top %i/Year] | 40m Simple Span',BaseData.SName,Stations(BaseData.StationNum),BaseData.NumAnalyses);
%     
%     % Further trimming if necessary
%     if BaseData.Stage2Prune
%         PDCx = PruneWIM2(PDCx,0);
%     end
%     
%     if BaseData.ClassOnly
%         PDCx(PDCx.CLASS == 0,:) = [];
%     end
%             
%     % Convert PDC to AllTrAx
%     [PDCx, AllTrAx, TrLineUp] = WIMtoAllTrAx(PDCx,round(Inf.x(end)),Lane.Dir,BaseData.ILRes);
%     
%     % Round TrLineUp first row, move unrounded to fifth row
%     TrLineUp(:,5) = TrLineUp(:,1); TrLineUp(:,1) = round(TrLineUp(:,1)/BaseData.ILRes);
%     
%     
%     
%     
%     [x,y] = AxleStats(PDCx,TrAxPerGr,TrTyps,BaseData.SName,Year(i),1);
%     
%     
%         
%     J = (PDC.GW_TOT/102)./(PDC.LENTH/100);
%     M = [M; mean(J) prctile(J,95) prctile(J,99) prctile(J,99.99)];
%     
%     
%     L = PDC.W1_2+PDC.W2_3+PDC.W3_4+PDC.W4_5+PDC.W5_6+PDC.W6_7+PDC.W7_8;
%     L = L + 255;
%     
%     Jx = (PDC.GW_TOT/102)./(L/100);
%     Mx = [Mx; mean(Jx) prctile(Jx,95) prctile(Jx,99) prctile(Jx,99.99)];
%     
%     %PD = PD(PD.ZST == 408,:);
% %     [TotDaysOpen(x), y] = size(unique(PD.JJJJMMTT));
% %     [NumTrucks(x), z] = size(PD);
% %     ADTT(x) = NumTrucks(x)/TotDaysOpen(x);
% %     AvgWeight(x) = mean(PD.GW_TOT);
% %     StdWeight(x) = std(PD.GW_TOT); 
%     
% end
% 
% % x = [StartY:EndY];
% % plot(x,ADTT)
% % 
% % z = [mean(Lane1) mean(Lane2) mean(Lane3) mean(Lane4)];
% % 
% % bar(z)


