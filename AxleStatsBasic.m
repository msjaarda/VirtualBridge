% ------------------------------------------------------------------------
%                             AxleStatsBasic
% ------------------------------------------------------------------------
% Assemble All, Simple, Tandem, and Tridem Axles, using geometry, to gain
% information on Q1 and maximum axle loads
% Differs from function AxleStats because it finds axle groups in
% non-classified vehicles. Optional variable save at end (large var)

 % Initial commands
clear, clc, format long g, rng('shuffle'), close all;

% Notes
% - Could add the ability to load and add new years/stations
% - Remember that we are limited to 25t - larger getts tossed by S1Prune
% - Make sure ClassOW is set to true inside Classify.m

% Input Information --------------------
                      
% Traffic Info
Year = 2003:2019;
%Year = 2013;
SName = {'Ceneri', 'Denges', 'Gotthard', 'Oberburen'};
%SName = {'Oberburen'};

% Toggles
AxleStatsT = 0;
AxleStatsPlot = 0;

Stage2Prune = true;
ILRes = 0.2;   % Needed for WIMtoAllTrAx
    
% Input Complete   ---------------------
    
% For each station to be analyzed
for r = 1:length(SName)
        
    if strcmp(SName{r},'Gotthard')
        LaneDir = [1 2];
    else
        LaneDir = [1 1];
    end
    
    % For each year to be analyzed
    for i = 1:length(Year)
        
        % Denges 2010 Missing
        if strcmp(SName{r},'Denges') && Year(i) == 2010
            continue
        else
        
        % Load File
        PD = load(['PrunedS1 WIM/',SName{r},'/',SName{r},'_',num2str(Year(i)),'.mat']);
                
        % Add row for Class, Daytime, and Daycount
        PD = Classify(PD.PD);  PD = Daytype(PD,Year(i));
        
        % Fix Oberburen pre 2006 station naming issue (ZST = 410 both dirs)
        if strcmp(SName{r},'Oberburen') && Year(i) < 2006
            PD.ZST(PD.FS < 3) = 415;
            PD.ZST(PD.ZST == 410) = 416;
        end
        
        % We treat each station separately
        Stations = unique(PD.ZST);
        
        % For each station
        for w = 1:length(Stations)
            
            Station = Stations(w);
            
            PDCx = PD(PD.ZST == Station,:);
            
            % Further trimming if necessary
            if Stage2Prune
                PDCx = PruneWIM2(PDCx,0);
            end
            
            % Convert PDC to AllTrAx (must be greater than 0 to actually Spacesave!
            % The 4 here is strategic... combined with min veh length
            [PDCx, AllTrAx, TrLineUp] = WIMtoAllTrAx(PDCx,4,LaneDir,ILRes);
                       
            % Round TrLineUp first row, move unrounded to fifth row
            TrLineUp(:,5) = TrLineUp(:,1); TrLineUp(:,1) = round(TrLineUp(:,1)/ILRes);
            
            % TrLineUp [       1             2         3        4         5       ]
            %            AllTrAxIndex    AxleValue   Truck#   LaneID  Station(m)
                        
            % Distances refer to distance in front
            
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
            
            % Optional: Verify with AxleStats
            if AxleStatsT
                TrTyps = [11; 12; 22; 23; 111; 11117; 1127; 12117; 122; 11127; 1128; 1138; 1238];
                TrAxPerGr = [11; 12; 22; 23; 111; 1111; 112; 1211; 122; 1112; 112; 113; 123];
                Vec = [0 1 2 1 0 0 1 1 2 1 1 0 1];
                
                [STaTr,AllAx] = AxleStats(PDCx,TrAxPerGr,TrTyps,[SName{r} ' ' num2str(Station)],Year(i),AxleStatsPlot);
            end
            
            % Could add date stamp PDCx.JJJJMMTT(TrLineUp(:,3)) or more...
            % PDCx Index is found in TrLineUp(:,3)
            
            % All [Q Class]
            Axles.([SName{r} num2str(Station)])(Year(i)-2000).All = [TrLineUp(:,2) PDCx.CLASS(TrLineUp(:,3))];
            % Single [Q Class]
            Axles.([SName{r} num2str(Station)])(Year(i)-2000).Single = [TrLineUp(TrLineUp(:,7)==1,2) PDCx.CLASS(TrLineUp(TrLineUp(:,7)==1,3))];
            % Tandem [Total Q1 Q2 Class]
            Axles.([SName{r} num2str(Station)])(Year(i)-2000).Tandem = [(TrLineUp(TrLineUp(:,9)==1,2) + TrLineUp(circshift(TrLineUp(:,9)==1,1),2)) TrLineUp(TrLineUp(:,9)==1,2) TrLineUp(circshift(TrLineUp(:,9)==1,1),2) PDCx.CLASS(TrLineUp(TrLineUp(:,9)==1,3))]; 
            % Tridem [Total Q1 Q2 Q3 Class]
            Axles.([SName{r} num2str(Station)])(Year(i)-2000).Tridem = [(TrLineUp(TrLineUp(:,8)==1,2) + TrLineUp(circshift(TrLineUp(:,8)==1,1),2) + TrLineUp(circshift(TrLineUp(:,8)==1,2),2))  TrLineUp(TrLineUp(:,8)==1,2)  TrLineUp(circshift(TrLineUp(:,8)==1,1),2)  TrLineUp(circshift(TrLineUp(:,8)==1,2),2) PDCx.CLASS(TrLineUp(TrLineUp(:,8)==1,3))]; 
        end    
        end
    end
end

% Saving is manual
%save('WIMAxles', 'Axles')
