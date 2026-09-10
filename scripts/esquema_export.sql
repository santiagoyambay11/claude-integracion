--
-- esquema_export.sql : genera el changelog Liquibase del esquema actual
--                      (tablas, vistas, paquetes, secuencias, grants...).
-- Uso:  @esquema_export <directorio_destino>
--
define OUT_DIR = &1

cd &OUT_DIR

prompt
prompt >> Generando changelog del esquema en &OUT_DIR
prompt    (puede tardar varios minutos en esquemas grandes)
prompt

lb generate-schema -split -grants -synonyms -replace -overwrite-files -sql

prompt
prompt >> Listo. Archivo maestro: &OUT_DIR\controller.xml
prompt
undefine OUT_DIR
