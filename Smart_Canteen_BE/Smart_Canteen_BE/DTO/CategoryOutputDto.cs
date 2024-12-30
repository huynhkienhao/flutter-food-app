namespace Smart_Canteen_BE.DTO
{
    public class CategoryOutputDto
    {
        public int CategoryId { get; set; }
        public string CategoryName { get; set; }
        public string Description { get; set; }

        // Thêm danh sách sản phẩm
        public List<ProductOutputDto> Products { get; set; } = new List<ProductOutputDto>();
    }
}
