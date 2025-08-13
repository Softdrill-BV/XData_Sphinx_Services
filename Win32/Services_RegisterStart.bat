REM Run all commands from drive (/d) and folder from which batch file is run

cd /d %~dp0

XDataService.exe /INSTALL
net start XDataService

SphinxService.exe /INSTALL
net start SphinxService

pause

