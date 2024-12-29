using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Smart_Canteen_BE.Model;

namespace Smart_Canteen_BE.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class UserController : ControllerBase
    {
        private readonly UserManager<User> _userManager;

        public UserController(UserManager<User> userManager)
        {
            _userManager = userManager;
        }

        // Lấy danh sách tất cả người dùng
        [HttpGet]
        public async Task<IActionResult> GetAllUsers()
        {
            var users = await _userManager.Users.ToListAsync();
            return Ok(users.Select(u => new
            {
                u.Id,
                u.UserName,
                u.Email,
            }));
        }

        // Lấy thông tin chi tiết của một người dùng
        [HttpGet("{id}")]
        public async Task<IActionResult> GetUserById(string id)
        {
            var user = await _userManager.FindByIdAsync(id);
            if (user == null)
                return NotFound(new { Message = "User not found" });

            return Ok(new
            {
                user.Id,
                user.UserName,
                user.Email,
            });
        }

        // Xóa một người dùng
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteUser(string id)
        {
            var user = await _userManager.FindByIdAsync(id);
            if (user == null)   
                return NotFound(new { Message = "User not found" });

            var result = await _userManager.DeleteAsync(user);
            if (!result.Succeeded)
                return StatusCode(500, new { Message = "Failed to delete user", Errors = result.Errors });

            return Ok(new { Message = "User deleted successfully" });
        }
    }
}
