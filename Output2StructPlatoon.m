% Output2StructPlatoon

clear, clc

% Takes in the folder name(s) where results are and gives a structure variable
% which stores the results in a way that is condusive to plotting them. 
% You can optionally probe folder to see contents using "GenerateInputxls.m"

% NOTE: Simple notation Mn has 90 and 100m spans Mn90 Mn100

% Folder name where results are. Results should be "similar" files
%Folder_Name = 'Platoon';
%Folder_Name{1} = 'Platoon';
%Folder_Name{2} = 'PlatoonTwin';
%Folder_Name{3} = 'PlatoonDenges';
%Folder_Name{4} = 'PlatoonStand';
%Folder_Name{1} = 'PlatoonNoCompact';
%Folder_Name{2} = 'PlatoonNoCompactDenges';
%Folder_Name{1} = 'PlatoonBunch';
Folder_Name{1} = 'PlatoonBunch2';


% We have a thought here.... right now we do 1 single base analysis, and
% one analysis per platooning case. We use the base analysis as the
% denominator for all Platoon Impact Ratios. However - the base analysis is
% not computationally expensive. Therefore, we may as well perform many
% base analyses and take the average. This will reduce scatter in the
% results. We've seen this reduction in scatter in PlatoonConfidence

% The above has been done for 

% Structure Name
Struct_Name = 'PLAT';
% Add to existing Structure (PLATResults)
%load('Results Variables\PLATResultsNoCompact.mat')
%load('Results Variables\Ceneri2017Results.mat')

RegSpans = true; % Used to tell if the normal sequence of Spans (10-80)

% Check if Folder_Name is cell... needed to add as loop
if ~iscell(Folder_Name)
   Folder_NameC{1} = Folder_Name;
else
    Folder_NameC = Folder_Name;
end

% Do for all folders in Folder_NameC
for p = 1:length(Folder_NameC)
    
    % Ensure file list is succinct
    File_List = GetFileList(Folder_NameC{p});
    % Initialize ResultsPerRun
    ResultsPerRun = 4;
    % Initialize BaseFlag Boolean
    BaseFlagx = false(length(File_List),1);
    % Read in .mat results variables into a signle OInfo variable
    for i = 1:length(File_List)
        load(['Output/' Folder_NameC{p} '/' File_List(i).name])
        OInfo(i) = OutInfo;
        % BaseFlagx is a full vector of all files
        if OInfo(i).BaseData.RunPlat == 0
            BaseFlagx(i) = i;
        end
        % Trim if analysis was general, and not just 20:20:80m
        if strcmp(OInfo(i).BaseData.ILs,'V,Mp,Mn')
            % Trim ESIM, Mean, and OverMaxT... to match others
            OInfo(i).ESIM = OInfo(i).ESIM(2:2:24);
            OInfo(i).ESIMS = OInfo(i).ESIMS(2:2:24);
            OInfo(i).Mean = OInfo(i).Mean(2:2:24);
            OInfo(i).Std = OInfo(i).Std(2:2:24);
            OInfo(i).InfNames = OInfo(i).InfNames(2:2:24);
            OInfo(i).OverMax = OInfo(i).OverMax(:,2:2:24);
        end
    end
    
    % Clear OutInfo to avoid confusion (we now use complete OInfo)
    clear OutInfo
    
    % Name each column of the final matrix/table in the structure
    ColumnNames = {'BaseMean','BaseMax','SMean','MSMean','MLMean','LMean','SMax','MSMax','MLMax','LMax'};
    
    % Get Span Divisor
    SpanDiv = 20; % Platoon (we only do 20, 40, 60, 80m Spans)
    
    % Initialize the final matrix/table
    X = NaN(ResultsPerRun,length(ColumnNames));
    XT = array2table(X,'VariableNames',ColumnNames);
    
    % For reference, the form of the variable
    %PLAT.(Section).(Dist).(Loc).(PlatSize).(PlatRate).(AE).(IVD)(Span/20)
    
    % Get Base Inds
    Inds = find(BaseFlagx == true);
    
    % Step through to get averages
    for i = 1:length(File_List)
        for j = 1:size(OInfo(i).OverMax,2)
            b = sort(OInfo(i).OverMax(:,j),'descend');
            %OInfo(i).ESIMx(j) = mean(b(1:10))*1.1;
            
            Fit = lognfit(b);
            pd = makedist('lognormal',"mu",Fit(1),"sigma",Fit(2));
            OInfo(i).ESIMx(j) = icdf(pd,.99)*1.1;
        end
    end
    
    % Take averages from basefiles
    % Normal way (ESIM)
    %BaseRes.ESIM = mean(reshape([OInfo(BaseFlagx).ESIM],12,[]),2);
    % Advanced way (top 10 average)
    BaseRes.ESIM = mean(reshape([OInfo(BaseFlagx).ESIMx],12,[]),2);
    
    BaseRes.Mean = mean(reshape([OInfo(BaseFlagx).Mean],12,[]),2);
    
    % Get Non-Base Inds
    Inds = find(BaseFlagx == false);
    
    % Step through all output files and put them into Structure Variable
    for i = Inds';
        
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
        
        % Platoon Specific
        %--------------------------------------------------
        if OInfo(i).BaseData.PlatRate == 0.2
            PlatRate = 'L20';
        elseif OInfo(i).BaseData.PlatRate == 0.4
            PlatRate = 'H40';
        end
        
        Loc = OInfo(i).BaseData.Traffic{:};
        
        if OInfo(i).BaseData.PlatSize == 2
            PlatSize = 'S2';
        elseif OInfo(i).BaseData.PlatSize == 3
            PlatSize = 'M3';
        elseif  OInfo(i).BaseData.PlatSize == 4
            PlatSize = 'L4';
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
           
            % Try assigning values directly, catch if table is not yet initialized
            try %PLAT.(Section).(Dist).(Loc).(PlatSize).(PlatRate).(AE).(IVD)(Span/SpanDiv)
                if istable(PLAT.(Section).(Dist).(Loc).(PlatSize).(PlatRate).(AE))
                    PLAT.(Section).(Dist).(Loc).(PlatSize).(PlatRate).(AE).(PlatFolDist)(Span/SpanDiv) = OInfo(i).Mean(k);
                    PLAT.(Section).(Dist).(Loc).(PlatSize).(PlatRate).(AE).([PlatFolDist(1:end-4) 'Max'])(Span/SpanDiv) = OInfo(i).ESIMx(k);
                end
            catch
                PLAT.(Section).(Dist).(Loc).(PlatSize).(PlatRate).(AE) = XT;
                PLAT.(Section).(Dist).(Loc).(PlatSize).(PlatRate).(AE).(PlatFolDist)(Span/SpanDiv) = OInfo(i).Mean(k);
                PLAT.(Section).(Dist).(Loc).(PlatSize).(PlatRate).(AE).([PlatFolDist(1:end-4) 'Max'])(Span/SpanDiv) = OInfo(i).ESIMx(k);
            end
            PLAT.(Section).(Dist).(Loc).(PlatSize).(PlatRate).(AE).BaseMean(Span/SpanDiv) = BaseRes.Mean(k);
            PLAT.(Section).(Dist).(Loc).(PlatSize).(PlatRate).(AE).BaseMax(Span/SpanDiv) = BaseRes.ESIM(k);
            
        end
    end
    
    clear OInfo

end

% User may choose to save the file (they do so manually)
