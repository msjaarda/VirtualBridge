% Load info from Direct WIM Axle Analysis and draw conclusions

clear, clc

load('YearlyMaxQSum.mat')
%['Output' '/AllAxles' '/' 'YearlyMaxQSum']

load('AxleGroupWeights.mat')
% 1 to 56... 
% SName = {'Ceneri', 'Denges', 'Gotthard', 'Oberburen'};
% 2011 to 2018 with Gotthard just 1 station



Master = [];
for i = 1:length(Axles)
    % Load tandems and add to a master tandem
    Temp = Axles{i}{2};
    Master =  [Master; Temp];
    
    
end

% Use this axle histogram to get alphaQ1!
% Look at Prof. B's memo... and all reliability concepts
% Include gamma = 1.4?
histogram(Master,100,'normalization','pdf')
prctile(Master,99.99)



prctile(YearlyMax.MaxLE(YearlyMax.Width == 2),99)

scatter(YearlyMax.Width,YearlyMax.MaxLE)


