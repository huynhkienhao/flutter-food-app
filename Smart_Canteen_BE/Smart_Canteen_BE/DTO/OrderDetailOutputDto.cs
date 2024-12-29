namespace Smart_Canteen_BE.DTO
{
    public class OrderDetailOutputDto
    {
        public int OrderDetailId { get; set; }
        public int ProductId { get; set; }
        public string ProductName { get; set; }
        public int Quantity { get; set; }
        public decimal SubTotal { get; set; }
    }

}
