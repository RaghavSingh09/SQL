param ($FolderPath)

Function Get-FilesFromZipRecursively {
param ($InputItem)

Write-Host $InputItem.name"~"$InputItem.path"~"$InputItem.isfolder"~"$InputItem.size"~"$InputItem.ModifyDate

    if ($InputItem.IsFolder) 
    {
        foreach ($Item in ($Shell.NameSpace($InputItem.Path)).Items()) 
        {
            Get-FilesFromZipRecursively -InputItem $Item
        }
    }
}

$shell = new-object -com shell.application
#$FolderPath = "C:\Users\rkumar699\Desktop\Zip Test"
#$FolderPath = -Path $FolderPath
$zip = $shell.namespace("$FolderPath")
$zip.items() | ForEach-Object {
Get-FilesFromZipRecursively -InputItem $_
}