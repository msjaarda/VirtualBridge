function [File_List] = GetFileList(Folder_Name)
%UNTITLED7 Summary of this function goes here
%   Detailed explanation goes here


% Ensure file list is succinct
File_List = dir(['Output/' Folder_Name]); File_List(1:2) = []; i = 1;
% Take only .mat files (no excel files)
while i <= length(File_List)
    try
        if File_List(i).name(end-4:end) == '.xlsx'
            File_List(i) = [];
        else
            i = i + 1;
        end
    catch
        continue
    end
end


end

