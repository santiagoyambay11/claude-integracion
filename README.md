# SQLcl — instalación reciclable

Esta carpeta contiene **solo la herramienta**. Nada de una base ni de una
aplicación en particular vive acá: eso va en cada carpeta de proyecto.

```
C:\SQLcl\
├─ sqlcl.cmd          lanzador (fija el JDK, SQLPATH y TNS_ADMIN)
├─ config\
│  ├─ env.cmd         configuración global (JDK, modo portable, carpeta de proyectos)
│  └─ login.sql       perfil que se carga en cada arranque
├─ scripts\           scripts .sql genéricos, parametrizados
├─ tools\             comandos (están en el PATH)
├─ tns\tnsnames.ora   alias de conexión, compartidos entre proyectos
├─ home\              conexiones guardadas cifradas + historial
└─ sqlcl\             Oracle SQLcl 26.2.2
```

## El modelo: una herramienta, muchos proyectos

Cada proyecto es una carpeta con un archivo **`proyecto.cmd`** en su raíz:

```
C:\Proyectos\
├─ PROYECTO_A\
│  ├─ proyecto.cmd     ← conexión, workspace de APEX, directorio Data Pump
│  ├─ exports\
│  └─ db\
└─ PROYECTO_B\
   ├─ proyecto.cmd
   └─ ...
```

Cualquier comando de `tools\` busca `proyecto.cmd` desde la carpeta actual
**hacia arriba**, lo carga, y a partir de ahí sabe a qué base conectarse, qué
workspace usar y dónde escribir las exportaciones. Es el mismo mecanismo que
usan `git` o `package.json`.

En la práctica:

```bash
apex-listar
```

Sin argumentos, sin rutas. Funciona igual desde cualquier subcarpeta del proyecto.

## Crear un proyecto nuevo

```bash
nuevo-proyecto EMPRESA_A
```

Crea la carpeta bajo `PROYECTOS_BASE` (definido en `config\env.cmd`) con su
`proyecto.cmd` en blanco, más `exports\` y `db\`. Después se edita el
`proyecto.cmd` con la conexión y el workspace, y ya responde a todos los comandos.

Para apuntar a otra base, primero guardá la conexión (se comparte entre proyectos):

```bash
guardar-conexion MIBASE usuario host:1521/servicio
```

## Comandos

Todos aceptan una conexión como primer argumento; si la omitís (o pasás `-`)
usan la del proyecto.

| Comando | Qué hace |
|---|---|
| `conectar` | sesión interactiva |
| `diagnostico` | versión de base y APEX, workspaces, directorios Data Pump, roles |
| `apex-listar` | apps del workspace del proyecto (`-todos` para toda la instancia) |
| `apex-exportar <id>` | export APEX clásico, split, con traducciones |
| `apex-exportar-lang <id>` | export APEXlang (`.apx`), versionable en git |
| `apex-exportar-workspace <ws_id>` | workspace + usuarios + estáticos + todas las apps |
| `apex-importar-lang <ruta> [id] [ws]` | valida e importa APEXlang |
| `apex-importar-sql <archivo> <ws> [id]` | importa un `f###.sql` clásico |
| `esquema-exportar` | estructura del esquema como changelog Liquibase |
| `esquema-importar <carpeta>` | aplica el changelog (muestra el SQL y pide confirmación) |
| `datapump-exportar <esquemas>` | export Data Pump |
| `datapump-importar <orig> <dest> <dump>` | import con remapeo de esquema |
| `guardar-conexion` / `listar-conexiones` | almacén de credenciales cifrado |
| `nuevo-proyecto <nombre>` | crea la carpeta de un proyecto |

Las exportaciones van siempre a `<proyecto>\exports\`, en subcarpetas con fecha
y hora. Si corrés un comando fuera de un proyecto, caen en `.\exports\`.

## Uso interactivo

```bash
conectar
```

Dentro de la sesión, `scripts\` está en el `SQLPATH`:

```
SQL> @apex_list %
SQL> @apex_export_lang 101 C:/temp/salida
SQL> @diagnostico
SQL> apex list
SQL> help apex
```

## Notas

- **Evitá rutas con espacios** en los destinos de exportación: `apex export -dir`
  no las maneja bien.
- Los comandos de exportación usan `-force`, que **borra la carpeta destino**
  antes de escribir. Si le pasás una carpeta propia que no está vacía, se pide
  confirmación primero.
- El JDK está fijado a Temurin 21 en `config\env.cmd`. Con el JDK 26 SQLcl
  imprime avisos de *restricted method* de JLine en cada arranque.
- `C:\SQLcl` y `C:\SQLcl\tools` están en el PATH del usuario.
