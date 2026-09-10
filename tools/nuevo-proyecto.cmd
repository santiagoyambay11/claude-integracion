@echo off
rem =====================================================================
rem  Crea la carpeta de un proyecto nuevo con su proyecto.cmd.
rem
rem  Uso: nuevo-proyecto <nombre> [carpeta_base]
rem  Ej.: nuevo-proyecto EMPRESA_A
rem       nuevo-proyecto EMPRESA_B D:\trabajo
rem
rem  Sin carpeta_base usa PROYECTOS_BASE de config\env.cmd.
rem =====================================================================
setlocal
for %%I in ("%~dp0..") do set "SQLCL_ROOT=%%~fI"
if exist "%SQLCL_ROOT%\config\env.cmd" call "%SQLCL_ROOT%\config\env.cmd"
if "%~1"=="" goto :uso

set "NOMBRE=%~1"
set "BASE=%~2"
if not defined BASE set "BASE=%PROYECTOS_BASE%"
if not defined BASE goto :sin_base
set "DEST=%BASE%\%NOMBRE%"

if exist "%DEST%\proyecto.cmd" (
  echo [ERROR] Ya existe un proyecto en: %DEST%
  exit /b 1
)

mkdir "%DEST%\exports" 2>nul
mkdir "%DEST%\db" 2>nul

> "%DEST%\proyecto.cmd" echo @echo off
>> "%DEST%\proyecto.cmd" echo rem ===================================================================
>> "%DEST%\proyecto.cmd" echo rem  Proyecto: %NOMBRE%
>> "%DEST%\proyecto.cmd" echo rem  Lo carga automaticamente cualquier comando de C:\SQLcl\tools
>> "%DEST%\proyecto.cmd" echo rem  ejecutado desde esta carpeta o cualquier subcarpeta.
>> "%DEST%\proyecto.cmd" echo rem ===================================================================
>> "%DEST%\proyecto.cmd" echo.
>> "%DEST%\proyecto.cmd" echo rem Conexion guardada (crearla con: guardar-conexion ^<nombre^> ^<usuario^> ^<alias^>)
>> "%DEST%\proyecto.cmd" echo set "SQLCL_DEFAULT_CONN="
>> "%DEST%\proyecto.cmd" echo.
>> "%DEST%\proyecto.cmd" echo rem Workspace de APEX (nombre e id). Verlos con: apex-listar
>> "%DEST%\proyecto.cmd" echo set "APEX_WORKSPACE="
>> "%DEST%\proyecto.cmd" echo set "APEX_WORKSPACE_ID="
>> "%DEST%\proyecto.cmd" echo.
>> "%DEST%\proyecto.cmd" echo rem Directorio logico de la base para Data Pump
>> "%DEST%\proyecto.cmd" echo set "DP_DIRECTORY=DATA_PUMP_DIR"

mkdir "%DEST%\docs" 2>nul

rem --- CLAUDE.md a partir de la plantilla, sustituyendo el nombre ---
if exist "%SQLCL_ROOT%\config\plantilla-CLAUDE.md" (
  powershell -NoProfile -Command ^
    "(Get-Content -Raw -Encoding UTF8 '%SQLCL_ROOT%\config\plantilla-CLAUDE.md')" ^
    " -replace '<PROYECTO>', '%NOMBRE%'" ^
    " -replace '<RUTA_HERRAMIENTA>', '%SQLCL_ROOT%'" ^
    " | Set-Content -Encoding UTF8 '%DEST%\CLAUDE.md'"
)

rem --- .gitignore y .gitattributes ---
> "%DEST%\.gitignore" echo exports/
>> "%DEST%\.gitignore" echo *.dmp
>> "%DEST%\.gitignore" echo *.sso
>> "%DEST%\.gitignore" echo *.p12
>> "%DEST%\.gitignore" echo wallet*.zip

> "%DEST%\.gitattributes" echo * text=auto eol=lf
>> "%DEST%\.gitattributes" echo *.apx text eol=lf
>> "%DEST%\.gitattributes" echo *.sql text eol=lf
>> "%DEST%\.gitattributes" echo *.md text eol=lf
>> "%DEST%\.gitattributes" echo *.json text eol=lf
>> "%DEST%\.gitattributes" echo *.cmd text eol=crlf
>> "%DEST%\.gitattributes" echo *.bat text eol=crlf
>> "%DEST%\.gitattributes" echo *.png binary
>> "%DEST%\.gitattributes" echo *.dmp binary

echo.
echo   Proyecto "%NOMBRE%" creado en:
echo     %DEST%
echo.
echo   Generados: proyecto.cmd, CLAUDE.md, .gitignore, .gitattributes
echo              exports\  db\  docs\
echo.
echo   Siguiente paso:
echo     1^) editar  %DEST%\proyecto.cmd
echo     2^) cd "%DEST%"
echo     3^) apex-listar
echo.
exit /b 0

:sin_base
echo [ERROR] No hay carpeta base. Pasala como 2o argumento o define
echo         PROYECTOS_BASE en C:\SQLcl\config\env.cmd
exit /b 1

:uso
echo.
echo Uso: nuevo-proyecto ^<nombre^> [carpeta_base]
echo.
exit /b 1
