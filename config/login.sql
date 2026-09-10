--
-- login.sql : perfil que SQLcl ejecuta al arrancar y tras cada CONNECT.
-- Se carga porque sqlcl.cmd apunta SQLPATH a esta carpeta.
-- Solo debe contener comandos SET (se ejecuta tambien sin conexion).
--
set pagesize 9999
set linesize 32767
set long 1000000
set longchunksize 32767
set trimspool on
set sqlblanklines on
set serveroutput on size unlimited
set feedback on
set verify off
set timing off
set null (null)
set sqlformat ansiconsole
set encoding utf-8

-- Prompt: usuario@conexion
set sqlprompt "_user@_connect_identifier> "

-- Editor para el comando EDIT
define _editor = notepad
