﻿namespace Smart_Canteen_BE.DTO
{
    public class ProductOutputDto
    {
        public int ProductId { get; set; }
        public string ProductName { get; set; }
        public decimal Price { get; set; }
        public string Description { get; set; }
        public int CategoryId { get; set; }
        public string CategoryName { get; set; }
        public string Image { get; set; }
        public int Stock { get; set; }
    }

}
