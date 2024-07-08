: Hppsrc 2024
: Dioxide 

@ECHO OFF

@REM ========== CONFIG SECTION ==========

: Variables
SET BUILD=70813
SET VERSION=0.6.0
SET VERSION_STATUS=ALPHA
SET DIOXIDE_PATH=%LOCALAPPDATA%\Hppsrc\Dioxide\
SET DIOXIDE_COMMON=%DIOXIDE_PATH%common\data.txt

: Check args
IF "%1"=="-h" GOTO :HELP                @REM Help msg
IF "%1"=="-i" GOTO :PREINSTALL          @REM Install
IF "%1"=="-hd" GOTO :HELP               @REM Help msg with extra commands

IF "%1"=="-c" ( DEL %DIOXIDE_COMMON%>nul 2>&1 & ECHO Dioxide: Folder registry deleted & GOTO :EOF ) & @REM Deletes the folder registry
IF "%1"=="-v" ( ECHO Dioxide %VERSION% ^(%BUILD%^) & GOTO :EOF )                                                & @REM Version

IF "%1"=="-fi" GOTO :PREINSTALL         @REM Force install / same as force update
IF "%1"=="-ig" GOTO :IGNORE_RUN         @REM Ignore path and run Dioxide everywhere (toggleable)
IF "%1"=="-d" GOTO :DEV_MODE            @REM Enable echoing (toogleable)
IF "%1"=="-a" GOTO :ADM_MODE            @REM Disable admin priv for install (toogleable)
IF "%1"=="-b" GOTO :CREATE_BK           @REM Enable create backups for old builds (toogleable)

: Check if .dioxide_run exist run dioxide as normal
IF EXIST "%DIOXIDE_PATH%.dioxide_run" GOTO :RUN

: Check if .enable_dev exist and enable echoing
IF EXIST "%DIOXIDE_PATH%.enable_dev" ECHO ON

: Check path ("Is installed?")
IF "%~d0%~p0"=="%DIOXIDE_PATH%bin\" ( GOTO :PRERUN ) ELSE (
    ECHO Detected that this is not a regular Dioxide run, running installation process.
    GOTO :PREINSTALL
)

@REM ========== EXECUTE SECTION ==========

: Checks what Dioxide action to run
:PRERUN

: Run normal dioxide 
IF ["%~n0"]==["d"] (
    GOTO :D_RUN
)

: Run interactive dioxide
IF ["%~n0"]==["di"] (
    GOTO :DI_RUN
)

: Run d functions
:D_RUN

IF "%1"=="" ( 

    CD %userprofile%
    GOTO :CLOSE_RUN

) ELSE (

    : Check if folder is on same dir
    IF EXIST %CD%\%1\ (

        CD %CD%\%1>nul
        CALL :ADD_COMMON
        GOTO :CLOSE_RUN

    ) ELSE (

        : Check if folder is a dir
        IF EXIST %1\ (

            CD /d %1>nul
            CALL :ADD_COMMON
            GOTO :CLOSE_RUN

        ) ELSE (

            : Check if theres any match on common
            FOR /F "TOKENS=*" %%a IN ('FINDSTR /R /I "%*" "%DIOXIDE_COMMON%"') DO (
                
                SET MATCH=%%a
                CD %MATCH%
                GOTO :CLOSE_RUN

            )

        )

    )

)
            
ECHO Dioxide: No match found

GOTO :CLOSE_RUN

:DI_RUN
ECHO NOT YET
PAUSE
GOTO :CLOSE_RUN

@REM ========== INSTALL SECTION ==========

: Check if skip admin check or is a new version
:PREINSTALL

TITLE Dioxide install %VERSION%

: Check if .disable_adm exist and skip admin check
IF EXIST "%DIOXIDE_PATH%.disable_adm" GOTO :UPDATE_CHECK

: Get Admin priv
NET SESSION >nul 2>&1
IF %ERRORLEVEL% == 0 (
    ECHO.
) ELSE (
    ECHO Not running as administrator, restarting script.
    TIMEOUT /T 1 /NOBREAK > nul
        
    ECHO Set UAC = CreateObject^("Shell.Application"^) > "%temp%\elevate.vbs"

    IF "%1"=="" (
        ECHO UAC.ShellExecute "%~s0", "-i", "", "runas", 1 >> "%temp%\elevate.vbs"
    )

    IF "%1"=="-i" (
        ECHO UAC.ShellExecute "%~s0", "-i", "", "runas", 1 >> "%temp%\elevate.vbs"
    )
    
    IF "%1"=="-fi" (
        ECHO UAC.ShellExecute "%~s0", "-fi", "", "runas", 1 >> "%temp%\elevate.vbs"
    )
        
    "%temp%\elevate.vbs"
    DEL "%temp%\elevate.vbs"
    EXIT
)

CLS

: Check if already installed
:UPDATE_CHECK

IF "%1"=="-fi" GOTO :CONTINUE_INSTALL

IF EXIST %DIOXIDE_PATH%bin\d.bat SET DIOXIDE_CHECK=d.bat
IF EXIST %DIOXIDE_PATH%bin\di.bat ( SET DIOXIDE_CHECK=di.bat ) ELSE ( GOTO :INSTALL)

FOR /f "TOKENS=2" %%a IN ('FINDSTR /C:"SET VERSION=" "%DIOXIDE_PATH%bin\%DIOXIDE_CHECK%"') DO (
    SET INSTALLED_VERSION=%%a

    FOR /f "TOKENS=2" %%a IN ('FINDSTR /C:"SET BUILD=" "%DIOXIDE_PATH%bin\%DIOXIDE_CHECK%"') DO (
        SET INSTALLED_BUILD=%%a
        GOTO :BREAK1
    )

)

:BREAK1

IF DEFINED INSTALLED_VERSION (

    : Script has a new version
    IF %INSTALLED_BUILD% LSS %BUILD% (
        ECHO There seems to be an older version of Dioxide installed on the system.
        ECHO Installed Script:  %INSTALLED_VERSION% ^(%INSTALLED_BUILD%^)
        ECHO Current Script:    %VERSION% ^(%BUILD%^)
        ECHO.
        ECHO Do you want to upgrade Dioxide to the version %VERSION% ^(%BUILD%^)?

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
        ECHO Do you want to go back to this previous Dioxide version %VERSION% ^(%BUILD%^)?
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

: Create backup of prev version
IF EXIST "%DIOXIDE_PATH%.create_back" (
    MKDIR %DIOXIDE_PATH%bin\old\>nul 2>&1
    COPY %DIOXIDE_PATH%bin\d.bat %DIOXIDE_PATH%bin\old\Dioxide_%BUILD%_.bat>nul 2>&1
)

CLS

ECHO Creating directories...
MKDIR %DIOXIDE_PATH%bin\>nul 2>&1
MKDIR %DIOXIDE_PATH%common\>nul 2>&1

ECHO Creating files...
COPY %~f0 %DIOXIDE_PATH%bin\d.bat>nul 2>&1
COPY %~f0 %DIOXIDE_PATH%bin\di.bat>nul 2>&1

ECHO Add to PATH... 
ECHO TO^(re^)DO

ECHO.
ECHO Dioxide %VERSION% ^(%BUILD%^) was installed on your system, you can now use it in your terminal.
PAUSE
EXIT

PAUSE

GOTO :CLOSE

@REM ========== MSG SECTION ==========

: Display Help msg
:HELP

ECHO Dioxide %VERSION% ^(%BUILD%^)
ECHO @Hppsrc on Twitter
ECHO https://www.github.com/Hppsrc/Dioxide
ECHO.
ECHO A Zoxide clone made using Windows Batch
ECHO. 
ECHO Usage:
ECHO    d ^<Directory/Path/Command^>
ECHO.
ECHO Commands:
ECHO    nothing here yet...
ECHO.
ECHO Options:
ECHO    -h      Get this text.
ECHO    -i      Install Dioxide.
ECHO    -c      Clears the folder registry.
ECHO    -v      Prints the version.
IF "%1"=="-hd" (
    ECHO.
    ECHO DEV Commands
    ECHO    -fi     Forces installation or upgrade.
    ECHO    -ig     Allows to run a Dioxide script anywhere.
    ECHO    -d      Enables echo on each execution, useful for debugging.
    ECHO    -a      Enable or disable administrator privileges check for installation.
    ECHO    -b      Create backup files of previous builds.
) ELSE (
    ECHO    -hd     Displays help for dev commands.
)

GOTO :EOF

@REM ========== ACTIONS SECTION ==========

: Add .dioxide_run to run anyway here
:IGNORE_RUN
IF EXIST %DIOXIDE_PATH%.dioxide_run ( DEL %DIOXIDE_PATH%.dioxide_run ) ELSE ( COPY /y nul %DIOXIDE_PATH%.dioxide_run >nul )
GOTO :EOF

: Add .enable_dev to enable echo
:DEV_MODE
IF EXIST %DIOXIDE_PATH%.enable_dev ( DEL %DIOXIDE_PATH%.enable_dev ) ELSE ( COPY /y nul %DIOXIDE_PATH%.enable_dev >nul )
GOTO :EOF

: Add .disable_adm to disable admin priv check at install
:ADM_MODE
IF EXIST %DIOXIDE_PATH%.disable_adm (
    DEL %DIOXIDE_PATH%.disable_adm
    ECHO Dioxide: Admin check ENABLED
) ELSE ( 
    COPY /y nul %DIOXIDE_PATH%.disable_adm >nul
    ECHO Dioxide: Admin check DISABLED
)
GOTO :EOF

: Add .create_back to create backups of prevs builds
:CREATE_BK 
IF EXIST %DIOXIDE_PATH%.create_back ( DEL %DIOXIDE_PATH%.create_back ) ELSE (  COPY /y nul %DIOXIDE_PATH%.create_back >nul )
GOTO :EOF

:ADD_COMMON
IF NOT EXIST %DIOXIDE_COMMON% ( COPY /y nul %DIOXIDE_COMMON% >nul )
IF NOT "%1"==".." (ECHO %CD%\%1>>%DIOXIDE_COMMON%)
GOTO :EOF

@REM ========== CLOSE SECTION ==========

: Exit script but not close CMD
:CLOSE

CLS 

: Exit script but not close CMD and dont clean screen
:CLOSE_RUN

@REM TODO UPDATE RANK SERVICE

TITLE %CD%
@ECHO ON