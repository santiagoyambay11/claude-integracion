@echo off
rem =====================================================================
rem  Exporta una aplicacion en formato APEXlang a una ruta FIJA del
rem  proyecto: src\apex\app<id>\
rem
rem  Diferencia con apex-exportar-lang:
rem    apex-exportar-lang -> exports\...\<fecha-hora>\   (instantanea)
rem    apex-sync          -> src\apex\app<id>\           (ruta estable)
rem
rem  La ruta estable es la que sirve para git: cada sync sobrescribe los
rem  mismos archivos y el commit muestra que cambio. Con carpetas por
rem  fecha, git guardaria una copia completa por cada exportacion.
rem
rem  Uso: apex-sync [conexion] <app_id>
rem       apex-sync            (usa APEX_APP_ID del proyecto)
rem =====================================================================
setlocal
call "%~dp0_common.cmd" %1
if errorlevel 1 exit /b 1

set "APPID=%~2"
if not defined APPID set "APPID=%APEX_APP_ID%"
if not defined APPID goto :uso
if not defined PROJECT_ROOT goto :sin_proyecto

set "OUT=%PROJECT_ROOT%\src\apex\app%APPID%"
if not exist "%PROJECT_ROOT%\src\apex" mkdir "%PROJECT_ROOT%\src\apex"
set "OUTF=%OUT:\=/%"

echo.
echo   Conexion : %CONN%
echo   App      : %APPID%   (APEXlang, ruta estable para git)
echo   Destino  : %OUT%
echo.
set "RUN_SCRIPT=%SQLCL_ROOT%\scripts\apex_export_lang.sql"
set "RUN_ARGS=%APPID% %OUTF%"
set "RUN_SILENT="
call "%~dp0_run.cmd"
set "RC=%ERRORLEVEL%"
if not "%RC%"=="0" exit /b %RC%
echo.
echo   Revisa los cambios con:  git status  /  git diff
echo.
exit /b 0

:sin_proyecto
echo.
echo [ERROR] apex-sync necesita estar dentro de una carpeta de proyecto.
echo.
exit /b 1

:uso
echo.
echo Uso: apex-sync [conexion] ^<app_id^>
echo      Sin app_id usa APEX_APP_ID de proyecto.cmd
echo.
exit /b 1
