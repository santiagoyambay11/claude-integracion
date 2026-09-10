@echo off
rem  Lista las conexiones guardadas en el almacen de SQLcl.
setlocal
for %%I in ("%~dp0..") do set "SQLCL_ROOT=%%~fI"
set "SQLCL=%SQLCL_ROOT%\sqlcl.cmd"
set "LOGON=/nolog"
set "RUN_SCRIPT=%SQLCL_ROOT%\scripts\conexiones.sql"
set "RUN_ARGS="
set "RUN_SILENT=-S"
set "RUN_ONERR=continue none"
call "%~dp0_run.cmd"
