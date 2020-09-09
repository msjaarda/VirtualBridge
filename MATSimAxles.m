% ------------------------------------------------------------------------
%                            MATSimAxles
% ------------------------------------------------------------------------
% Explore questions related to axle weights Q1 and Q2

 % Initial commands
clear, clc, format long g, rng('shuffle'), close all; 
warning('off','MATLAB:mir_warning_maybe_uninitialized_temporary')

% NOTES
% - Allow for parfor if possible (for AxleCalcs) only for one InfDist value
% - Create AxleCalcs from all possible axles of all possible years/stations
% - Fix Classification issue (Class OW >= Class, no rounding effects)
% - Fix Q1Q2Investigation to include final recommendation (notes r there)
% - Gather some Aprcu's for the memo
% - Polish memo (French), and add new results
% - Check in on Colin (see Google drive folder and Alain email)
% - Set meetings with EB, RH, and DP
% - Read and incorporate more of EB's memo into mine
% - Always remember that we are limited to 25t - larger getts tossed

% Input Information --------------------
                      
% Traffic Info
Year = 2011:2019; % Also have 2010 WIMEnhanced for Ceneri and Oberburen
%Year = 2015:2016;
SName = {'Ceneri', 'Denges', 'Gotthard', 'Oberburen'};
%SName = {'Denges'};
InfDist = 0.6:0.2:2.6; % Strip width
%InfDist = 1.2;%:0.2:2.6;

ApercuT = 0;
SaveT = 0; 

% All
% Class
% ClassOW

% Initialize variables
YearlyMax = [];

% For each length of area to be analyzed, optional parfor
parfor u = 1:length(InfDist)
    
    % Initialize BaseData (keep inside parfor)
    BaseData = table;
    % Roadway Info
    BaseData.TransILx = 0; BaseData.TransILy = 0; BaseData.LaneCen = 0;
    BaseData.StationNum = 1;
    
    BaseData.Stage2Prune = true;
    ClassOnly = [0 1 1];
    ClassOW = [0 0 1];
    
    BaseData.ILs = {'Axle'};  
    BaseData.ILRes = 0.1;   % Do not change right now
    
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
    
    % Tried to solve this by using ILRes = 0.1... check that it worked then
    % delete these comments (above)
    
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
        StN = floor((max(Inf.x)/BaseData.ILRes)/2);
        Inf.v(:) = 0; Inf.v(StN:StN+InfDist(u)/BaseData.ILRes-1) = 1;
        
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
                
                PDCy = PD(PD.ZST == Station,:);
                
                % Further trimming if necessary
                if BaseData.Stage2Prune
                    PDCy = PruneWIM2(PDCy,0);
                end
                
                for m = 1:3
                    
                    PDCx = PDCy;
                        
                    if ClassOnly(m) == 1
                        PDCx.CLASS(PDCx.CLASS == 119) = 0;
                        PDCx(PDCx.CLASS == 0,:) = [];
                        if ClassOW(m) == 1
                            PDCx.CLASS(PDCx.CLASS > 39 & PDCx.CLASS < 50) = 0;
                            PDCx(PDCx.CLASS == 0,:) = [];
                        end
                    end
                    
                    % Convert PDC to AllTrAx (must be greater than 0 to actually Spacesave! Decide on spacesave... should be < 80 I think)
                    [PDCr, AllTrAx, TrLineUp] = WIMtoAllTrAx(PDCx,4,Lane.Dir,BaseData.ILRes);
                    
                    % Round TrLineUp first row, move unrounded to fifth row
                    TrLineUp(:,5) = TrLineUp(:,1); TrLineUp(:,1) = round(TrLineUp(:,1)/BaseData.ILRes);
                    
                    %OverMax = [];
                    BaseData.ApercuTitle = [SName{r} ' ' num2str(Station) ' ' num2str(Year(i)) ' Max'];
                    
                    % Atm, just one analysis per year stored in YearlyMax
                    for k = 1:BaseData.NumAnalyses
                        
                        % Subject Influence Line to Truck Axle Stream
                        [MaxLE,SMaxMaxLE,DLF,BrStInd,AxonBr,FirstAxInd,FirstAx] = GetMaxLE(AllTrAx,Inf,BaseData.RunDyn,1);
                        % % Record Maximums
                        %OverMax = [OverMax; [1, Year(i), MaxLE, SMaxMaxLE, DLF, BrStInd, FirstAxInd, FirstAx]];
                        
                        if ApercuT
                            T = Apercu(PDCr,BaseData.ApercuTitle,Inf.x,Inf.v(:,1),BrStInd,TrLineUp,MaxLE/ESIA.Total(1),DLF,Lane.Dir,BaseData.ILRes);
                        end
                        
                        % % Delete vehicle entries from TrLineUp for re-analysis
                        %TrLineUp(TrLineUp(:,1) > BrStInd & TrLineUp(:,1) < BrStInd + Inf.x(end),:) = [];
                        % % Set Axles to zero in AllTrAx (can't delete because indices are locations)
                        %AllTrAx(BrStInd:BrStInd + Inf.x(end),:) = 0;
                        
                    end

                    YearlyMax = [YearlyMax; [Year(i), Station, round(MaxLE,3), InfDist(u)]];

                end
                
            end
        end
    end
end

% Add Column for All, Class, ClassOW
YearlyMax = array2table(YearlyMax,'VariableNames',{'Year', 'Station', 'MaxLE', 'Width'});
YearlyMax.ClassT = repmat(["All"; "ClassOW"; "Class"],height(YearlyMax)/3,1);

% Optional Save
if SaveT
    save('YearlyMaxQSum','YearlyMax');
end

% Run Separately... then combine into one

