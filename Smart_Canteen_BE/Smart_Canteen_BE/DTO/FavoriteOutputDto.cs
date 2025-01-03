namespace Smart_Canteen_BE.DTO
{
    public class FavoriteOutputDto
    {
        public int FavoriteId { get; set; }
        public string UserId { get; set; }
        public int ProductId { get; set; }
        public string ProductName { get; set; }
        public decimal ProductPrice { get; set; }
        public string ProductImage { get; set; }
    }

}
