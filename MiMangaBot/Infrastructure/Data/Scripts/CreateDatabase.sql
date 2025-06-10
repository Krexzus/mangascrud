USE mangasdbb;
GO

-- Eliminar procedimientos almacenados si existen
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_VerificarDuplicados')
    DROP PROCEDURE sp_VerificarDuplicados;
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_ObtenerEstadisticas')
    DROP PROCEDURE sp_ObtenerEstadisticas;
GO

-- Verificar si la tabla existe y crear/modificar según sea necesario
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Mangas]') AND type in (N'U'))
BEGIN
    -- Crear la tabla si no existe
    CREATE TABLE [dbo].[Mangas](
        [Id] [int] IDENTITY(1,1) PRIMARY KEY,
        [Title] [nvarchar](200) NOT NULL,
        [Author] [nvarchar](100) NOT NULL,
        [Genre] [nvarchar](50) NOT NULL,
        [Status] [nvarchar](20) NOT NULL,
        [PublicationDate] [datetime] NOT NULL
    );
END
ELSE
BEGIN
    -- Verificar y agregar columnas faltantes
    IF NOT EXISTS(SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Mangas') AND name = 'Title')
    BEGIN
        ALTER TABLE dbo.Mangas ADD Title nvarchar(200) NOT NULL DEFAULT 'Sin título';
    END

    IF NOT EXISTS(SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Mangas') AND name = 'Author')
    BEGIN
        ALTER TABLE dbo.Mangas ADD Author nvarchar(100) NOT NULL DEFAULT 'Desconocido';
    END

    IF NOT EXISTS(SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Mangas') AND name = 'Genre')
    BEGIN
        ALTER TABLE dbo.Mangas ADD Genre nvarchar(50) NOT NULL DEFAULT 'Sin género';
    END

    IF NOT EXISTS(SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Mangas') AND name = 'Status')
    BEGIN
        ALTER TABLE dbo.Mangas ADD Status nvarchar(20) NOT NULL DEFAULT 'Desconocido';
    END

    IF NOT EXISTS(SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Mangas') AND name = 'PublicationDate')
    BEGIN
        ALTER TABLE dbo.Mangas ADD PublicationDate datetime NOT NULL DEFAULT GETDATE();
    END
END
GO

-- Crear o recrear índices
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Mangas_Title' AND object_id = OBJECT_ID('Mangas'))
    DROP INDEX IX_Mangas_Title ON Mangas;
GO

IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Mangas_Author' AND object_id = OBJECT_ID('Mangas'))
    DROP INDEX IX_Mangas_Author ON Mangas;
GO

CREATE INDEX [IX_Mangas_Title] ON [dbo].[Mangas]([Title]);
GO

CREATE INDEX [IX_Mangas_Author] ON [dbo].[Mangas]([Author]);
GO

-- Crear procedimiento para verificar duplicados
CREATE PROCEDURE sp_VerificarDuplicados
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Títulos duplicados
    SELECT Title, COUNT(*) as cantidad
    FROM Mangas
    GROUP BY Title
    HAVING COUNT(*) > 1;

    -- Autores con múltiples mangas
    SELECT Author, COUNT(*) as cantidad_mangas
    FROM Mangas
    GROUP BY Author
    HAVING COUNT(*) > 1;

    -- Combinaciones exactamente iguales
    SELECT Title, Author, COUNT(*) as veces_repetido
    FROM Mangas
    GROUP BY Title, Author
    HAVING COUNT(*) > 1;

    -- Resumen general
    SELECT 
        (SELECT COUNT(*) FROM Mangas) as total_mangas,
        (SELECT COUNT(DISTINCT Title) FROM Mangas) as titulos_unicos,
        (SELECT COUNT(DISTINCT Author) FROM Mangas) as autores_unicos,
        (SELECT COUNT(*) FROM (
            SELECT DISTINCT Title, Author 
            FROM Mangas
        ) as combinaciones) as combinaciones_unicas;
END;
GO

-- Crear procedimiento para obtener estadísticas
CREATE PROCEDURE sp_ObtenerEstadisticas
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Distribución por género
    SELECT Genre, COUNT(*) as cantidad
    FROM Mangas
    GROUP BY Genre
    ORDER BY cantidad DESC;

    -- Distribución por estado
    SELECT Status, COUNT(*) as cantidad
    FROM Mangas
    GROUP BY Status
    ORDER BY cantidad DESC;

    -- Distribución por década
    SELECT 
        CONCAT(YEAR(PublicationDate) / 10 * 10, 's') as Decada,
        COUNT(*) as Cantidad
    FROM Mangas
    GROUP BY YEAR(PublicationDate) / 10
    ORDER BY Decada;
END;
GO 