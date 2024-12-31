using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;

namespace Smart_Canteen_BE.Model
{
    public class Product
    {
        public int ProductId { get; set; }

        [Required(ErrorMessage = "Product name is required")]
        public string ProductName { get; set; }

        [Range(0.01, double.MaxValue, ErrorMessage = "Price must be greater than zero")]
        public decimal Price { get; set; }

        public string Description { get; set; }

        [Required(ErrorMessage = "CategoryId is required")] // Đảm bảo CategoryId được cung cấp
        public int CategoryId { get; set; }

        public Category Category { get; set; } // Navigation property

        [Required(ErrorMessage = "Image is required")]
        public string Image { get; set; }

        [Range(0, int.MaxValue, ErrorMessage = "Stock must be a non-negative number")]
        public int Stock { get; set; }

        [JsonIgnore]
        public ICollection<Cart> Carts { get; set; } = new List<Cart>();

        [JsonIgnore]
        public ICollection<OrderDetail> OrderDetails { get; set; } = new List<OrderDetail>();
    }
}
