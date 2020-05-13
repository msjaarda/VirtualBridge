function CreateFolders(Folder_Name,BVWIM,BApercu,BSave)
%xCREATEFOLDER Creates folders in certain spots if there isn't already one

if ~isfolder(['Output' Folder_Name])
    if BSave == 1
        mkdir(['Output' Folder_Name])
    end
end
if ~isfolder(['VirtualWIM' Folder_Name])
    if BVWIM == 1
        mkdir(['VirtualWIM' Folder_Name])
    end
end
if ~isfolder(['Apercu' Folder_Name])
    if BApercu == 1
        mkdir(['Apercu' Folder_Name])
    end
end

end