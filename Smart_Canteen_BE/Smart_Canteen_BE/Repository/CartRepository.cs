using Microsoft.EntityFrameworkCore;
using Smart_Canteen_BE.Model;

namespace Smart_Canteen_BE.Repository
{
    public class CartRepository : ICartRepository
    {
        private readonly ApplicationDbContext _context;

        public CartRepository(ApplicationDbContext context)
        {
            _context = context;
        }

        public async Task<IEnumerable<Cart>> GetAllCartsByUserIdAsync(string userId)
        {
            return await _context.Carts.Include(c => c.Product).Where(c => c.UserId == userId).ToListAsync();
        }

        public async Task AddToCartAsync(Cart cart)
        {
            var existingCart = await _context.Carts
                .FirstOrDefaultAsync(c => c.UserId == cart.UserId && c.ProductId == cart.ProductId);

            if (existingCart != null)
            {
                // Nếu sản phẩm đã tồn tại trong giỏ hàng, tăng số lượng
                existingCart.Quantity += cart.Quantity;
                _context.Carts.Update(existingCart);
            }
            else
            {
                // Nếu sản phẩm chưa tồn tại, thêm mới
                await _context.Carts.AddAsync(cart);
            }

            await _context.SaveChangesAsync();
        }

        public async Task RemoveFromCartAsync(int cartId)
        {
            var cart = await _context.Carts.FindAsync(cartId);
            if (cart != null)
            {
                _context.Carts.Remove(cart);
                await _context.SaveChangesAsync();
            }
        }

        public async Task UpdateCartAsync(Cart cart)
        {
            _context.Carts.Update(cart);
            await _context.SaveChangesAsync();
        }
    }

}
