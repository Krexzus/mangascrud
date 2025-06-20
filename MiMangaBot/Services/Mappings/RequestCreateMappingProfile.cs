using System;
using AutoMapper;
using JaveragesLibrary.Domain.Dtos;
using JaveragesLibrary.Domain.Entities;

namespace JaveragesLibrary.Services.Mappings;

public class RequestCreateMappingProfile : Profile
{
    public RequestCreateMappingProfile()
    {
        CreateMap<MangaCreateDTO, Manga>()
            .ForMember(dest => dest.Genres, opt => opt.Ignore())
            .AfterMap
            (
                (src, dest) => 
                {
                    dest.PublicationDate = DateTime.Now;
                }
            );
    }
} 