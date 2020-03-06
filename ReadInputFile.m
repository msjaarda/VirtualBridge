function [BaseData,LaneData,TrData,FolDist] = ReadInputFile(InputFile)
%READINPUTFILE Reads MATSimInput, and returns variables
% Must recognize if input method is simple, or complex.
% User has the choice for each spreadsheet tab
%    LaneData
%    TrData
%    FolDist 

% Get all sheetNames in InputFile
[~, sheetNames] = xlsfinfo(InputFile);

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

% BaseData is always required
BaseData = sheetNames{strcmp(names,'BaseData')};

% Get LaneData from sheet if it exists
if sum(strcmp(names,'LaneData')) > 0
    LaneData = sheetNames{strcmp(names,'LaneData')};
else
    LaneData = [];
end

% Get TrData from sheet if it exists (TrDistr is the flag... it is all or none)
if sum(strcmp(names,'TrDistr')) > 0
    TrData.TrDistr = sheetNames{strcmp(names,'TrDistr')};
    TrData.TrLinFit = sheetNames{strcmp(names,'TrLinFit')};
    TrData.TrAllo = sheetNames{strcmp(names,'TrAllo')};
    TrData.TrBetAx = sheetNames{strcmp(names,'TrBetAx')};
    TrData.TrWitAx = sheetNames{strcmp(names,'TrWitAx')};
else
    TrData = [];
end

% Get FolDist from sheet if it exists
if sum(strcmp(names,'FolDist')) > 0
    FolDist = sheetNames{strcmp(names,'FolDist')};
else
    FolDist = [];
end

end

