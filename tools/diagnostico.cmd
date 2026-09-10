@echo off
rem  Comprueba que la conexion sirve para trabajar con APEX / Data Pump.
rem  Uso: diagnostico.cmd [conexion]
setlocal
call "%~dp0_common.cmd" %1
if errorlevel 1 exit /b 1
set "RUN_SCRIPT=%SQLCL_ROOT%\scripts\diagnostico.sql"
set "RUN_ARGS="
set "RUN_SILENT=-S"
set "RUN_ONERR=continue none"
call "%~dp0_run.cmd"
