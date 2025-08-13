REM Run all commands from drive (/d) and folder from which batch file is run

cd /d %~dp0

net stop SphinxService
SphinxService.exe /UNINSTALL

net stop XDataService
XDataService.exe /UNINSTALL

pause