USE mangasdbb;
GO

SET NOCOUNT ON;

-- Limpiar tablas temporales si existen
IF OBJECT_ID('tempdb..#TitulosBase') IS NOT NULL DROP TABLE #TitulosBase;
IF OBJECT_ID('tempdb..#Prefijos') IS NOT NULL DROP TABLE #Prefijos;
IF OBJECT_ID('tempdb..#Conectores') IS NOT NULL DROP TABLE #Conectores;
IF OBJECT_ID('tempdb..#Sufijos') IS NOT NULL DROP TABLE #Sufijos;
IF OBJECT_ID('tempdb..#TitulosGenerados') IS NOT NULL DROP TABLE #TitulosGenerados;
GO

-- Limpiar datos existentes
TRUNCATE TABLE manga_generos;
DELETE FROM mangas;
DBCC CHECKIDENT ('mangas', RESEED, 0);
GO

-- Crear índices para mejorar el rendimiento
CREATE TABLE #TitulosGenerados (
    id INT IDENTITY(1,1) PRIMARY KEY,
    titulo VARCHAR(200)
);

-- Crear tablas temporales con índices
CREATE TABLE #TitulosBase (
    id INT IDENTITY(1,1) PRIMARY KEY,
    palabra VARCHAR(100)
);

CREATE TABLE #Prefijos (
    id INT IDENTITY(1,1) PRIMARY KEY,
    prefijo VARCHAR(100)
);

CREATE TABLE #Conectores (
    id INT IDENTITY(1,1) PRIMARY KEY,
    conector VARCHAR(20)
);

CREATE TABLE #Sufijos (
    id INT IDENTITY(1,1) PRIMARY KEY,
    sufijo VARCHAR(100)
);

-- Insertar datos base en lotes
INSERT INTO #TitulosBase (palabra)
SELECT palabra FROM (VALUES 
    ('Dragon'), ('Demon'), ('Black'), ('Blue'), ('Red'), ('Silver'), ('Golden'),
    ('Magic'), ('Ninja'), ('Samurai'), ('Hero'), ('Knight'), ('King'), ('Queen'),
    ('Shadow'), ('Light'), ('Star'), ('Moon'), ('Sun'), ('Fire'), ('Ice'),
    ('Wind'), ('Storm'), ('Ocean'), ('Mountain'), ('Sky'), ('Earth'), ('Heaven'),
    ('Crystal'), ('Steel'), ('Iron'), ('Bronze'), ('Copper'), ('Diamond'), ('Ruby'),
    ('Sapphire'), ('Pearl'), ('Jade'), ('Onyx'), ('Crimson'), ('Azure'), ('Violet'),
    ('Green'), ('Yellow'), ('Purple'), ('Gray'), ('Ancient'), ('Eternal'), ('Immortal'),
    ('Hidden'), ('Secret'), ('Mystic'), ('Sacred'), ('Divine'), ('Cursed'), ('Blessed')
) AS palabras(palabra);

INSERT INTO #Prefijos (prefijo)
SELECT prefijo FROM (VALUES 
    ('The'), ('My'), ('Our'), ('Their'), ('A'), ('The Last'), ('The First'),
    ('Tales of'), ('Legend of'), ('Chronicles of'), ('Saga of'), ('Story of'),
    ('Rise of'), ('Fall of'), ('Path of'), ('Way of'), ('Book of')
) AS prefijos(prefijo);

INSERT INTO #Conectores (conector)
SELECT conector FROM (VALUES 
    ('of'), ('and'), ('in'), ('from'), ('beyond'), ('under'), ('above'),
    ('within'), ('through'), ('between'), ('among'), ('beside')
) AS conectores(conector);

INSERT INTO #Sufijos (sufijo)
SELECT sufijo FROM (VALUES 
    ('Academy'), ('Chronicles'), ('Story'), ('Tale'), ('Adventure'), ('Journey'),
    ('Legend'), ('Quest'), ('Battle'), ('War'), ('Paradise'), ('World'), ('Realm'),
    ('Empire'), ('Dynasty'), ('Revolution'), ('Destiny'), ('Fate'), ('Soul'),
    ('Heart'), ('Blade'), ('Sword'), ('Shield'), ('Hunter'), ('Slayer'), ('Master')
) AS sufijos(sufijo);

-- Generar títulos en lotes
DECLARE @BatchSize INT = 500;
DECLARE @CurrentBatch INT = 1;
DECLARE @TotalBatches INT = 7; -- 3500/500

WHILE @CurrentBatch <= @TotalBatches
BEGIN
    WITH TitulosUnicos AS (
        SELECT DISTINCT TOP (@BatchSize)
            CONCAT(
                p.prefijo,
                ' ',
                t1.palabra,
                CASE WHEN ABS(CHECKSUM(NEWID())) % 2 = 0 
                    THEN CONCAT(' ', c.conector, ' ', t2.palabra)
                    ELSE ''
                END,
                ' ',
                s.sufijo
            ) AS titulo,
            NEWID() as orden
        FROM #TitulosBase t1
        CROSS JOIN #TitulosBase t2
        CROSS JOIN #Prefijos p
        CROSS JOIN #Conectores c
        CROSS JOIN #Sufijos s
        WHERE t1.palabra <> t2.palabra
        AND NOT EXISTS (
            SELECT 1 
            FROM #TitulosGenerados tg 
            WHERE tg.titulo = CONCAT(
                p.prefijo,
                ' ',
                t1.palabra,
                CASE WHEN ABS(CHECKSUM(NEWID())) % 2 = 0 
                    THEN CONCAT(' ', c.conector, ' ', t2.palabra)
                    ELSE ''
                END,
                ' ',
                s.sufijo
            )
        )
    )
    INSERT INTO #TitulosGenerados (titulo)
    SELECT titulo
    FROM TitulosUnicos
    ORDER BY orden;

    SET @CurrentBatch = @CurrentBatch + 1;
    
    -- Mostrar progreso
    PRINT 'Generados ' + CAST((@CurrentBatch-1)*@BatchSize AS VARCHAR) + ' títulos';
END

-- Insertar mangas optimizado
INSERT INTO mangas (
    titulo, autor, anio_publicacion, estado, descripcion,
    fecha_registro, Title, Author, Genre, Status, PublicationDate
)
SELECT 
    t.titulo,
    'Autor ' + CAST(ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS VARCHAR),
    1975 + (ABS(CHECKSUM(NEWID())) % 48), -- 1975 a 2023
    CASE ABS(CHECKSUM(NEWID())) % 5
        WHEN 0 THEN 'En curso'
        WHEN 1 THEN 'Finalizado'
        WHEN 2 THEN 'Cancelado'
        WHEN 3 THEN 'En pausa'
        ELSE 'Próximamente'
    END,
    'Historia de ' + t.titulo,
    GETDATE(),
    t.titulo,
    'Autor ' + CAST(ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS VARCHAR),
    CASE ABS(CHECKSUM(NEWID())) % 6
        WHEN 0 THEN 'Shonen'
        WHEN 1 THEN 'Seinen'
        WHEN 2 THEN 'Shoujo'
        WHEN 3 THEN 'Josei'
        WHEN 4 THEN 'Kodomo'
        ELSE 'Gore'
    END,
    CASE ABS(CHECKSUM(NEWID())) % 5
        WHEN 0 THEN 'En curso'
        WHEN 1 THEN 'Finalizado'
        WHEN 2 THEN 'Cancelado'
        WHEN 3 THEN 'En pausa'
        ELSE 'Próximamente'
    END,
    DATEADD(
        DAY,
        ABS(CHECKSUM(NEWID())) % 365,
        DATEADD(
            YEAR,
            ABS(CHECKSUM(NEWID())) % 48,
            '1975-01-01'
        )
    )
FROM #TitulosGenerados t;

-- Limpiar tablas temporales
DROP TABLE #TitulosGenerados;
DROP TABLE #TitulosBase;
DROP TABLE #Prefijos;
DROP TABLE #Conectores;
DROP TABLE #Sufijos;

PRINT 'Generación completada exitosamente';
GO 