function [BaseData,LaneData,TrData,FolDist] = VBReadInputFile(InputFile)
% Reads VBInput and returns main variables (Tables)
% Input can be Simple or Complete
% BaseData must be included in the InputFile.

% Simple Input: LaneData, TrData, and FolDist are included in BaseData
% and are retreived in the UpdateData function. Here they are
% assigned null values.

% Complete Input: LaneData, TrData, and FolDist are included in the InputFile.
% TrData is comprised of TrDistr and all other Tr options. If TrDistr is
% included, all other Tr options must be included.

% A combination of Simple and Complete is tolerated (Simple LaneData and
% Complete TrData and FolDist input, for example.

% Get all sheetNames in InputFile
[~, sheetNames] = xlsfinfo(InputFile);
% Get number of sheets
NumSheets = length(sheetNames);

% Convert sheetNames from Cell Array (sheetNames) to String Array (names)
% Initialize names
names = strings(size(sheetNames));
% Populate names
[names{:}] = sheetNames{:};

% Overwrite sheetNames to be the actual tabular data in each sheet
for i = 1:NumSheets
    sheetNames{i} = readtable(InputFile,'Sheet',names(i));
end



% BaseData is always required, so we do not check if it exists first
BaseData = sheetNames{strcmp(names,'BaseData')};

if ~ismember('InfSurf', BaseData.Properties.VariableNames)
    BaseData.InfSurf(:) = 0;
end
if ~ismember('PlatRate', BaseData.Properties.VariableNames)
    BaseData.PlatRate(:) = 0;
end
if ~ismember('RunPlat', BaseData.Properties.VariableNames)
    BaseData.RunPlat(:) = 0;
end
if ~ismember('PlatFolDist', BaseData.Properties.VariableNames)
    BaseData.PlatFolDist(:) = 0;
end
% Folder is optional, but when not included (or when given as 0), must be '/'
if ismember('Folder', BaseData.Properties.VariableNames)
    if iscell(BaseData.Folder)
        for i = 1:height(BaseData)
            if isempty(findstr('/',BaseData.Folder{i}))
                if length(BaseData.Folder{i}) > 1
                    BaseData.Folder{i} = ['/' BaseData.Folder{i}];
                else
                    BaseData.Folder{i} = ['/'];
                end
            end
        end
    else
        % This '/' is given so that the filepath still reads correctly with no folder
        clear BaseData.Folder
        BaseData.Folder = cell(height(BaseData),1);
        BaseData.Folder(:) = {'/'};
    end
else
    % This '/' is given so that the filepath still reads correctly with no folder
    clear BaseData.Folder
    BaseData.Folder = cell(height(BaseData),1);
    BaseData.Folder(:) = {'/'};
end

% Get LaneData from sheet if it exists
if sum(strcmp(names,'LaneData')) > 0
    LaneData = sheetNames{strcmp(names,'LaneData')};
else
    % Assign null value it if doesn't
    LaneData = [];
end

% TrData is formed from TrDistr and all other Tr options
% Get TrData from sheet if it exists (TrDistr is the flag... it is all or none)
if sum(strcmp(names,'TrDistr')) > 0
    TrData.TrDistr = sheetNames{strcmp(names,'TrDistr')};
    TrData.TrLinFit = sheetNames{strcmp(names,'TrLinFit')};
    TrData.TrAllo = sheetNames{strcmp(names,'TrAllo')};
    TrData.TrBetAx = sheetNames{strcmp(names,'TrBetAx')};
    TrData.TrWitAx = sheetNames{strcmp(names,'TrWitAx')};
else
    % Assign null value it if doesn't
    TrData = [];
end

% Get FolDist from sheet if it exists
if sum(strcmp(names,'FolDist')) > 0
    FolDist = sheetNames{strcmp(names,'FolDist')};
else
    % Assign null value it if doesn't
    FolDist = [];
end

warning('off','MATLAB:mir_warning_maybe_uninitialized_temporary')

end

