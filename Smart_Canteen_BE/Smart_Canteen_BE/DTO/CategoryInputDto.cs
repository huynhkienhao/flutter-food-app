using System.ComponentModel.DataAnnotations;

namespace Smart_Canteen_BE.DTO
{
    public class CategoryInputDto
    {
        [Required(ErrorMessage = "Tên danh mục là bắt buộc")]
        [MaxLength(100, ErrorMessage = "Tên danh mục không được vượt quá 100 ký tự")]
        public string CategoryName { get; set; }

        public string Description { get; set; }
    }
}
