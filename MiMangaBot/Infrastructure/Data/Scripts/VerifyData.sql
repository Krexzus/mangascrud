-- 1. Verificar cantidad total de mangas
SELECT COUNT(*) as TotalMangas FROM Mangas;

GO

-- 2. Verificar todos los géneros disponibles
SELECT Id, Name, Description,
    (SELECT COUNT(*) FROM MangaGenres WHERE GenresId = Genres.Id) as CantidadMangas
FROM Genres
ORDER BY CantidadMangas DESC;

GO

-- 3. Verificar distribución de mangas por estado
SELECT Status, COUNT(*) as Cantidad,
    CAST(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Mangas) AS DECIMAL(5,2)) as Porcentaje
FROM Mangas
GROUP BY Status
ORDER BY Cantidad DESC;

GO

-- 4. Mostrar algunos mangas con sus géneros (limitado a 10 ejemplos)
SELECT TOP 10
    m.Id,
    m.Title,
    m.Author,
    m.Status,
    m.PublicationDate,
    (
        SELECT STRING_AGG(g.Name, ', ')
        FROM MangaGenres mg2
        JOIN Genres g ON mg2.GenresId = g.Id
        WHERE mg2.MangasId = m.Id
    ) as Generos
FROM Mangas m
ORDER BY m.Id;

GO

-- 5. Encontrar mangas por género específico (ejemplo con 'Acción')
SELECT TOP 5 m.Title, m.Author, m.Status
FROM Mangas m
JOIN MangaGenres mg ON m.Id = mg.MangasId
JOIN Genres g ON mg.GenresId = g.Id
WHERE g.Name = 'Acción';

GO

-- 6. Distribución de mangas por año
SELECT 
    YEAR(PublicationDate) as Año,
    COUNT(*) as CantidadMangas
FROM Mangas
GROUP BY YEAR(PublicationDate)
ORDER BY Año;

GO

-- 7. Verificar la cantidad de géneros por manga
SELECT CantidadGeneros, COUNT(*) as CantidadMangas,
    CAST(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Mangas) AS DECIMAL(5,2)) as Porcentaje
FROM (
    SELECT m.Id, COUNT(mg.GenresId) as CantidadGeneros
    FROM Mangas m
    LEFT JOIN MangaGenres mg ON m.Id = mg.MangasId
    GROUP BY m.Id
) t
GROUP BY CantidadGeneros
ORDER BY CantidadGeneros;

-- 8. Encontrar combinaciones más comunes de géneros
WITH GenerosCombinados AS (
    SELECT 
        m.Id,
        STRING_AGG(g.Name, ' + ') WITHIN GROUP (ORDER BY g.Name) as Combinacion
    FROM Mangas m
    JOIN MangaGenres mg ON m.Id = mg.MangasId
    JOIN Genres g ON mg.GenresId = g.Id
    GROUP BY m.Id
)
SELECT TOP 10
    Combinacion,
    COUNT(*) as Frecuencia,
    CAST(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Mangas) AS DECIMAL(5,2)) as Porcentaje
FROM GenerosCombinados
GROUP BY Combinacion
ORDER BY Frecuencia DESC;

-- 9. Autores más prolíficos
SELECT TOP 10
    Author,
    COUNT(*) as CantidadMangas,
    STRING_AGG(DISTINCT g.Name, ', ') as GenerosUtilizados
FROM Mangas m
LEFT JOIN MangaGenres mg ON m.Id = mg.MangasId
LEFT JOIN Genres g ON mg.GenresId = g.Id
GROUP BY Author
ORDER BY CantidadMangas DESC;

-- 10. Verificar mangas sin géneros (no debería haber ninguno)
SELECT Id, Title, Author
FROM Mangas m
WHERE NOT EXISTS (
    SELECT 1 FROM MangaGenres WHERE MangasId = m.Id
); 