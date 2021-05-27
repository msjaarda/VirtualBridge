clear, clc

load('WIMYearlyMaxQSum')

Years = unique(YearlyMax.Year);
Stations = unique(YearlyMax.Station);
Widths = unique(YearlyMax.Width);
ClassTs = unique(YearlyMax.ClassT);
% "All", "Class", "ClassOW"

count = 0;
%SaveCase = table();

for i = 1:length(Years)
    
    for j = 1:length(Stations)
        
        for k = 1:length(Widths)
            
            if YearlyMax.MaxLE(YearlyMax.Year == Years(i) & YearlyMax.Station == Stations(j) & YearlyMax.Width == Widths(k) & YearlyMax.ClassT == "ClassOW") > YearlyMax.MaxLE(YearlyMax.Year == Years(i) & YearlyMax.Station == Stations(j) & YearlyMax.Width == Widths(k) & YearlyMax.ClassT == "Class")
                
                count = count + 1;
                %YearlyMax(YearlyMax.Year == Years(i) & YearlyMax.Station == Stations(j) & YearlyMax.Width == Widths(k),:)
                SaveCase(count).Year = Years(i);
                SaveCase(count).Station = Stations(j);
                SaveCase(count).Width = Widths(k);
                
            end
            
        end
        
    end
    
end

Del = true(length(SaveCase),1);

for i = 2:length(SaveCase)
    if SaveCase(i).Year == SaveCase(i-1).Year && SaveCase(i).Station == SaveCase(i-1).Station
        Del(i-1) = false;
    end
end

N = [[SaveCase.Year]' [SaveCase.Station]' [SaveCase.Width]'];

%SaveCase

N = N(Del,:);

ClassOWApercu = N;
save('ClassOWApercu','ClassOWApercu')

