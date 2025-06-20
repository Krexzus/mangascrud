using Microsoft.AspNetCore.Mvc;
using JaveragesLibrary.Domain.Entities;
using JaveragesLibrary.Infrastructure.Data;
using System.Threading.Tasks;
using System.Linq;

namespace JaveragesLibrary.Controllers;

[ApiController]
[Route("api/[controller]")]
public class GenreController : ControllerBase
{
    private readonly MangaDbContext _context;

    public GenreController(MangaDbContext context)
    {
        _context = context;
    }

    // Consultar todos los géneros
    [HttpGet]
    public IActionResult GetAll()
    {
        var genres = _context.Genres.ToList();
        return Ok(genres);
    }

    // Consultar un género por id
    [HttpGet("{id}")]
    public IActionResult GetById(int id)
    {
        var genre = _context.Genres.FirstOrDefault(g => g.Id == id);
        if (genre == null)
            return NotFound();
        return Ok(genre);
    }

    // Crear un nuevo género
    [HttpPost]
    public async Task<IActionResult> Create([FromBody] Genre genre)
    {
        _context.Genres.Add(genre);
        await _context.SaveChangesAsync();
        return CreatedAtAction(nameof(GetById), new { id = genre.Id }, genre);
    }

    // Actualizar un género existente
    [HttpPut("{id}")]
    public async Task<IActionResult> Update(int id, [FromBody] Genre updatedGenre)
    {
        var genre = _context.Genres.FirstOrDefault(g => g.Id == id);
        if (genre == null)
            return NotFound();
        genre.Name = updatedGenre.Name;
        genre.Description = updatedGenre.Description;
        await _context.SaveChangesAsync();
        return Ok(genre);
    }
} 