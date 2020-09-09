% ------------------------------------------------------------------------
%                            MATSimAxles
% ------------------------------------------------------------------------
% Explore questions related to axle weights Q1 and Q2

 % Initial commands
clear, clc, format long g, rng('shuffle'), close all; 
warning('off','MATLAB:mir_warning_maybe_uninitialized_temporary')

% Tasks
% - Finish data processing for 2019 and add to AxleCalcs and YearlyMax
% - Allow for parfor if possible (for AxleCalcs) only for one InfDist value
% - Create AxleCalcs from all possible axles of all possible years/stations
% - Fix Classification issue (Class OW >= Class, no rounding effects)
% - Fix Q1Q2Investigation to include final recommendation (notes r there)
% - Gather some Aprcu's for the memo
% - Polish memo (French), and add new results
% - Begin Platooning Paper w/ Normalized Plots
% - Check in on Colin (see Google drive folder and Alain email)
% - Set meetings with EB, RH, and DP
% - Read and incorporate more of EB's memo into mine
% - Do fatigue coding and compare (/reply to) John M.
% - Buy computer
% - Summarize existing traffic model for Isabelle
% - Do baby shopping
% - Coffee Break French
% - Bible Study John 2
% - Run

% Input Information --------------------
                      
% Traffic Info
%Year = 2011:2018; % 2010 WIMEnhanced for Ceneri and Oberburen - obtain 2019 from MAF
Year = 2013;
%SName = {'Ceneri', 'Denges', 'Gotthard', 'Oberburen'};
SName = {'Denges'};

ApercuB = 1;
BDSave = 0; 
BDFolder = '/ClassOWAxles'; % Also try class only... consider class only with special classes as an extra
AxleCalcs = 0;
AxleStatsPlot = 0;
% Influence Line Info
%InfDist = 0.6:0.2:2.6; % Length of area looked at
InfDist = 1.2;%:0.2:2.6;

%         NEW IDEAS: 
%         - Make plots showing the width taken (0.5-2.4m) and corresponding
%         load (kN or kN/m) it might show jumps where tandems, tridems fit
%         - Do this class only and all... 
%         - Tie the yearly maximums to a return period...
%         - Revisit Prof. B's memo
%         - Always remember that we are limited to 25t - larger getts tossed

YearlyMax = [];
%Loc = [];
count = 1;

% For each length of area to be analyzed
% Cannot do AxleCalcs with parfor
for u = 1:length(InfDist)
    
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
    BaseData.MultipleCases = 1;
    BaseData.NumAnalyses = 1;
    
    % Input Complete   ---------------------
    
    % We can observe a phenomenon where including the ClassOW can sometimes
    % decrease the results. This is because of rounding. It increases more
    % than it decreases... a mean of 0.9 % overall. 
    
    % One ideal is to run both Class and ClassOW, and detect if an OW
    % vehicle is involved in the maximum or not. If it is not, the higher
    % from Class and ClassOW should be taken as both Class and ClassOW. If it is, ClassOW
    % will be the higher one, and Class will remain lower.
    
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
                   
                    TrTyps = [11; 12; 22; 23; 111; 11117; 1127; 12117; 122; 11127; 1128; 1138; 1238];
                    TrAxPerGr = [11; 12; 22; 23; 111; 1111; 112; 1211; 122; 1112; 112; 113; 123];
                    Vec = [0 1 2 1 0 0 1 1 2 1 1 0 1];
                    
                    [STaTr,AllAx] = AxleStats(PDCx,TrAxPerGr,TrTyps,[SName{r} ' ' num2str(Station)],Year(i),AxleStatsPlot);
                    
                    STA = [];
                    %Single = struct();
                    STA(1) = cell2struct(TrLineUp(TrLineUp(:,7)==1,2));
                    %Tandem = struct();
                    STA(2) = TrLineUp(TrLineUp(:,9)==1,2) + TrLineUp(circshift(TrLineUp(:,9)==1,1),2);
                    %Tridem = struct();
                    STA(3) = TrLineUp(TrLineUp(:,8)==1,2) + TrLineUp(circshift(TrLineUp(:,8)==1,1),2) + TrLineUp(circshift(TrLineUp(:,8)==1,2),2);
                    STA = STA';
                    
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
                
                OverMax = [];
                BaseData.ApercuTitle = [SName{r} ' ' num2str(Station) ' ' num2str(Year(i)) ' Max'];
                
                % Atm, just one analysis per year stored in YearlyMax
                for k = 1:BaseData.NumAnalyses
                    
                    % Subject Influence Line to Truck Axle Stream
                    [MaxLE,SMaxMaxLE,DLF,BrStInd,AxonBr,FirstAxInd,FirstAx] = GetMaxLE(AllTrAx,Inf,BaseData.RunDyn,1);
                    % Record Maximums
%                     OverMax = [OverMax; [1, Year(i), MaxLE, SMaxMaxLE, DLF, BrStInd, FirstAxInd, FirstAx]];
                    
                    if ApercuB
                        T = Apercu(PDCx,BaseData.ApercuTitle,Inf.x,Inf.v(:,1),BrStInd,TrLineUp,MaxLE/ESIA.Total(1),DLF,Lane.Dir,BaseData.ILRes);
                    end
                    
                    % Consider adding grey strip to Apercu?
                    
%                     % Delete vehicle entries from TrLineUp for re-analysis
%                     TrLineUp(TrLineUp(:,1) > BrStInd & TrLineUp(:,1) < BrStInd + Inf.x(end),:) = [];
%                     % Set Axles to zero in AllTrAx (can't delete because indices are locations)
%                     AllTrAx(BrStInd:BrStInd + Inf.x(end),:) = 0;
                    
                end
                
                YearlyMax = [YearlyMax; [Year(i), Station, round(MaxLE,3), InfDist(u)]];
                %Loc = [Loc; SName{r}];
                
                % Comment if in parfor
%                 if AxleCalcs && u == 1
%                      Axles{count} = STA;
%                      count = count+1;
%                 end   
            end
        end
    end
end

YearlyMax = array2table(YearlyMax,'VariableNames',{'Year', 'Station', 'MaxLE', 'Width'});
%YearlyMax.SName = Loc;
%YearlyMax.Properties.VariableNames = {'SName', 'Year', 'Station', 'MaxLE', 'Width'};
% Optional Save - consider adding location folder... create first?
if BDSave
    save(['Output' BDFolder '/' 'YearlyMaxQSum'], 'YearlyMax')
end

