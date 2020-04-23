function [Folder_List] = GetFolderList(Folder_Name)

% Ensure file list is succinct
Folder_List = dir(Folder_Name); Folder_List(1:2) = []; i = 1;
% Take only .mat files (no excel files)
while i <= length(Folder_List)
    if Folder_List(i).isdir == 0
        Folder_List(i) = [];
    else
        i = i + 1;
    end
end

end