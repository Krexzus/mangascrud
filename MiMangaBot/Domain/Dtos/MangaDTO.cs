using System.Collections.Generic;

namespace JaveragesLibrary.Domain.Dtos;

public class MangaDTO
{
    public int Id { get; set; }
    public string Title { get; set; } = null!;
    public string Author { get; set; } = null!;
    public string Status { get; set; } = null!;
    public DateTime PublicationDate { get; set; }
    public ICollection<string> Genres { get; set; } = new List<string>();
} 