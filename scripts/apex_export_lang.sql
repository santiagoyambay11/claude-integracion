--
-- apex_export_lang.sql : exporta UNA aplicacion en formato APEXlang (.apx),
--                        el formato legible/versionable de APEX 24.2+.
-- Uso:  @apex_export_lang <application_id> <directorio_destino>
--
define APP_ID  = &1
define OUT_DIR = &2

prompt
prompt >> Exportando aplicacion &APP_ID en formato APEXlang  ->  &OUT_DIR
prompt

apex export -applicationid &APP_ID -dir &OUT_DIR -exptype APEXLANG -skipexportdate -force

prompt
prompt >> Listo. Validalo con:  apex validate -input &OUT_DIR
prompt
undefine APP_ID
undefine OUT_DIR
