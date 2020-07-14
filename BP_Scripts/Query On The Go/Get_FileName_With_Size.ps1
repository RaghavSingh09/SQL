Get-ChildItem -Path C:\Users\rkumar498\Desktop\Java\ReadCSVData\* –Recurse -File | 
Select-Object Name,@{Name="KB";Expression={[math]::Round($_.Length/1kb)}}  |
Export-Csv -NoTypeInformation -Path C:\Users\rkumar498\Desktop\file-1.csv -Append
ConvertFrom-Csv -Path C:\Users\rkumar498\Desktop\file-1.csv -Header Name,KB | 
Select @{n=’Name’;e={$_.Name + '^' + $_.KB}}|Export-Csv -NoTypeInformation -Path C:\Users\rkumar498\Desktop\file-2.csv -Append