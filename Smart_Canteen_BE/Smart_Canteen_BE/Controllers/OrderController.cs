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
    public class OrderController : ControllerBase
    {
        private readonly IOrderRepository _orderRepository;
        private readonly ApplicationDbContext _context;

        public OrderController(IOrderRepository orderRepository, ApplicationDbContext context)
        {
            _orderRepository = orderRepository;
            _context = context;
        }

        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            var orders = await _orderRepository.GetAllOrdersAsync();
            return Ok(orders);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(int id)
        {
            var order = await _context.Orders
                .Include(o => o.OrderDetails)
                .ThenInclude(od => od.Product) // Bao gồm thông tin sản phẩm
                .FirstOrDefaultAsync(o => o.OrderId == id);

            if (order == null)
                return NotFound(new { Message = $"Order with ID {id} does not exist." });

            var orderOutput = new OrderOutputDto
            {
                OrderId = order.OrderId,
                TotalPrice = order.TotalPrice,
                Status = order.Status,
                OrderTime = order.OrderTime,
                OrderDetails = order.OrderDetails.Select(od => new OrderDetailOutputDto
                {
                    OrderDetailId = od.OrderDetailId,
                    ProductId = od.ProductId,
                    ProductName = od.Product?.ProductName ?? "Không xác định", // Lấy tên sản phẩm từ Product
                    Quantity = od.Quantity,
                    SubTotal = od.SubTotal
                }).ToList()
            };

            return Ok(orderOutput);
        }


        [HttpGet("user/{userId}")]
        public async Task<IActionResult> GetOrdersByUserId(string userId)
        {
            var orders = await _orderRepository.GetOrdersByUserIdAsync(userId);
            return Ok(orders);
        }



        [HttpPost]
        public async Task<IActionResult> Create([FromBody] OrderInputDto orderInput)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            // Kiểm tra UserId
            var user = await _context.Users.FindAsync(orderInput.UserId);
            if (user == null)
            {
                return BadRequest(new { Message = $"User with ID {orderInput.UserId} does not exist." });
            }

            // Lấy danh sách Cart từ CartIds
            var carts = await _context.Carts
                .Include(c => c.Product)
                .Where(c => orderInput.CartIds.Contains(c.CartId) && c.UserId == orderInput.UserId)
                .ToListAsync();

            if (carts.Count != orderInput.CartIds.Count)
            {
                return BadRequest(new { Message = "One or more Cart IDs do not exist or do not belong to the user." });
            }

            // Tính tổng giá và tạo danh sách OrderDetails
            decimal totalPrice = 0;
            var orderDetails = carts.Select(cart => new OrderDetail
            {
                ProductId = cart.ProductId,
                Quantity = cart.Quantity,
                SubTotal = cart.Product.Price * cart.Quantity
            }).ToList();

            totalPrice = orderDetails.Sum(od => od.SubTotal);

            // Tạo Order mới
            var order = new Order
            {
                UserId = orderInput.UserId,
                TotalPrice = totalPrice,
                OrderTime = DateTime.UtcNow,
                Status = "Pending",
                OrderDetails = orderDetails
            };

            await _context.Orders.AddAsync(order);

            // Xóa Cart sau khi Order
            _context.Carts.RemoveRange(carts);

            await _context.SaveChangesAsync();

            // Trả về OrderOutputDto
            var orderOutput = new OrderOutputDto
            {
                OrderId = order.OrderId,
                UserId = order.UserId,
                TotalPrice = order.TotalPrice,
                Status = order.Status,
                OrderTime = order.OrderTime,
                OrderDetails = orderDetails.Select(od => new OrderDetailOutputDto
                {
                    OrderDetailId = od.OrderDetailId,
                    ProductId = od.ProductId,
                    ProductName = od.Product?.ProductName ?? "Unknown Product",
                    Quantity = od.Quantity,
                    SubTotal = od.SubTotal
                }).ToList()
            };

            return CreatedAtAction(nameof(GetById), new { id = order.OrderId }, orderOutput);
        }

        [Authorize(Policy = "AdminOnly")]
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateStatus(int id, [FromBody] string status)
        {
            await _orderRepository.UpdateOrderStatusAsync(id, status);
            return NoContent();
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            await _orderRepository.DeleteOrderAsync(id);
            return NoContent();
        }

        [Authorize(Policy = "AdminOnly")]
        [HttpPut("{id}/status")]
        public async Task<IActionResult> UpdateOrderStatus(int id, [FromBody] string status)
        {
            if (string.IsNullOrEmpty(status))
            {
                return BadRequest(new { Message = "Status is required" });
            }

            var order = await _context.Orders.FindAsync(id);
            if (order == null)
            {
                return NotFound(new { Message = $"Order with ID {id} not found." });
            }

            order.Status = status;
            _context.Orders.Update(order);
            await _context.SaveChangesAsync();

            return Ok(new { Message = "Order status updated successfully." });
        }
    }

}

