-- Crear las tablas si no existen
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Genres]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[Genres] (
        [Id] INT IDENTITY(1,1) PRIMARY KEY,
        [Name] NVARCHAR(50) NOT NULL,
        [Description] NVARCHAR(200) NULL
    );
END;

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Mangas]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[Mangas] (
        [Id] INT IDENTITY(1,1) PRIMARY KEY,
        [Title] NVARCHAR(200) NOT NULL,
        [Author] NVARCHAR(100) NOT NULL,
        [Status] NVARCHAR(20) NOT NULL,
        [PublicationDate] DATE NOT NULL
    );
END;

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[MangaGenres]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[MangaGenres] (
        [MangasId] INT NOT NULL,
        [GenresId] INT NOT NULL,
        CONSTRAINT [PK_MangaGenres] PRIMARY KEY ([MangasId], [GenresId]),
        CONSTRAINT [FK_MangaGenres_Mangas] FOREIGN KEY ([MangasId]) REFERENCES [Mangas]([Id]),
        CONSTRAINT [FK_MangaGenres_Genres] FOREIGN KEY ([GenresId]) REFERENCES [Genres]([Id])
    );
END;
GO

-- Limpiar datos existentes si es necesario
DELETE FROM MangaGenres;
DELETE FROM Mangas;
DELETE FROM Genres;
GO

-- Reiniciar los identity
DBCC CHECKIDENT ('Mangas', RESEED, 0);
DBCC CHECKIDENT ('Genres', RESEED, 0);
GO

-- Limpiar funciones existentes si existen
IF OBJECT_ID('GenerateRandomDate') IS NOT NULL DROP FUNCTION GenerateRandomDate;
IF OBJECT_ID('GenerateRandomTitle') IS NOT NULL DROP FUNCTION GenerateRandomTitle;
IF OBJECT_ID('GenerateRandomAuthor') IS NOT NULL DROP FUNCTION GenerateRandomAuthor;
GO

-- Primero, insertamos los géneros básicos
SET IDENTITY_INSERT Genres ON;
INSERT INTO Genres (Id, Name, Description)
VALUES 
    (1, 'Acción', 'Manga con énfasis en escenas de acción y combate'),
    (2, 'Aventura', 'Historias centradas en viajes y descubrimientos'),
    (3, 'Comedia', 'Manga con enfoque humorístico'),
    (4, 'Drama', 'Historias con desarrollo emocional profundo'),
    (5, 'Fantasía', 'Mundos imaginarios y elementos mágicos'),
    (6, 'Ciencia Ficción', 'Historias basadas en avances científicos y tecnológicos'),
    (7, 'Romance', 'Centrado en relaciones románticas'),
    (8, 'Slice of Life', 'Historias de la vida cotidiana'),
    (9, 'Deportes', 'Manga centrado en deportes y competencias'),
    (10, 'Horror', 'Historias de terror y suspenso'),
    (11, 'Misterio', 'Tramas con elementos de investigación y suspense'),
    (12, 'Psicológico', 'Exploración de la mente y comportamiento humano');
SET IDENTITY_INSERT Genres OFF;
GO

-- Procedimiento para generar los 3500 registros
IF OBJECT_ID('GenerateTestData') IS NOT NULL DROP PROCEDURE GenerateTestData;
GO

CREATE PROCEDURE GenerateTestData
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @Counter INT = 1;
    DECLARE @MaxManga INT = 3500;
    
    -- Tablas temporales para generar nombres
    DECLARE @Adjectives TABLE (id INT IDENTITY(1,1), word NVARCHAR(50))
    INSERT INTO @Adjectives (word) VALUES 
        ('Dark'), ('Mystic'), ('Eternal'), ('Lost'), ('Sacred'),
        ('Silent'), ('Crystal'), ('Golden'), ('Shadow'), ('Divine');
    
    DECLARE @Nouns TABLE (id INT IDENTITY(1,1), word NVARCHAR(50))
    INSERT INTO @Nouns (word) VALUES 
        ('Blade'), ('Dragon'), ('Knight'), ('Soul'), ('World'),
        ('Kingdom'), ('Hunter'), ('Legend'), ('Hero'), ('Gate');
    
    DECLARE @FirstNames TABLE (id INT IDENTITY(1,1), name NVARCHAR(50))
    INSERT INTO @FirstNames (name) VALUES 
        ('Hiroshi'), ('Kenji'), ('Yuki'), ('Akira'), ('Takeshi'),
        ('Masashi'), ('Rumiko'), ('Yoshihiro'), ('Naoki'), ('Eiichiro');
    
    DECLARE @LastNames TABLE (id INT IDENTITY(1,1), name NVARCHAR(50))
    INSERT INTO @LastNames (name) VALUES 
        ('Yamamoto'), ('Tanaka'), ('Suzuki'), ('Sato'), ('Nakamura'),
        ('Takahashi'), ('Kobayashi'), ('Watanabe'), ('Ito'), ('Saito');
    
    WHILE @Counter <= @MaxManga
    BEGIN
        -- Generar título aleatorio
        DECLARE @AdjIndex INT = CAST(RAND() * 10 + 1 AS INT);
        DECLARE @NounIndex INT = CAST(RAND() * 10 + 1 AS INT);
        DECLARE @RandomNumber INT = CAST(RAND() * 1000 AS INT);
        
        DECLARE @Title NVARCHAR(200);
        SELECT @Title = a.word + ' ' + n.word + ' ' + CAST(@RandomNumber AS NVARCHAR(4))
        FROM @Adjectives a
        CROSS JOIN @Nouns n
        WHERE a.id = @AdjIndex AND n.id = @NounIndex;
        
        -- Generar autor aleatorio
        DECLARE @FirstNameIndex INT = CAST(RAND() * 10 + 1 AS INT);
        DECLARE @LastNameIndex INT = CAST(RAND() * 10 + 1 AS INT);
        
        DECLARE @Author NVARCHAR(100);
        SELECT @Author = f.name + ' ' + l.name
        FROM @FirstNames f
        CROSS JOIN @LastNames l
        WHERE f.id = @FirstNameIndex AND l.id = @LastNameIndex;
        
        -- Generar fecha aleatoria entre 2000 y 2024
        DECLARE @StartDate DATE = '2000-01-01';
        DECLARE @EndDate DATE = '2024-12-31';
        DECLARE @Days INT = DATEDIFF(DAY, @StartDate, @EndDate);
        DECLARE @RandomDays INT = CAST(RAND() * @Days AS INT);
        DECLARE @PublicationDate DATE = DATEADD(DAY, @RandomDays, @StartDate);
        
        -- Insertar manga
        INSERT INTO Mangas (Title, Author, Status, PublicationDate)
        VALUES (
            @Title,
            @Author,
            CASE CAST(RAND() * 3 AS INT)
                WHEN 0 THEN 'En curso'
                WHEN 1 THEN 'Finalizado'
                ELSE 'En pausa'
            END,
            @PublicationDate
        );
        
        -- Asignar géneros aleatorios (entre 1 y 4)
        DECLARE @GenreCount INT = CAST(RAND() * 4 + 1 AS INT);
        
        WITH RandomGenres AS (
            SELECT TOP (@GenreCount) Id
            FROM Genres
            ORDER BY NEWID()
        )
        INSERT INTO MangaGenres (MangasId, GenresId)
        SELECT 
            SCOPE_IDENTITY(),
            Id
        FROM RandomGenres;
        
        SET @Counter = @Counter + 1;
    END;
END;
GO

-- Ejecutar el procedimiento
EXEC GenerateTestData;
GO

-- Limpiar el procedimiento
DROP PROCEDURE GenerateTestData;
GO 