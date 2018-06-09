cd %~dp0
powershell.exe %~dp0SendCommands.ps1 -Path %~dp0computers.txt -ScriptPath %~dp0commands.bat
pause 