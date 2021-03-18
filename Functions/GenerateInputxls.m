function [Input,Summary] = GenerateInputxls(FolderName,SaveT)
%Generate the Input file that would produce the output variables in the
%folder...

% FolderName call be 'All' or the name of a specific folder
% SaveT is the save toggle.

% Perform with both the Output.xlsx and the variables themselves
% report if these two do not match

% If we have this, there is no need to keep input files in the input
% folder! We can just have one our in the main area (or keep the input
% folder)

Folder_List = GetFolderList('Output');
Check = [];

if strcmp(FolderName,'All')
    jj = 1:length(Folder_List);
else
    jj = find(strcmp(FolderName,{Folder_List.name}));
end


for w = 1:numel(jj)
    
    j = jj(w);
    
    File_List = GetFileList(Folder_List(j).name);
    
    try
        for i = 1:length(File_List)
            load(['Output/' Folder_List(j).name '/' File_List(i).name])
            OInfo(i) = OutInfo;
        end
        clear OutInfo
    catch
        continue
    end
    
    SumTab.(Folder_List(j).name) = struct2table(File_List);
    SumTab.(Folder_List(j).name)(:,2:end) = [];
    SumTab.(Folder_List(j).name).Properties.VariableNames{'name'} = 'FName';
    SumTab2 = [];
    
    for i = 1:length(OInfo)
        try
            if ~iscell(OInfo(i).BaseData.TransILx)
                OInfo(i).BaseData.TransILx = cellstr(num2str(OInfo(i).BaseData.TransILx));
                OInfo(i).BaseData.TransILy = cellstr(num2str(OInfo(i).BaseData.TransILy));
                OInfo(i).BaseData.LaneCen = cellstr(num2str(OInfo(i).BaseData.LaneCen));
            end
        end
        SumTab2 = [SumTab2; OInfo(i).BaseData];
    end
    
    % If it has an existing Output.xlsx then check for compatibility
    File_Listx = dir(['Output/' Folder_List(j).name]); File_Listx(1:2) = []; i = 1;
    BaseInfo = [];
    for k = 1:length(File_Listx)
        if ~isempty(strfind(File_Listx(k).name,'Output'))
            ExcelOutput = File_Listx(k).name;
            ExcelSheetNames = sheetnames(['Output/' Folder_List(j).name '/' ExcelOutput]);
            for p = 1:length(ExcelSheetNames)
                New = readtable(['Output/' Folder_List(j).name '/' ExcelOutput],'Sheet',ExcelSheetNames(p),'Range','B9:AG10');
                try
                    if ~iscell(New.TransILx)
                        New.TransILx = cellstr(num2str(New.TransILx));
                        New.TransILy = cellstr(num2str(New.TransILy));
                        New.LaneCen = cellstr(num2str(New.LaneCen));
                    end
                end
                try
                    New.Flow = cellstr(num2str(New.Flow));
                end
                BaseInfo = [BaseInfo;  New];
            end
            BaseInfo = rmmissing(BaseInfo,2);
        end
    end
    
    if ~isempty(BaseInfo)
        % Compare
        Check = [Check; isequal(BaseInfo,SumTab2)];
        Folder_List(j).Check = isequal(BaseInfo,SumTab2);
    else
        Check = [Check; -1];
        Folder_List(j).Check = -1;
    end
    SumTab.(Folder_List(j).name) = [SumTab.(Folder_List(j).name) SumTab2];
    clear File_List, clear OInfo, clear SumTab2
    
    if SaveT
        % Write to Excel File
        writetable(SumTab.(Folder_List(j).name)(:,2:end-1),['Output/' Folder_List(j).name '/InputAutoGen.xlsx'],'Sheet','BaseData');
    end
    
end

if strcmp(FolderName,'All')
    Input = SumTab;
else
    Input = SumTab.(FolderName);
end

Summary = Folder_List;

end

