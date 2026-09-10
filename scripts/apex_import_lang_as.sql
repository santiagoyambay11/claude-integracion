--
-- apex_import_lang_as.sql : importa una fuente APEXlang cambiando el
--                           id de aplicacion y el workspace destino.
-- Uso:  @apex_import_lang_as <ruta_entrada> <nuevo_app_id> <workspace>
--
define IN_PATH = &1
define NEW_ID  = &2
define WS      = &3

prompt
prompt >> Validando &IN_PATH  (workspace &WS)
prompt
apex validate -input &IN_PATH -workspace &WS

prompt
prompt >> Importando &IN_PATH  como app &NEW_ID en workspace &WS
prompt
apex import -input &IN_PATH -id &NEW_ID -workspace &WS

prompt
prompt >> Listo.
prompt
undefine IN_PATH
undefine NEW_ID
undefine WS
