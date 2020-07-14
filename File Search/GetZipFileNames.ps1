﻿#ERROR REPORTING ALL 
Set-StrictMode -Version latest 
 
#---------------------------------------------------------- 
#STATIC VARIABLES 
#---------------------------------------------------------- 
$search = "argo" 
$dest   = "C:\Users\rkumar699\Desktop\Test" 
$zips   = "C:\Users\rkumar699\Desktop" 
 
#---------------------------------------------------------- 
#FUNCTION GetZipFileItems 
#---------------------------------------------------------- 
Function GetZipFileItems 
{ 
  Param([string]$zip) 
   
  $split = $split.Split(".") 
  $dest = $dest + "\" + $split[0] 
  If (!(Test-Path $dest)) 
  { 
    Write-Host "Created folder : $dest" 
    $strDest = New-Item $dest -Type Directory 
  } 
 
  $shell   = New-Object -Com Shell.Application 
  $zipItem = $shell.NameSpace($zip) 
  $items   = $zipItem.Items() 
  GetZipFileItemsRecursive $items 
} 
 
#---------------------------------------------------------- 
#FUNCTION GetZipFileItemsRecursive 
#---------------------------------------------------------- 
Function GetZipFileItemsRecursive 
{ 
  Param([object]$items) 
 
  ForEach($item In $items) 
  { 
    If ($item.GetFolder -ne $Null) 
    { 
      GetZipFileItemsRecursive $item.GetFolder.items() 
    } 
    $strItem = [string]$item.Name 
    If ($strItem -Like "*$search*") 
    { 
      If ((Test-Path ($dest + "\" + $strItem)) -eq $False) 
      { 
        Write-Host "Copied file : $strItem from zip-file : $zipFile to destination folder" 
        $shell.NameSpace($dest).CopyHere($item) 
      } 
      Else 
      { 
        Write-Host "File : $strItem already exists in destination folder" 
      } 
    } 
  } 
} 
 
#---------------------------------------------------------- 
#FUNCTION GetZipFiles 
#---------------------------------------------------------- 
Function GetZipFiles 
{ 
  $zipFiles = Get-ChildItem -Path $zips -Recurse -Filter "*.zip" | % { $_.DirectoryName + "\$_" } 
   
  ForEach ($zipFile In $zipFiles) 
  { 
    $split = $zipFile.Split("\")[-1] 
    Write-Host "Found zip-file : $split" 
    GetZipFileItems $zipFile 
  } 
} 
#RUN SCRIPT  
GetZipFiles 