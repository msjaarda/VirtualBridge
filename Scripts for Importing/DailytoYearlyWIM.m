%  April 2019 | Matthew Sjaarda
%  Take daily traffic files *.V00 from OFROU, combine into a yearly *.trd
%  Keep in mind one must rename the header row in a text editor because
%  matlab cannot write hyphens, and the .trd file has hyphens
%  Say 'Yes' to pruning if the file hasn't already been compiled. If it
%  has, use the PruneYearlymatFile instead.

clear
clc
close all
format long g

% -------- INPUT -------- 

% Tell Matlab where the directory is that holds the daily files

% ----- INPUT -----

Year = {'2009'};
Station = {'408'};
SName = 'Ceneri';

% -----------------

for q = 1:length(Year)
    
for w = 1:length(Station)

TFileName1 = strcat(SName,Station{w},'_',Year{q});
TFileName = strcat(SName,'_',Year{q});
Loc = strcat('C:\Users\sjaarda\Desktop\',SName,Station{w});
%Loc = strcat('C:\Users\sjaarda\Desktop\WIMDaily\',SName,'\',Station{w});
%Loc = strcat('C:\Users\sjaarda\Desktop\WIMDaily\',SName,'\',Station{w},'\',Year{q});

% Create a structure will all filesnames in order to step through and
% process these individual daily files (import, edit, and add to 'RD',
% which stands for Raw Data, and will be our yearly file

File_List = dir(Loc);
File_List(1:2) = [];
NumFiles = size(File_List,1);

for i = 1:NumFiles
    
    % Get individual filename
    FileName = File_List(i).name;
    
    % Import file using "importfile", which was generated automatically from ML's "Import
    % Data" tool. It takes in the file name, first row you want, and last row
    % however, in order to get all the data, just set the last row to a high
    % number! It does not give an error for this. Row 22 is the first row
    % we want. The total number of columns given after importfile is 36. 
    RDi = importDAILYfile(strcat(Loc,'\',FileName),22,10000000);
    
    % Delete last row (always meaningless after the import)
    [RDisize, RDirows]= size(RDi);
    if RDisize == 0
        continue
    else
        
    RDi(RDisize,:) = [];
    RDi.ZST = str2num(Station{w})*ones(size(RDi,1),1);
    
    % Append to growing yearly file
    if i == 1
        % Configure wait bar
        f = waitbar((i)/NumFiles,['Processed ',num2str(i),' of ',num2str(NumFiles),' Files for ',SName,' ',Station{w}]);
        RD = RDi;
        % Preallocate the rest of the table rows for speed. Guess at 2 millions rows
        Preall = array2table(zeros(2000000,RDirows));
        Preall.Properties.VariableNames = RD.Properties.VariableNames;
        RD = [RD; Preall];
        StartRow = RDisize;
    else
        EndRow = StartRow + RDisize - 2;
        RD(StartRow:EndRow,:) = RDi;
        % RD = [RD; RDi];
        % update wait bar
        waitbar((i)/NumFiles,f,['Processed ',num2str(i),' of ',num2str(NumFiles),' Files for ',SName,' ',Station{w}]);
        StartRow = EndRow + 1;
    end
    end
       
end

close(f)

% Take out potentially gibberish rows

% Must be commented for Oberburen!!! Actually can't do this since it
% doesn't destroy the rows of blanks...

NotZST = RD.ZST~=str2num(Station{w});
TotNotZST = sum(NotZST);
RD(NotZST,:) = [];

% ----- Perform Mass Edits -----

% Delete unnecessary rows

%RD.RESCOD = [];
%RD.Head = [];
%RD.HEADx = [];
% Dec 19
%RD.HH = [];
%RD.WBTOT = [];

% Reorder dates and times
RD.JJJJMMTT = strcat('20',RD.YY,RD.MM,RD.DD); 
RD.JJJJMMTT = str2double(RD.JJJJMMTT);
RD.YY = [];
RD.MM = [];
RD.DD = [];

% Dec 19
RD.HHMMSS = strcat(RD.HHMM,RD.SS);
RD.HHMMSS = str2double(RD.HHMMSS);
RD.HHMM = [];
RD.SS = [];

% Multiply speed by 100 for some odd reason haha
RD.SPEED = RD.SPEED*100;

% Create new rows with nothing in them...

RD.AWT10 = zeros(size(RD,1),1);
RD.T = zeros(size(RD,1),1);
RD.ST = zeros(size(RD,1),1);
RD.CSF = zeros(size(RD,1),1);
RD.W9_10 = zeros(size(RD,1),1);
RD.FZG_NR = zeros(size(RD,1),1);

% Reorder rows to match .trd format - note that some header names will have
% to be edited to replace _ with - which is not allowed in Matlab. Must be
% done after the fact in a text editor
RD = RD(:,[{'ZST'} {'JJJJMMTT'} {'T'} {'ST'} {'HHMMSS'} {'FZG_NR'} {'FS'} {'SPEED'} {'LENTH'} {'CS'} {'CSF'} {'GW_TOT'} {'AX'} {'AWT01'}...
    {'AWT02'} {'AWT03'} {'AWT04'} {'AWT05'} {'AWT06'} {'AWT07'} {'AWT08'} {'AWT09'} {'AWT10'} {'W1_2'} {'W2_3'} {'W3_4'} {'W4_5'}...
    {'W5_6'} {'W6_7'} {'W7_8'} {'W8_9'} {'W9_10'} {'HH'} {'Head'} {'HEADx'} {'GAP'}]);

% They used units of 10kg when logging.... change to kg
Factor = 10;
RD.GW_TOT = RD.GW_TOT*Factor;

% Do for the axles by stepping through rows

for i = 14:23  
    RD.(i) = RD.(i)*Factor; 
end

% writetable(RD,TFileName)
save(TFileName1,'RD')

% ----- Perform Mass Pruning -----

PD = PruneWIM((Year{q}),Station{w},SName,RD,1,0);

[TotDaysOpen, y] = size(unique(PD.JJJJMMTT));

% writetable(PD,strcat(TFileName,'_Filtered'))
%save(strcat(TFileName,'_Filtered'),'PD')
%save(TFileName,'PD')

end

end

