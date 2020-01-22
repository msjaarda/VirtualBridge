% New script to open and manipulate results files
% We probably want to add some infomation to OutInfo... InfLine List...

clear, clc, close all, format long g, rng('shuffle'); % Initial commands

% Input File or Folder Name
InputF = 'Output/PlatStud';
File_List = dir(InputF);

if File_List(1).isdir
    File_List(1:2) = [];  Folder_Name = InputF(6:end);
end

% Divide by 2 to take only the variable files
for i = 1:length(File_List)/2
    load([InputF '/' File_List(i).name])
    OInfo(i) = OutInfo;
end

BD = cat(1,OInfo.BaseData);
Mean = cat(1,OInfo.Mean);

BunchRes = Mean(BD.RunPlat == 0 & BD.BunchFactor > 1,:);

Ratio(:,1) = Mean(:,1)/BunchRes(1);
Ratio(:,2) = Mean(:,2)/BunchRes(2);

%Ratio = cat(1,OInfo.ESIM)./cat(1,OInfo.ESIA);
scatter(BD.PlatFolDist(Ratio(:,1) > 1),Ratio(Ratio(:,1) > 1,1))
