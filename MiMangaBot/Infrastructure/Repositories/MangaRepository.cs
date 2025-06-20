using System.Collections.Generic;
using System.Linq;
using Microsoft.EntityFrameworkCore;
using JaveragesLibrary.Domain.Entities;
using JaveragesLibrary.Infrastructure.Data;

namespace JaveragesLibrary.Infrastructure.Repositories;

public class MangaRepository
{
    private readonly MangaDbContext _context;

    public MangaRepository(MangaDbContext context)
    {
        _context = context;
    }

    public IQueryable<Manga> GetQueryable()
    {
        return _context.Mangas.AsNoTracking();
    }

    public IEnumerable<Manga> GetAll()
    {
        return GetQueryable().Include(m => m.Genres).ToList();
    }

    public Manga GetById(int id)
    {
        return _context.Mangas
            .Include(m => m.Genres)
            .FirstOrDefault(manga => manga.Id == id)
            ?? new Manga
            {
                Title = string.Empty,
                Author = string.Empty,
                Status = string.Empty
            };
    }

    public void Add(Manga manga)
    {
        _context.Mangas.Add(manga);
        _context.SaveChanges();
    }

    public void Update(Manga updatedManga)
    {
        var manga = GetById(updatedManga.Id);
        if (manga.Id > 0)
        {
            _context.Entry(manga).CurrentValues.SetValues(updatedManga);
            _context.SaveChanges();
        }
    }

    public void Delete(int id)
    {
        var manga = GetById(id);
        if (manga.Id > 0)
        {
            _context.Mangas.Remove(manga);
            _context.SaveChanges();
        }
    }

    public void BulkInsert(IEnumerable<Manga> mangas)
    {
        _context.Mangas.AddRange(mangas);
        _context.SaveChanges();
    }
} 