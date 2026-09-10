@echo off
rem =====================================================================
rem  Exporta la ESTRUCTURA del esquema conectado como changelog Liquibase
rem  (tablas, indices, vistas, paquetes, triggers, secuencias, grants...).
rem  Sirve para versionar en git y para recrear el esquema en otra base.
rem
rem  Uso: esquema-exportar.cmd <conexion> [carpeta_destino]
rem =====================================================================
setlocal
call "%~dp0_common.cmd" %1
if errorlevel 1 exit /b 1

set "OUT=%~2"
if not defined OUT set "OUT=%SQLCL_EXPORTS%\esquema\%STAMP%"
if not exist "%OUT%" mkdir "%OUT%"
set "OUTF=%OUT:\=/%"

echo.
echo   Conexion : %CONN%
echo   Destino  : %OUT%
echo.
set "RUN_SCRIPT=%SQLCL_ROOT%\scripts\esquema_export.sql"
set "RUN_ARGS=%OUTF%"
set "RUN_SILENT="
call "%~dp0_run.cmd"
exit /b %ERRORLEVEL%
