-- Encontrar títulos duplicados
SELECT Title, COUNT(*) as Cantidad
FROM Mangas
GROUP BY Title
HAVING COUNT(*) > 1
ORDER BY Cantidad DESC;

-- Encontrar mangas del mismo autor
SELECT Author, COUNT(*) as CantidadMangas
FROM Mangas
GROUP BY Author
HAVING COUNT(*) > 1
ORDER BY CantidadMangas DESC;

-- Encontrar combinaciones exactas de título y autor
SELECT Title, Author, COUNT(*) as Repeticiones
FROM Mangas
GROUP BY Title, Author
HAVING COUNT(*) > 1
ORDER BY Repeticiones DESC;

-- Encontrar mangas con títulos similares (usando SOUNDEX)
SELECT m1.Title, m2.Title
FROM Mangas m1
JOIN Mangas m2 ON SOUNDEX(m1.Title) = SOUNDEX(m2.Title)
WHERE m1.Id < m2.Id;

-- Encontrar mangas publicados en la misma fecha
SELECT PublicationDate, COUNT(*) as Cantidad
FROM Mangas
GROUP BY PublicationDate
HAVING COUNT(*) > 1
ORDER BY Cantidad DESC;

-- Resumen de duplicados por género
SELECT Genre, 
       COUNT(*) as TotalMangas,
       COUNT(DISTINCT Title) as TitulosUnicos,
       COUNT(*) - COUNT(DISTINCT Title) as PosiblesDuplicados
FROM Mangas
GROUP BY Genre
ORDER BY PosiblesDuplicados DESC;

-- Encontrar mangas con el mismo título pero diferente autor
SELECT m1.Title, m1.Author as Autor1, m2.Author as Autor2
FROM Mangas m1
JOIN Mangas m2 ON m1.Title = m2.Title AND m1.Author != m2.Author
WHERE m1.Id < m2.Id;

-- Estadísticas generales de duplicados
SELECT 
    (SELECT COUNT(*) FROM Mangas) as TotalMangas,
    (SELECT COUNT(DISTINCT Title) FROM Mangas) as TitulosUnicos,
    (SELECT COUNT(DISTINCT Author) FROM Mangas) as AutoresUnicos,
    (SELECT COUNT(*) FROM (
        SELECT Title, Author
        FROM Mangas
        GROUP BY Title, Author
        HAVING COUNT(*) > 1
    ) t) as CombinacionesDuplicadas; 