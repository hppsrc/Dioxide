: Hppsrc 2024
: Dioxide 

@ECHO OFF && CLS

: Variables
SET VERSION=0.1.0
SET VERSION_STATUS=ALPHA
SET BUILD=1727
SET PR_TITLE=%CD%
SET DIOXIDE_PATH=%LOCALAPPDATA%\Hppsrc\Dioxide\
TITLE Dioxide %VERSION%

: Check path ("Is installed?")
IF "%~d0%~p0"=="%DIOXIDE_PATH%bin\" ( GOTO PRERUN ) ELSE GOTO PREINSTALL

:PRERUN

ECHO %~n0 IS INSTALLED
PAUSE
EXIT 

:PREINSTALL

: Get Admin priv
NET SESSION >nul 2>&1
IF %errorLevel% == 0 (
    ECHO.
) else (
    ECHO Not running as administrator, restarting script
        
    ECHO Set UAC = CreateObject^("Shell.Application"^) > "%temp%\elevate.vbs"
    ECHO UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\elevate.vbs"
        
    "%temp%\elevate.vbs"
    DEL "%temp%\elevate.vbs"
    EXIT
)

CLS

: Check if CHOICE Exist
WHERE /q CHOICE && ECHO. || GOTO INSTALL_NC

: Choice Exist
:INSTALL

ECHO Welcome to the Dioxide installation process
ECHO Dioxide is a script that tries to replicate all the functions of Zoxide in Windows Batch.
ECHO.
ECHO You are about to install the version %VERSION% %VERSION_STATUS% (%BUILD%)
ECHO.
ECHO Want to continue?

CHOICE /m choose

IF %ERRORLEVEL%==1 GOTO CONTINUE_INSTALL
IF %ERRORLEVEL%==2 GOTO CLOSE

: Choice doesn't exist
:INSTALL_NC

ECHO Welcome to the Dioxide installation process
ECHO Dioxide is a script that tries to replicate all the functions of Zoxide in Windows Batch.
ECHO.
ECHO You are about to install the version %VERSION% %VERSION_STATUS% (%BUILD%)
ECHO.
ECHO Want to continue?
ECHO [Y/N]?

SET /p ANS=

IF %ANS%==y GOTO CONTINUE_INSTALL
IF %ANS%==n GOTO CLOSE
IF %ANS%==Y GOTO CONTINUE_INSTALL
IF %ANS%==N GOTO CLOSE

CLS
ECHO ERROR, You entered an invalid value, try again.
ECHO.
GOTO INSTALL_NC

: Install Dioxide
:CONTINUE_INSTALL

CLS

ECHO Creating directories...
mkdir %DIOXIDE_PATH%\bin\>nul 2>&1
ECHO Creating files...
COPY %~f0 %DIOXIDE_PATH%\bin\d.bat>nul 2>&1
COPY %~f0 %DIOXIDE_PATH%\bin\di.bat>nul 2>&1
ECHO Add to PATH...
SETX /M PATH "%PATH%;%localappdata%\Hppsrc\Dioxide\bin"

ECHO.
ECHO Dioxide %VERSION% was installed on your system, you can now use it in your terminal.
PAUSE
EXIT

PAUSE

:CLOSE

@ECHO ON && TITLE %PR_TITLE% && CLS && 