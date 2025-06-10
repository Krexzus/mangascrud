USE mangasdbb;
GO

-- 1. Conteo total de mangas
SELECT COUNT(*) as TotalMangas FROM mangas;

-- 2. Verificar títulos duplicados
WITH DuplicadosTitulos AS (
    SELECT 
        titulo,
        COUNT(*) as Repeticiones
    FROM mangas
    GROUP BY titulo
    HAVING COUNT(*) > 1
)
SELECT 
    'Títulos duplicados encontrados: ' + CAST(COUNT(*) as varchar) as Resultado,
    SUM(Repeticiones) as TotalRepeticiones
FROM DuplicadosTitulos;

-- 3. Mostrar detalles de los mangas duplicados (si existen)
SELECT 
    m.id,
    m.titulo,
    m.autor,
    m.estado,
    m.Genre,
    m.PublicationDate
FROM mangas m
INNER JOIN (
    SELECT titulo
    FROM mangas
    GROUP BY titulo
    HAVING COUNT(*) > 1
) d ON m.titulo = d.titulo
ORDER BY m.titulo, m.id;

-- 4. Distribución por estado
SELECT 
    estado,
    COUNT(*) as Cantidad,
    CAST(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM mangas) as DECIMAL(5,2)) as Porcentaje
FROM mangas
GROUP BY estado
ORDER BY Cantidad DESC;

-- 5. Distribución por género
SELECT 
    Genre,
    COUNT(*) as Cantidad,
    CAST(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM mangas) as DECIMAL(5,2)) as Porcentaje
FROM mangas
GROUP BY Genre
ORDER BY Cantidad DESC;

-- 6. Estadísticas generales
SELECT 
    COUNT(DISTINCT titulo) as TitulosUnicos,
    COUNT(DISTINCT autor) as AutoresUnicos,
    COUNT(DISTINCT estado) as EstadosUnicos,
    COUNT(DISTINCT Genre) as GenerosUnicos,
    MIN(anio_publicacion) as AnioMasAntiguo,
    MAX(anio_publicacion) as AnioMasReciente
FROM mangas;

-- 7. Top 10 autores con más mangas
SELECT TOP 10
    autor,
    COUNT(*) as CantidadMangas,
    STRING_AGG(titulo, ', ') as Titulos
FROM mangas
GROUP BY autor
ORDER BY CantidadMangas DESC;

-- 8. Distribución por década
SELECT 
    CONCAT(
        (anio_publicacion / 10) * 10, 
        's'
    ) as Decada,
    COUNT(*) as Cantidad,
    CAST(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM mangas) as DECIMAL(5,2)) as Porcentaje
FROM mangas
GROUP BY (anio_publicacion / 10) * 10
ORDER BY Decada;

-- 9. Verificar consistencia entre Title/titulo y Author/autor
SELECT 
    'Inconsistencias Title/titulo: ' + 
    CAST(SUM(CASE WHEN Title <> titulo THEN 1 ELSE 0 END) as varchar) as InconsistenciasTitulo,
    'Inconsistencias Author/autor: ' + 
    CAST(SUM(CASE WHEN Author <> autor THEN 1 ELSE 0 END) as varchar) as InconsistenciasAutor
FROM mangas;

-- 10. Mangas por año (últimos 10 años)
SELECT TOP 10
    anio_publicacion,
    COUNT(*) as Cantidad
FROM mangas
GROUP BY anio_publicacion
ORDER BY anio_publicacion DESC; 