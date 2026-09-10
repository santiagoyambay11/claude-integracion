--
-- dp_export.sql : export Data Pump (DBMS_DATAPUMP) de uno o varios esquemas.
--   El .dmp queda en el SERVIDOR, dentro del directorio logico indicado.
-- Uso:  @dp_export <esquemas> <directorio_logico> <dumpfile> <logfile>
-- Ej.:  @dp_export VENTAS,STOCK DATA_PUMP_DIR ventas.dmp ventas.log
--
define DP_SCHEMAS = &1
define DP_DIR     = &2
define DP_DUMP    = &3
define DP_LOG     = &4

prompt
prompt >> Data Pump EXPORT
prompt    esquemas : &DP_SCHEMAS
prompt    directorio: &DP_DIR   dump: &DP_DUMP   log: &DP_LOG
prompt

datapump export -schemas &DP_SCHEMAS -directory &DP_DIR -dumpfile &DP_DUMP -logfile &DP_LOG -includemetadata true -includerows true -reusefile true -parallel 1 -wait true

prompt
prompt >> Listo. El archivo esta en el servidor:
prompt    select directory_path from all_directories where directory_name='&DP_DIR';
prompt
undefine DP_SCHEMAS
undefine DP_DIR
undefine DP_DUMP
undefine DP_LOG
