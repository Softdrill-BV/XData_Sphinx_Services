REM Run all commands from drive (/d) and folder from which batch file is run

cd /d %~dp0

net stop SphinxService
net stop XDataService

pause

