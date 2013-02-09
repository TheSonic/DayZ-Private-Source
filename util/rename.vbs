Set objFso = CreateObject("Scripting.FileSystemObject")
Set Folder = objFSO.GetFolder("build\MPMissions")

For Each File In Folder.Files
    sNewFile = File.Name
    sNewFile = Replace(sNewFile,"dayz","rmod")
    if (sNewFile<>File.Name) then 
        File.Move(File.ParentFolder+"\"+sNewFile)
    end if
Next