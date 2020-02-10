function [BaseData,LaneData,TrData,FolDist] = ReadInputFile(InputFile)
%READINPUTFILE Gives parameters associated with Inputfile

[~, sheetNames] = xlsfinfo(InputFile);
names = strings(size(sheetNames));
[names{:}] = sheetNames{:};

for i = 1:length(sheetNames)
    sheetNames{i} = readtable(InputFile,'Sheet',names(i));
end

BaseData = sheetNames{strcmp(names,'BaseData')};
LaneData = sheetNames{strcmp(names,'LaneData')};

if ismember('Traffic', BaseData.Properties.VariableNames)
    load('TrLib.mat')
    TrData = TrLib.(BaseData.Traffic{:});
else
    TrData.TrDistr = sheetNames{strcmp(names,'TrDistr')};
    TrData.TrLinFit = sheetNames{strcmp(names,'TrLinFit')};
    TrData.TrAllo = sheetNames{strcmp(names,'TrAllo')};
    TrData.TrBetAx = sheetNames{strcmp(names,'TrBetAx')};
    TrData.TrWitAx = sheetNames{strcmp(names,'TrWitAx')};
end

if ismember('Flow', BaseData.Properties.VariableNames)
    load('FlowLib.mat')
    FolDist = FlowLib.(BaseData.Flow{:});
else
    FolDist = sheetNames{strcmp(names,'FolDist')};
end

end

