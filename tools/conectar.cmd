@echo off
rem =====================================================================
rem  Abre una sesion interactiva de SQLcl con la conexion del proyecto.
rem  Uso: conectar [conexion] [argumentos de sqlcl]
rem       conectar -  @script.sql     ("-" = usar la conexion del proyecto)
rem =====================================================================
setlocal
call "%~dp0_common.cmd" %1
if errorlevel 1 exit /b 1
shift
set "ARGS="
:_loop
if "%~1"=="" goto :_go
set "ARGS=%ARGS% %1"
shift
goto :_loop
:_go
call "%SQLCL%" %LOGON%%ARGS%
