using Microsoft.EntityFrameworkCore;
using JaveragesLibrary.Domain.Entities;

namespace JaveragesLibrary.Infrastructure.Data;

public class MangaDbContext : DbContext
{
    public MangaDbContext(DbContextOptions<MangaDbContext> options)
        : base(options)
    {
    }

    public DbSet<Manga> Mangas { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Manga>(entity =>
        {
            entity.ToTable("Mangas");
            
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Id)
                .UseIdentityColumn();
            
            entity.Property(e => e.Title)
                .IsRequired()
                .HasMaxLength(200);
            
            entity.Property(e => e.Author)
                .IsRequired()
                .HasMaxLength(100);
            
            entity.Property(e => e.Genre)
                .IsRequired()
                .HasMaxLength(50);
            
            entity.Property(e => e.Status)
                .IsRequired()
                .HasMaxLength(20);
            
            entity.Property(e => e.PublicationDate)
                .IsRequired();

            entity.HasIndex(e => e.Title)
                .HasDatabaseName("IX_Mangas_Title");
            
            entity.HasIndex(e => e.Author)
                .HasDatabaseName("IX_Mangas_Author");
        });
    }
} 