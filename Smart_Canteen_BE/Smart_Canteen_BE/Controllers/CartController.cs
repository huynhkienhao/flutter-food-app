using Microsoft.AspNetCore.Mvc;
using Smart_Canteen_BE.Model;
using Smart_Canteen_BE.Repository;
using Microsoft.EntityFrameworkCore;
using Smart_Canteen_BE.DTO;
using Microsoft.AspNetCore.Authorization;

namespace Smart_Canteen_BE.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class CartController : ControllerBase
    {
        private readonly ICartRepository _cartRepository;
        private readonly ApplicationDbContext _context;

        public CartController(ICartRepository cartRepository, ApplicationDbContext context)
        {
            _cartRepository = cartRepository;
            _context = context;
        }

        [HttpGet("user/{userId}")]
        public async Task<IActionResult> GetCartsByUserId(string userId)
        {
            var carts = await _cartRepository.GetAllCartsByUserIdAsync(userId);

            // Chuyển đổi sang DTO
            var cartOutputs = carts.Select(cart => new CartOutputDto
            {
                CartId = cart.CartId,
                UserId = cart.UserId,
                ProductId = cart.ProductId,
                ProductName = cart.Product?.ProductName,
                ProductPrice = cart.Product?.Price ?? 0,
                Quantity = cart.Quantity,
                Stock = cart.Product?.Stock ?? 0, // Thêm stock
                AddedTime = cart.AddedTime
            });

            return Ok(cartOutputs);
        }

        [HttpPost]
        public async Task<IActionResult> AddToCart([FromBody] CartInputDto cartInput)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            // Kiểm tra nếu UserId không tồn tại
            var user = await _context.Users.FindAsync(cartInput.UserId);
            if (user == null)
            {
                return BadRequest(new { Message = $"User with ID {cartInput.UserId} does not exist." });
            }

            // Kiểm tra nếu ProductId không tồn tại
            var product = await _context.Products.FindAsync(cartInput.ProductId);
            if (product == null)
            {
                return BadRequest(new { Message = $"Product with ID {cartInput.ProductId} does not exist." });
            }

            // Tạo đối tượng Cart
            var cart = new Cart
            {
                UserId = cartInput.UserId,
                ProductId = cartInput.ProductId,
                Quantity = cartInput.Quantity,
                AddedTime = DateTime.UtcNow,
                User = user,
                Product = product
            };

            // Thêm Cart vào cơ sở dữ liệu
            await _cartRepository.AddToCartAsync(cart);

            // Trả về DTO cho client
            var cartOutput = new CartOutputDto
            {
                CartId = cart.CartId,
                UserId = cart.UserId,
                ProductId = cart.ProductId,
                ProductName = product.ProductName,
                ProductPrice = product.Price,
                Quantity = cart.Quantity,
                AddedTime = cart.AddedTime
            };

            return CreatedAtAction(nameof(GetCartsByUserId), new { userId = cart.UserId }, cartOutput);
        }

        [HttpDelete("{cartId}")]
        public async Task<IActionResult> RemoveFromCart(int cartId)
        {
            await _cartRepository.RemoveFromCartAsync(cartId);
            return NoContent();
        }

        [HttpPut("{cartId}")]
        public async Task<IActionResult> UpdateCartQuantity(int cartId, [FromBody] int newQuantity)
        {
            if (newQuantity <= 0)
            {
                return BadRequest(new { Message = "Quantity must be greater than 0." });
            }

            var cartItem = await _context.Carts.FindAsync(cartId);
            if (cartItem == null)
            {
                return NotFound(new { Message = $"Cart item with ID {cartId} does not exist." });
            }

            cartItem.Quantity = newQuantity;
            _context.Carts.Update(cartItem);
            await _context.SaveChangesAsync();

            return Ok(new
            {
                cartItem.CartId,
                cartItem.ProductId,
                cartItem.Quantity,
                ProductPrice = cartItem.Product?.Price,
                TotalPrice = cartItem.Product?.Price * cartItem.Quantity
            });
        }

        [HttpGet("count")]
        public async Task<IActionResult> GetCartItemCount([FromQuery] string userId)
        {
            if (string.IsNullOrEmpty(userId))
            {
                return BadRequest(new { message = "User ID is required." });
            }

            try
            {
                // Đếm tổng số lượng sản phẩm trong giỏ hàng của người dùng
                var count = await _context.Carts
                                          .Where(c => c.UserId == userId)
                                          .SumAsync(c => c.Quantity);

                return Ok(new { count });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "An error occurred.", error = ex.Message });
            }
        }
    }
}
