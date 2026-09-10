@echo off
rem =====================================================================
rem  Exporta UNA aplicacion APEX en formato estandar (split, 1 archivo por
rem  componente) con traduciones y objetos de soporte.
rem
rem  Uso: apex-exportar.cmd <conexion> <app_id> [carpeta_destino]
rem  Ej.: apex-exportar.cmd MIBASE_DEV 100
rem =====================================================================
setlocal
call "%~dp0_common.cmd" %1
if errorlevel 1 exit /b 1
if "%~2"=="" goto :uso

set "APPID=%~2"
set "OUT=%~3"
if not defined OUT set "OUT=%SQLCL_EXPORTS%\apex\app%APPID%\%STAMP%"
call "%~dp0_confirmar.cmd"
if errorlevel 1 exit /b 1
if not exist "%OUT%" mkdir "%OUT%"
set "OUTF=%OUT:\=/%"

echo.
echo   Conexion : %CONN%
echo   App      : %APPID%
echo   Destino  : %OUT%
echo.
set "RUN_SCRIPT=%SQLCL_ROOT%\scripts\apex_export_app.sql"
set "RUN_ARGS=%APPID% %OUTF%"
set "RUN_SILENT="
call "%~dp0_run.cmd"
exit /b %ERRORLEVEL%

:uso
echo.
echo Uso: apex-exportar.cmd ^<conexion^> ^<app_id^> [carpeta_destino]
echo Ej.: apex-exportar.cmd MIBASE_DEV 100
echo.
exit /b 1
