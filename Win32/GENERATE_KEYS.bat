REM Run all commands from drive (/d) and folder from which batch file is run

cd /d %~dp0

REM Delete any existing files
del my-private.key
del my-public.key
del my-private.key.pub

REM Create the key files
ssh-keygen -t rsa -b 2048 -m PEM -N "" -f my-private.key
ssh-keygen -e -m PEM -f my-private.key > my-public.key

pause
