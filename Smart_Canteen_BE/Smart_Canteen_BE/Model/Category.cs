using System.Text.Json.Serialization;

namespace Smart_Canteen_BE.Model
{
    public class Category
    {
        public int CategoryId { get; set; }
        public string CategoryName { get; set; }
        public string Description { get; set; }
        [JsonIgnore] // Bỏ qua trường này khi xử lý JSON
        public ICollection<Product> Products { get; set; } = new List<Product>(); // Giá trị mặc định
    }

}
