using System.ComponentModel.DataAnnotations;

namespace Smart_Canteen_BE.Model
{
    public class LoginModel
    {
        [Required(ErrorMessage = "Tên người dùng phải bắt buộc")]
        public string Username { get; set; } = string.Empty;

        [Required(ErrorMessage = "Mật khẩu phải bắt buộc")]
        public string Password { get; set; } = string.Empty;
    }
}
