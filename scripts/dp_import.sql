--
-- dp_import.sql : import Data Pump con remapeo opcional de esquema.
-- Uso:  @dp_import <esquema_origen> <esquema_destino> <directorio_logico> <dumpfile> <logfile>
-- Ej.:  @dp_import VENTAS MIBASE_DEV DATA_PUMP_DIR ventas.dmp ventas_imp.log
--
define SRC_SCHEMA = &1
define TGT_SCHEMA = &2
define DP_DIR     = &3
define DP_DUMP    = &4
define DP_LOG     = &5

prompt
prompt >> Data Pump IMPORT
prompt    &SRC_SCHEMA  ->  &TGT_SCHEMA
prompt    directorio: &DP_DIR   dump: &DP_DUMP   log: &DP_LOG
prompt

datapump import -schemas &SRC_SCHEMA -remapschemas &SRC_SCHEMA:&TGT_SCHEMA -directory &DP_DIR -dumpfile &DP_DUMP -logfile &DP_LOG -includemetadata true -includerows true -tableexists replace -wait true

prompt
prompt >> Listo.
prompt
undefine SRC_SCHEMA
undefine TGT_SCHEMA
undefine DP_DIR
undefine DP_DUMP
undefine DP_LOG
