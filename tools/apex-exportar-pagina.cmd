@echo off
rem =====================================================================
rem  Exporta UNA pagina de una aplicacion, instalable por separado.
rem
rem  Uso: apex-exportar-pagina.cmd <conexion> <app_id> <pagina> [destino]
rem  Ej.: apex-exportar-pagina.cmd - 101 1
rem
rem  Sale un .sql clasico que se instala con apex-importar-sql.cmd.
rem  OJO: la pagina sola no lleva componentes compartidos (listas de
rem  valores, esquemas de autorizacion, items de la pagina 0). Si el
rem  cambio toca alguno, hay que llevarlo aparte.
rem =====================================================================
setlocal
call "%~dp0_common.cmd" %1
if errorlevel 1 exit /b 1
if "%~3"=="" goto :uso

set "APPID=%~2"
set "PAGINA=%~3"
set "OUT=%~4"
if not defined OUT set "OUT=%SQLCL_EXPORTS%\paginas\app%APPID%\%STAMP%"
if not exist "%OUT%" mkdir "%OUT%"
set "OUTF=%OUT:\=/%"

echo.
echo   Conexion : %CONN%
echo   App      : %APPID%
echo   Pagina   : %PAGINA%
echo   Destino  : %OUT%
echo.
set "RUN_SCRIPT=%SQLCL_ROOT%\scripts\apex_export_pagina.sql"
set "RUN_ARGS=%APPID% %PAGINA% %OUTF%"
set "RUN_SILENT="
call "%~dp0_run.cmd"
exit /b %ERRORLEVEL%

:uso
echo.
echo Uso: apex-exportar-pagina.cmd ^<conexion^> ^<app_id^> ^<pagina^> [destino]
echo Ej.: apex-exportar-pagina.cmd - 101 1
echo.
exit /b 1
