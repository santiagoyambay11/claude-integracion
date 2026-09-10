--
-- apex_list.sql : inventario de aplicaciones APEX.
-- Uso:  @apex_list <filtro_workspace>      ('%' = todos)
--
define WS_FILTER = &1
set feedback off
prompt
prompt ===== Aplicaciones (workspace like '&WS_FILTER') =====
prompt
select workspace,
       workspace_id,
       application_id,
       alias,
       application_name,
       to_char(last_updated_on,'YYYY-MM-DD HH24:MI') as ultima_modificacion
  from apex_applications
 where workspace like '&WS_FILTER'
 order by workspace, application_id;

prompt
prompt ===== Version de APEX instalada =====
prompt
select version_no, api_compatibility
  from apex_release;
set feedback on
undefine WS_FILTER
