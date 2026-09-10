@echo off
rem =====================================================================
rem  Import Data Pump con remapeo de esquema.
rem  El .dmp debe estar ya en el directorio logico del SERVIDOR destino.
rem
rem  Uso: datapump-importar.cmd <conexion> <esq_origen> <esq_destino> <dumpfile> [directorio_logico]
rem  Ej.: datapump-importar.cmd MIBASE_QA VENTAS MIBASE_QA ventas.dmp
rem =====================================================================
setlocal
call "%~dp0_common.cmd" %1
if errorlevel 1 exit /b 1
if "%~4"=="" goto :uso

set "SRC=%~2"
set "TGT=%~3"
set "DUMP=%~4"
set "DIRLOG=%~5"
if not defined DIRLOG set "DIRLOG=%DP_DIRECTORY%"
if not defined DIRLOG set "DIRLOG=DATA_PUMP_DIR"
set "LOGF=imp_%STAMP%.log"

echo.
echo   Conexion   : %CONN%
echo   Remapeo    : %SRC%  -^>  %TGT%
echo   Directorio : %DIRLOG%
echo   Dumpfile   : %DUMP%
echo.
echo   [AVISO] Las tablas existentes en %TGT% se REEMPLAZAN (tableexists=replace).
set "RESP="
set /p "RESP=  Continuar? (s/N): "
if /i not "%RESP%"=="s" if /i not "%RESP%"=="si" echo   Cancelado. & exit /b 1

set "RUN_SCRIPT=%SQLCL_ROOT%\scripts\dp_import.sql"
set "RUN_ARGS=%SRC% %TGT% %DIRLOG% %DUMP% %LOGF%"
set "RUN_SILENT="
call "%~dp0_run.cmd"
exit /b %ERRORLEVEL%

:uso
echo.
echo Uso: datapump-importar.cmd ^<conexion^> ^<esq_origen^> ^<esq_destino^> ^<dumpfile^> [directorio_logico]
echo.
exit /b 1
