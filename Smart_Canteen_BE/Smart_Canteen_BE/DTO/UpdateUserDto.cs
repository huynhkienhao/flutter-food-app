using System.ComponentModel.DataAnnotations;

namespace Smart_Canteen_BE.DTO
{
    public class UpdateUserDto
    {
        [Required(ErrorMessage = "Họ tên phải bắt buộc")]
        public string FullName { get; set; }

        [EmailAddress(ErrorMessage = "Định dạng email không hợp lệ")]
        public string Email { get; set; }

        [Phone(ErrorMessage = "Số điện thoại không hợp lệ")]
        public string PhoneNumber { get; set; }
    }
}
