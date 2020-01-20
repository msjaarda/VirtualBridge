function [BaseData,LaneData,TrData,FolDist] = ReadInputFile(InputFile)
%xREADINPUTFILE Gives parameters associated with Inputfile

[~, sheetNames] = xlsfinfo(InputFile);

for i = 1:length(sheetNames)
    sheetNames{i} = readtable(InputFile,'Sheet',sheetNames{i});
end

BaseData = sheetNames{1};
LaneData = sheetNames{2};

TrData.TrDistr = sheetNames{3};
TrData.TrLinFit = sheetNames{4};
TrData.TrAllo = sheetNames{5};
TrData.TrBetAx = sheetNames{6};
TrData.TrWitAx = sheetNames{7};

FolDist = sheetNames{8};

end

