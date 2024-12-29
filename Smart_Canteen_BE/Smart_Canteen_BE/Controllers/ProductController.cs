using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Smart_Canteen_BE.DTO;
using Smart_Canteen_BE.Model;
using Smart_Canteen_BE.Repository;

namespace Smart_Canteen_BE.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ProductController : ControllerBase
    {
        private readonly IProductRepository _productRepository;
        private readonly ApplicationDbContext _context;

        public ProductController(IProductRepository productRepository, ApplicationDbContext context)
        {
            _productRepository = productRepository;
            _context = context;
        }
        [Authorize(Policy = "AdminOrUser")]
        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            var products = await _productRepository.GetAllProductsAsync();
            return Ok(products);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(int id)
        {
            var product = await _context.Products.Include(p => p.Category).FirstOrDefaultAsync(p => p.ProductId == id);
            if (product == null)
                return NotFound();

            var productOutput = new ProductOutputDto
            {
                ProductId = product.ProductId,
                ProductName = product.ProductName,
                Price = product.Price,
                Description = product.Description,
                CategoryId = product.CategoryId,
                CategoryName = product.Category?.CategoryName,
                Image = product.Image,
                Stock = product.Stock
            };

            return Ok(productOutput);
        }

        [Authorize(Policy = "AdminOnly")]
        [HttpPost]
        public async Task<IActionResult> Create([FromBody] ProductInputDto productInput)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            // Kiểm tra nếu CategoryId không tồn tại
            var category = await _context.Categories.FindAsync(productInput.CategoryId);
            if (category == null)
            {
                return BadRequest(new { Message = $"Category with ID {productInput.CategoryId} does not exist." });
            }

            // Tạo Product từ DTO
            var product = new Product
            {
                ProductName = productInput.ProductName,
                Price = productInput.Price,
                Description = productInput.Description,
                CategoryId = productInput.CategoryId,
                Category = category,
                Image = productInput.Image,
                Stock = productInput.Stock
            };

            // Thêm sản phẩm vào cơ sở dữ liệu
            await _context.Products.AddAsync(product);
            await _context.SaveChangesAsync();

            // Trả về thông tin sản phẩm mới
            return CreatedAtAction(nameof(GetById), new { id = product.ProductId }, product);
        }


        [Authorize(Policy = "AdminOnly")]
        [HttpPut("{id}")]
        public async Task<IActionResult> Update(int id, [FromBody] Product product)
        {
            if (id != product.ProductId)
                return BadRequest();

            await _productRepository.UpdateProductAsync(product);
            return NoContent();
        }
        [Authorize(Policy = "AdminOnly")]
        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            await _productRepository.DeleteProductAsync(id);
            return NoContent();
        }


    }

}
