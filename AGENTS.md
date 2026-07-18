# GAS-APP — Guía para agentes de código

> Archivo dirigido a agentes de IA. Resume la arquitectura, convenciones, comandos y consideraciones de seguridad del proyecto. El contenido está basado en los archivos reales del repositorio.

---

## 1. Visión general del proyecto

**GAS-APP** (nombre del paquete `GasoilProyecto`) es una aplicación de gestión de combustible y flota de transporte pesado construida con el **SAP Cloud Application Programming Model (CAP)** en Node.js. Expone un backend OData V4 y varias aplicaciones frontend **SAP Fiori / UI5** que consumen ese servicio.

- **Propósito principal:** administrar viajes, vehículos, choferes, rutas, proveedores, tanques, órdenes de carga y surtidos, y generar reportes de rendimiento de combustible.
- **Stack tecnológico:**
  - Backend: Node.js 20 + `@sap/cds` 9.x + Express.
  - Base de datos: PostgreSQL 16 en desarrollo/producción (`@cap-js/postgres`); SQLite disponible solo para ejecución en memoria (`--in-memory?`).
  - Frontend: SAPUI5 1.120+ / 1.145, aplicaciones Fiori Elements (List Report / Object Page) y OVP (Overview Page).
  - Otras herramientas: OData V2 adapter (`@cap-js-community/odata-v2-adapter`), `cds-plugin-ui5`, Google Maps API, Python 3 para scripts de soporte.
- **Idioma dominante:** español en comentarios, nombres de entidades, rutas, scripts y documentación de la app. Este documento se redacta en español por coherencia.

---

## 2. Estructura del proyecto

```
.
├── app/                          # Aplicaciones UI5 (Fiori)
│   ├── index.html                # Fiori Launchpad local (sandbox)
│   ├── services.cds              # Agrega anotaciones de UI de todas las apps
│   └── <app>-maint/              # Una carpeta por aplicación Fiori
├── db/                           # Modelos de dominio (CDS) y datos semilla
│   ├── schema.cds                # Punto de entrada de los modelos operacionales
│   ├── common.cds                # Listas de valores (code lists) compartidas
│   ├── data/                     # CSVs de carga inicial
│   ├── <Modulo>/<modulo>-schema.cds
│   └── Reporting/                # Modelos de reporting (hechos + dimensiones)
├── srv/                          # Servicios OData y lógica de negocio
│   ├── service.cds               # Agrega todos los servicios
│   ├── config-service.cds        # Servicio principal (vacío, se extiende)
│   ├── config-service.js         # Ensambla handlers personalizados en ConfigService
│   ├── server.js                 # Punto de entrada customizado (config DB por env)
│   ├── <Modulo>/service/         # Definiciones CDS y handlers JS por dominio
│   ├── <Modulo>/annotations/     # Anotaciones de UI/CDS por dominio
│   └── utils/                    # Utilidades compartidas (ej. cálculo de rendimiento)
├── scripts/                      # Scripts de utilidad/migración (Node.js y Python)
├── gen/                          # Artefactos generados por CDS (no versionar)
├── pg.yml                        # Docker Compose para PostgreSQL local
├── dockerfile                    # Imagen de producción
├── deploy.sql / deploy_clean.sql # Salida de `cds deploy --to postgres --dry`
└── package.json
```

### 2.1 Aplicaciones UI5 existentes

Carpetas bajo `app/` (excepto `index.html` y `services.cds`):

- `almacen-maint`, `caja-maint`, `choferes-maint`, `motores-maint`, `transmision-maint`, `vehiculos-maint`, `tanques-maint`, `ruta-maint`, `proveedor-maint`, `rubros-maint`, `ordenes-carga-maint`, `surtidos-maint`, `viajes-maint`, `calendario-viajes`, `overview-page`, `reporting-list`, `reportes`.

Cada app tiene su propio `package.json`, `ui5.yaml`, `webapp/manifest.json` y `webapp/Component.js`. La mayoría son **List Report Page V4** generadas con el SAP Fiori Application Generator.

### 2.2 Namespaces CDS

- `gas.app` — entidades operacionales (Viaje, Vehiculo, Chofer, Ruta, etc.).
- `gas.common` — code lists reutilizables (EstadoViaje, VH_State, EjesCamion, etc.).
- `gas.reporting` — modelo de reporting (HechoViaje, dimensiones y vistas agregadas).
- `ConfigService` — servicio OData principal que expone las entidades operacionales.
- `ReportingService` — servicio OData de reporting con hechos, dimensiones y agregaciones.

---

## 3. Arquitectura de ejecución

- **Servidor CAP:** Arranca por `srv/server.js` (CDS lo detecta automáticamente). Registra credenciales de PostgreSQL según el perfil y carga `dotenv`.
- **Servicios OData:**
  - `ConfigService` es el servicio central. Los archivos `srv/<Modulo>/service/<modulo>-service.cds` lo **extienden** con proyecciones de entidades. Los handlers JS (`srv/<Modulo>/service/<modulo>-service.js`) se registran desde `srv/config-service.js`.
  - `ReportingService` es un servicio separado (`/odata/v4/reporting/`) con datos de solo lectura para gráficos, KPIs y reportes.
  - `MapsService` (dentro de `ConfigService`) expone funciones `MapsApiKey()` y `MapsMapId()` para que el frontend obtenga las claves de Google Maps sin hardcodearlas.
- **Base de datos:**
  - Desarrollo/producción: PostgreSQL. Tablas y vistas se crean mediante `cds deploy` o `cds watch` (auto-deploy).
  - Vistas agregadas para el Overview Page se crean también con scripts auxiliares (`scripts/create-missing-overview-views.js`) cuando CDS no las genera por completo.
- **Frontend:** Las apps UI5 se sirven a través de `cds-plugin-ui5`. El launchpad local está en `app/index.html`.

---

## 4. Comandos de construcción y ejecución

### 4.1 Instalación

```bash
npm install
```

Usa `workspaces` (`app/*`), por lo que también instala dependencias de cada aplicación UI5.

### 4.2 Base de datos local (PostgreSQL)

```bash
docker compose -f pg.yml up -d   # Puerto 5441 mapeado a 5432
```

Credenciales por defecto (según `.cdsrc.json` y `pg.yml`):
- Host: `localhost`, puerto: `5441`
- Usuario: `postgres`, contraseña: `gas-db`, base de datos: `gas-db`

### 4.3 Ejecutar en desarrollo

```bash
npm start
# o
npm run watch
```

Esto arranca `cds watch` en el puerto 4004, con recarga automática y despliegue de esquema en la base de datos configurada.

### 4.4 Ejecutar con SQLite en memoria (sin PostgreSQL)

```bash
npm run serve
# Equivalente a: cds serve --with-mocks --in-memory?
```

### 4.5 Producción / Docker

```bash
npm run serve-production
# Equivalente a: cds s --profile prod
```

Imagen Docker:

```bash
docker build -t gas-app .
docker run -p 4004:4004 \
  -e GAS_DB_PROD_HOST=<host> \
  -e GAS_DB_PROD_PORT=5432 \
  -e GAS_DB_PROD_USER=postgres \
  -e GAS_DB_PROD_PASSWORD=<pass> \
  -e GAS_DB_PROD_NAME=gas-db \
  gas-app
```

> **Nota:** El `dockerfile` NO copia `.env` a la imagen. Las credenciales se inyectan por variables de entorno en runtime.

### 4.6 Desplegar esquema a PostgreSQL (dry run / real)

```bash
npx cds deploy --to postgres --dry      # Genera SQL sin ejecutar (como deploy.sql)
npx cds deploy --to postgres             # Ejecuta el despliegue
```

Los archivos `deploy.sql` y `deploy_clean.sql` existentes son salidas de ejecuciones anteriores `--dry`; sirven como referencia pero no como fuente única de verdad.

### 4.7 Lint

```bash
npx eslint .
```

Configuración: `eslint.config.mjs` exporta `cds.recommended` de `@sap/cds`.

---

## 5. Comandos de prueba

Actualmente **no hay tests automatizados** en el repositorio. El proyecto incluye la dependencia de desarrollo `@cap-js/cds-test`, pero no existe carpeta `test/` ni scripts `npm test`.

- Si se agregan tests, la convención de CAP es colocarlos en `test/` y ejecutarlos con `npx cds-test` o `npm test`.
- Hasta entonces, la verificación se hace manualmente con:
  - `cds watch` + navegación a las apps.
  - `npx eslint .` para revisión de estilo.
  - Ejecución de scripts de utilidad como `node scripts/create-missing-overview-views.js` para validar vistas.

---

## 6. Convenciones de código

### 6.1 Organización CDS

- **Modelos de dominio** en `db/<Modulo>/<modulo>-schema.cds`.
- **Servicios** en `srv/<Modulo>/service/<modulo>-service.cds`.
- **Anotaciones de UI** en `srv/<Modulo>/annotations/annotations<Entidad>.cds` y `app/<app>/annotations.cds`.
- **Puntos de agregación:**
  - `db/schema.cds` importa todos los esquemas con `using from ...`.
  - `srv/service.cds` importa todos los servicios.
  - `app/services.cds` importa todas las anotaciones de apps.
- **Convención de nombres:**
  - Entidades en singular: `Viaje`, `Vehiculo`, `Chofer`.
  - Servicios en PascalCase y terminados en `Service`: `ConfigService`, `ReportingService`.
  - Archivos y carpetas en kebab-case: `viaje-service.cds`, `orden-carga-service.js`.

### 6.2 JavaScript

- Extensión `.js` para handlers de servicio y scripts.
- Lógica de servicio en `srv/<Modulo>/service/<modulo>-service.js`.
- `srv/config-service.js` ensambla dinámicamente los handlers personalizados en `ConfigService`.
- `srv/server.js` centraliza la configuración de base de datos por entorno.
- Idioma de comentarios y mensajes: español.
- Se usan las APIs de CDS: `cds.entities`, `SELECT`, `UPDATE`, `INSERT`, `DELETE`, `cds.transaction()`.

### 6.3 Datos semilla

Los CSVs en `db/data/` se cargan automáticamente durante `cds watch` o `cds deploy`. Convención de nombres:

- `gas.app-<Entidad>.csv` para entidades operacionales.
- `gas.common-<CodeList>.csv` para listas de valores.
- `gas.reporting-<Entidad>.csv` para datos de reporting (si aplica).

Configuración en `package.json`:

```json
"cds": {
  "features": {
    "deploy_data_onconflict": "replace"
  }
}
```

Esto reemplaza datos existentes en conflictos durante el despliegue.

### 6.4 Anotaciones destacadas

- `@odata.draft.enabled` en entidades editables del Fiori Elements.
- `@odata.draft.bypass` en entidades que no requieren borradores.
- `@readonly` en entidades de reporting.
- `@Analytics.dataCategory` en vistas agregadas.

---

## 7. Consideraciones de seguridad

- **No subir credenciales:** `.env` y `.cdsrc-private.json` están en `.gitignore`. Siempre usar `.env.example` como plantilla.
- **Variables de entorno obligatorias:**
  - `GAS_DB_HOST`, `GAS_DB_PORT`, `GAS_DB_USER`, `GAS_DB_PASSWORD`, `GAS_DB_NAME` (desarrollo/test).
  - `GAS_DB_PROD_HOST`, `GAS_DB_PROD_PORT`, `GAS_DB_PROD_USER`, `GAS_DB_PROD_PASSWORD`, `GAS_DB_PROD_NAME` (producción).
  - `GOOGLE_MAPS_API_KEY`, `GOOGLE_MAPS_MAP_ID` (mapas).
- **Docker:** la imagen no incluye `.env`. Inyectar secretos con `-e` o mecanismos de Kubernetes/Cloud Foundry (`VCAP_SERVICES`, Secrets).
- **Validación de transiciones:** `Viajes` tiene validación de estados (`Programado → EnCurso/Finalizado/Cancelado`; `EnCurso → Finalizado`) en `srv/Viaje/service/viaje-service.js`. No existe un framework de autorización/autenticación en el código actual; el servicio está abierto por defecto si se expone.
- **Scripts de utilidad:** varios scripts en `scripts/` abren conexiones directas a PostgreSQL con credenciales por defecto. Si se ejecutan en producción, asegúrate de exportar las variables correctas.

---

## 8. Procesos de despliegue

1. **Base de datos:**
   - Levantar PostgreSQL (Docker Compose `pg.yml` o instancia administrada).
   - Copiar `.env.example` a `.env` y rellenar valores.
   - Ejecutar `npx cds deploy --to postgres` para crear tablas y vistas.
   - Si el Overview Page no muestra datos, ejecutar `node scripts/create-missing-overview-views.js`.

2. **Aplicación:**
   - Opción A: `npm run serve-production` directamente en un servidor Node.js 20.
   - Opción B: construir y ejecutar la imagen Docker (`docker build` + `docker run` con variables de entorno).

3. **Datos iniciales:**
   - Los CSVs en `db/data/` se cargan en el arranque si `deploy_data_onconflict` está configurado.
   - Para geocodificar rutas: `node scripts/geocode-rutas.js` (requiere `GOOGLE_MAPS_API_KEY`).
   - Para sincronizar puntos de rutas desde Excel: `python scripts/actualizar-rutas-puntos-postgres.py` (requiere `Rutas.xlsx` en la raíz y las librerías Python `openpyxl`, `psycopg2`).

4. **Sincronización de reporting:**
   - `ReportingService` intenta sincronizar hechos al inicio (`srv/Reporting/service/reporting-service.js`).
   - También expone la acción `sincronizar()` para refrescar manualmente.

---

## 9. Notas para el desarrollo

- **Vistas manuales:** el modelo de reporting usa vistas CDS (`db/Reporting/vistas-agregadas.cds`), pero algunas vistas del Overview Page (`ConfigService_Performance*`, `ConfigService_ViajesPor*`, etc.) se mantienen con scripts SQL en `scripts/create-missing-overview-views.js` porque la generación automática no cubre todos los casos.
- **Cálculo de rendimiento:** la lógica de regresión lineal está en `srv/utils/rendimientoCalculator.js`. Los coeficientes están documentados en la cabecera del archivo y se usan para calcular `rendimientoTeorico`, `combustibleTeorico` y `costoTeorico` en `srv/Viaje/service/viaje-service.js`.
- **Drafts:** las entidades editables en Fiori Elements usan `cds draft`. La validación de estados también se aplica en los borradores (`Viajes.drafts`).
- **No editar `gen/`:** es código generado por CDS. Está en `.gitignore`.
- **Extensiones UI5:** las apps personalizadas (por ejemplo, `vehiculosmaint.ext.controller.VehiculoOP`) se declaran en el `manifest.json` bajo `sap.ui5.extends.extensions`.

---

## 10. Resumen de perfiles de base de datos

| Perfil | Fuente de configuración | Uso típico |
|--------|------------------------|------------|
| `development` (default) | `.cdsrc.json` | `cds watch` local con PostgreSQL en `localhost:5441` |
| `test` | `srv/server.js` + variables de entorno | Tests / CI con PostgreSQL |
| `prod` | `srv/server.js` + variables de entorno | Producción / Docker |
| SQLite en memoria | `--in-memory?` | `npm run serve`, ejecución rápida sin BD |

> `.cdsrc.txt` (SQLite) parece ser una configuración alternativa/legada; el proyecto activo usa PostgreSQL.

---

*Última actualización: 2026-07-18 — basada en el contenido real del repositorio GAS-APP.*
