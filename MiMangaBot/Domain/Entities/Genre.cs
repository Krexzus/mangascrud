using System.Collections.Generic;

namespace JaveragesLibrary.Domain.Entities;

public class Genre
{
    public int Id { get; set; }
    public required string Name { get; set; }
    public required string Description { get; set; }

    // Relación muchos a muchos con Manga
    public ICollection<Manga> Mangas { get; set; } = new List<Manga>();
} 