@echo off
rem =====================================================================
rem  Export Data Pump de uno o varios esquemas (estructura + datos).
rem  OJO: el .dmp se escribe en el SERVIDOR de base de datos, dentro del
rem  directorio logico (DBA_DIRECTORIES), no en este PC.
rem
rem  Uso: datapump-exportar.cmd <conexion> <esquemas> [dumpfile] [directorio_logico]
rem  Ej.: datapump-exportar.cmd MIBASE_DEV VENTAS
rem       datapump-exportar.cmd MIBASE_DEV "VENTAS,APEX_APP" ventas.dmp DATA_PUMP_DIR
rem =====================================================================
setlocal
call "%~dp0_common.cmd" %1
if errorlevel 1 exit /b 1
if "%~2"=="" goto :uso

set "SCHEMAS=%~2"
set "DUMP=%~3"
set "DIRLOG=%~4"
if not defined DIRLOG set "DIRLOG=%DP_DIRECTORY%"
if not defined DIRLOG set "DIRLOG=DATA_PUMP_DIR"
if not defined DUMP set "DUMP=exp_%STAMP%.dmp"
set "LOGF=%DUMP%.log"

echo.
echo   Conexion   : %CONN%
echo   Esquemas   : %SCHEMAS%
echo   Directorio : %DIRLOG%  (logico, en el servidor)
echo   Dumpfile   : %DUMP%
echo.
set "RUN_SCRIPT=%SQLCL_ROOT%\scripts\dp_export.sql"
set "RUN_ARGS=%SCHEMAS% %DIRLOG% %DUMP% %LOGF%"
set "RUN_SILENT="
call "%~dp0_run.cmd"
exit /b %ERRORLEVEL%

:uso
echo.
echo Uso: datapump-exportar.cmd ^<conexion^> ^<esquemas^> [dumpfile] [directorio_logico]
echo.
exit /b 1
