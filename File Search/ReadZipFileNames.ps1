param ([string]$Folder=$null)

#$Folder = "C:\Users\rkumar699\Desktop\Zip Test"[Reflection.Assembly]::LoadWithPartialName('System.IO.Compression.FileSystem')foreach($sourceFile in (Get-ChildItem -Path $Folder -filter '*.zip')){[IO.Compression.ZipFile]::OpenRead($sourceFile.FullName).Entries.FullName | %{"'$sourceFile'::$_"}}