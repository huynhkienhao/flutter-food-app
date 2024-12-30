using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;

namespace Smart_Canteen_BE.Model
{
    public class Product
    {
        public int ProductId { get; set; }

        [Required(ErrorMessage = "Tên sản phẩm là bắt buộc")]
        public string ProductName { get; set; }

        [Range(0.01, double.MaxValue, ErrorMessage = "Giá phải lớn hơn 0")]
        public decimal Price { get; set; }

        public string Description { get; set; }

        [Required(ErrorMessage = "ID sản phẩm là bắt buộc")] // Đảm bảo CategoryId được cung cấp
        public int CategoryId { get; set; }

        public Category Category { get; set; } // Navigation property

        [Required(ErrorMessage = "Hình ảnh là bắt buộc")]
        public string Image { get; set; }

        [Range(0, int.MaxValue, ErrorMessage = "Cổ phiếu phải là một số không âm")]
        public int Stock { get; set; }

        [JsonIgnore]
        public ICollection<Cart> Carts { get; set; } = new List<Cart>();

        [JsonIgnore]
        public ICollection<OrderDetail> OrderDetails { get; set; } = new List<OrderDetail>();
    }
}
