@echo off
rem =====================================================================
rem  Importa una exportacion APEX clasica (f###.sql o install.sql de un
rem  export -split) fijando workspace y, opcionalmente, un id nuevo.
rem
rem  Uso: apex-importar-sql.cmd <conexion> <archivo.sql> <WORKSPACE> [nuevo_app_id]
rem  Ej.: apex-importar-sql.cmd MIBASE_QA exports\apex\app100\20260907\f100.sql VENTAS_WS
rem       apex-importar-sql.cmd MIBASE_QA .\f100.sql VENTAS_WS 200
rem =====================================================================
setlocal
call "%~dp0_common.cmd" %1
if errorlevel 1 exit /b 1
if "%~3"=="" goto :uso

set "IN=%~f2"
if not exist "%IN%" (
  echo [ERROR] No existe el archivo: %IN%
  exit /b 1
)
set "INF=%IN:\=/%"
set "WS=%~3"
set "NEWID=%~4"

echo.
echo   Conexion  : %CONN%
echo   Archivo   : %IN%
echo   Workspace : %WS%
if defined NEWID echo   Nuevo id  : %NEWID%
echo.

set "TMPSQL=%TEMP%\sqlcl_apeximp_%RANDOM%%RANDOM%.sql"
> "%TMPSQL%" echo set define off
>> "%TMPSQL%" echo set serveroutput on
>> "%TMPSQL%" echo whenever sqlerror exit failure
>> "%TMPSQL%" echo begin apex_application_install.set_workspace^(p_workspace =^> '%WS%'^); end;
>> "%TMPSQL%" echo /
>> "%TMPSQL%" echo begin apex_application_install.generate_offset; end;
>> "%TMPSQL%" echo /
if not defined NEWID goto :sin_id
>> "%TMPSQL%" echo begin apex_application_install.set_application_id^(p_application_id =^> %NEWID%^); end;
>> "%TMPSQL%" echo /
:sin_id
>> "%TMPSQL%" echo @"%INF%"
>> "%TMPSQL%" echo exit

call "%SQLCL%" %LOGON% @"%TMPSQL%"
set "RC=%ERRORLEVEL%"
del "%TMPSQL%" >nul 2>&1
exit /b %RC%

:uso
echo.
echo Uso: apex-importar-sql.cmd ^<conexion^> ^<archivo.sql^> ^<WORKSPACE^> [nuevo_app_id]
echo.
echo Nota: el WORKSPACE es el NOMBRE del workspace destino, no el id.
echo       Listalo con:  tools\apex-listar.cmd ^<conexion^>
echo.
exit /b 1
