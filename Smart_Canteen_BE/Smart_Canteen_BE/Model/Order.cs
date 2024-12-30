using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;

namespace Smart_Canteen_BE.Model
{
    public class Order
    {
        public int OrderId { get; set; }

        [Required(ErrorMessage = "ID user là bắt buộc")]
        public string UserId { get; set; }

        [JsonIgnore] // Loại bỏ khỏi JSON xử lý
        public User User { get; set; }

        public decimal TotalPrice { get; set; }

        [Required(ErrorMessage = "Trạng thái là bắt buộc")]
        public string Status { get; set; }

        public DateTime OrderTime { get; set; }

        [JsonIgnore] // Loại bỏ khỏi JSON xử lý
        public QRCode QRCode { get; set; }

        [JsonIgnore] // Loại bỏ khỏi JSON xử lý
        public ICollection<OrderDetail> OrderDetails { get; set; }
    }
}
