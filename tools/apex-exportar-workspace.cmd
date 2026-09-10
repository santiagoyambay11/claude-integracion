@echo off
rem =====================================================================
rem  Exporta un workspace completo: definicion + usuarios + archivos
rem  estaticos, y todas sus aplicaciones.
rem
rem  Uso: apex-exportar-workspace.cmd <conexion> <workspace_id> [carpeta]
rem  El workspace_id lo saca de:  tools\apex-listar.cmd <conexion>
rem =====================================================================
setlocal
call "%~dp0_common.cmd" %1
if errorlevel 1 exit /b 1
if "%~2"=="" goto :uso

set "WSID=%~2"
set "OUT=%~3"
if not defined OUT set "OUT=%SQLCL_EXPORTS%\apex\ws%WSID%\%STAMP%"
call "%~dp0_confirmar.cmd"
if errorlevel 1 exit /b 1
if not exist "%OUT%\workspace" mkdir "%OUT%\workspace"
if not exist "%OUT%\apps"      mkdir "%OUT%\apps"
set "WSF=%OUT:\=/%/workspace"
set "APPSF=%OUT:\=/%/apps"

echo.
echo   Conexion  : %CONN%
echo   Workspace : %WSID%
echo   Destino   : %OUT%
echo.
set "RUN_SCRIPT=%SQLCL_ROOT%\scripts\apex_export_workspace.sql"
set "RUN_ARGS=%WSID% %WSF% %APPSF%"
set "RUN_SILENT="
call "%~dp0_run.cmd"
exit /b %ERRORLEVEL%

:uso
echo.
echo Uso: apex-exportar-workspace.cmd ^<conexion^> ^<workspace_id^> [carpeta]
echo.
exit /b 1
