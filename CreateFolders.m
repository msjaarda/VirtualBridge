function CreateFolders(Folder_Name)
%xCREATEFOLDER Creates folders in certain spots if there isn't already one

if ~isfolder(['Output' Folder_Name])
    mkdir(['Output' Folder_Name])
end
if ~isfolder(['VirtualWIM' Folder_Name])
    mkdir(['VirtualWIM' Folder_Name])
end
if ~isfolder(['Apercu' Folder_Name])
    mkdir(['Apercu' Folder_Name])
end
if ~isfolder(['Key Results' Folder_Name])
    mkdir(['Key Results' Folder_Name])
end

end