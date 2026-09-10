--
-- diagnostico.sql : comprueba que la conexion sirve para trabajar con APEX.
-- Uso:  @diagnostico
--
set feedback off
prompt
prompt ===== Conexion =====
select user                                            as usuario,
       sys_context('userenv','db_name')                as base,
       sys_context('userenv','con_name')               as contenedor,
       sys_context('userenv','server_host')            as host
  from dual;

prompt
prompt ===== Version de la base =====
select banner_full from v$version;

prompt
prompt ===== APEX =====
select version_no, api_compatibility from apex_release;

prompt
prompt ===== Workspaces accesibles =====
select workspace_id, workspace from apex_workspaces order by workspace;

prompt
prompt ===== Esquemas del workspace =====
prompt (el esquema de analisis es el dueno de las tablas, no el usuario conectado)
select workspace_name, schema
  from apex_workspace_schemas order by 1, 2;

prompt
prompt ===== Directorios para Data Pump =====
select directory_name, directory_path from all_directories order by directory_name;

prompt
prompt ===== Privilegios de rol =====
select granted_role from user_role_privs order by 1;
set feedback on
