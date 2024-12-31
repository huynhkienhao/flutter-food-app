using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Smart_Canteen_BE.DTO;
using Smart_Canteen_BE.Model;
using Smart_Canteen_BE.Repository;

namespace Smart_Canteen_BE.Controllers
{

    [ApiController]
    [Route("api/[controller]")]
    public class CategoryController : ControllerBase
    {
        private readonly ICategoryRepository _categoryRepository;

        public CategoryController(ICategoryRepository categoryRepository)
        {
            _categoryRepository = categoryRepository;
        }

        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            var categories = await _categoryRepository.GetAllCategoriesAsync();
            var categoryOutputs = categories.Select(c => new CategoryOutputDto
            {
                CategoryId = c.CategoryId,
                CategoryName = c.CategoryName,
                Description = c.Description
            });

            return Ok(categoryOutputs);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(int id)
        {
            // Lấy danh mục kèm theo các sản phẩm
            var category = await _categoryRepository.GetCategoryByIdAsync(id, includeProducts: true);

            if (category == null)
                return NotFound(new { Message = "Category not found" });

            // Bao gồm danh sách sản phẩm
            var categoryOutput = new CategoryOutputDto
            {
                CategoryId = category.CategoryId,
                CategoryName = category.CategoryName,
                Description = category.Description,
                Products = category.Products.Select(p => new ProductOutputDto
                {
                    ProductId = p.ProductId,
                    ProductName = p.ProductName,
                    Price = p.Price,
                    Description = p.Description,
                    Image = p.Image,
                    Stock = p.Stock,
                    CategoryId = p.CategoryId
                }).ToList()
            };

            return Ok(categoryOutput);
        }




        [Authorize(Policy = "AdminOnly")]
        [HttpPost]
        public async Task<IActionResult> Create([FromBody] CategoryInputDto categoryInput)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            // Kiểm tra trùng lặp tên danh mục
            var existingCategory = await _categoryRepository.GetAllCategoriesAsync();
            if (existingCategory.Any(c => c.CategoryName.Equals(categoryInput.CategoryName, StringComparison.OrdinalIgnoreCase)))
            {
                return Conflict(new { Message = "Category with the same name already exists." });
            }

            // Tạo Category từ DTO
            var category = new Category
            {
                CategoryName = categoryInput.CategoryName,
                Description = categoryInput.Description
            };

            await _categoryRepository.AddCategoryAsync(category);

            // Trả về thông tin danh mục vừa tạo
            var categoryOutput = new CategoryOutputDto
            {
                CategoryId = category.CategoryId,
                CategoryName = category.CategoryName,
                Description = category.Description
            };

            return CreatedAtAction(nameof(GetById), new { id = category.CategoryId }, categoryOutput);
        }


        [Authorize(Policy = "AdminOnly")]
        [HttpPut("{id}")]
        public async Task<IActionResult> Update(int id, [FromBody] CategoryInputDto categoryInput)
        {
            var category = await _categoryRepository.GetCategoryByIdAsync(id);
            if (category == null)
                return NotFound(new { Message = "Category not found" });

            category.CategoryName = categoryInput.CategoryName;
            category.Description = categoryInput.Description;

            await _categoryRepository.UpdateCategoryAsync(category);
            return NoContent();
        }




        [Authorize(Policy = "AdminOnly")]
        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            await _categoryRepository.DeleteCategoryAsync(id);
            return NoContent();
        }

    }

}
