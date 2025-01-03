namespace Smart_Canteen_BE.Model
{
    public class Favorite
    {
        public int Id { get; set; }
        public string UserId { get; set; }
        public int ProductId { get; set; }

        public User User { get; set; }
        public Product Product { get; set; }
    }

}
