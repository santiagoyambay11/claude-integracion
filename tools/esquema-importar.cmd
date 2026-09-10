@echo off
rem =====================================================================
rem  Aplica un changelog Liquibase (generado con esquema-exportar.cmd)
rem  sobre la conexion indicada. Primero muestra el SQL, luego lo aplica.
rem
rem  Uso: esquema-importar.cmd <conexion> <carpeta_con_controller.xml>
rem =====================================================================
setlocal
call "%~dp0_common.cmd" %1
if errorlevel 1 exit /b 1
if "%~2"=="" goto :uso

set "IN=%~f2"
if not exist "%IN%\controller.xml" (
  echo [ERROR] No se encontro "%IN%\controller.xml"
  exit /b 1
)
set "INF=%IN:\=/%"

echo.
echo   Conexion : %CONN%
echo   Changelog: %IN%\controller.xml
echo.
echo   [AVISO] Esto MODIFICA el esquema de destino.
set "RESP="
set /p "RESP=  Continuar? (s/N): "
if /i not "%RESP%"=="s" if /i not "%RESP%"=="si" echo   Cancelado. & exit /b 1

set "RUN_SCRIPT=%SQLCL_ROOT%\scripts\esquema_import.sql"
set "RUN_ARGS=%INF%"
set "RUN_SILENT="
call "%~dp0_run.cmd"
exit /b %ERRORLEVEL%

:uso
echo.
echo Uso: esquema-importar.cmd ^<conexion^> ^<carpeta_con_controller.xml^>
echo.
exit /b 1
