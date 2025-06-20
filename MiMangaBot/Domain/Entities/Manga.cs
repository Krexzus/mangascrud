using System;
using System.Collections.Generic;

namespace JaveragesLibrary.Domain.Entities;

public class Manga
{
    public int Id { get; set; }
    public string Title { get; set; } = string.Empty;
    public string Author { get; set; } = string.Empty;
    public string Status { get; set; } = string.Empty;
    public DateTime PublicationDate { get; set; }

    // Relación muchos a muchos con Genre
    public ICollection<Genre> Genres { get; set; } = new List<Genre>();
} 