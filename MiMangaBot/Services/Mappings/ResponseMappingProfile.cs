using System;
using System.Linq;
using AutoMapper;
using JaveragesLibrary.Domain.Dtos;
using JaveragesLibrary.Domain.Entities;

namespace JaveragesLibrary.Services.Mappings;

public class ResponseMappingProfile : Profile
{
    public ResponseMappingProfile()
    {
        CreateMap<Manga, MangaDTO>()
            .ForMember(
                dest => dest.Genres,
                opt => opt.MapFrom(src => src.Genres.Select(g => g.Name))
            );
    }
} 