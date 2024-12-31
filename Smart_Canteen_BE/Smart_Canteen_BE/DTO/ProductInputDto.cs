using System.ComponentModel.DataAnnotations;

namespace Smart_Canteen_BE.DTO
{
    public class ProductInputDto
    {
        [Required(ErrorMessage = "Product name is required")]
        public string ProductName { get; set; }

        [Range(0.01, double.MaxValue, ErrorMessage = "Price must be greater than zero")]
        public decimal Price { get; set; }

        public string Description { get; set; }

        [Required(ErrorMessage = "CategoryId is required")]
        public int CategoryId { get; set; }

        [Required(ErrorMessage = "Image is required")]
        public string Image { get; set; }

        [Range(0, int.MaxValue, ErrorMessage = "Stock must be a non-negative number")]
        public int Stock { get; set; }
    }

}
