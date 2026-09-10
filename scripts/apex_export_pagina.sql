--
-- apex_export_pagina.sql : exporta UNA pagina de una aplicacion en formato
--                          APEX clasico, instalable por separado.
-- Uso:  @apex_export_pagina <application_id> <numero_pagina> <directorio>
--
define APP_ID  = &1
define PAGINA  = &2
define OUT_DIR = &3

prompt
prompt >> Exportando pagina &PAGINA de la aplicacion &APP_ID  ->  &OUT_DIR
prompt

cd &OUT_DIR
apex export-components -applicationid &APP_ID -expcomponents "PAGE:&PAGINA" -expsupportingobjects N

prompt
prompt >> Listo. El archivo instalable quedo en &OUT_DIR
prompt
undefine APP_ID
undefine PAGINA
undefine OUT_DIR
