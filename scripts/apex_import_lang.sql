--
-- apex_import_lang.sql : valida e importa una fuente APEXlang
--                        (.apx / carpeta / zip) en el workspace indicado.
-- Uso:  @apex_import_lang <ruta_entrada> <workspace>
--
define IN_PATH = &1
define WS      = &2

prompt
prompt >> Validando &IN_PATH  (workspace &WS)
prompt
apex validate -input &IN_PATH -workspace &WS

prompt
prompt >> Importando &IN_PATH
prompt
apex import -input &IN_PATH -workspace &WS

prompt
prompt >> Listo.
prompt
undefine IN_PATH
undefine WS
