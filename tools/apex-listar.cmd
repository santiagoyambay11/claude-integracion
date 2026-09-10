@echo off
rem =====================================================================
rem  Lista las aplicaciones APEX del workspace del proyecto.
rem
rem  Uso: apex-listar [conexion] [-todos]
rem       apex-listar            -> solo el workspace del proyecto
rem       apex-listar -todos     -> todos los workspaces de la instancia
rem =====================================================================
setlocal
set "TODOS="
set "ARG1=%~1"
if /i "%ARG1%"=="-todos" (
  set "TODOS=1"
  set "ARG1="
)
if /i "%~2"=="-todos" set "TODOS=1"

call "%~dp0_common.cmd" %ARG1%
if errorlevel 1 exit /b 1

set "WS_FILTER=%APEX_WORKSPACE%"
if "%TODOS%"=="1" set "WS_FILTER=%%"
if not defined WS_FILTER set "WS_FILTER=%%"

set "RUN_SCRIPT=%SQLCL_ROOT%\scripts\apex_list.sql"
set "RUN_ARGS=%WS_FILTER%"
set "RUN_SILENT=-S"
set "RUN_ONERR=continue none"
call "%~dp0_run.cmd"
