% OutputFolder Peek

% Gives a view inside a folder by showing BaseData for each run

clear, clc, close all

Folder_Namex = 'AGB2002';

Folder_List = GetFolderList('Output');

for j = 1:length(Folder_List)
    
    File_List = GetFileList(Folder_List(j).name);
    
    for i = 1:length(File_List)
        load(['Output/' Folder_List(j).name '/' File_List(i).name])
        OInfo(i) = OutInfo;
    end
    clear OutInfo
    
    SumTab.(Folder_List(j).name) = struct2table(File_List);
    SumTab.(Folder_List(j).name)(:,2:end) = [];
    SumTab.(Folder_List(j).name).Properties.VariableNames{'name'} = 'FName';
    SumTab2 = [];
    
    for i = 1:length(OInfo)
%         if OInfo(i).BaseData.TransILx == 0
%             OInfo(i).BaseData.TransILx = {'0'};
%         end
        try
        OInfo(i).BaseData.TransILx = num2cell(OInfo(i).BaseData.TransILx);
        OInfo(i).BaseData.TransILy = num2cell(OInfo(i).BaseData.TransILy);
        OInfo(i).BaseData.LaneCen = num2cell(OInfo(i).BaseData.LaneCen);
        end
        SumTab2 = [SumTab2; OInfo(i).BaseData];
    end
    
    SumTab.(Folder_List(j).name) = [SumTab.(Folder_List(j).name) SumTab2];
    clear File_List
    clear OInfo
    clear SumTab2
    
end

SumTab.(Folder_Namex)