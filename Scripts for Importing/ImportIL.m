%ImportIL
%Imports influence lines to the library, InfLib

clear,clc

FileName = 'Misc/InfLineImport.xlsx';
LibName = 'FornNS';

X = readtable(FileName);

load('InfLib.mat')

InfLib.(LibName).Infx = X.Infx;
InfLib.(LibName).Infv = X{:,3:end};
InfLib.(LibName).Name = X.Name(1:size(InfLib.(LibName).Infv,2))';

save('InfLib.mat','InfLib')

fprintf('\nInfluence line(s) imported!\n\n')

clear