using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using JaveragesLibrary.Domain.Entities;
using JaveragesLibrary.Infrastructure.Data;
using JaveragesLibrary.Infrastructure.Repositories;
using JaveragesLibrary.Domain.Dtos;

namespace JaveragesLibrary.Services.Features.Mangas;

public class MangaService
{
    private readonly MangaRepository _mangaRepository;
    private readonly MangaDbContext _context;

    public MangaService(MangaRepository mangaRepository, MangaDbContext context)
    {
        _mangaRepository = mangaRepository;
        _context = context;
    }

    public IEnumerable<MangaDTO> GetAll()
    {
        return _mangaRepository.GetQueryable()
            .Include(m => m.Genres)
            .Select(m => new MangaDTO
            {
                Id = m.Id,
                Title = m.Title,
                Author = m.Author,
                Status = m.Status,
                PublicationDate = m.PublicationDate,
                Genres = m.Genres.Select(g => g.Name).ToList()
            })
            .ToList();
    }

    public PaginatedResponse<MangaDTO> GetPaginated(int pageNumber = 1, int pageSize = 50)
    {
        var query = _mangaRepository.GetQueryable()
            .Include(m => m.Genres);
            
        var totalItems = query.Count();
        var totalPages = (int)Math.Ceiling(totalItems / (double)pageSize);

        pageNumber = Math.Max(1, pageNumber);
        pageNumber = Math.Min(pageNumber, totalPages);

        var items = query
            .Skip((pageNumber - 1) * pageSize)
            .Take(pageSize)
            .Select(m => new MangaDTO
            {
                Id = m.Id,
                Title = m.Title,
                Author = m.Author,
                Status = m.Status,
                PublicationDate = m.PublicationDate,
                Genres = m.Genres.Select(g => g.Name).ToList()
            })
            .ToList();

        return new PaginatedResponse<MangaDTO>
        {
            Items = items,
            PageNumber = pageNumber,
            PageSize = pageSize,
            TotalPages = totalPages,
            TotalItems = totalItems
        };
    }

    public MangaDTO GetById(int id)
    {
        var manga = _context.Mangas
            .Include(m => m.Genres)
            .FirstOrDefault(m => m.Id == id);

        if (manga == null)
            throw new KeyNotFoundException($"Manga with ID {id} not found");

        return new MangaDTO
        {
            Id = manga.Id,
            Title = manga.Title,
            Author = manga.Author,
            Status = manga.Status,
            PublicationDate = manga.PublicationDate,
            Genres = manga.Genres.Select(g => g.Name).ToList()
        };
    }

    public async Task<Manga> Add(MangaCreateDTO mangaDto)
    {
        var manga = new Manga
        {
            Title = mangaDto.Title,
            Author = mangaDto.Author,
            Status = mangaDto.Status,
            PublicationDate = mangaDto.PublicationDate
        };

        // Procesar géneros
        foreach (var genreName in mangaDto.Genres)
        {
            var genre = await _context.Genres
                .FirstOrDefaultAsync(g => g.Name == genreName);
                
            if (genre != null)
            {
                manga.Genres.Add(genre);
            }
        }

        _mangaRepository.Add(manga);
        return manga;
    }

    public async Task Update(int id, MangaCreateDTO mangaDto)
    {
        var manga = await _context.Mangas
            .Include(m => m.Genres)
            .FirstOrDefaultAsync(m => m.Id == id);

        if (manga == null)
            throw new KeyNotFoundException($"Manga with ID {id} not found");

        manga.Title = mangaDto.Title;
        manga.Author = mangaDto.Author;
        manga.Status = mangaDto.Status;
        manga.PublicationDate = mangaDto.PublicationDate;

        // Actualizar géneros
        manga.Genres.Clear();
        foreach (var genreName in mangaDto.Genres)
        {
            var genre = await _context.Genres
                .FirstOrDefaultAsync(g => g.Name == genreName);
                
            if (genre != null)
            {
                manga.Genres.Add(genre);
            }
        }

        await _context.SaveChangesAsync();
    }

    public void Delete(int id)
    {
        _mangaRepository.Delete(id);
    }
} 