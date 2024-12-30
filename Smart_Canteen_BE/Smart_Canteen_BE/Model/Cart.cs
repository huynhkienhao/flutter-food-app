using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;

namespace Smart_Canteen_BE.Model
{
    public class Cart
    {
        public int CartId { get; set; }

        [Required(ErrorMessage = "ID user là bắt buộc")]
        public string UserId { get; set; }

        [JsonIgnore] // Loại bỏ User khỏi xử lý JSON
        public User User { get; set; } // Navigation property

        [Required(ErrorMessage = "ID sản phẩm là bắt buộc")]
        public int ProductId { get; set; }

        [JsonIgnore] // Loại bỏ Product khỏi xử lý JSON
        public Product Product { get; set; } // Navigation property

        [Required(ErrorMessage = "Số lượng là bắt buộc")]
        [Range(1, int.MaxValue, ErrorMessage = "Số lượng phải ít nhất là 1")]
        public int Quantity { get; set; }

        public DateTime AddedTime { get; set; } = DateTime.UtcNow; // Giá trị mặc định
    }
}
