@echo off
rem =====================================================================
rem  Valida e importa una fuente APEXlang (carpeta, .zip o .apx).
rem
rem  Uso: apex-importar-lang.cmd <conexion> <ruta> [nuevo_app_id] [workspace]
rem
rem  Si no se indica workspace se usa APEX_WORKSPACE de config\env.cmd.
rem  Ej.: apex-importar-lang.cmd MIBASE exports\apexlang\app101\...\sistema
rem       apex-importar-lang.cmd MIBASE .\sistema 201 MI_WORKSPACE
rem =====================================================================
setlocal
call "%~dp0_common.cmd" %1
if errorlevel 1 exit /b 1
if "%~2"=="" goto :uso

set "IN=%~f2"
if not exist "%IN%" (
  echo [ERROR] No existe: %IN%
  exit /b 1
)
set "INF=%IN:\=/%"
set "NEWID=%~3"
set "WS=%~4"
if not defined WS set "WS=%APEX_WORKSPACE%"
if not defined WS goto :sin_ws

echo.
echo   Conexion : %CONN%
echo   Origen   : %IN%
echo   Workspace: %WS%
if defined NEWID echo   Nuevo id : %NEWID%
echo.

if defined NEWID (
  set "RUN_SCRIPT=%SQLCL_ROOT%\scripts\apex_import_lang_as.sql"
  set "RUN_ARGS=%INF% %NEWID% %WS%"
) else (
  set "RUN_SCRIPT=%SQLCL_ROOT%\scripts\apex_import_lang.sql"
  set "RUN_ARGS=%INF% %WS%"
)
set "RUN_SILENT="
call "%~dp0_run.cmd"
exit /b %ERRORLEVEL%

:sin_ws
echo.
echo [ERROR] Falta el workspace. Pasalo como 4o argumento o define
echo         APEX_WORKSPACE en config\env.cmd
echo.
exit /b 1

:uso
echo.
echo Uso: apex-importar-lang.cmd ^<conexion^> ^<ruta^> [nuevo_app_id] [workspace]
echo.
exit /b 1
