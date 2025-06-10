# API de Gestión de Mangas

Esta es una API REST desarrollada en .NET para la gestión de mangas. El proyecto es un trabajo en equipo donde se implementa un CRUD (Create, Read, Update, Delete) para mangas.

## Estado Actual del Proyecto

Actualmente, la API tiene implementadas las siguientes funcionalidades:

### Endpoints Implementados
- **CREATE**
  - POST `/api/Manga` - Crear un nuevo manga
- **READ**
  - GET `/api/Manga` - Obtener todos los mangas
  - GET `/api/Manga/{id}` - Obtener un manga específico
  - GET `/api/Manga/count` - Obtener el total de mangas
  - GET `/api/Manga/verificar-duplicados` - Verificar mangas duplicados

### Estructura de Datos
```json
{
  "title": "string",
  "author": "string",
  "genre": "string",
  "status": "string",
  "publicationDate": "datetime"
}
```

## Tareas Pendientes (Para el siguiente desarrollador)

### Implementar los siguientes endpoints:

1. **UPDATE**
   - Implementar el método PUT `/api/Manga/{id}`
   - Debe permitir actualizar un manga existente
   - Verificar que el manga existe antes de actualizarlo

2. **DELETE**
   - Implementar el método DELETE `/api/Manga/{id}`
   - Debe permitir eliminar un manga existente
   - Verificar que el manga existe antes de eliminarlo

## Configuración de la Base de Datos

La base de datos está configurada en SQL Server con la siguiente estructura:

```sql
CREATE TABLE dbo.Mangas (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Title NVARCHAR(200) NOT NULL,
    Author NVARCHAR(100) NOT NULL,
    Genre NVARCHAR(50) NOT NULL DEFAULT '',
    Status NVARCHAR(20) NOT NULL DEFAULT '',
    PublicationDate DATETIME NOT NULL DEFAULT GETDATE()
);
```

## Cómo Empezar

1. Clona el repositorio
2. Configura la cadena de conexión en `appsettings.json`
3. Ejecuta la aplicación
4. Accede a Swagger en `https://localhost:xxxx/swagger`

## Tecnologías Utilizadas
- .NET
- Entity Framework Core
- SQL Server
- AutoMapper
- Swagger 