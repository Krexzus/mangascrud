USE mangasdbb;
GO

-- Primero eliminar los registros de la tabla intermedia
DELETE FROM manga_generos;
GO

-- Luego eliminar los registros de la tabla principal
DELETE FROM mangas;
GO

-- Reiniciar el contador de identidad
DBCC CHECKIDENT ('mangas', RESEED, 0);
GO

-- Verificar que las tablas estén vacías
SELECT COUNT(*) as MangasCount FROM mangas;
SELECT COUNT(*) as GenerosMangaCount FROM manga_generos;
GO 