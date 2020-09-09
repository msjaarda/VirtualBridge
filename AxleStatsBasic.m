% ------------------------------------------------------------------------
%                             AxleStatsBasic
% ------------------------------------------------------------------------
% Assemble Simple, Tandem, and Tridem Axles, using geometry, to gain
% information on Q1 and maximum axle loads
% Differs from function AxleStats because it finds axle groups in
% non-classified vehicles.

 % Initial commands
clear, clc, format long g, rng('shuffle'), close all;

% Tasks
% - Create AxleCalcs from all possible axles of all possible years/stations
% - Fix Q1Q2Investigation to include final recommendation (notes r there)
% - Always remember that we are limited to 25t - larger getts tossed

% Input Information --------------------
                      
% Traffic Info
%Year = 2011:2018;
Year = 2013;
%SName = {'Ceneri', 'Denges', 'Gotthard', 'Oberburen'};
SName = {'Denges'};

BDSave = 0; 
BDFolder = '/ClassOWAxles'; % Also try class only... consider class only w/ special classes as an extra
AxleStatsPlot = 0;

%Loc = [];
count = 1;

BaseData = table;
% Roadway Info
BaseData.TransILx = 0; BaseData.TransILy = 0; BaseData.LaneCen = 0;
BaseData.StationNum = 1;
BaseData.Stage2Prune = true;
BaseData.ClassOnly = true;
BaseData.ClassOW = true;
BaseData.ILs = {'Axle'};
BaseData.ILRes = 0.2;   % Do not change right now
% Analysis Info
BaseData.RunDyn = 0;
BaseData.MultipleCases = 1;
BaseData.NumAnalyses = 1;
    
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
        
        % We treat each station separately
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
                if ~BaseData.ClassOW
                    PDC.CLASS(PDC.CLASS > 39 & PDC.CLASS < 50) = 0; 
                    PDC.CLASS(PDC.CLASS == 119) = 0;
                end
            end
            
            % Convert PDC to AllTrAx (must be greater than 0 to actually Spacesave! Decide on spacesave... should be < 80 I think)
            [PDCx, AllTrAx, TrLineUp] = WIMtoAllTrAx(PDCx,4,Lane.Dir,BaseData.ILRes);
            
            % Round TrLineUp first row, move unrounded to fifth row
            TrLineUp(:,5) = TrLineUp(:,1); TrLineUp(:,1) = round(TrLineUp(:,1)/BaseData.ILRes);
            
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
           
            Axles{count} = STA;
            count = count+1;
        end
    end
end

if BDSave
    save(['Output' BDFolder '/' 'YearlyMaxQSum'], 'YearlyMax')
end
