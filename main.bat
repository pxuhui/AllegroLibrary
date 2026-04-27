@echo off
chcp 65001 >nul

echo ---------------------------------------------------
echo   MODE 1 (RE):  Delete Always (e.g. .log, .art)
echo   MODE 2 (REB): Delete Backup ONLY (e.g. .txt,1)
echo ---------------------------------------------------


powershell.exe -ExecutionPolicy Bypass -Command "$RE='\.jrl|\.PcbDocPreview|\.SchDocPreview|\.PrjPCBStructure|\.o|\.d|\.DBK|\.axf|\.tra|\.dep|\.map|\._2i|\.obj|\.omf|\.bak|\.ddk|\.edk|\.lst|\.inp|\.mpf|\.mpj|\.plg'; $REB='\.txt|\.dxf|\.log|\.art|\.jrl|\.art|\.drl|\.rou|\.iml|\.dat|\.cfg|\.rpt|\.cnv|\.dml'; Get-ChildItem -Path . -Recurse -File | Where-Object { $_.Name -match \"($RE)(,\d+)?$\" -or $_.Name -match \"($REB)(,\d+)+$\" } | ForEach-Object { Write-Host 'Processing:' $_.FullName -ForegroundColor Cyan; try { Add-Type -AssemblyName Microsoft.VisualBasic; [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteFile($_.FullName, 'OnlyErrorDialogs', 'SendToRecycleBin') } catch { Write-Warning 'Locked' } }"
pause