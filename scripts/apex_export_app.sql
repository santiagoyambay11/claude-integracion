--
-- apex_export_app.sql : exporta UNA aplicacion en formato APEX estandar,
--                       partida en un archivo por componente.
-- Uso:  @apex_export_app <application_id> <directorio_destino>
-- Ej.:  @apex_export_app 100 C:/exports/app100
--
define APP_ID  = &1
define OUT_DIR = &2

prompt
prompt >> Exportando aplicacion &APP_ID  ->  &OUT_DIR
prompt

apex export -applicationid &APP_ID -dir &OUT_DIR -split -exptranslations -expsupportingobjects Y -expsavedreports -exppubreports -skipexportdate -force

prompt
prompt >> Listo. Contenido en &OUT_DIR
prompt
undefine APP_ID
undefine OUT_DIR
