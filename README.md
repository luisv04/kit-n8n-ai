# Kit n8n AI

Un entorno completo de desarrollo con n8n, PostgreSQL, Qdrant y un extractor de documentos OCR, todo orquestado con Docker Compose.

## 📋 Tabla de Contenidos

- [Características](#características)
- [Requisitos Previos](#requisitos-previos)
- [Estructura del Proyecto](#estructura-del-proyecto)
- [Configuración Inicial](#configuración-inicial)
- [Despliegue](#despliegue)
- [Importación de Datos](#importación-de-datos)
- [Servicios Incluidos](#servicios-incluidos)
- [Puertos](#puertos)
- [Solución de Problemas](#solución-de-problemas)

## 🚀 Características

- **n8n**: Plataforma de automatización de workflows con interfaz visual
- **PostgreSQL**: Base de datos relacional para persistencia de datos
- **Qdrant**: Base de datos vectorial para aplicaciones de IA
- **Doc OCR Extractor**: Servicio personalizado para extracción de texto de documentos
- **Importación Automática**: Sistema automático de importación de credenciales y workflows
- **Healthchecks**: Monitoreo de salud de todos los servicios
- **Volúmenes Persistentes**: Datos persistentes entre reinicios

## 📋 Requisitos Previos

- [Docker](https://www.docker.com/get-started) (versión 20.10 o superior)
- [Docker Compose](https://docs.docker.com/compose/install/) (versión 2.0 o superior)
- Al menos 4GB de RAM disponible
- Puertos 5678, 5432, 8000 disponibles

## 📁 Estructura del Proyecto

```
kit-n8n-ai/
├── docker-compose.yml          # Configuración principal de servicios
├── auto-import.sh             # Script de importación automática
├── .env                       # Variables de entorno (crear manualmente)
├── Dockerfiles/               # Dockerfiles personalizados
│   ├── Dockerfile.n8n
│   └── Dockerfile.postgres
├── doc-ocr-extractor/         # Servicio de extracción OCR
│   ├── Dockerfile
│   └── server.py
└── storage/                   # Datos persistentes
    ├── n8n/                   # Datos de n8n
    ├── postgres/              # Datos de PostgreSQL
    ├── qdrant/                # Datos de Qdrant
    ├── shared/                # Archivos compartidos
    └── n8n-import/            # Archivos para importación
        ├── credentials/       # Credenciales de n8n (.json)
        └── workflows/         # Workflows de n8n (.json)
```

## ⚙️ Configuración Inicial

### 1. Crear archivo de variables de entorno

Crea un archivo `.env` en el directorio raíz con el siguiente contenido:

```env
# Configuración de PostgreSQL
POSTGRES_HOST=postgres
POSTGRES_USER=n8n
POSTGRES_PASSWORD=n8n_password_segura
POSTGRES_DB=n8n

# Configuración de n8n
N8N_ENCRYPTION_KEY=tu-clave-de-encriptacion-muy-segura-aqui
N8N_USER_MANAGEMENT_JWT_SECRET=tu-jwt-secret-muy-seguro-aqui

# Configuración de zona horaria
TZ=America/Mexico_City
```

> ⚠️ **Importante**: Cambia los valores de `N8N_ENCRYPTION_KEY` y `N8N_USER_MANAGEMENT_JWT_SECRET` por valores únicos y seguros de al menos 32 caracteres.

### 2. Crear estructura de directorios

Los directorios se crearán automáticamente al ejecutar Docker Compose, pero puedes crearlos manualmente si lo prefieres:

```bash
mkdir -p storage/n8n-import/credentials
mkdir -p storage/n8n-import/workflows
mkdir -p storage/shared
```

## 🚀 Despliegue

### Despliegue Completo

```bash
# Clonar o descargar el proyecto
git clone <url-del-repositorio>
cd kit-n8n-ai

# Crear archivo .env (ver sección anterior)

# Construir e iniciar todos los servicios
docker-compose up -d --build

# Verificar que todos los servicios estén funcionando
docker-compose ps
```

### Comandos Útiles

```bash
# Ver logs de todos los servicios
docker-compose logs

# Ver logs de un servicio específico
docker-compose logs n8n

# Reiniciar un servicio específico
docker-compose restart n8n

# Detener todos los servicios
docker-compose down

# Detener y eliminar volúmenes (⚠️ elimina todos los datos)
docker-compose down -v
```

## 📥 Importación de Datos

### Importación Automática

El sistema incluye importación automática de credenciales y workflows:

1. **Coloca tus archivos** en las carpetas correspondientes:

   - Credenciales: `storage/n8n-import/credentials/`
   - Workflows: `storage/n8n-import/workflows/`

2. **Formatos soportados**:

   - Archivos `.json` exportados desde n8n
   - Un archivo por credencial/workflow
   - Formato de exportación individual de n8n

3. **Proceso automático**:
   - Al ejecutar `docker-compose up -d`, el servicio `n8n-import` se ejecuta automáticamente
   - Espera a que n8n esté completamente listo
   - Importa todas las credenciales y workflows encontrados
   - Muestra un reporte detallado en los logs

### Copiar archivos desde otro servidor

Si tienes archivos de n8n en otro servidor, puedes copiarlos usando `scp`:

#### Copiar credenciales desde servidor remoto

```bash
# Copiar todas las credenciales desde un servidor remoto
scp usuario@servidor-remoto:/ruta/a/credenciales/*.json ./storage/n8n-import/credentials/

# Copiar una credencial específica
scp usuario@servidor-remoto:/ruta/a/credenciales/archivo.json ./storage/n8n-import/credentials/

# Copiar con puerto SSH personalizado
scp -P 2222 usuario@servidor-remoto:/ruta/a/credenciales/*.json ./storage/n8n-import/credentials/
```

#### Copiar workflows desde servidor remoto

```bash
# Copiar todos los workflows desde un servidor remoto
scp usuario@servidor-remoto:/ruta/a/workflows/*.json ./storage/n8n-import/workflows/

# Copiar un workflow específico
scp usuario@servidor-remoto:/ruta/a/workflows/mi-workflow.json ./storage/n8n-import/workflows/

# Copiar recursivamente una carpeta completa
scp -r usuario@servidor-remoto:/ruta/completa/n8n-export/ ./storage/n8n-import/
```

#### Ejemplos prácticos

```bash
# Ejemplo: Copiar desde un servidor de producción
scp root@produccion.ejemplo.com:/var/lib/n8n/exports/credentials/*.json ./storage/n8n-import/credentials/
scp root@produccion.ejemplo.com:/var/lib/n8n/exports/workflows/*.json ./storage/n8n-import/workflows/

# Ejemplo: Copiar con clave SSH específica
scp -i ~/.ssh/mi-clave-privada usuario@servidor:/exports/*.json ./storage/n8n-import/credentials/

# Ejemplo: Copiar comprimido (más eficiente para muchos archivos)
ssh usuario@servidor-remoto "cd /ruta/a/exports && tar -czf - ." | tar -xzf - -C ./storage/n8n-import/

# Alternativa: Crear archivo comprimido y luego transferir
ssh usuario@servidor-remoto "tar -czf /tmp/n8n-backup.tar.gz -C /ruta/a/exports ."
scp usuario@servidor-remoto:/tmp/n8n-backup.tar.gz ./
tar -xzf n8n-backup.tar.gz -C ./storage/n8n-import/
rm n8n-backup.tar.gz

# Ejemplo: Sincronización con rsync (alternativa a scp)
rsync -avz -e ssh usuario@servidor-remoto:/ruta/a/exports/ ./storage/n8n-import/
```

#### Opciones útiles de scp

| Opción      | Descripción                         |
| ----------- | ----------------------------------- |
| `-r`        | Copia recursiva de directorios      |
| `-P puerto` | Especifica puerto SSH personalizado |
| `-i clave`  | Usa clave SSH específica            |
| `-v`        | Modo verbose (muestra progreso)     |
| `-C`        | Compresión durante la transferencia |

> 💡 **Tip**: Después de copiar archivos con `scp`, ejecuta `docker-compose up -d` para que se importen automáticamente.

### Ver logs de importación

```bash
# Ver logs del proceso de importación
docker logs n8n-import
```

### Importación Manual

Si necesitas importar archivos manualmente:

```bash
# Importar credenciales
docker exec n8n n8n import:credentials --separate --input=/demo-data/credentials

# Importar todos los workflows de la carpeta
docker exec n8n n8n import:workflow --separate --input=/demo-data/workflows/
```
