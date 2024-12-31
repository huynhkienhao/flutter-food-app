using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Smart_Canteen_BE.DTO;
using Smart_Canteen_BE.Model;

namespace Smart_Canteen_BE.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class UserController : ControllerBase
    {
        private readonly UserManager<User> _userManager;
        private readonly RoleManager<IdentityRole> _roleManager;

        public UserController(UserManager<User> userManager, RoleManager<IdentityRole> roleManager)
        {
            _userManager = userManager;
            _roleManager = roleManager;
        }


        // Lấy danh sách tất cả người dùng
        [Authorize(Policy = "AdminOnly")]
        [HttpGet]
        public async Task<IActionResult> GetAllUsers()
        {
            var users = await _userManager.Users.ToListAsync();
            return Ok(users.Select(u => new
            {
                u.Id,
                u.UserName,
                u.Email,
                u.PhoneNumber
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
                user.PhoneNumber,
                user.FullName
            });
        }

        // Cập nhật thông tin người dùng
        [Authorize(Policy = "AdminOrUser")]
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateUser(string id, [FromBody] UpdateUserDto updateUserDto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var user = await _userManager.FindByIdAsync(id);
            if (user == null)
                return NotFound(new { Message = "User not found" });

            // Cập nhật thông tin người dùng
            user.FullName = updateUserDto.FullName ?? user.FullName;
            user.Email = updateUserDto.Email ?? user.Email;
            user.PhoneNumber = updateUserDto.PhoneNumber ?? user.PhoneNumber;

            var result = await _userManager.UpdateAsync(user);
            if (!result.Succeeded)
                return StatusCode(500, new { Message = "Failed to update user", Errors = result.Errors });

            return Ok(new { Message = "User updated successfully" });
        }

        [Authorize(Policy = "AdminOnly")]
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
        [Authorize(Policy = "AdminOnly")]
        [HttpGet("role/{roleName}")]
        public async Task<IActionResult> GetUsersByRole(string roleName)
        {
            // Kiểm tra nếu vai trò tồn tại
            var roleExists = await _roleManager.RoleExistsAsync(roleName);
            if (!roleExists)
            {
                return NotFound(new { Message = $"Role '{roleName}' does not exist." });
            }

            // Lấy danh sách người dùng có vai trò tương ứng
            var usersInRole = await _userManager.GetUsersInRoleAsync(roleName);

            var userOutputs = usersInRole.Select(user => new
            {
                user.Id,
                user.UserName,
                user.Email,
                user.FullName
            });

            return Ok(userOutputs);
        }

    }
}
