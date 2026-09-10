@echo off
rem =====================================================================
rem  Lanzador de Oracle SQLcl  (setup APEX / APEXlang)
rem
rem  Uso:
rem    sqlcl.cmd                                  -> abre SQLcl sin conectar
rem    sqlcl.cmd -name MI_CONEXION                -> conexion guardada
rem    sqlcl.cmd usuario@host:1521/servicio       -> pide la clave
rem    sqlcl.cmd -name MI_CONEXION @scripts\x.sql -> ejecuta un script
rem =====================================================================
setlocal
set "SQLCL_ROOT=%~dp0"
if "%SQLCL_ROOT:~-1%"=="\" set "SQLCL_ROOT=%SQLCL_ROOT:~0,-1%"

if exist "%SQLCL_ROOT%\config\env.cmd" call "%SQLCL_ROOT%\config\env.cmd"

rem ---- Java -----------------------------------------------------------
if defined SQLCL_JAVA_HOME if exist "%SQLCL_JAVA_HOME%\bin\java.exe" set "JAVA_HOME=%SQLCL_JAVA_HOME%"
if not exist "%JAVA_HOME%\bin\java.exe" (
  echo [ERROR] No se encontro un JDK valido.
  echo         Revisa SQLCL_JAVA_HOME en "%SQLCL_ROOT%\config\env.cmd"
  exit /b 1
)

rem ---- Perfil (login.sql) y ruta de scripts ---------------------------
set "SQLPATH=%SQLCL_ROOT%\config;%SQLCL_ROOT%\scripts"

rem ---- TNS_ADMIN local (tnsnames.ora / wallet) ------------------------
if exist "%SQLCL_ROOT%\tns\tnsnames.ora"  set "TNS_ADMIN=%SQLCL_ROOT%\tns"
if exist "%SQLCL_ROOT%\tns\sqlnet.ora"    set "TNS_ADMIN=%SQLCL_ROOT%\tns"

set "SQLCL_EXE=%SQLCL_ROOT%\sqlcl\bin\sql.exe"
if not exist "%SQLCL_EXE%" (
  echo [ERROR] No se encontro "%SQLCL_EXE%"
  exit /b 1
)

if "%SQLCL_PORTABLE%"=="1" (
  "%SQLCL_EXE%" -home "%SQLCL_ROOT%\home" %*
) else (
  "%SQLCL_EXE%" %*
)
exit /b %ERRORLEVEL%
