using System.ComponentModel.DataAnnotations;

namespace Smart_Canteen_BE.DTO
{
    public class CategoryInputDto
    {
        [Required(ErrorMessage = "Category name is required")]
        [MaxLength(100, ErrorMessage = "Category name cannot exceed 100 characters")]
        public string CategoryName { get; set; }

        public string Description { get; set; }
    }
}
