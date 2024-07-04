: Hppsrc 2024
: Dioxide 

@ECHO OFF

: Variables
SET BUILD=70416
SET VERSION=0.3.0
SET VERSION_STATUS=ALPHA
SET PR_TITLE=%CD%
SET DIOXIDE_PATH=%LOCALAPPDATA%\Hppsrc\Dioxide\

: Check args
IF "%1"=="-i" GOTO :PREINSTALL          @REM Install
IF "%1"=="-fi" GOTO :PREINSTALL         @REM Force install / Same as force update
IF "%1"=="-ig" GOTO :IGNORE_RUN         @REM Ignore path and run Dioxide as normal (toggleable)

: Check if current directory has .dioxide_run and run dioxide as normal
IF EXIST ".dioxide_run" GOTO :RUN

: Check path ("Is installed?")
IF "%~d0%~p0"=="%DIOXIDE_PATH%bin\" ( GOTO :PRERUN ) ELSE (
    ECHO Detected that this is not a regular Dioxide run, running installation process.
    GOTO :PREINSTALL
)

: Checks what Dioxide action to run
:PRERUN

: Run normal dioxide 
IF ["%~n0"]==["d"] (
    GOTO :D_RUN
)

: Run inteactive dioxide
IF ["%~n0"]==["di"] (
    GOTO :DI_RUN
)

: Run d functions
:D_RUN

IF ["%1"]==[""] ( CD %userprofile% ) ELSE (

    @REM TODO CHECK IF NOT IN COMMON FOLDER

    IF NOT EXIST %CD%\%1\ (
        ECHO Dioxide: no match found
    ) ELSE (
        CD %CD%\%1>nul 2>&1
    )
)

GOTO :CLOSE_RUN

:DI_RUN
ECHO NOT YET
PAUSE
GOTO :CLOSE_RUN

:PREINSTALL

TITLE Dioxide install %VERSION%

: Get Admin priv
NET SESSION >nul 2>&1
IF %ERRORLEVEL% == 0 (
    IF "%1"=="-fi" GOTO :CONTINUE_INSTALL
) ELSE (
    ECHO Not running as administrator, restarting script.
    TIMEOUT /T 1 /NOBREAK > nul

    @REM TODO CHECK IF -I OR -FI
        
    ECHO Set UAC = CreateObject^("Shell.Application"^) > "%temp%\elevate.vbs"
    ECHO UAC.ShellExecute "%~s0", "-i", "", "runas", 1 >> "%temp%\elevate.vbs"
        
    "%temp%\elevate.vbs"
    DEL "%temp%\elevate.vbs"
    EXIT
)

CLS

: Check if already installed
IF EXIST %DIOXIDE_PATH%bin\d.bat SET DIOXIDE_CHECK=d.bat
IF EXIST %DIOXIDE_PATH%bin\di.bat ( SET DIOXIDE_CHECK=di.bat ) ELSE ( GOTO :INSTALL)

FOR /f "tokens=2 delims==" %%a IN ('findstr /C:"SET VERSION=" "%DIOXIDE_PATH%bin\%DIOXIDE_CHECK%"') DO (
    SET INSTALLED_VERSION=%%a

    FOR /f "tokens=2 delims==" %%a IN ('findstr /C:"SET BUILD=" "%DIOXIDE_PATH%bin\%DIOXIDE_CHECK%"') DO (
        SET INSTALLED_BUILD=%%a
        GOTO :BREAK
    )

)

:BREAK

IF DEFINED INSTALLED_VERSION (

    : Script has a new version
    IF %INSTALLED_BUILD% LSS %BUILD% (
        ECHO There seems to be an older version of Dioxide installed on the system.
        ECHO Installed Script:  %INSTALLED_VERSION% ^(%INSTALLED_BUILD%^)
        ECHO Current Script:    %VERSION% ^(%BUILD%^)
        ECHO.
        ECHO Do you want to upgrade Dioxide to the version %VERSION%?

        CHOICE /C YN /M "Choose"

        IF ERRORLEVEL 2 GOTO :CLOSE
        IF ERRORLEVEL 1 GOTO :CONTINUE_INSTALL
    )

    : Script has an old version
    IF %INSTALLED_BUILD% GTR %BUILD% (
        ECHO There seems to be a newer version of Dioxide installed on the system.
        ECHO Installed Script:  %INSTALLED_VERSION% ^(%INSTALLED_BUILD%^)
        ECHO Current Script:    %VERSION% ^(%BUILD%^)
        ECHO.
        ECHO Do you want to go back to this previous Dioxide version %VERSION%?
        ECHO.
        ECHO Remember that this implies that many functions of Dioxide may stop working.
        ECHO If you are installing this because the current version has a bug please report it on github.

        CHOICE /C YN /M "Choose"

        IF ERRORLEVEL 2 GOTO :CLOSE
        IF ERRORLEVEL 1 GOTO :CONTINUE_INSTALL
    )

    : Script has same version
    IF %INSTALLED_BUILD% EQU %BUILD% (
        ECHO The installation process was cancelled. 
        ECHO This script contains the same version as the one installed on the system.
        ECHO Version installed: %INSTALLED_VERSION% ^(%BUILD%^)
        PAUSE
        GOTO :CLOSE
    )
)

: Install process
:INSTALL

ECHO Welcome to the Dioxide installation process
ECHO Dioxide is a script that tries to replicate all the functions of Zoxide in Windows Batch.
ECHO.
ECHO You are about to install the version %VERSION% %VERSION_STATUS% (%BUILD%)
ECHO.
ECHO Want to continue?

CHOICE /m choose

IF %ERRORLEVEL%==1 GOTO :CONTINUE_INSTALL
IF %ERRORLEVEL%==2 GOTO :CLOSE

: Install Dioxide
:CONTINUE_INSTALL

CLS

ECHO Creating directories...
MKDIR %DIOXIDE_PATH%bin\>nul 2>&1
MKDIR %DIOXIDE_PATH%common\>nul 2>&1

ECHO Creating files...
COPY %~f0 %DIOXIDE_PATH%bin\d.bat>nul 2>&1
COPY %~f0 %DIOXIDE_PATH%bin\di.bat>nul 2>&1

ECHO Add to PATH...
ECHO %PATH%>nul | FINDSTR /C:"%DIOXIDE_PATH%bin" >nul
IF %ERRORLEVEL% NEQ 0 (
    SETX PATH "%PATH%;%DIOXIDE_PATH%bin"
)

ECHO.
ECHO Dioxide %VERSION% ^(%BUILD%^) was installed on your system, you can now use it in your terminal.
PAUSE
EXIT

PAUSE

GOTO :CLOSE

: Add .dioxide_run to run anyway here
:IGNORE_RUN

IF EXIST .dioxide_run (
    DEL .dioxide_run
) ELSE (
    COPY /y nul .dioxide_run >nul
)

GOTO :EOF

: Exit script but not close CMD
:CLOSE

CLS 

: Exit script but not close CMD and dont clean screen
:CLOSE_RUN

TITLE %PR_TITLE%
@ECHO ON