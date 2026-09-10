--
-- esquema_import.sql : aplica un changelog Liquibase sobre la conexion actual.
-- Uso:  @esquema_import <directorio_con_controller.xml>
--
define IN_DIR = &1

cd &IN_DIR

prompt
prompt >> Vista previa del SQL que se ejecutara (no aplica nada todavia)
prompt
lb update-sql -changelog-file controller.xml

prompt
prompt >> Aplicando cambios sobre la conexion actual
prompt
lb update -changelog-file controller.xml

prompt
prompt >> Listo. Revisa el historial con:  lb history
prompt
undefine IN_DIR
