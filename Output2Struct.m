% Results2MATStruct
% Takes in the folder name where results are and gives a structure variable
% (often called MAT) which stores the results in a way that is condusive to
% plotting them. You can optionally probe folder to see contents using
% "OutputFolderPeek.m"

clear, clc

% Folder name where results are. Results should be "similar" files
% AGB
%Folder_Name = 'AGB2002f50k';
% Ceneri2017
Folder_Name = 'AGB2018';
% Platoon
%Folder_Name = 'Platoon';

% Structure Name
% AGB and Ceneri2017
Struct_Name = 'MAT';
% Platoon
%Struct_Name = 'PLAT';
RegSpans = true; % Used to tell if the normal sequence of Spans (10-80)

% Number of Vehicles for Bidirectional
% AGB
BiVehNum = 1000000;
% Ceneri2017 and Platoon
%BiVehNum = 25000;

% Ensure file list is succinct
File_List = GetFileList(Folder_Name);
% Initialize ResultsPerRun
ResultsPerRun = 0;
% Read in .mat results variables into a signle OInfo variable
for i = 1:length(File_List)
    load(['Output/' Folder_Name '/' File_List(i).name])
    OInfo(i) = OutInfo;
    % BaseFlag only used in cases of Platooning (but shouldn't be a prob)
    if OInfo(i).BaseData.RunPlat == 0
        BaseFlag = i;
    end
    % Create matrix of just span lengths
    for k = 1:length(OInfo(i).InfNames)
        if RegSpans
            SpanLengths(k) = str2num(OInfo(i).InfNames{k}(end-1:end));
        else % Insert dummy... if we don't have one (change value later)
            SpanLengths(k) = 0;
        end
    end
    % Find the number of unique span lengths
    if length(unique(OInfo(i).InfNames)) > ResultsPerRun
        ResultsPerRun = length(unique(SpanLengths));
    end
end

% Clear OutInfo to avoid confusion (we now use complete OInfo)
clear OutInfo

% Name each column of the final matrix/table in the structure
% AGB
ColumnNames = {'EQ1','EQ2','Eq','GS','GD','MS','MD','DS','DD','DetS','DetD','E'};
% Ceneri2017
%ColumnNames = {'EQ1','EQ2','Eq','TWES','TWED','TWOS','TWOD','FIFS','FIFD','E'};
% Platoon
%ColumnNames = {'BaseMean','BaseMax','SMean','MSMean','MLMean','LMean','SMax','MSMax','MLMax','LMax'};

% AGB and Ceneri2017
if ResultsPerRun == 4
    SpanDiv = 20;
else % Platoon (we only do 20, 40, 60, 80m Spans)
    SpanDiv = 10;
end

% Initialize the final matrix/table
X = NaN(ResultsPerRun,length(ColumnNames));
XT = array2table(X,'VariableNames',ColumnNames);

% Sometimes we may want to load a results variable in order to add to it
%load('AGBMATResults')

% For reference, the form of each variable
%PLAT.(Section).(Dist).(Loc).(PlatSize).(PlatRate).(AE).(IVD)(Span/20)
%MAT.(Section).(Config).(Dist).(AE).(Loc).(Span/10)

% Step through all output files and put them into Structure Variable
for i = 1:length(OInfo)
    
    % Get Section
    if iscell(OInfo(i).BaseData.TransILx)
        if OInfo(i).BaseData.TransILx{:} == '0'
            Section = 'Box';
        elseif strcmp(OInfo(i).BaseData.TransILx{:},'1.5,5.5')
            Section = 'TwinRed';
        elseif strcmp(OInfo(i).BaseData.TransILx{:},'2.5,8.5')
            Section = 'TwinExp';
        elseif strcmp(OInfo(i).BaseData.TransILy{:},'0.9,0.1')
            Section = 'Twin';
        else% strcmp(OInfo(i).BaseData.TransILy{:},'0.7,0.3')
            Section = 'TwinConc';
        end
    else
        Section = 'Box';
    end
    
    % Get Configuration
    if OInfo(i).BaseData.NumVeh == BiVehNum
        Config = 'Bi';
    else
        Config = 'Mo';
    end
    
    % Get Distribution
    if strcmp(OInfo(i).BaseData.LaneTrDistr{:},'50,50')
        Dist = 'Split';
    elseif strcmp(OInfo(i).BaseData.LaneTrDistr{:},'96,4')
        Dist = 'Stand';
    elseif strcmp(OInfo(i).BaseData.LaneTrDistr{:},'100,0')
        Dist = 'ExSlow';
    else
        Dist = 'ExFast';
    end
    
    % Get Location (can use various deciders... customization required here)
    if OInfo(i).BaseData.TrRate == 0.29
        Loc = 'GD';
    elseif OInfo(i).BaseData.TrRate == 0.14
        Loc = 'MD';
    elseif OInfo(i).BaseData.TrRate == 0.07
        Loc = 'DD';
    elseif OInfo(i).BaseData.TrRate == 0.12 % use CD for Ceneri... change this
        Loc = 'xTCD';
    else
        Loc = 'DetD';
    end
    
%     if OInfo(i).BaseData.NumVeh == 20000000
%         Loc = 'TWED';
%     elseif OInfo(i).BaseData.NumVeh == 2000000
%         Loc = 'TWOD';
%     else
%         Loc = 'FIFD';
%     end
    
    % Platoon Specific
    %--------------------------------------------------
    if strcmp(Struct_Name,'PLAT')
        if OInfo(i).BaseData.PlatRate == 0.2
            PlatRate = 'L20';
        elseif OInfo(i).BaseData.PlatRate == 0.4
            PlatRate = 'H40';
        else
            PlatRate = 'Base';
        end
        
        if OInfo(i).BaseData.TrRate == 0.12
            Loc = 'Ceneri2017';
        end
        
        if OInfo(i).BaseData.PlatSize == 2
            PlatSize = 'S2';
        elseif OInfo(i).BaseData.PlatSize == 3
            PlatSize = 'M3';
        elseif  OInfo(i).BaseData.PlatSize == 4
            PlatSize = 'L4';
        else
            PlatSize = 'Base';
        end
        
        if OInfo(i).BaseData.PlatFolDist == 2.5
            PlatFolDist = 'SMean';
        elseif OInfo(i).BaseData.PlatFolDist == 5
            PlatFolDist = 'MSMean';
        elseif  OInfo(i).BaseData.PlatFolDist == 7.5
            PlatFolDist = 'MLMean';
        else
            PlatFolDist = 'LMean';
        end
    end
    
    %--------------------------------------------------
    
    % Assign results of current OInfo to correct region in matrix/table
    % For each InfCase in OInfo
    for k = 1:length(unique(OInfo(i).InfNames))
        % Get InfName (call it Temp)
        % Needed because there are 2 influence lines for each Twin ESIM
        UniqNames = unique(OInfo(i).InfNames,'stable'); % Sorts alphabetically!!!BUG added 'stable'
        
        if RegSpans
            Temp = UniqNames{k}; %Fixed 26.5.20
            % Get Span from InfName
            Span = str2num(Temp(end-1:end));
            % Get Action Effect from InfName
            AE = Temp(1:end-2);
        else
            Span = 10; %b/c SpanDiv will be 10
            AE = UniqNames{k};
        end
        
        % Platoon Specific
        if strcmp(Struct_Name,'PLAT')
            if OInfo(i).BaseData.RunPlat == 1
                
                % Try assigning values directly, catch if table is not yet initialized
                try %PLAT.(Section).(Dist).(Loc).(PlatSize).(PlatRate).(AE).(IVD)(Span/SpanDiv)
                    if istable(PLAT.(Section).(Dist).(Loc).(PlatSize).(PlatRate).(AE))
                        PLAT.(Section).(Dist).(Loc).(PlatSize).(PlatRate).(AE).(PlatFolDist)(Span/SpanDiv) = OInfo(i).Mean(k);
                        PLAT.(Section).(Dist).(Loc).(PlatSize).(PlatRate).(AE).([PlatFolDist(1:end-4) 'Max'])(Span/SpanDiv) = OInfo(i).ESIM(k);
                    end
                catch
                    PLAT.(Section).(Dist).(Loc).(PlatSize).(PlatRate).(AE) = XT;
                    PLAT.(Section).(Dist).(Loc).(PlatSize).(PlatRate).(AE).(PlatFolDist)(Span/SpanDiv) = OInfo(i).Mean(k);
                    PLAT.(Section).(Dist).(Loc).(PlatSize).(PlatRate).(AE).([PlatFolDist(1:end-4) 'Max'])(Span/SpanDiv) = OInfo(i).ESIM(k);
                end
                PLAT.(Section).(Dist).(Loc).(PlatSize).(PlatRate).(AE).BaseMean(Span/SpanDiv) = OInfo(BaseFlag).Mean(k);
                PLAT.(Section).(Dist).(Loc).(PlatSize).(PlatRate).(AE).BaseMax(Span/SpanDiv) = OInfo(BaseFlag).ESIM(k);
            end
            
        elseif strcmp(Struct_Name,'MAT')
            
            % Try assigning values directly, catch if table is not yet initialized
            try
                if istable(MAT.(Section).(Config).(Dist).(AE))
                    MAT.(Section).(Config).(Dist).(AE).(Loc)(Span/SpanDiv) = OInfo(i).ESIM(k);
                    if ~isempty(OInfo(i).ESIMS)
                        MAT.(Section).(Config).(Dist).(AE).([Loc(1:end-1) 'S'])(Span/SpanDiv) = OInfo(i).ESIMS(k);
                    end
                    % Only if it has it
                    if ~isempty(OInfo(i).ESIA)
                        MAT.(Section).(Config).(Dist).(AE).E(Span/SpanDiv) = OInfo(i).ESIA.Total(k);
                        MAT.(Section).(Config).(Dist).(AE).Eq(Span/SpanDiv) = OInfo(i).ESIA.Eq(k);
                        MAT.(Section).(Config).(Dist).(AE).EQ1(Span/SpanDiv) = OInfo(i).ESIA.EQ(1,k);
                        MAT.(Section).(Config).(Dist).(AE).EQ2(Span/SpanDiv) = OInfo(i).ESIA.EQ(2,k);
                    end
                end
            catch
                MAT.(Section).(Config).(Dist).(AE) = XT;
                MAT.(Section).(Config).(Dist).(AE).(Loc)(Span/SpanDiv) = OInfo(i).ESIM(k);
                if ~isempty(OInfo(i).ESIMS)
                    MAT.(Section).(Config).(Dist).(AE).([Loc(1:end-1) 'S'])(Span/SpanDiv) = OInfo(i).ESIMS(k);
                end
                % Only if it has it
                if ~isempty(OInfo(i).ESIA)
                    MAT.(Section).(Config).(Dist).(AE).E(Span/SpanDiv) = OInfo(i).ESIA.Total(k);
                    MAT.(Section).(Config).(Dist).(AE).Eq(Span/SpanDiv) = OInfo(i).ESIA.Eq(k);
                    MAT.(Section).(Config).(Dist).(AE).EQ1(Span/SpanDiv) = OInfo(i).ESIA.EQ(1,k);
                    MAT.(Section).(Config).(Dist).(AE).EQ2(Span/SpanDiv) = OInfo(i).ESIA.EQ(2,k);
                end
            end
        end
    end
end

% User may choose to save the file (they do so manually)
