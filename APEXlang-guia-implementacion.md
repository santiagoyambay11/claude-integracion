# APEXlang con agente de IA — guía de implementación

Oracle APEX 26.1 o superior. Reemplazar los marcadores `<ASI>` por los valores de
cada proyecto. Complementa al instructivo de VS Code: aquel cubre el flujo
manual, este el automatizado por terminal y agente.

---

## 1. Arquitectura

Tres capas con ciclos de vida distintos. Separarlas es lo que hace que un mismo
setup sirva para varios proyectos.

```
<RUTA_HERRAMIENTA>\                    HERRAMIENTA — una sola, reutilizable
├─ sqlcl.cmd                           lanzador propio
├─ config\  scripts\  tools\           configuración, scripts, comandos (al PATH)
├─ tns\                                tnsnames.ora
├─ home\                               credenciales cifradas — no se versiona
└─ sqlcl\                              binario de Oracle — no se versiona

<RUTA_TRABAJO>\
├─ skills\oracle-skills\               REPO AJENO — solo pull
├─ <PROYECTO_A>\                       REPO PROPIO
│  ├─ proyecto.cmd                     conexión, workspace, ids
│  ├─ CLAUDE.md                        contexto para el agente
│  ├─ src\apex\app<ID>\                fuente versionada, ruta estable
│  ├─ exports\                         instantáneas, fuera de git
│  └─ db\  docs\
└─ <PROYECTO_B>\                       REPO PROPIO
```

El clon de las skills va **fuera** de los repos de proyecto: un `.gitignore`
también funciona, pero la separación física no depende de que esté bien escrito.
Un solo clon sirve para todos.

---

## 2. Usuario de base de datos

**El rol `DBA` no alcanza para exportar una aplicación APEX.** Permite leer las
vistas `APEX_*` —por eso `apex list` funciona— pero no establece el *Security
Group ID* del workspace, que es lo que necesita el motor de exportación. Sin él,
`apex export` falla con `ORA-20987`.

Ese contexto se obtiene siendo el **esquema de análisis** del workspace, o con un
**rol de administrador de APEX**.

```sql
CREATE USER <USUARIO> IDENTIFIED BY "<PASSWORD>"
  DEFAULT TABLESPACE <TABLESPACE> TEMPORARY TABLESPACE TEMP;

GRANT CREATE SESSION TO <USUARIO>;            -- sin esto: ORA-01045
GRANT SELECT_CATALOG_ROLE TO <USUARIO>;       -- diccionario
GRANT APEX_ADMINISTRATOR_ROLE TO <USUARIO>;   -- sin esto: ORA-20987
```

Para una cuenta de solo exportación, `APEX_ADMINISTRATOR_READ_ROLE`. Solo si se
mueven datos:

```sql
GRANT DATAPUMP_EXP_FULL_DATABASE, DATAPUMP_IMP_FULL_DATABASE TO <USUARIO>;
GRANT READ, WRITE ON DIRECTORY <DIRECTORIO_LOGICO> TO <USUARIO>;
```

### Lo que no hay que otorgar

| Privilegio | Por qué no |
|---|---|
| `DBA` | No habilita nada de APEX y da acceso total |
| `CREATE USER` | La cuenta no administra usuarios |
| `CREATE ANY TABLE` | Permite escribir en esquemas ajenos |
| `WITH ADMIN OPTION` | Permite propagar privilegios a terceros |
| `CREATE TABLE`, `VIEW`, `PROCEDURE`, etc. | Solo si la cuenta crea objetos propios |

### Verificación

```sql
SELECT granted_role, admin_option FROM dba_role_privs WHERE grantee = '<USUARIO>';
SELECT privilege, admin_option   FROM dba_sys_privs  WHERE grantee = '<USUARIO>';
SELECT COUNT(*) FROM dba_objects WHERE owner = '<USUARIO>';  -- 0 => es seguro
                                                             -- revocar UNLIMITED
                                                             -- TABLESPACE
```

Para bajar un `ADMIN OPTION` hay que revocar y volver a otorgar; Oracle no
permite modificarlo.

---

## 3. Instalación

Al terminar, todo cuelga de una sola carpeta:

```
C:\SQLcl
├─ sqlcl\       distribución de Oracle, tal cual sale del zip
├─ tools\       los comandos del flujo
├─ scripts\     los .sql que usan esos comandos
├─ config\      env.cmd (tuyo) y la plantilla de CLAUDE.md
├─ tns\         tnsnames.ora (tuyo)
├─ home\        conexiones guardadas e historial
└─ sqlcl.cmd    el lanzador
```

**1. Descargar SQLcl** — `oracle.com/database/sqldeveloper/technologies/sqlcl/download/`,
archivo `sqlcl-latest.zip`. Mínimo **26.1.2**: APEXlang no existe antes.

**2. Descargar el JDK** — `adoptium.net/temurin/releases/?version=21`, Windows
x64, instalador `.msi`. JDK 17 o 21, **no 26**: con el 26 SQLcl imprime avisos de
*restricted method* en cada arranque.

**3. Armar la carpeta** — si el equipo ya tiene el repositorio de la herramienta:

```bash
git clone <URL_DEL_REPO> C:\SQLcl
```

Trae `tools\`, `scripts\`, `config\`, `tns\` y el lanzador. Ruta sin espacios.

**4. Descomprimir SQLcl adentro** — el zip trae una carpeta `sqlcl` en su raíz;
descomprimido en `C:\SQLcl` tiene que quedar `C:\SQLcl\sqlcl\bin\sql.exe`, que es
la ruta exacta que busca el lanzador. Si quedó `sqlcl-26.2\`, renombrala.

**5. El lanzador** — fija JDK, `SQLPATH` y `TNS_ADMIN` sin tocar el entorno
global. Lo esencial:

```bat
if exist "%SQLCL_ROOT%\config\env.cmd" call "%SQLCL_ROOT%\config\env.cmd"
if defined SQLCL_JAVA_HOME set "JAVA_HOME=%SQLCL_JAVA_HOME%"
set "SQLPATH=%SQLCL_ROOT%\config;%SQLCL_ROOT%\scripts"
if exist "%SQLCL_ROOT%\tns\tnsnames.ora" set "TNS_ADMIN=%SQLCL_ROOT%\tns"
"%SQLCL_ROOT%\sqlcl\bin\sql.exe" -home "%SQLCL_ROOT%\home" %*
```

`-home` mantiene conexiones, historial y ajustes dentro de la carpeta: la
instalación queda portable y no ensucia el perfil del usuario.

**6. Configuración local**

```bash
copy C:\SQLcl\config\env.cmd.ejemplo C:\SQLcl\config\env.cmd
```

Dos líneas marcadas adentro: la ruta del JDK —confirmala con
`dir "C:\Program Files\Eclipse Adoptium"`, el número de versión cambia— y la
carpeta donde van a vivir los proyectos. El archivo es de cada máquina y está
fuera del control de versiones.

**7. Agregar al PATH** — `C:\SQLcl` y `C:\SQLcl\tools`:

```powershell
[Environment]::SetEnvironmentVariable('Path', [Environment]::GetEnvironmentVariable('Path','User') + ';C:\SQLcl;C:\SQLcl\tools', 'User')
```

Cerrá la terminal y abrí una nueva: el PATH se lee al arrancar.

**8. Verificar**

```bash
sqlcl -V
```

Responde `SQLcl: Versión 26.x Production`. Si no encuentra el JDK, es el paso 6;
si la terminal no reconoce el comando, es el 7. **Hasta acá no hizo falta base de
datos**, así que cualquier problema posterior es de red o de permisos, no de
instalación.

**9. Datos de la base**

```bash
copy C:\SQLcl\tns\tnsnames.ora.ejemplo C:\SQLcl\tns\tnsnames.ora
```

Con los datos reales, que los da quien administra la base. Para Autonomous
Database, en vez de esto se descomprime el wallet directamente en `tns\`.

**10. Guardar la conexión**

```bash
guardar-conexion <CONEXION> <USUARIO> <HOST>:<PUERTO>/<SERVICIO>
```

Pide la contraseña una vez y la guarda cifrada en `home\connections`, contra tu
usuario de Windows: no queda en ningún archivo y no sirve en otra máquina.
`<CONEXION>` es un nombre que elegís vos. Si hay alias en el `tnsnames.ora`,
alcanza con el alias. Verificar con `listar-conexiones`.

**11. Primer proyecto** — `nuevo-proyecto <EMPRESA>`, y sigue la sección 4.

### Conexiones remotas

Con la base al otro lado de internet o de un túnel, keepalive TCP en el
descriptor. Sin esto una llamada larga sin tráfico —un import completo— la corta
un firewall intermedio y llega como `ORA-17008`:

```
<CONEXION> = (DESCRIPTION =
    (ENABLE = BROKEN)
    (ADDRESS = (PROTOCOL = TCP)(HOST = <HOST>)(PORT = <PUERTO>))
    (CONNECT_DATA = (SERVER = DEDICATED)(SERVICE_NAME = <SERVICIO>)))
```

Antes de culpar a la red, descartar que sea Oracle matando la sesión:

```sql
SELECT p.resource_name, p.limit FROM dba_profiles p, dba_users u
 WHERE u.username = '<USUARIO>' AND p.profile = u.profile
   AND p.resource_name IN ('IDLE_TIME','CONNECT_TIME');
```

---

## 4. Proyectos

Cada proyecto lleva un `proyecto.cmd` en su raíz:

```bat
set "SQLCL_DEFAULT_CONN=<CONEXION>"
set "APEX_WORKSPACE=<WORKSPACE>"
set "APEX_WORKSPACE_ID=<WORKSPACE_ID>"
set "APEX_APP_ID=<APP_ID>"
set "DP_DIRECTORY=<DIRECTORIO_LOGICO>"
```

Los comandos lo buscan desde el directorio actual **hacia arriba**, como `git`
con `.git`. En la práctica: `cd` al proyecto y van sin argumentos ni rutas, desde
cualquier subcarpeta. Fuera de un proyecto, el comando avisa en lugar de hacer
algo inesperado.

`nuevo-proyecto <EMPRESA>` genera de una vez `proyecto.cmd`, `.gitignore`,
`.gitattributes`, las carpetas y un **`CLAUDE.md` desde plantilla**, con el
nombre y la ruta de la herramienta ya sustituidos. Ese archivo es lo que hace que
una sesión nueva arranque con contexto sin que nadie lo retipee. Como se
commitea, la contraseña no va ahí; y conviene no inflarlo, porque todo lo que
contiene se carga en cada sesión — lo que se consulta a veces vive en `docs/`.

### De dónde sale cada marcador

Casi todos de correr `diagnostico` una vez, con la conexión ya guardada. Los
ejemplos son inventados.

| Marcador | De dónde sale | Ejemplo |
|---|---|---|
| `<CONEXION>` | El nombre que elegiste al guardarla. `listar-conexiones` | `TALLER_PROD` |
| `<VERSION_BASE>` | `diagnostico` → *Version de la base* | `Oracle 19c EE 19.3.0.0.0` |
| `<VERSION_APEX>` | `diagnostico` → *APEX*, columna `VERSION_NO` | `24.1.0` |
| `<PDB>` | `diagnostico` → *Conexion*, columna `CONTENEDOR` | `TALLERPDB` |
| `<HOST>` | `diagnostico` → *Conexion*, columna `HOST` | `10.0.0.7` |
| `<WORKSPACE>` y `<WORKSPACE_ID>` | `diagnostico` → *Workspaces accesibles*. En App Builder, arriba a la derecha | `TALLER` — `1234567890123456` |
| `<PARSING_SCHEMA>` | `diagnostico` → *Esquemas del workspace*. Es el dueño de las tablas, **no** el usuario de la conexión | `APP_TALLER` |
| `<APP_ID>` | `apex-listar`. En App Builder, el número de la tarjeta y el `p=` de la URL | `120` |
| `<ALIAS>` y `<NOMBRE_APP>` | `apex-listar`, las otras dos columnas | `TALLER_APP` — `120-Taller` |
| `<DIRECTORIO_LOGICO>` | `diagnostico` → *Directorios para Data Pump*. Si hay varios, el que apunte a una ruta escribible del servidor | `DATA_PUMP_DIR` |

Si `<PARSING_SCHEMA>` no coincide con el usuario de la conexión, la cuenta
necesita rol de administrador de APEX. Es la causa más común de que el primer
export falle.

Los bloques `<COMPLETAR: ...>` del `CLAUDE.md` no salen de ningún comando: el
modelo de datos y las funciones de negocio se sacan leyendo las consultas de las
regiones que ya existen, que son la fuente autoritativa. Adivinar por nombre de
tabla no sirve.

---

## 5. Repositorio del proyecto

### `src\` y `exports\` no son lo mismo

Un export con marca de fecha crea una carpeta nueva por corrida. Para archivar
está bien; **para git es inservible**: cada exportación agrega miles de archivos
en vez de mostrar qué cambió. Hace falta un segundo comando que exporte a una
**ruta fija**, siempre sobrescrita.

| | `exports\` | `src\apex\` |
|---|---|---|
| Ruta | con fecha y hora | fija |
| Git | ignorado | versionado |
| Para qué | instantánea, respaldo | ver qué cambió, commitear |

Con `-skipexportdate` el export de una app sin cambios es byte a byte idéntico:
un commit aparece solo cuando alguien tocó algo. Sin ese flag cada corrida cambia
una línea por archivo y los diffs no sirven.

### `.gitattributes` y `.gitignore`

Sin lo primero, al clonar en otra máquina todos los `.apx` figuran modificados
sin que nadie los toque, y un `.cmd` con LF rompe los `goto`.

```gitattributes
* text=auto eol=lf
*.apx *.sql *.json *.md   text eol=lf
*.cmd *.bat               text eol=crlf
*.png *.dmp               binary
```

```gitignore
exports/
*.dmp
*.sso
*.p12
wallet*.zip
```

El repositorio es privado: el fuente contiene la lógica de negocio completa.
Antes del primer commit, revisar el árbol buscando la contraseña en texto plano.

---

## 6. Ciclo de trabajo

```
sincronizar → editar → revisar diff → comprobar → importar → commit
```

### Sincronizar antes de editar

**Un import empuja la aplicación entera y pisa cualquier edición hecha en el App
Builder desde el último export.** Exportar a `exports\` y comparar contra `src\`:

```
diff -rq src/apex/app<ID>/<alias> exports/apexlang/app<ID>/<marca>/<alias>
```

Los archivos que difieran son los cambios propios **más** los ajenos. Para aislar
los ajenos, comparar dos exports sucesivos entre sí.

### Comportamiento del import

| | |
|---|---|
| Alcance | La aplicación completa. No acepta páginas sueltas |
| Atomicidad | Si falla, revierte todo. No deja estados parciales |
| Páginas ausentes | **Se eliminan.** Borrar un archivo borra la página de la base |
| Duración | Minutos en aplicaciones grandes |

El agente no importa sin aprobación, y el commit que se despliega tiene que estar
en el remoto antes de importar.

### Validar

`apex validate` sobre una aplicación grande tarda **más de quince minutos**: no
sirve como chequeo de rutina, solo al cerrar un ciclo, antes de un despliegue
importante o tras escribir un componente nuevo a mano. Para iterar, `sql /nolog`:
el compilador trabaja contra los archivos, no contra la base.

---

## 7. Comprobaciones estáticas antes de importar

Reemplazan a la validación completa en el ciclo diario. Corren en segundos sobre
los archivos y detectan las clases de error que frenan un import.

| Comprobación | Por qué falla |
|---|---|
| Referencias por ID numérico en `authorizationScheme`, `whenButtonPressed`, `add`, `update`, `delete` | El componente fue borrado o es de otra aplicación |
| `interactiveGrid: @X` donde `X` no es grilla | Un reporte no tiene columnas editables |
| `interactiveGrid: @X` sin bloque `edit` | Sin edición no hay evento de cambio de columna |
| `formRegion: @X` donde `X` no es `form` | El proceso no tiene destino válido |
| `refresh` sin `affectedElements` | No tiene sobre qué actuar |
| `<propiedad>: null` | El exportador escribe `null` donde APEX no tiene valor; el compilador espera un valor del catálogo |

Cero en todas no garantiza que el `validate` pase —cubre lo conocido— pero evita
la mayoría de los intentos fallidos. Gratis además: contar paréntesis y llaves de
cada archivo modificado; un desbalance delata una edición mal hecha antes de
intentar nada.

---

## 8. Catálogo de errores

| Tipo | Significado |
|---|---|
| `REFERENCE_NOT_FOUND` | Referencia a un componente inexistente, o que no cumple la condición del tipo de referencia |
| `DUPLICATED_COMPONENT` | Dos componentes con el mismo nombre en el mismo ámbito |
| `INVALID_PROPERTY` | Propiedad o valor fuera del catálogo |
| `LOV_NOT_FOUND` | Parámetro de lista de valores no admitido |
| `MISSING_REQUIRED_PROPERTY` | Falta una propiedad obligatoria |

No bloquean: `FILENAME_MISMATCH` y `PROPERTY_DEPRECATED`.

### Clasificar antes de corregir

Es lo que hace abordable una depuración de cientos de ítems.

- **Mecánicos.** Arreglo determinista, sin criterio a definir. Ejemplo: una
  referencia que apunta a un componente de otra aplicación cuando en la propia
  existe uno homónimo y solo uno.
- **De negocio.** Requieren una decisión que no está en el código. Ejemplo: una
  autorización que apunta a un esquema borrado — qué permiso debería proteger esa
  región no se puede inferir.

Antes de clasificar, contrastar contra el diccionario: si un ID no resuelve,
consultar si existe en otra aplicación del workspace. Esa consulta suele
convertir un grupo grande de decisiones de negocio en arreglos mecánicos.

### Patrones que se repiten

- **Muchos errores son consecuencia de otro.** Al hacer editable una grilla
  desaparecen las condiciones que el compilador marcaba como inválidas. Resolver
  primero las causas estructurales y recontar después.
- **Las copias de páginas arrastran referencias a la original.** Las páginas cuyo
  nombre termina en número o incluye `backup` concentran errores; a veces conviene
  borrarlas enteras.
- **El código desactivado a mano indica intención.** Un componente con
  `serverSideCondition: never` deliberado es candidato a borrarse, no a repararse.
  Y esa condición no silencia los errores: el compilador valida la referencia del
  bloque `when` sin mirar la condición.
- **Antes de borrar, verificar referencias entrantes.** Para una página: que
  ninguna la enlace, que no esté en listas ni breadcrumbs, y que sus items no se
  usen fuera.
- **Repetir una autorización en cada columna no agrega control.** Si la región no
  renderiza, las columnas tampoco, y el esquema se evalúa una vez por página
  igual —suelen estar en `Once per page view`. El control va en el contenedor.

---

## 9. Configuración del agente

`github.com/oracle/skills` — los plugins relevantes son `apex` (incluye APEXlang)
y `db`.

```
git config --global core.longpaths true     # Windows, o el checkout falla
git clone https://github.com/oracle/skills.git <RUTA_TRABAJO>\skills\oracle-skills
git -C <RUTA_TRABAJO>\skills\oracle-skills pull      # actualizar
```

Si el entorno soporta plugins, se registra el clon local como marketplace; si no,
sus assets se leen directamente. El contenido está en los `.md` y `.json`; las
herramientas `.mjs` son proyecciones sobre eso y requieren Node.

Lo concreto que aporta: el contrato de cada componente distingue propiedades
**requeridas** de **opcionales**. Los identificadores internos que aparecen en
todo export —`savedReportMappingIdentifier`, `executionMappingIdentifier`— no
están en ninguna de las dos listas: **no se emiten al generar código nuevo**. Los
asigna APEX al importar; inventar un número arriesga una colisión.

Las reglas de trabajo del agente no se escriben a mano: están en la plantilla
`config\plantilla-CLAUDE.md` y el alta de proyecto las copia. La que más cambia
la calidad de las respuestas es **contrastar contra el diccionario antes de
afirmar**: un ID que no resuelve puede ser un componente borrado o uno de otra
aplicación, y son problemas distintos con soluciones distintas.

---

## 10. Prompts de arranque

Los prompts se pegan en una sesión del agente **abierta en la carpeta del
proyecto**: es lo que hace que lea el `CLAUDE.md` solo. Abierta en otro lado,
arranca a ciegas.

```bash
cd <RUTA_TRABAJO>\<PROYECTO>
```

Los marcadores `<ASI>` se reemplazan **antes** de pegar. Si le dejás el marcador,
el agente pregunta o —peor— inventa.

| Situación | Prompt |
|---|---|
| Proyecto recién creado, nunca exportado | 10.1 |
| Ya está exportado, quiero saber qué está roto | 10.2 |
| Tengo la lista de errores y voy a corregir | 10.3 |
| Voy a desplegar a la base | 10.4 |
| Quiero agregar una pantalla o un componente | 10.5 |
| Auditar los permisos de la cuenta | 10.6 |

### 10.0 Primera vez: probar el circuito en seco

Corrida descartable, solo lectura, antes de tocar una aplicación real:

```bash
nuevo-proyecto PRUEBA
```

Poné en su `proyecto.cmd` la conexión que ya guardaste y, parado en esa carpeta,
corré `diagnostico` y `apex-listar`. Si los dos responden, el entorno está sano:
lanzador, JDK, TNS, credencial y detección de proyecto. Si `diagnostico` falla,
el problema es de entorno y no tiene sentido seguir — sección 11.

Recién ahí abrí el agente en esa carpeta y probá el 10.1. Al terminar, borrá la
carpeta.

### 10.1 Alta de proyecto

**Antes:** proyecto creado y `diagnostico` respondiendo.

```
Vamos a preparar un proyecto APEXlang nuevo.
Conexión: <CONEXION> · Workspace: <WORKSPACE> · Aplicación: <APP_ID>

1. Verificá la conexión y traeme el diagnóstico: versión de base y de APEX,
   workspaces accesibles, esquema de análisis del workspace, directorios de
   Data Pump y roles efectivos del usuario.
2. Completá el CLAUDE.md con lo que devuelva el diagnóstico: entorno,
   conexión, workspace, esquema de análisis y estado.
3. Inicializá el repositorio y hacé el primer commit.

No exportes todavía. Mostrame el diagnóstico y esperá.
```

Con datos inventados, la primera línea queda
`Conexión: TALLER_PROD · Workspace: TALLER · Aplicación: 120`.

**Esperá:** el diagnóstico en pantalla y el `CLAUDE.md` completo. Si el esquema
de análisis no coincide con el usuario de la conexión, la cuenta necesita rol de
administrador de APEX: mejor saberlo acá que en el primer export.

### 10.2 Primera auditoría

**Antes:** 10.1 terminado. Este prompt **sí** corre `apex validate`, los quince
minutos. Es la única vez que conviene.

```
Exportá la aplicación <APP_ID> en APEXlang a la ruta versionada y corré
apex validate una vez.

1. Contá los errores por tipo.
2. Agrupá por causa, no por página. Si veinte errores son el mismo problema
   repetido, presentámelo como un problema.
3. Clasificá cada grupo en mecánicos (arreglo determinista) o de negocio
   (requieren una decisión que no está en el código).
4. Antes de clasificar, contrastá contra el diccionario: si una referencia
   no resuelve, consultá si el componente existe en otra aplicación.

No corrijas nada todavía.
```

**Esperá:** una lista de grupos, no de errores sueltos. Si devuelve doscientas
líneas sin agrupar, no sirve: pedile que reagrupe por causa.

### 10.3 Ciclo de corrección

**Antes:** la clasificación de 10.2. Se corre una vez por grupo.

```
Vamos con <GRUPO>, uno a uno.

Para cada caso mostrame qué es, dónde está, por qué falla y qué proponés,
incluyendo dónde verlo en el App Builder.

Esperá mi confirmación antes de tocar nada.

Después de cada cambio verificá que no queden referencias rotas ni bloques
desbalanceados, y commiteá ese caso solo, con el motivo en el mensaje.

No corras apex validate sin que te lo pida.
```

`<GRUPO>` es el nombre que le puso el agente al clasificar.

**Esperá:** un caso por vez, y que frene. Un commit por caso hace que el
historial sirva de documentación y que revertir uno no arrastre los demás.

### 10.4 Antes de importar

```
Vamos a importar. Antes:

1. Exportá a exports/ y compará contra src/. Decime qué difiere y separá
   nuestros cambios de los hechos en el App Builder.
2. Si hay algo editado en el navegador desde el último export, traelo primero.
3. Corré las comprobaciones estáticas.
4. Pusheá: el commit que se despliega tiene que estar en el remoto.

Recién ahí dame el comando. Decime exactamente qué entra, incluidos los
cambios que alteran comportamiento.
```

**Esperá:** el listado de diferencias antes del comando. El paso 1 no es
burocracia: lo que alguien haya tocado en el App Builder desde el último export
se pierde en el import, sin aviso.

### 10.5 Componente nuevo

```
Necesito <DESCRIPCION> en la página <PAGINA>.

Antes de escribir nada:

1. Buscá si la aplicación ya define ese concepto: una función, o la consulta
   de una región existente. Si existe, usá ese criterio.
2. Probá la consulta contra la base y mostrame el resultado.
3. Buscá un componente equivalente ya exportado y seguí su forma.
4. Consultá el contrato de la skill para saber qué propiedades son
   requeridas. No emitas identificadores internos.

Mostrame el plan antes de escribir el archivo.
```

`<DESCRIPCION>` concreto, no genérico: *un reporte interactivo de los diez
artículos más vendidos*.

**Esperá:** el resultado de la consulta antes del archivo. El punto 1 evita el
error más caro: un componente nuevo con otro criterio muestra números distintos a
los que ya están en la misma pantalla, y nadie sabe cuál está bien.

### 10.6 Revisión de permisos

```
Revisá los privilegios de <USUARIO> contra lo que este flujo necesita y
pasame un script para dejarlo en el mínimo.

Verificá antes si la cuenta tiene objetos propios o cuotas en tablespaces,
porque eso cambia qué se puede revocar sin romper nada.

Incluí el estado antes y después, y un rollback.
```

**Esperá:** un script para revisar y ejecutar vos, no una ejecución. Los `REVOKE`
los corre un DBA, no la cuenta que se está recortando.

---

## 11. Errores frecuentes

| Síntoma | Causa | Solución |
|---|---|---|
| `ORA-01045: sin privilegio CREATE SESSION` | Cuenta sin grants | Sección 2. Las credenciales son correctas: si estuvieran mal sería `ORA-01017` |
| `ORA-20987: Security Group ID is invalid` | Falta rol de APEX | `APEX_ADMINISTRATOR_ROLE`. `DBA` no sirve |
| `ORA-17008` durante el import | Corte de red en llamada larga | `(ENABLE = BROKEN)` en el descriptor |
| `Multiple workspaces available` | La conexión ve más de uno | `-workspace <NOMBRE>` o `-workspaceid <ID>` |
| `Filename too long` al clonar | Rutas largas de Windows | `git config --global core.longpaths true` |
| Un `.cmd` falla en un `goto` | Guardado con LF | CRLF — ver `.gitattributes` |
| Al clonar, todos los `.apx` modificados | Conversión de fin de línea | `.gitattributes` con `eol=lf` |
| Un cambio del App Builder desapareció | El import empujó la app entera | Sincronizar antes de importar |
| `apex` no se reconoce en la terminal | No es un comando del sistema | Es un subcomando de SQLcl |
| Salida SQL ilegible | Formato por defecto | `SET LINESIZE 200`, `SET PAGESIZE 100` |

---

## Referencias

- Oracle APEX — Using SQLcl with APEXlang
- SQL Developer for VS Code — Working with APEXlang applications
- Skills oficiales de Oracle: `github.com/oracle/skills`
