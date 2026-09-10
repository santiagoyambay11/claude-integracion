# Proyecto <PROYECTO> — Oracle APEX / APEXlang

> Plantilla. Completar los marcadores `<ASI>` con el diagnóstico inicial
> (`diagnostico`) y borrar esta línea.

## Entorno

| | |
|---|---|
| Base | `<VERSION_BASE>`, PDB `<PDB>`, host `<HOST>` |
| APEX | `<VERSION_APEX>` |
| Workspace | `<WORKSPACE>` — id `<WORKSPACE_ID>` |
| Esquema de análisis | `<PARSING_SCHEMA>` |
| Aplicación | `<APP_ID>` — alias `<ALIAS>`, nombre `<NOMBRE_APP>` |
| Conexión SQLcl | `<CONEXION>` (guardada cifrada, no pedir contraseña) |
| Data Pump | `<DIRECTORIO_LOGICO>` |

> Si el esquema de análisis **no** es el usuario de la conexión, la cuenta
> necesita `APEX_ADMINISTRATOR_ROLE`. Sin eso, `apex export` falla con
> `ORA-20987` aunque el usuario sea DBA.

La herramienta vive en `<RUTA_HERRAMIENTA>`, fuera de este repo, y está en el
PATH junto con `<RUTA_HERRAMIENTA>\tools`. Los comandos detectan el proyecto
leyendo `proyecto.cmd` desde el directorio actual hacia arriba: hacer `cd` acá y
después van sin argumentos.

```
apex-listar                        apps del workspace
diagnostico                        base, APEX, workspaces, directorios, roles
apex-sync - <APP_ID>               export APEXlang a src/ (ruta fija, para git)
apex-exportar-lang - <APP_ID>      export a exports/ (instantánea, fuera de git)
conectar                           sesión interactiva
```

## Estructura

```
src/apex/app<APP_ID>/      fuente versionada
exports/                   instantáneas, ignorado por git
db/                        scripts SQL del proyecto
docs/                      documentación del trabajo hecho
```

## Estado

`<COMPLETAR: última validación, si está desplegado, si src/ y la base están
sincronizados>`

## Reglas

- **No ejecutar `apex validate` sin autorización explícita.** En aplicaciones
  grandes tarda más de quince minutos. Para el ciclo rápido, comprobaciones
  estáticas sobre los `.apx`: referencias por ID numérico, `interactiveGrid`
  apuntando a algo que no es grilla o que no tiene bloque `edit`, `formRegion`
  que no apunta a un `form`, `refresh` sin `affectedElements`, propiedades con
  valor `null`, y balance de paréntesis y llaves.
- **No importar sin aprobación.** El import despliega la aplicación completa a
  producción, es atómico y **elimina las páginas ausentes de la fuente**.
- **Antes de importar, sincronizar.** Exportar a `exports/` y comparar contra
  `src/`: un import pisa cualquier edición hecha en el App Builder desde el
  último export.
- **Antes de importar, pushear.** El commit que se despliega tiene que estar en
  el remoto.
- **Contrastar contra el diccionario antes de afirmar.** Si una referencia no
  resuelve, consultar si el componente existe en otra aplicación del workspace:
  son problemas distintos con soluciones distintas.
- **No emitir identificadores internos** (`savedReportMappingIdentifier`,
  `executionMappingIdentifier`). Los asigna APEX al importar.
- **Solo APEXlang.** Nunca generar llamadas `wwv_flow_imp_*`.
- **Un commit por caso**, con el motivo en el mensaje.
- La contraseña no va en ningún archivo. Está en el almacén cifrado de SQLcl.

## Antes de escribir SQL

Buscar si la aplicación ya define ese concepto — una función, o la consulta de
una región existente. Un componente nuevo con otro criterio muestra números
distintos a los que ya están en pantalla.

`<COMPLETAR: funciones de negocio que definan conceptos reutilizables>`

## Modelo de datos

`<COMPLETAR: las tablas principales y cómo se relacionan. Sacarlo de las
consultas de las regiones existentes, que son la fuente autoritativa, no de
adivinar por nombre de tabla.>`

`<COMPLETAR: items globales de la página 0, funciones de parámetros>`

## Documentación

`docs/` — documentación del proyecto.

La guía genérica del flujo, aplicable a cualquier proyecto, está en
`../APEXlang-guia-implementacion.md`.
