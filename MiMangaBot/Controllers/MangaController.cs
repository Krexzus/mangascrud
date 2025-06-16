using AutoMapper;
using JaveragesLibrary.Domain.Dtos;
using JaveragesLibrary.Domain.Entities;
using JaveragesLibrary.Services.Features.Mangas;
using Microsoft.AspNetCore.Mvc;
using System.Linq;

namespace JaveragesLibrary.Controllers;

[ApiController]
[Route("api/[controller]")]
public class MangaController : ControllerBase
{
    private readonly MangaService _mangaService;
    private readonly IMapper _mapper;

    public MangaController(MangaService mangaService, IMapper mapper)
    {
        this._mangaService = mangaService;
        this._mapper = mapper;
    }

    [HttpGet]
    public IActionResult GetAll()
    {
        var mangas = _mangaService.GetAll();
        var mangaDtos = _mapper.Map<IEnumerable<MangaDTO>>(mangas); 
        
        return Ok(mangaDtos);
    }

    [HttpGet("{id}")]
    public IActionResult GetById(int id)
    {
        var manga = _mangaService.GetById(id);

        if (manga.Id <= 0)
            return NotFound();

        var dto = _mapper.Map<MangaDTO>(manga); 

        return Ok(dto);
    }

    [HttpPost]
    public IActionResult Add(MangaCreateDTO manga)
    {
        var entity = _mapper.Map<Manga>(manga);
        _mangaService.Add(entity);

        var dto = _mapper.Map<MangaDTO>(entity);
        return CreatedAtAction(nameof(GetById), new { id = entity.Id }, dto);
    }

    [HttpGet("count")]
    public ActionResult<int> GetCount()
    {
        var count = _mangaService.GetAll().Count();
        return Ok(new { total = count });
    }

    [HttpGet("verificar-duplicados")]
    public IActionResult VerificarDuplicados()
    {
        var mangas = _mangaService.GetAll().ToList();
        
        var resultado = new
        {
            total_mangas = mangas.Count,
            titulos_duplicados = mangas.GroupBy(m => m.Title)
                                     .Where(g => g.Count() > 1)
                                     .Select(g => new {
                                         titulo = g.Key,
                                         cantidad = g.Count(),
                                         mangas = g.Select(m => new { m.Id, m.Title, m.Author })
                                     })
                                     .ToList(),
            
            autores_duplicados = mangas.GroupBy(m => m.Author)
                                      .Where(g => g.Count() > 1)
                                      .Select(g => new {
                                          autor = g.Key,
                                          cantidad = g.Count(),
                                          mangas = g.Select(m => new { m.Id, m.Title, m.Author })
                                      })
                                      .ToList(),
            
            titulos_y_autores_duplicados = mangas.GroupBy(m => new { m.Title, m.Author })
                                                .Where(g => g.Count() > 1)
                                                .Select(g => new {
                                                    titulo = g.Key.Title,
                                                    autor = g.Key.Author,
                                                    cantidad = g.Count(),
                                                    mangas = g.Select(m => new { m.Id, m.Title, m.Author })
                                                })
                                                .ToList(),

            estadisticas = new
            {
                titulos_unicos = mangas.Select(m => m.Title).Distinct().Count(),
                autores_unicos = mangas.Select(m => m.Author).Distinct().Count(),
                combinaciones_unicas = mangas.Select(m => new { m.Title, m.Author }).Distinct().Count()
            }
        };

        return Ok(resultado);
    }

    [HttpPut("{id}")]
    public IActionResult Update(int id, MangaCreateDTO manga)
    {
        var entity = _mapper.Map<Manga>(manga);
        entity.Id = id;
        
        _mangaService.Update(entity);
        
        var updatedManga = _mangaService.GetById(id);
        if (updatedManga.Id <= 0)
            return NotFound();
            
        var dto = _mapper.Map<MangaDTO>(updatedManga);
        return Ok(dto);
    }

    [HttpDelete("{id}")]
    public IActionResult Delete(int id)
    {
        var manga = _mangaService.GetById(id);
        if (manga.Id <= 0)
            return NotFound();

        _mangaService.Delete(id);
        return NoContent();
    }
} 