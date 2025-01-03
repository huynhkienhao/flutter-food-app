using Microsoft.AspNetCore.Mvc;
using Smart_Canteen_BE.DTO;
using Smart_Canteen_BE.Model;
using Smart_Canteen_BE.Repository;

[ApiController]
[Route("api/[controller]")]
public class FavoriteController : ControllerBase
{
    private readonly IFavoriteRepository _favoriteRepository;
    private readonly ApplicationDbContext _context;

    public FavoriteController(IFavoriteRepository favoriteRepository, ApplicationDbContext context)
    {
        _favoriteRepository = favoriteRepository;
        _context = context;
    }

    [HttpGet("user/{userId}")]
    public async Task<IActionResult> GetFavoritesByUserId(string userId)
    {
        var favorites = await _favoriteRepository.GetAllFavoritesByUserIdAsync(userId);

        var favoriteOutputs = favorites.Select(favorite => new FavoriteOutputDto
        {
            FavoriteId = favorite.Id,
            UserId = favorite.UserId,
            ProductId = favorite.ProductId,
            ProductName = favorite.Product?.ProductName,
            ProductPrice = favorite.Product?.Price ?? 0,
            ProductImage = favorite.Product?.Image
        });

        return Ok(favoriteOutputs);
    }

    [HttpPost]
    public async Task<IActionResult> AddToFavorite([FromBody] FavoriteInputDto favoriteInput)
    {
        if (!ModelState.IsValid)
        {
            return BadRequest(ModelState);
        }

        // Kiểm tra nếu UserId không tồn tại
        var user = await _context.Users.FindAsync(favoriteInput.UserId);
        if (user == null)
        {
            return BadRequest(new { Message = $"User with ID {favoriteInput.UserId} does not exist." });
        }

        // Kiểm tra nếu ProductId không tồn tại
        var product = await _context.Products.FindAsync(favoriteInput.ProductId);
        if (product == null)
        {
            return BadRequest(new { Message = $"Product with ID {favoriteInput.ProductId} does not exist." });
        }

        var favorite = new Favorite
        {
            UserId = favoriteInput.UserId,
            ProductId = favoriteInput.ProductId,
            User = user,
            Product = product
        };

        await _favoriteRepository.AddToFavoriteAsync(favorite);

        var favoriteOutput = new FavoriteOutputDto
        {
            FavoriteId = favorite.Id,
            UserId = favorite.UserId,
            ProductId = favorite.ProductId,
            ProductName = product.ProductName,
            ProductPrice = product.Price,
            ProductImage = product.Image
        };

        return CreatedAtAction(nameof(GetFavoritesByUserId), new { userId = favorite.UserId }, favoriteOutput);
    }

    [HttpDelete("{favoriteId}")]
    public async Task<IActionResult> RemoveFromFavorite(int favoriteId)
    {
        await _favoriteRepository.RemoveFromFavoriteAsync(favoriteId);
        return NoContent();
    }
}
