% This file is to be used for WIM data that we already have in .trd format
% but that needs to be pruned (just to make sure it is good, and not too
% many vehicles are removed), and then saved as a Matlab variable. You
% first have to open up the .trd in access and save/export it as a .txt file into
% the "Current Folder".

clear
clc
close all
format long g

% Use importTRDTXTfile to get the text file into Matlab.

SName = 'Gotthard';
Year = '2010';
Station = '';
% You must give PruneWIM function a station number... just say ''
% Most files have a comma delimeter, some have a semi-colon
del = ';';

%RD = importTRDTXTfile(strcat('410_2004.txt'), 1, 10000000, del);
RD = importTRDTXTfile(strcat(SName,Year,'.txt'), 1, 10000000, del);

PD = PruneWIM(Year,Station,SName,RD,1,0);

FileName = strcat('PrunedS1 WIM\',SName,'\',SName,'_',Year);
save(FileName,'PD');