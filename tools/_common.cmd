@echo off
rem =====================================================================
rem  Helper interno. No se ejecuta suelto.
rem  Uso:  call "%~dp0_common.cmd" %1
rem
rem  Define: SQLCL_ROOT, SQLCL, PROJECT_ROOT, PROJECT_NAME,
rem          SQLCL_EXPORTS, STAMP, CONN, LOGON
rem
rem  El proyecto se detecta buscando un archivo proyecto.cmd desde la
rem  carpeta actual hacia arriba. Ese archivo define la conexion, el
rem  workspace de APEX y demas valores propios del proyecto.
rem =====================================================================
for %%I in ("%~dp0..") do set "SQLCL_ROOT=%%~fI"
if exist "%SQLCL_ROOT%\config\env.cmd" call "%SQLCL_ROOT%\config\env.cmd"
set "SQLCL=%SQLCL_ROOT%\sqlcl.cmd"

set "PROJECT_ROOT="
set "PROJECT_NAME="
set "_D=%CD%"

:_buscar
if exist "%_D%\proyecto.cmd" (
  set "PROJECT_ROOT=%_D%"
  goto :_hay_proyecto
)
for %%I in ("%_D%\..") do set "_P=%%~fI"
if /i "%_P%"=="%_D%" goto :_no_hay_proyecto
set "_D=%_P%"
goto :_buscar

:_hay_proyecto
call "%PROJECT_ROOT%\proyecto.cmd"
for %%I in ("%PROJECT_ROOT%") do set "PROJECT_NAME=%%~nxI"
if not defined SQLCL_EXPORTS set "SQLCL_EXPORTS=%PROJECT_ROOT%\exports"
goto :_conexion

:_no_hay_proyecto
if not defined SQLCL_EXPORTS set "SQLCL_EXPORTS=%CD%\exports"

:_conexion
if not exist "%SQLCL_EXPORTS%" mkdir "%SQLCL_EXPORTS%"
for /f "usebackq delims=" %%I in (`powershell -NoProfile -Command "Get-Date -Format yyyyMMdd-HHmmss"`) do set "STAMP=%%I"

set "CONN=%~1"
if "%CONN%"=="-" set "CONN="
if not defined CONN set "CONN=%SQLCL_DEFAULT_CONN%"
if not defined CONN goto :_sin_conexion

if not "%CONN%"=="%CONN:@=%" (set "LOGON=%CONN%") else (set "LOGON=-name %CONN%")
exit /b 0

:_sin_conexion
echo.
if defined PROJECT_ROOT (
  echo [ERROR] El proyecto "%PROJECT_NAME%" no define SQLCL_DEFAULT_CONN.
  echo         Editalo en: %PROJECT_ROOT%\proyecto.cmd
) else (
  echo [ERROR] No estas dentro de una carpeta de proyecto y no indicaste conexion.
  echo         Hace "cd" a la carpeta del proyecto, o pasa la conexion como
  echo         primer argumento, o crea un proyecto nuevo con:
  echo             nuevo-proyecto ^<nombre^>
)
echo.
echo         Conexiones guardadas:  listar-conexiones
echo.
exit /b 1
