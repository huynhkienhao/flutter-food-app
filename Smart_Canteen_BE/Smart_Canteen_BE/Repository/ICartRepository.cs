using Smart_Canteen_BE.Model;

namespace Smart_Canteen_BE.Repository
{
    public interface ICartRepository
    {
        Task<IEnumerable<Cart>> GetAllCartsByUserIdAsync(string userId);
        Task AddToCartAsync(Cart cart);
        Task RemoveFromCartAsync(int cartId);
        Task UpdateCartAsync(Cart cart);
    }

}
