using System.ComponentModel.DataAnnotations;

namespace Smart_Canteen_BE.Model
{
    public class RegistrationModel
    {
        [Required(ErrorMessage = "Tên người dùng phải bắt buộc")]
        public string Username { get; set; } = string.Empty;

        [Required(ErrorMessage = "Email phải bắt buộc")]
        [EmailAddress(ErrorMessage = "Địa chỉ email không hợp lệ")]
        public string Email { get; set; } = string.Empty;

        [Required(ErrorMessage = "Mật khẩu phải bắt buộc")]
        [MinLength(6, ErrorMessage = "Mật khẩu phải có ít nhất 6 ký tự")]
        public string Password { get; set; } = string.Empty;

        public string FullName { get; set; } // Add FullName
        public string? Role { get; set; } // Optional: Assign a role if needed
    }
}
