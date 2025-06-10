using Bogus;
using JaveragesLibrary.Domain.Entities;
using System.Text.Json;

namespace JaveragesLibrary.Infrastructure.Data.Seed;

public static class MangaDataGenerator
{
    public static void GenerateAndSaveData(string filePath, int count = 3500)
    {
        // Configurar locale para nombres japoneses
        Faker.GlobalUniqueIndex = 0;
        var faker = new Faker("ja");

        // Lista de palabras para títulos
        var titlePrefixes = new[] { 
            "The Legend of", "Rise of", "Tales of", "Chronicles of", "Saga of", 
            "Journey to", "Path of", "Spirit of", "Heroes of", "Warriors of",
            "Secret of", "Heart of", "Soul of", "Blade of", "Master of",
            "Legacy of", "Dawn of", "Twilight of", "Shadow of", "Light of"
        };
        
        var titleWords = new[] { 
            "Dragon", "Sword", "Ninja", "Samurai", "Magic", "Kingdom", "Empire", 
            "Academy", "School", "Battle", "War", "Peace", "Love", "Death", "Life", 
            "Soul", "Spirit", "Destiny", "Fate", "Legend", "Phoenix", "Moon", "Sun", 
            "Star", "Ocean", "Mountain", "Forest", "Storm", "Thunder", "Lightning",
            "Fire", "Ice", "Wind", "Earth", "Heaven", "Hell", "Demon", "Angel",
            "God", "Devil"
        };
        
        var titleSuffixes = new[] { 
            "Chronicles", "Stories", "Tales", "Legends", "Adventures", 
            "Quest", "Saga", "Journey", "Path", "Destiny",
            "Legacy", "Prophecy", "Mystery", "Secret", "Dream",
            "Vision", "Awakening", "Revolution", "Empire", "Kingdom"
        };

        var uniqueTitles = new HashSet<string>();
        var uniqueMangas = new List<Manga>();
        var random = new Random();

        while (uniqueMangas.Count < count)
        {
            var prefix = titlePrefixes[random.Next(titlePrefixes.Length)];
            var word = titleWords[random.Next(titleWords.Length)];
            var suffix = titleSuffixes[random.Next(titleSuffixes.Length)];
            var title = $"{prefix} {word} {suffix}";

            if (uniqueTitles.Add(title))  // Returns true if the title was added (i.e., it was unique)
            {
                var manga = new Manga
                {
                    Id = uniqueMangas.Count + 1,
                    Title = title,
                    Author = $"{faker.Name.LastName()} {faker.Name.FirstName()}",
                    Genre = faker.Random.ArrayElement(new[] {
                        "Shonen", "Seinen", "Shoujo", "Josei", "Kodomo", 
                        "Mecha", "Isekai", "Slice of Life", "Romance", "Action",
                        "Adventure", "Comedy", "Drama", "Fantasy", "Horror",
                        "Mystery", "Psychological", "Sci-Fi", "Sports", "Supernatural"
                    }),
                    Status = faker.Random.ArrayElement(new[] {
                        "En curso", "Finalizado", "En pausa", "Cancelado"
                    }),
                    PublicationDate = faker.Date.Between(
                        new DateTime(1980, 1, 1), 
                        DateTime.Now
                    )
                };
                uniqueMangas.Add(manga);
            }
        }

        var jsonString = JsonSerializer.Serialize(uniqueMangas, new JsonSerializerOptions 
        { 
            WriteIndented = true 
        });
        
        File.WriteAllText(filePath, jsonString);
    }
} 