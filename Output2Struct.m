%Results2MATStruct

clear, clc

Folder_Name = 'AGB2002';
% Add cols CD and CS for Ceneri... load old mat file

% Ensure file list is succinct
File_List = GetFileList(Folder_Name);

% Read in .mat results variables
for i = 1:length(File_List)
    load(['Output/' Folder_Name '/' File_List(i).name])
    OInfo(i) = OutInfo;
end

clear OutInfo

% Initialize
X = NaN(8,12);
XT = array2table(X,'VariableNames',{'EQ1','EQ2','Eq','GS','GD','MS','MD','DS','DD','DetS','DetD','E'});
SectionInfo = cell(length(OInfo),1);
ConfigInfo = cell(length(OInfo),1);
DistInfo = cell(length(OInfo),1);
LocInfo = cell(length(OInfo),1);
ILsInfo = cell(length(OInfo),1);

% Added after for MC... could remove
load('AGBMATResultsxx')

SumTab = struct2table(File_List);
SumTab(:,2:end) = [];
SumTab.Properties.VariableNames{'name'} = 'FName';
SumTab2 = [];

% Step through all output files and put them into MAT struct
for i = 1:length(OInfo)
    
    if iscell(OInfo(i).BaseData.TransILx)
        if OInfo(i).BaseData.TransILx{:} == '0'
            Sectionx = 'Box';
        elseif strcmp(OInfo(i).BaseData.TransILx{:},'1.5,5.5')
            Sectionx = 'TwinRed';
        elseif strcmp(OInfo(i).BaseData.TransILx{:},'2.5,8.5')
            Sectionx = 'TwinExp';
        elseif strcmp(OInfo(i).BaseData.TransILy{:},'0.9,0.1')
            Sectionx = 'Twin';
        else% strcmp(OInfo(i).BaseData.TransILy{:},'0.7,0.3')
            Sectionx = 'TwinConc';
        end
    else
        Sectionx = 'Box';
    end
    
    % Change back to 1000000
    if OInfo(i).BaseData.NumVeh == 1000000
        Configx = 'Bi';
    else
        Configx = 'Mo';
    end
    
    if strcmp(OInfo(i).BaseData.LaneTrDistr{:},'50,50')
        Distx = 'Split';
    elseif strcmp(OInfo(i).BaseData.LaneTrDistr{:},'96,4')
        Distx = 'Stand';
    elseif strcmp(OInfo(i).BaseData.LaneTrDistr{:},'85,15')
        Distx = 'ExFast';
    else
        Distx = 'ExSlow';
    end
    
    if OInfo(i).BaseData.TrRate == 0.29
        Locx = 'GD';
    elseif OInfo(i).BaseData.TrRate == 0.14
        Locx = 'MD';
    elseif OInfo(i).BaseData.TrRate == 0.07
        Locx = 'DD';
    elseif OInfo(i).BaseData.TrRate == 0.12 % use CD for Ceneri... change this
        Locx = 'xTCD';
    else
        Locx = 'DetD';
    end
    
    for k = 1:length(OInfo(i).ESIM)
        if strcmp(Sectionx,'Box')
            Temp = OInfo(i).InfNames{k};
        else % Had to add because there are 2 influence lines for each Twin ESIM
            Temp = OInfo(i).InfNames{2*k};
        end
        Span = str2num(Temp(end-1:end));
        AEx = Temp(1:end-2);
        try
            if istable(MAT.(Sectionx).(Configx).(Distx).(AEx))
                MAT.(Sectionx).(Configx).(Distx).(AEx).(Locx)(Span/10) = OInfo(i).ESIM(k);
                if ~isempty(OInfo(i).ESIMS)
                    MAT.(Sectionx).(Configx).(Distx).(AEx).([Locx(1:end-1) 'S'])(Span/10) = OInfo(i).ESIMS(k);
                end
                % Only if it has it
                if ~isempty(OInfo(i).ESIA)
                    MAT.(Sectionx).(Configx).(Distx).(AEx).E(Span/10) = OInfo(i).ESIA.Total(k);
                    MAT.(Sectionx).(Configx).(Distx).(AEx).Eq(Span/10) = OInfo(i).ESIA.Eq(k);
                    MAT.(Sectionx).(Configx).(Distx).(AEx).EQ1(Span/10) = OInfo(i).ESIA.EQ(1,k);
                    MAT.(Sectionx).(Configx).(Distx).(AEx).EQ2(Span/10) = OInfo(i).ESIA.EQ(2,k);
                end
            end
        catch
            MAT.(Sectionx).(Configx).(Distx).(AEx) = XT;
            MAT.(Sectionx).(Configx).(Distx).(AEx).(Locx)(Span/10) = OInfo(i).ESIM(k);
            if ~isempty(OInfo(i).ESIMS)
                MAT.(Sectionx).(Configx).(Distx).(AEx).([Locx(1:end-1) 'S'])(Span/10) = OInfo(i).ESIMS(k);
            end
            % Only if it has it
            if ~isempty(OInfo(i).ESIA)
                MAT.(Sectionx).(Configx).(Distx).(AEx).E(Span/10) = OInfo(i).ESIA.Total(k);
                MAT.(Sectionx).(Configx).(Distx).(AEx).Eq(Span/10) = OInfo(i).ESIA.Eq(k);
                MAT.(Sectionx).(Configx).(Distx).(AEx).EQ1(Span/10) = OInfo(i).ESIA.EQ(1,k);
                MAT.(Sectionx).(Configx).(Distx).(AEx).EQ2(Span/10) = OInfo(i).ESIA.EQ(2,k);
            end
        end
    end
    
    
end


SectionInfo{i} = Sectionx;
ConfigInfo{i} = Configx;
DistInfo{i} = Distx;
try
    LocInfo{i} = OInfo(i).BaseData.Traffic{:};
catch
    LocInfo{i} = OInfo(i).BaseData.Type;
end
ILsInfo{i} = OInfo(i).BaseData.ILs{:};



SumTab.Section = SectionInfo;
SumTab.Config = ConfigInfo;
SumTab.Dist = DistInfo;
SumTab.Loc = LocInfo;
SumTab.ILs = ILsInfo;


SumTab;