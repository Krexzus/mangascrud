using JaveragesLibrary.Domain.Dtos;
using JaveragesLibrary.Services.Features.Auth;
using Microsoft.AspNetCore.Mvc;

namespace JaveragesLibrary.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AuthController : ControllerBase
{
    private readonly AuthService _authService;

    public AuthController(AuthService authService)
    {
        _authService = authService;
    }

    [HttpPost("login")]
    public IActionResult Login([FromBody] LoginDTO login)
    {
        var token = _authService.Authenticate(login);
        
        if (token == null)
        {
            return Unauthorized(new { message = "Usuario o contraseña incorrectos" });
        }

        return Ok(token);
    }
} 