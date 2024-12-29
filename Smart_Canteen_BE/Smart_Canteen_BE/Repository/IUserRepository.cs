namespace Smart_Canteen_BE.Repository
{
    using Microsoft.AspNetCore.Identity;
    using Smart_Canteen_BE.Model;

    public interface IUserRepository
    {
        Task<IEnumerable<User>> GetAllUsersAsync();
        Task<User> GetUserByIdAsync(string userId);
        Task AddUserAsync(User user, string password);
        Task UpdateUserAsync(User user);
        Task DeleteUserAsync(string userId);
        Task<bool> AssignRoleAsync(User user, string role);
    }

}
