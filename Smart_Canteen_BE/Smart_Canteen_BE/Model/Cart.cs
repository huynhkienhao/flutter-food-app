using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;

namespace Smart_Canteen_BE.Model
{
    public class Cart
    {
        public int CartId { get; set; }

        [Required(ErrorMessage = "UserId is required")]
        public string UserId { get; set; }

        [JsonIgnore] // Loại bỏ User khỏi xử lý JSON
        public User User { get; set; } // Navigation property

        [Required(ErrorMessage = "ProductId is required")]
        public int ProductId { get; set; }

        [JsonIgnore] // Loại bỏ Product khỏi xử lý JSON
        public Product Product { get; set; } // Navigation property

        [Required(ErrorMessage = "Quantity is required")]
        [Range(1, int.MaxValue, ErrorMessage = "Quantity must be at least 1")]
        public int Quantity { get; set; }

        public DateTime AddedTime { get; set; } = DateTime.UtcNow; // Giá trị mặc định
    }
}
