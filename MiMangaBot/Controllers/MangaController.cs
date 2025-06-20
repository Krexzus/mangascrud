using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using JaveragesLibrary.Domain.Dtos;
using JaveragesLibrary.Domain.Entities;
using JaveragesLibrary.Services.Features.Mangas;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace JaveragesLibrary.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class MangaController : ControllerBase
{
    private readonly MangaService _mangaService;
    private readonly IMapper _mapper;

    public MangaController(MangaService mangaService, IMapper mapper)
    {
        _mangaService = mangaService;
        _mapper = mapper;
    }

    /// <summary>
    /// Obtiene todos los mangas sin paginación (no recomendado para grandes conjuntos de datos)
    /// </summary>
    [HttpGet("all")]
    public IActionResult GetAll()
    {
        var mangaDtos = _mangaService.GetAll();
        return Ok(mangaDtos);
    }

    /// <summary>
    /// Obtiene una lista paginada de mangas
    /// </summary>
    /// <param name="pageNumber">Número de página (por defecto: 1)</param>
    /// <param name="pageSize">Tamaño de página (por defecto: 50, máximo: 100)</param>
    [HttpGet]
    public IActionResult GetPaginated([FromQuery] int pageNumber = 1, [FromQuery] int pageSize = 50)
    {
        // Validar y ajustar el tamaño de página
        pageSize = Math.Min(Math.Max(1, pageSize), 100);
        pageNumber = Math.Max(1, pageNumber);

        var response = _mangaService.GetPaginated(pageNumber, pageSize);
        return Ok(response);
    }

    [HttpGet("{id}")]
    public IActionResult GetById(int id)
    {
        try
        {
            var manga = _mangaService.GetById(id);
            return Ok(manga);
        }
        catch (KeyNotFoundException)
        {
            return NotFound();
        }
    }

    [HttpPost]
    public async Task<IActionResult> Add(MangaCreateDTO manga)
    {
        var entity = await _mangaService.Add(manga);
        var dto = _mangaService.GetById(entity.Id);
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
                                         mangas = g.Select(m => new { m.Id, m.Title, m.Author, m.Genres })
                                     })
                                     .ToList(),
            
            autores_duplicados = mangas.GroupBy(m => m.Author)
                                      .Where(g => g.Count() > 1)
                                      .Select(g => new {
                                          autor = g.Key,
                                          cantidad = g.Count(),
                                          mangas = g.Select(m => new { m.Id, m.Title, m.Author, m.Genres })
                                      })
                                      .ToList(),
            
            titulos_y_autores_duplicados = mangas.GroupBy(m => new { m.Title, m.Author })
                                                .Where(g => g.Count() > 1)
                                                .Select(g => new {
                                                    titulo = g.Key.Title,
                                                    autor = g.Key.Author,
                                                    cantidad = g.Count(),
                                                    mangas = g.Select(m => new { m.Id, m.Title, m.Author, m.Genres })
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
    public async Task<IActionResult> Update(int id, MangaCreateDTO manga)
    {
        try
        {
            await _mangaService.Update(id, manga);
            var updatedManga = _mangaService.GetById(id);
            return Ok(updatedManga);
        }
        catch (KeyNotFoundException)
        {
            return NotFound();
        }
    }

    [HttpDelete("{id}")]
    public IActionResult Delete(int id)
    {
        try
        {
            var manga = _mangaService.GetById(id);
            _mangaService.Delete(id);
            return NoContent();
        }
        catch (KeyNotFoundException)
        {
            return NotFound();
        }
    }
} 