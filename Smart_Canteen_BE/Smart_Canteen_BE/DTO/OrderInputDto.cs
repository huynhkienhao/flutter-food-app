using System.ComponentModel.DataAnnotations;

namespace Smart_Canteen_BE.DTO
{
    public class OrderInputDto
    {
        [Required(ErrorMessage = "UserId is required")]
        public string UserId { get; set; }

        [Required(ErrorMessage = "CartIds are required")]
        public List<int> CartIds { get; set; }
    }

}
