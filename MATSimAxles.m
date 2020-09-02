% ------------------------------------------------------------------------
%                            MATSimAxles
% ------------------------------------------------------------------------
% Explore questions related to axle weights Q1 and Q2

 % Initial commands
clear, clc, format long g, rng('shuffle'), close all; tic
warning('off','MATLAB:mir_warning_maybe_uninitialized_temporary')

% Input Information --------------------
                      
% Traffic Info
Year = 2011:2018; % 2010 WIMEnhanced for Ceneri and Oberburen - obtain 2019 from MAF
%Year = 2018;
SName = {'Ceneri', 'Denges', 'Gotthard', 'Oberburen'};
%SName = {'Denges'};

ApercuB = 0;
BDSave = 1; 
BDFolder = '/ClassOWAxles'; % Also try class only... consider class only with special classes as an extra
AxleCalcs = 0;
AxleStatsPlot = 0;
% Influence Line Info
InfDist = 0.6:0.2:2.6; % Length of area looked at
%InfDist = 2.4;%:0.2:2.6;

%         NEW IDEAS: 
%         - Make plots showing the width taken (0.5-2.4m) and corresponding
%         load (kN or kN/m) it might show jumps where tandems, tridems fit
%         - Do this class only and all... 
%         - Tie the yearly maximums to a return period...
%         - Revisit Prof. B's memo
%         - Always remember that we are limited to 25t - larger getts tossed

YearlyMax = [];
%Loc = [];
%count = 1;

% For each length of area to be analyzed
% Cannot do AxleCalcs with parfor
parfor u = 1:length(InfDist)
    
    BaseData = table;
    % Roadway Info
    BaseData.TransILx = 0; BaseData.TransILy = 0; BaseData.LaneCen = 0;
    BaseData.StationNum = 1;
    BaseData.Stage2Prune = true;
    BaseData.ClassOnly = true;
    BaseData.ILs = {'Axle'};  
    BaseData.ILRes = 0.2;   % Do not change right now
    % Analysis Info
    BaseData.RunDyn = 0;
    BaseData.NumAnalyses = 0;
    
    % Input Complete   ---------------------
    
    % For each station to be analyzed
    for r = 1:length(SName)
        
        if strcmp(SName{r},'Gotthard')
            BaseData.LaneDir = {'1,2'};
        else
            BaseData.LaneDir = {'1,1'};
        end
        
        % Obtain Influence Line Info
        [NLanes,Lane,LaneData,~,~] = UpdateData(BaseData,[],1,1);
        [Inf,NInfCases,Inf.x,Inf.v,ESIA] = GetInfLines(LaneData,BaseData,NLanes);
        % Modify IL according to area to be analyzed
        Inf.v(:) = 0; Inf.v(94:94+InfDist(u)/0.2-1) = 1;
        
        % For each year to be analyzed
        for i = 1:length(Year)
            
            % Load File
            PD = load(['PrunedS1 WIM/',SName{r},'/',SName{r},'_',num2str(Year(i)),'.mat']);
            
            % Add row for Class, Daytime, and Daycount
            PD = Classify(PD.PD);  PD = Daytype(PD,Year(i));
            
            % We treat each station separately..
            Stations = unique(PD.ZST);
        
            % For each station
            for w = 1:length(Stations)
                
                Station = Stations(w);
                
                PDCx = PD(PD.ZST == Station,:);
        
                % Further trimming if necessary
                if BaseData.Stage2Prune
                    PDCx = PruneWIM2(PDCx,0);
                end
                if BaseData.ClassOnly
                    PDCx(PDCx.CLASS == 0,:) = [];
                end
                
                % Convert PDC to AllTrAx (must be greater than 0 to actually Spacesave! Decide on spacesave... should be < 80 I think)
                [PDCx, AllTrAx, TrLineUp] = WIMtoAllTrAx(PDCx,4,Lane.Dir,BaseData.ILRes);
                
                % Round TrLineUp first row, move unrounded to fifth row
                TrLineUp(:,5) = TrLineUp(:,1); TrLineUp(:,1) = round(TrLineUp(:,1)/BaseData.ILRes);
                
                % Axle calculations are optional
                if AxleCalcs

                    % TrLineUp [       1             2         3        4         5       ]
                    %            AllTrAxIndex    AxleValue   Truck#   LaneID  Station(m)
                    
                    % Distance in front
                    
                    TrTyps = [11; 12; 22; 23; 111; 11117; 1127; 12117; 122; 11127; 1128; 1138; 1238];
                    TrAxPerGr = [11; 12; 22; 23; 111; 1111; 112; 1211; 122; 1112; 112; 113; 123];
                    Vec = [0 1 2 1 0 0 1 1 2 1 1 0 1];
                    
                    %[STaTr,AllAx] = AxleStats(PDCx,TrAxPerGr,TrTyps,[SName{r} ' ' num2str(Station)],Year(i),AxleStatsPlot);
                    %clear STAx
                    %STAx = STaTr';
                    
         
                    % Treat the lanes separately
                    Lanes = unique(PDCx.FS);
                    for p = 1:length(Lanes)
                        % LaneB is lane boolean
                        LaneB = TrLineUp(:,4) == Lanes(p);
                        TrLineUp(LaneB,6) = [10; diff(TrLineUp(LaneB,5))];
                        % 7th column is Single Axles [ >= 2.4m infront and behind ]
                        TrLineUp(LaneB,7) = (TrLineUp(LaneB,6) >= 2.4 & circshift(TrLineUp(LaneB,6),-1) >= 2.4) | (circshift(TrLineUp(LaneB,3),1) ~= TrLineUp(LaneB,3) & circshift(TrLineUp(LaneB,6),-1) >= 2.4)...
                            | (circshift(TrLineUp(LaneB,3),-1) ~= TrLineUp(LaneB,3) & TrLineUp(LaneB,6) >= 2.4);
                        % 8th column is Tridem Axles
                        %                       cannot be single            cannot begin before the third axle                       first gap less than 2.4               second gap less than 2.4            third gap larger than 2.4
                        TrLineUp(LaneB,8) = TrLineUp(LaneB,7) == 0 & circshift(TrLineUp(LaneB,3),2) == TrLineUp(LaneB,3) & circshift(TrLineUp(LaneB,6),-1) < 2.4 & circshift(TrLineUp(LaneB,6),-2) < 2.4 & circshift(TrLineUp(LaneB,6),-3) >= 2.4;
                    end
        
                    % Set the 7th column to 3 whenever we have a tridem
                    TrLineUp(TrLineUp(:,8)==1,7) = 3;
                    TrLineUp(circshift(TrLineUp(:,8)==1,1),7) = 3;
                    TrLineUp(circshift(TrLineUp(:,8)==1,2),7) = 3;
                    
                    for p = 1:length(Lanes)
                        % LaneB is lane boolean
                        LaneB = TrLineUp(:,4) == Lanes(p);
                        % 9th column is Tandem Axles
                        %                cannot be single or tridem  neither can the following one                      gap less than 2.4         gap infront larger than 2         second gap larger than 2
                        TrLineUp(LaneB,9) = TrLineUp(LaneB,7) == 0 & circshift(TrLineUp(LaneB,7),-1) == 0 & circshift(TrLineUp(LaneB,6),-1) < 2.4 & TrLineUp(LaneB,6) >= 2;% & circshift(TrLineUp(LaneB,6),-2) >= 1.2;
                    end
                    
                    % Clean up 3 in a rows
                    TrLineUp(TrLineUp(:,9) == 1 & circshift(TrLineUp(:,9),-1) == 1 & circshift(TrLineUp(:,9),1) == 1,9) = 0;
                    
                    % Set the 7th column to 2 whenever we have a tandem
                    TrLineUp(TrLineUp(:,9)==1,7) = 2;
                    TrLineUp(circshift(TrLineUp(:,9)==1,1),7) = 2;
                   

                    
                    %clear STA;
                    %Single = struct();
                    %STA{1} = TrLineUp(TrLineUp(:,7)==1,2);
                    %Tandem = struct();
                    %STA{2} = TrLineUp(TrLineUp(:,9)==1,2) + TrLineUp(circshift(TrLineUp(:,9)==1,1),2);
                    %Tridem = struct();
                    %STA{3} = TrLineUp(TrLineUp(:,8)==1,2) + TrLineUp(circshift(TrLineUp(:,8)==1,1),2) + TrLineUp(circshift(TrLineUp(:,8)==1,2),2);
                    %STA = STA';
%                     toc
                    % Checks
%                     sum(TrLineUp(:,7)==1)/length(STaTr{1});
%                     (sum(TrLineUp(:,7)==2)./2)/length(STaTr{2});
%                     (sum(TrLineUp(:,7)==3)./3)/length(STaTr{3});
%                     sum(TrLineUp(:,7)==2)./2;
%                     sum(TrLineUp(:,9));
%                     
%                     Optional Plots
%                     hold on
%                     subplot(2,2,1)
%                     histogram(STA{1},'BinWidth',2.5,'normalization','pdf','FaceAlpha',0.4)
%                     subplot(2,2,2)
%                     histogram(STA{2},'BinWidth',2.5,'normalization','pdf','FaceAlpha',0.4)
%                     subplot(2,2,3)
%                     histogram(STA{3},'BinWidth',2.5,'normalization','pdf','FaceAlpha',0.4)
%                     subplot(2,2,4)
%                     histogram(TrLineUp(:,2),'BinWidth',1.5,'normalization','pdf','FaceAlpha',0.4)
%                     
%                     prctile(STA{1},99.99);
%                     prctile(STA{2},99.99);
%                     prctile(STA{3},99.99);

     
                end
                
%                 OverMax = [];
%                 BaseData.ApercuTitle = [SName{r} ' ' num2str(Station) ' ' num2str(Year(i)) ' Max'];
                
                % Atm, just one analysis per year stored in YearlyMax
                for k = 1:BaseData.NumAnalyses
                    
                    % Subject Influence Line to Truck Axle Stream
                    [MaxLE,SMaxMaxLE,DLF,BrStInd,AxonBr,FirstAxInd,FirstAx] = GetMaxLE(AllTrAx,Inf,BaseData.RunDyn,1);
                    % Record Maximums
%                     OverMax = [OverMax; [1, Year(i), MaxLE, SMaxMaxLE, DLF, BrStInd, FirstAxInd, FirstAx]];
                    
                    if ApercuB
                        %T = Apercu(PDCx,BaseData.ApercuTitle,Inf.x,Inf.v(:,1),BrStInd,TrLineUp,MaxLE/ESIA.Total(1),DLF,Lane.Dir,BaseData.ILRes);
                    end
                    
%                     % Delete vehicle entries from TrLineUp for re-analysis
%                     TrLineUp(TrLineUp(:,1) > BrStInd & TrLineUp(:,1) < BrStInd + Inf.x(end),:) = [];
%                     % Set Axles to zero in AllTrAx (can't delete because indices are locations)
%                     AllTrAx(BrStInd:BrStInd + Inf.x(end),:) = 0;
                    
                end
                
                YearlyMax = [YearlyMax; [Year(i), Station, round(MaxLE,3), InfDist(u)]];
                %Loc = [Loc; SName{r}];
                
                % Comment if in parfor
                if AxleCalcs && u == 1
                     %Axles{count} = STA;
                     % Compare Axlesx to previous
                     %Axlesx{count} = STAx;
                     %count = count+1;
                end   
            end
        end
    end
end

% Should we do axles from all locations?! no reason not to add all, as far
% as I can tell

YearlyMax = array2table(YearlyMax,'VariableNames',{'Year', 'Station', 'MaxLE', 'Width'});

%YearlyMax.SName = Loc;
%YearlyMax.Properties.VariableNames = {'SName', 'Year', 'Station', 'MaxLE', 'Width'};
% Optional Save - consider adding location folder... create first?
if BDSave
    save(['Output' BDFolder '/' 'YearlyMaxQSum'], 'YearlyMax')
end







% LEGACY

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


% % 
% %         Search through AllTrAx... DOESN"T QUITE WORK... MAY AS WELL USE
% %         MAXLE
% %         If we are using 0.2 m ILRes, add vector in chunks of 12 (2.4 m)
% %         for j = 1:12
% %             for m = 0:11
% %                 try
% %                     L(:,j,m+1) = AllTrAx(j+m:12:end,3);
% %                 catch
% %                     try
% %                         L(:,j,m+1) = [AllTrAx(j+m:12:end,3); 0];
% %                     catch
% %                         L(:,j,m+1) = [AllTrAx(j+m:12:end,3); 0; 0];
% %                     end
% %                 end
% %             end
% %             Tx(:,j) = sum(L(:,:,j),2);
% %         end   
% %         
% %         [a, b] = max(Tx);
% %         [TopM, d] = max(a);
% %         b(d);
% %         L(b(d),:,d);
% %         
% %         AllTrAx(b(d)*12:b(d)*12+10,:);
% %         INDs = find(AllTrAx(b(d)*12:b(d)*12+10,3)>0);
% %  
% %         TrLineUp(TrLineUp(:,1) == b(d)*12+INDs(1)-1,:);
% %         INDs2 = find(TrLineUp(:,1) == b(d)*12+INDs(1)-1);
% %         
% %         PDCx(TrLineUp(INDs2,3)-1:TrLineUp(INDs2,3)+1,:);
% %         
% %         TrLineUp(TrLineUp(:,1) == b(d)*12+INDs(2)-1,:);
% %         find(TrLineUp(:,1) == b(d)*12+INDs(2)-1);
% % 
% %         
% %         clear L
% %         clear Tx
% % %         This value, TopM, represents the most force (kN) found in a given
% % %         2.4 m strip of the vehicle line up.


