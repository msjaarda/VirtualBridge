clear
clc
close all
format long g

Loc = 'Raw Counting/Station137';

File_List = dir(Loc);
File_List(1:2) = [];
NumFiles = size(File_List,1);

% Initialize
i = 51;
% Get individual filename
FileName = File_List(i).name;
% Initialize rd
rd = importCOUNTLOGfile([Loc '/' FileName], 2, 100000);
% Delete nan
rd(isnan(rd.n),:) = [];
% Delete categorical part of rd
rd = rd(:,1:width(rd)-1);
% Count
next = height(rd)+1;
% Expand rd
rd(next:height(rd)*1000,:) = array2table(nan(height(rd)*1000-height(rd),width(rd)));

for i = 52:150
    
    % Get individual filename
    FileName = File_List(i).name;
    
    rdx = importCOUNTLOGfile([Loc '/' FileName], 2, 100000);
    % Delete categorical part of rd
    rdx = rdx(:,1:width(rdx)-1);
    rdx(isnan(rdx.n),:) = [];
    
    finish = height(rdx)+next-1;
    
    % Add to rd
    rd(next:finish,:) = rdx;
    
    next = finish + 1;
    
    clc, disp(i)
    % We don't need this speed thingie
    %rd.Speed(isnan(rd.Speed)) = 50;
    %rd.Time = rd.h + rd.m/60 + rd.s/3600 + rd.ms/360000;
    
    %save(filename(1:end-4),'rd')
    
end

% Delete NaN rows
rd(isnan(rd.n),:) = [];
% Add time
%rd.Time = rd.h + rd.m/60 + rd.s/3600 + rd.ms/360000;

% Check rd over for nan speeds and stuff