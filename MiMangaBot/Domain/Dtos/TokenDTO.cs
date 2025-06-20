using System;

namespace JaveragesLibrary.Domain.Dtos;

public class TokenDTO
{
    public string Token { get; set; } = string.Empty;
    public DateTime Expiration { get; set; }
} 