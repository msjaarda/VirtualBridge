function [PD] = CombineStations(Station, Year, SName)
% COMBINESTATIONS This function takes in Station (string array), SName
% (string), and Year (string/num, could be multiple years)

% Combine two .trd format Matlab variables into one (for example, both
% directions of WIM measurements like 408, 409 for Ceneri)

% One problem when you use this is that the table descriptions, which
% contain details about vehicles removed in pruning, overwrite each other

% ----- INPUT -----

for j = 1:length(Year)

% Get File Names
for i = 1:length(Station)

    TFileName{i} = strcat(SName,num2str(Station{i}),'_',num2str(Year(j)),'_Filtered');
    MFileName{i} = strcat(TFileName{i},'.mat');
        
end   

% Load first file
load(MFileName{1});

if numel(Station) == 2
    
    PD2 = PD;
    load(MFileName{2});
    PD = [PD; PD2];
    delete(MFileName{2})
end

FileName = strcat(SName,'_',num2str(Year(j)));
save(FileName,'PD');

% Delete original
delete(MFileName{1})

end