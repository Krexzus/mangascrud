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

-- Verificar si existe la tabla géneros y sus datos
IF NOT EXISTS (SELECT 1 FROM generos WHERE id = 1)
BEGIN
    -- Insertar géneros básicos
    INSERT INTO generos (id, nombre) VALUES
    (1, 'Shonen'),
    (2, 'Seinen'),
    (3, 'Shoujo'),
    (4, 'Josei'),
    (5, 'Kodomo');
END
GO

-- Insertar mangas
INSERT INTO mangas (
    titulo,      -- NOT NULL
    autor,       -- NULL permitido
    anio_publicacion, -- NULL permitido
    estado,      -- NULL permitido
    descripcion, -- NULL permitido
    fecha_registro, -- NULL permitido, tiene default
    Title,       -- NOT NULL, tiene default
    Author,      -- NOT NULL, tiene default
    Genre,       -- NOT NULL, tiene default
    Status,      -- NOT NULL, tiene default
    PublicationDate  -- NOT NULL
) VALUES
(
    'One Piece', -- titulo
    'Eiichiro Oda', -- autor
    1997, -- anio_publicacion
    'Activo', -- estado
    'La historia del Rey de los Piratas', -- descripcion
    GETDATE(), -- fecha_registro
    'One Piece', -- Title
    'Eiichiro Oda', -- Author
    'Shonen', -- Genre
    'En curso', -- Status
    GETDATE() -- PublicationDate
),
(
    'Naruto', -- titulo
    'Masashi Kishimoto', -- autor
    1999, -- anio_publicacion
    'Finalizado', -- estado
    'La historia del ninja número uno en sorprender a la gente', -- descripcion
    GETDATE(), -- fecha_registro
    'Naruto', -- Title
    'Masashi Kishimoto', -- Author
    'Shonen', -- Genre
    'Finalizado', -- Status
    GETDATE() -- PublicationDate
),
(
    'Berserk', -- titulo
    'Kentaro Miura', -- autor
    1989, -- anio_publicacion
    'En hiatus', -- estado
    'La historia del Espadachín Negro', -- descripcion
    GETDATE(), -- fecha_registro
    'Berserk', -- Title
    'Kentaro Miura', -- Author
    'Seinen', -- Genre
    'En hiatus', -- Status
    GETDATE() -- PublicationDate
);
GO

-- Insertar relaciones manga-género
INSERT INTO manga_generos (manga_id, genero_id)
SELECT m.id, 1 -- Shonen
FROM mangas m
WHERE m.Genre = 'Shonen';

INSERT INTO manga_generos (manga_id, genero_id)
SELECT m.id, 2 -- Seinen
FROM mangas m
WHERE m.Genre = 'Seinen';
GO

-- Verificar los datos insertados
SELECT 
    m.id,
    m.titulo,
    m.autor,
    m.anio_publicacion,
    m.estado,
    m.descripcion,
    m.fecha_registro,
    m.Title,
    m.Author,
    m.Genre,
    m.Status,
    m.PublicationDate,
    g.nombre as NombreGenero
FROM mangas m
LEFT JOIN manga_generos mg ON m.id = mg.manga_id
LEFT JOIN generos g ON mg.genero_id = g.id;
GO 