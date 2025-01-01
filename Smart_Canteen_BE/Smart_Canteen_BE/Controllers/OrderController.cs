using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.SignalR;
using Microsoft.EntityFrameworkCore;
using Smart_Canteen_BE.DTO;
using Smart_Canteen_BE.Hubs;
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

            // Kiểm tra stock và tính toán tổng giá
            decimal totalPrice = 0;
            var orderDetails = new List<OrderDetail>();

            foreach (var cart in carts)
            {
                var product = cart.Product;

                // Kiểm tra stock
                if (product.Stock < cart.Quantity)
                {
                    return BadRequest(new { Message = $"Insufficient stock for product {product.ProductName}. Available: {product.Stock}, Requested: {cart.Quantity}" });
                }

                // Giảm stock
                product.Stock -= cart.Quantity;

                // Tạo OrderDetail
                orderDetails.Add(new OrderDetail
                {
                    ProductId = cart.ProductId,
                    Quantity = cart.Quantity,
                    SubTotal = product.Price * cart.Quantity
                });

                // Tính tổng giá
                totalPrice += product.Price * cart.Quantity;
            }

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

            // Lưu thay đổi vào cơ sở dữ liệu
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
                    ProductName = _context.Products.FirstOrDefault(p => p.ProductId == od.ProductId)?.ProductName ?? "Unknown Product",
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

            var order = await _context.Orders.Include(o => o.OrderDetails).ThenInclude(od => od.Product).FirstOrDefaultAsync(o => o.OrderId == id);
            if (order == null)
            {
                return NotFound(new { Message = $"Order with ID {id} not found." });
            }

            if (status.Equals("Canceled", StringComparison.OrdinalIgnoreCase))
            {
                // Tăng lại stock nếu đơn hàng bị hủy
                foreach (var detail in order.OrderDetails)
                {
                    var product = detail.Product;
                    if (product != null)
                    {
                        product.Stock += detail.Quantity;
                    }
                }
            }

            order.Status = status;
            _context.Orders.Update(order);
            await _context.SaveChangesAsync();

            if (status.Equals("Completed", StringComparison.OrdinalIgnoreCase))
            {
                var hubContext = HttpContext.RequestServices.GetRequiredService<IHubContext<NotificationHub>>();
                await hubContext.Clients.All.SendAsync("OrderStatusUpdated", order.OrderId, status);
            }

            return Ok(new { Message = "Order status updated successfully." });
        }


    }

}

