-- 1. Verificar el número total real de mangas
SELECT COUNT(*) as TotalMangas FROM Mangas;

GO

-- 2. Verificar cuántos géneros tiene cada manga
SELECT 
    NumeroDeGeneros,
    COUNT(*) as CantidadDeMangas,
    CAST(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Mangas) AS DECIMAL(5,2)) as Porcentaje
FROM (
    SELECT 
        m.Id,
        COUNT(mg.GenresId) as NumeroDeGeneros
    FROM Mangas m
    LEFT JOIN MangaGenres mg ON m.Id = mg.MangasId
    GROUP BY m.Id
) t
GROUP BY NumeroDeGeneros
ORDER BY NumeroDeGeneros;

GO

-- 3. Mostrar algunos ejemplos de mangas con sus múltiples géneros
SELECT TOP 10
    m.Id,
    m.Title,
    COUNT(mg.GenresId) as NumeroDeGeneros,
    STRING_AGG(g.Name, ', ') as Generos
FROM Mangas m
JOIN MangaGenres mg ON m.Id = mg.MangasId
JOIN Genres g ON mg.GenresId = g.Id
GROUP BY m.Id, m.Title
ORDER BY NumeroDeGeneros DESC;

GO

-- 4. Calcular el promedio de géneros por manga
SELECT 
    CAST(AVG(CAST(CantidadGeneros AS FLOAT)) AS DECIMAL(3,2)) as PromedioGenerosPerManga
FROM (
    SELECT 
        m.Id,
        COUNT(mg.GenresId) as CantidadGeneros
    FROM Mangas m
    LEFT JOIN MangaGenres mg ON m.Id = mg.MangasId
    GROUP BY m.Id
) t;

GO

-- 5. Mostrar la distribución total
SELECT 
    'Total Mangas' as Metrica, CAST(COUNT(DISTINCT m.Id) AS VARCHAR) as Valor
FROM Mangas m
UNION ALL
SELECT 
    'Total Relaciones Manga-Genero', CAST(COUNT(*) AS VARCHAR)
FROM MangaGenres
UNION ALL
SELECT 
    'Promedio Generos por Manga', 
    CAST(CAST(COUNT(*) AS FLOAT) / CAST(COUNT(DISTINCT m.Id) AS FLOAT) AS VARCHAR)
FROM MangaGenres mg
JOIN Mangas m ON m.Id = mg.MangasId; 