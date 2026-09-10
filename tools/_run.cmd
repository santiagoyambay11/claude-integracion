@echo off
rem =====================================================================
rem  Helper interno. Ejecuta un script y cierra SQLcl devolviendo codigo.
rem  Entradas: SQLCL, LOGON, RUN_SCRIPT, RUN_ARGS, RUN_SILENT, RUN_ONERR
rem =====================================================================
if not defined RUN_ONERR set "RUN_ONERR=exit failure"
set "TMPSQL=%TEMP%\sqlcl_run_%RANDOM%%RANDOM%.sql"
> "%TMPSQL%" echo whenever sqlerror %RUN_ONERR%
>> "%TMPSQL%" echo whenever oserror %RUN_ONERR%
>> "%TMPSQL%" echo @"%RUN_SCRIPT%" %RUN_ARGS%
>> "%TMPSQL%" echo exit
call "%SQLCL%" %RUN_SILENT% %LOGON% @"%TMPSQL%"
set "RC=%ERRORLEVEL%"
del "%TMPSQL%" >nul 2>&1
exit /b %RC%
