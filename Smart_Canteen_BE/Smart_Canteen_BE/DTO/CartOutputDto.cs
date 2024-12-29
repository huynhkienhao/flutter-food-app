namespace Smart_Canteen_BE.DTO
{
    public class CartOutputDto
    {
        public int CartId { get; set; }
        public string UserId { get; set; }
        public int ProductId { get; set; }
        public string ProductName { get; set; }
        public decimal ProductPrice { get; set; }
        public int Quantity { get; set; }
        public DateTime AddedTime { get; set; }
    }

}
