using System.ComponentModel.DataAnnotations;

namespace Smart_Canteen_BE.DTO
{
    public class OrderInputDto
    {
        [Required(ErrorMessage = "ID user là bắt buộc")]
        public string UserId { get; set; }

        [Required(ErrorMessage = "ID giỏ hàng là bắt buộc")]
        public List<int> CartIds { get; set; }
    }

}
