@echo off
rem =====================================================================
rem  Exporta UNA aplicacion APEX en formato APEXlang (.apx) -- el formato
rem  legible y versionable en git de APEX 24.2+.
rem
rem  Uso: apex-exportar-lang.cmd <conexion> <app_id> [carpeta_destino]
rem  Ej.: apex-exportar-lang.cmd MIBASE_DEV 100
rem =====================================================================
setlocal
call "%~dp0_common.cmd" %1
if errorlevel 1 exit /b 1
if "%~2"=="" goto :uso

set "APPID=%~2"
set "OUT=%~3"
if not defined OUT set "OUT=%SQLCL_EXPORTS%\apexlang\app%APPID%\%STAMP%"
call "%~dp0_confirmar.cmd"
if errorlevel 1 exit /b 1
if not exist "%OUT%" mkdir "%OUT%"
set "OUTF=%OUT:\=/%"

echo.
echo   Conexion : %CONN%
echo   App      : %APPID%   (formato APEXlang)
echo   Destino  : %OUT%
echo.
set "RUN_SCRIPT=%SQLCL_ROOT%\scripts\apex_export_lang.sql"
set "RUN_ARGS=%APPID% %OUTF%"
set "RUN_SILENT="
call "%~dp0_run.cmd"
exit /b %ERRORLEVEL%

:uso
echo.
echo Uso: apex-exportar-lang.cmd ^<conexion^> ^<app_id^> [carpeta_destino]
echo Ej.: apex-exportar-lang.cmd MIBASE_DEV 100
echo.
exit /b 1
