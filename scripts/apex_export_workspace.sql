--
-- apex_export_workspace.sql : exporta un workspace completo.
--   1) definicion del workspace + usuarios + archivos estaticos
--   2) todas sus aplicaciones (split, con traducciones)
--
-- Uso:  @apex_export_workspace <workspace_id> <dir_workspace> <dir_apps>
--
define WS_ID    = &1
define WS_DIR   = &2
define APPS_DIR = &3

prompt
prompt >> Workspace &WS_ID : definicion y archivos estaticos -> &WS_DIR
prompt
apex export -workspaceid &WS_ID -expworkspace -expfiles -dir &WS_DIR -force

prompt
prompt >> Workspace &WS_ID : todas las aplicaciones -> &APPS_DIR
prompt
apex export -workspaceid &WS_ID -split -exptranslations -expsupportingobjects Y -skipexportdate -dir &APPS_DIR -force

prompt
prompt >> Listo.
prompt
undefine WS_ID
undefine WS_DIR
undefine APPS_DIR
