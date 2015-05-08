@echo off
call config.bat

echo This will download the game code from git and install the all the files and folders and symbolic links needed to use the server tools in to the current directory.

echo This requires git be installed.

echo Once this is done, you can safely delete this file if you wish.

echo Ready?
pause

call bin/findgit.bat

echo Downloading repo....
git clone %REPO_URL% gitrepo
IF %ERRORLEVEL% NEQ 0 (
	echo git clone failed. aborting.
	pause
	goto ABORT
)
echo Repo downloaded.
echo Setting up folders...
mkdir gamecode\a
mkdir gamecode\b
mkdir gamecode\override
mkdir gamedata
mkdir bot

echo Copying things around....
echo (1/3)
xcopy gitrepo\data gamedata\data /Y /X /K /R /H /I /C /V /E /Q >nul
xcopy gitrepo\config gamedata\config /Y /X /K /R /H /I /C /V /E /Q >nul
xcopy gitrepo\cfg gamedata\cfg /Y /X /K /R /H /I /C /V /E /Q >nul
xcopy gitrepo\bot bot /Y /X /K /R /H /I /C /V /E /Q >nul
echo (2/3)
xcopy gitrepo gamecode\a /Y /X /K /R /H /I /C /V /E /Q /EXCLUDE:copyexclude.txt >nul
echo (3/3)
xcopy gitrepo gamecode\b /Y /X /K /R /H /I /C /V /E /Q /EXCLUDE:copyexclude.txt >nul
echo done.

echo Setting up symbolic links.
mklink gamecode\a\nudge.py ..\..\bot\nudge.py
mklink gamecode\a\CORE_DATA.py ..\..\bot\CORE_DATA.py
mklink /d gamecode\a\data ..\..\gamedata\data
mklink /d gamecode\a\config ..\..\gamedata\config
mklink /d gamecode\a\cfg ..\..\gamedata\cfg

mklink gamecode\b\nudge.py ..\..\bot\nudge.py
mklink gamecode\b\CORE_DATA.py ..\..\bot\CORE_DATA.py
mklink /d gamecode\b\data ..\..\gamedata\data
mklink /d gamecode\b\config ..\..\gamedata\config
mklink /d gamecode\b\cfg ..\..\gamedata\cfg

mklink /d gamefolder gamecode\a

echo done. You may now run the updater to build the code, than watchdog to launch the server.
pause

:ABORT