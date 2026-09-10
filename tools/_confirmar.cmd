@echo off
rem =====================================================================
rem  Helper interno. Si %OUT% existe y tiene contenido, pide confirmacion
rem  porque "apex export -force" borra la carpeta antes de escribir.
rem  Salta la pregunta si CONFIRM_SKIP=1.
rem =====================================================================
if "%CONFIRM_SKIP%"=="1" exit /b 0
if not exist "%OUT%" exit /b 0
dir /b /a "%OUT%" 2>nul | findstr /r "." >nul || exit /b 0
echo.
echo  [AVISO] La carpeta destino no esta vacia y sera BORRADA antes de exportar:
echo          %OUT%
echo.
set "RESP="
set /p "RESP=  Continuar? (s/N): "
if /i "%RESP%"=="s" exit /b 0
if /i "%RESP%"=="si" exit /b 0
echo  Cancelado.
exit /b 1
