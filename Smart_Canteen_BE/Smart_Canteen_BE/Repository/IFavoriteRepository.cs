using Smart_Canteen_BE.Model;

namespace Smart_Canteen_BE.Repository
{
    public interface IFavoriteRepository
    {
        Task<IEnumerable<Favorite>> GetAllFavoritesByUserIdAsync(string userId);
        Task AddToFavoriteAsync(Favorite favorite);
        Task RemoveFromFavoriteAsync(int favoriteId);
    }

}
