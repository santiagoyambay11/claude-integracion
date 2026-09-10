@echo off
rem =====================================================================
rem  Guarda una conexion con nombre (y su clave) en el almacen de SQLcl.
rem  Uso: guardar-conexion.cmd <nombre> <usuario> <host:puerto/servicio>
rem =====================================================================
setlocal
for %%I in ("%~dp0..") do set "SQLCL_ROOT=%%~fI"
set "SQLCL=%SQLCL_ROOT%\sqlcl.cmd"
if "%~3"=="" goto :uso

set "TMPSQL=%TEMP%\sqlcl_save_%RANDOM%.sql"
> "%TMPSQL%" echo set feedback off
>> "%TMPSQL%" echo connect -save %~1 -savepwd -replace %~2@%~3
>> "%TMPSQL%" echo prompt
>> "%TMPSQL%" echo prompt ^>^> Conexion %~1 guardada correctamente.
>> "%TMPSQL%" echo prompt
>> "%TMPSQL%" echo exit

echo.
echo Guardando conexion "%~1"  (%~2@%~3)
echo Se te pedira la contrasena de %~2 ...
echo.
call "%SQLCL%" -L /nolog @"%TMPSQL%"
set "RC=%ERRORLEVEL%"
del "%TMPSQL%" >nul 2>&1
exit /b %RC%

:uso
echo.
echo Uso: guardar-conexion.cmd ^<nombre^> ^<usuario^> ^<host:puerto/servicio^>
echo.
echo Ejemplos:
echo   guardar-conexion.cmd MIBASE_DEV  miusuario localhost:1521/XEPDB1
echo   guardar-conexion.cmd MIBASE_PROD apex_app 10.0.0.5:1521/ORCLPDB1
echo.
echo Para Autonomous Database (wallet), copia el zip descomprimido en tns\
echo y usa el nombre de servicio del tnsnames.ora, por ejemplo:
echo   guardar-conexion.cmd ADB_DEV admin mibase_high
echo.
exit /b 1
