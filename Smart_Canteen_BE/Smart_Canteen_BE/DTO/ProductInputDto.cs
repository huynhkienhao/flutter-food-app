using System.ComponentModel.DataAnnotations;

namespace Smart_Canteen_BE.DTO
{
    public class ProductInputDto
    {
        [Required(ErrorMessage = "Tên sản phẩm là bắt buộc")]
        public string ProductName { get; set; }

        [Range(0.01, double.MaxValue, ErrorMessage = "Giá phải lớn hơn 0")]
        public decimal Price { get; set; }

        public string Description { get; set; }

        [Required(ErrorMessage = "ID danh mục là bắt buộc")]
        public int CategoryId { get; set; }

        [Required(ErrorMessage = "Hình ảnh phải bắt buộc")]
        public string Image { get; set; }

        [Range(0, int.MaxValue, ErrorMessage = "Cổ phiếu phải là một số không âm")]
        public int Stock { get; set; }
    }

}
