using System.ComponentModel.DataAnnotations;

namespace Smart_Canteen_BE.DTO
{
    public class UpdateUserDto
    {
        [Required(ErrorMessage = "Full name is required")]
        public string FullName { get; set; }

        [EmailAddress(ErrorMessage = "Invalid email format")]
        public string Email { get; set; }

        [Phone(ErrorMessage = "Invalid phone number")]
        public string PhoneNumber { get; set; }
    }
}
