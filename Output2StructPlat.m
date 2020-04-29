%Results2MATStruct

clear, clc

Folder_Name = 'Platoon';

% Ensure file list is succinct
File_List = GetFileList(Folder_Name);

% Read in .mat results variables
for i = 1:length(File_List)
    load(['Output/' Folder_Name '/' File_List(i).name])
    OInfo(i) = OutInfo;
    if OInfo(i).BaseData.RunPlat == 0
        BaseFlag = i;
    end
end

clear OutInfo

%PLAT.(Section).(Dist).(Loc).(PlatSize).(PlatRate).(AE).(IVD)(Span/20)

% Initialize
X = NaN(4,10);
XT = array2table(X,'VariableNames',{'BaseMean','BaseMax','SMean','MSMean','MLMean','LMean','SMax','MSMax','MLMax','LMax'});
SectionInfo = cell(length(OInfo),1);
PlatSizeInfo = cell(length(OInfo),1);
PlatRateInfo = cell(length(OInfo),1);
DistInfo = cell(length(OInfo),1);
LocInfo = cell(length(OInfo),1);
ILsInfo = cell(length(OInfo),1);

%load('AGBMATResults')

SumTab = struct2table(File_List);
SumTab(:,2:end) = [];
SumTab.Properties.VariableNames{'name'} = 'FName';
SumTab2 = [];

% Step through all output files and put them into PLAT struct
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
 
    if OInfo(i).BaseData.PlatRate == 0.2
        PlatRatex = 'L20';
    elseif OInfo(i).BaseData.PlatRate == 0.4
        PlatRatex = 'H40';
    else
        PlatRatex = 'Base';
        
    end
    
    if strcmp(OInfo(i).BaseData.LaneTrDistr{:},'50,50')
        Distx = 'Split';
    elseif strcmp(OInfo(i).BaseData.LaneTrDistr{:},'90,0')
        Distx = 'Stand';
    elseif strcmp(OInfo(i).BaseData.LaneTrDistr{:},'80,20')
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
        Locx = 'Ceneri2017';
    else
        Locx = 'DetD';
    end
    
    if OInfo(i).BaseData.PlatSize == 2
        PlatSizex = 'S2';
    elseif OInfo(i).BaseData.PlatSize == 3
        PlatSizex = 'M3';
    elseif  OInfo(i).BaseData.PlatSize == 4
        PlatSizex = 'L4';
    else
        PlatSizex = 'Base';
    end
    
    if OInfo(i).BaseData.PlatFolDist == 2.5
        PlatFolDistx = 'SMean';
    elseif OInfo(i).BaseData.PlatFolDist == 5
        PlatFolDistx = 'MSMean';
    elseif  OInfo(i).BaseData.PlatFolDist == 7.5
        PlatFolDistx = 'MLMean';
    else
        PlatFolDistx = 'LMean';
    end
    
    % For each influence line
    for k = 1:length(OInfo(i).ESIM)
        if OInfo(i).BaseData.RunPlat == 1
            if strcmp(Sectionx,'Box')
                Temp = OInfo(i).InfNames{k};
            else % Had to add because there are 2 influence lines for each Twin ESIM
                Temp = OInfo(i).InfNames{2*k};
            end
            Span = str2num(Temp(end-1:end));
            AEx = Temp(1:end-2);
            try %PLAT.(Section).(Dist).(Loc).(PlatSize).(PlatRate).(AE).(IVD)(Span/20)
                if istable(PLAT.(Sectionx).(Distx).(Locx).(PlatSizex).(PlatRatex).(AEx))
                    PLAT.(Sectionx).(Distx).(Locx).(PlatSizex).(PlatRatex).(AEx).(PlatFolDistx)(Span/20) = OInfo(i).Mean(k);
                    PLAT.(Sectionx).(Distx).(Locx).(PlatSizex).(PlatRatex).(AEx).([PlatFolDistx(1:end-4) 'Max'])(Span/20) = OInfo(i).Mean(k);
                end
            catch
                PLAT.(Sectionx).(Distx).(Locx).(PlatSizex).(PlatRatex).(AEx) = XT;
                PLAT.(Sectionx).(Distx).(Locx).(PlatSizex).(PlatRatex).(AEx).(PlatFolDistx)(Span/20) = OInfo(i).Mean(k);
                PLAT.(Sectionx).(Distx).(Locx).(PlatSizex).(PlatRatex).(AEx).([PlatFolDistx(1:end-4) 'Max'])(Span/20) = OInfo(i).Mean(k);
            end
            PLAT.(Sectionx).(Distx).(Locx).(PlatSizex).(PlatRatex).(AEx).BaseMean(Span/20) = OInfo(BaseFlag).Mean(k);
            PLAT.(Sectionx).(Distx).(Locx).(PlatSizex).(PlatRatex).(AEx).BaseMax(Span/20) = OInfo(BaseFlag).ESIM(k);
        end
    end
    
    
end


SectionInfo{i} = Sectionx;
DistInfo{i} = Distx;

try
    LocInfo{i} = OInfo(i).BaseData.Traffic{:};
catch
    LocInfo{i} = OInfo(i).BaseData.Type;
end
ILsInfo{i} = OInfo(i).BaseData.ILs{:};



SumTab.Section = SectionInfo;
SumTab.Dist = DistInfo;
SumTab.Loc = LocInfo;
SumTab.ILs = ILsInfo;


SumTab;