using System.ComponentModel.DataAnnotations;

namespace Smart_Canteen_BE.DTO
{
    public class CartInputDto
    {
        [Required(ErrorMessage = "ID user là bắt buộc")]
        public string UserId { get; set; }

        [Required(ErrorMessage = "ID sản phẩm là bắt buộc")]
        public int ProductId { get; set; }

        [Required(ErrorMessage = "Số lượng là bắt buộc")]
        [Range(1, int.MaxValue, ErrorMessage = "Số lượng phải ít nhất là 1")]
        public int Quantity { get; set; }
    }
}
