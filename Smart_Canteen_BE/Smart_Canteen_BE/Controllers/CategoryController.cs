using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
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
            return Ok(categories);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(int id)
        {
            var category = await _categoryRepository.GetCategoryByIdAsync(id);
            if (category == null)
                return NotFound();

            return Ok(category);
        }
        [Authorize(Policy = "AdminOnly")]
        [HttpPost]
        public async Task<IActionResult> Create([FromBody] Category category)
        {
            // Kiểm tra tính hợp lệ của Model
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            // Kiểm tra trùng lặp tên danh mục
            var existingCategory = await _categoryRepository.GetAllCategoriesAsync();
            if (existingCategory.Any(c => c.CategoryName.Equals(category.CategoryName, StringComparison.OrdinalIgnoreCase)))
            {
                return Conflict(new { Message = "Category with the same name already exists." });
            }

            // Thêm danh mục vào cơ sở dữ liệu
            await _categoryRepository.AddCategoryAsync(category);

            // Phản hồi thành công với thông tin danh mục vừa tạo
            return CreatedAtAction(nameof(GetById), new { id = category.CategoryId }, category);
        }

        [Authorize(Policy = "AdminOnly")]
        [HttpPut("{id}")]
        public async Task<IActionResult> Update(int id, [FromBody] Category category)
        {
            if (id != category.CategoryId)
                return BadRequest(new { Message = "Category ID mismatch" });

            try
            {
                await _categoryRepository.UpdateCategoryAsync(category);
                return NoContent();
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { Message = "Failed to update category", Details = ex.Message });
            }
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
