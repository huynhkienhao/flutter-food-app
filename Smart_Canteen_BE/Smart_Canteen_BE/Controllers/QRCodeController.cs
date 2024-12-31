using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using QRCoder;
using Smart_Canteen_BE.Model;
using Smart_Canteen_BE.Repository;
using System.Text;


namespace Smart_Canteen_BE.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class QRCodeController : ControllerBase
    {
        private readonly IQRCodeRepository _qrCodeRepository;
        private readonly ApplicationDbContext _context;

        public QRCodeController(IQRCodeRepository qrCodeRepository, ApplicationDbContext context)
        {
            _qrCodeRepository = qrCodeRepository;
            _context = context;
        }

        [HttpGet("{orderId}")]
        public async Task<IActionResult> GetQRCodeByOrderId(int orderId)
        {
            // Lấy QRCode kèm thông tin chi tiết Order
            var qrCode = await _qrCodeRepository.GetQRCodeByOrderIdAsync(orderId);
            if (qrCode == null)
            {
                return NotFound(new { Message = $"QR Code for Order ID {orderId} does not exist." });
            }

            // Lấy thông tin chi tiết sản phẩm từ Order
            var order = await _context.Orders
                .Include(o => o.OrderDetails)
                .ThenInclude(od => od.Product)
                .FirstOrDefaultAsync(o => o.OrderId == orderId);

            if (order == null)
            {
                return NotFound(new { Message = $"Order with ID {orderId} does not exist." });
            }

            // Chuẩn bị dữ liệu trả về
            var qrCodeDetails = new
            {
                QRCodeId = qrCode.QRCodeId,
                OrderId = qrCode.OrderId,
                TotalPrice = order.TotalPrice,
                QRCodeData = qrCode.QRCodeData,
                Items = order.OrderDetails.Select(od => new
                {
                    ProductId = od.ProductId,
                    ProductName = od.Product.ProductName,
                    ProductImage = od.Product.Image,
                    Quantity = od.Quantity,
                    SubTotal = od.SubTotal
                }).ToList()
            };

            return Ok(qrCodeDetails);
        }

        [HttpPost]
        public async Task<IActionResult> GenerateQRCodeForOrder([FromBody] dynamic payload)
        {
            if (!int.TryParse(payload?.orderId?.ToString(), out int orderId))
            {
                return BadRequest(new { Message = "Invalid or missing OrderId in the request." });
            }

            // Kiểm tra nếu Order tồn tại
            var order = await _context.Orders
                .Include(o => o.OrderDetails)
                .ThenInclude(od => od.Product)
                .FirstOrDefaultAsync(o => o.OrderId == orderId);

            if (order == null)
            {
                return BadRequest(new { Message = $"Order with ID {orderId} does not exist." });
            }

            // Tạo nội dung mã QR bao gồm OrderDetail
            var qrCodeContent = new StringBuilder();
            qrCodeContent.AppendLine($"OrderId: {order.OrderId}");
            qrCodeContent.AppendLine($"Total: {order.TotalPrice}");
            qrCodeContent.AppendLine("Order Details:");
            foreach (var detail in order.OrderDetails)
            {
                qrCodeContent.AppendLine($"- {detail.Product.ProductName} x{detail.Quantity}: {detail.SubTotal}");
            }

            // Sử dụng QRCoder để tạo mã QR
            using var qrGenerator = new QRCodeGenerator();
            var qrCodeData = qrGenerator.CreateQrCode(qrCodeContent.ToString(), QRCodeGenerator.ECCLevel.Q);

            // Tạo đối tượng QRCode
            var qrCode = new QRCode
            {
                OrderId = orderId,
                QRCodeData = qrCodeContent.ToString()
            };

            // Thêm vào cơ sở dữ liệu
            await _qrCodeRepository.AddQRCodeAsync(qrCode);

            return CreatedAtAction(nameof(GetQRCodeByOrderId), new { orderId = qrCode.OrderId }, new
            {
                QRCodeId = qrCode.QRCodeId,
                OrderId = qrCode.OrderId,
                QRCodeData = qrCode.QRCodeData
            });
        }


        [HttpGet("generate-svg/{qrCodeId}")]
        public async Task<IActionResult> GenerateQRCodeSvgWithUserDetails(int qrCodeId)
        {
            // Lấy QRCode từ cơ sở dữ liệu
            var qrCode = await _qrCodeRepository.GetQRCodeByIdAsync(qrCodeId);
            if (qrCode == null)
            {
                return NotFound(new { Message = $"QR Code with ID {qrCodeId} does not exist." });
            }

            // Lấy thông tin chi tiết của Order liên quan, bao gồm User
            var order = await _context.Orders
                .Include(o => o.OrderDetails)
                .ThenInclude(od => od.Product)
                .Include(o => o.User)
                .FirstOrDefaultAsync(o => o.OrderId == qrCode.OrderId);

            if (order == null)
            {
                return NotFound(new { Message = $"Order with ID {qrCode.OrderId} does not exist." });
            }

            // Chuẩn bị nội dung mã QR bao gồm User và OrderDetail
            var qrCodeContent = new StringBuilder();
            qrCodeContent.AppendLine($"OrderId: {order.OrderId}");
            qrCodeContent.AppendLine($"User: {order.User.FullName} ({order.User.Email})"); // Thêm thông tin User
            qrCodeContent.AppendLine($"Total: {order.TotalPrice}");
            qrCodeContent.AppendLine("Order Details:");
            foreach (var detail in order.OrderDetails)
            {
                qrCodeContent.AppendLine($"- {detail.Product.ProductName} x{detail.Quantity}: {detail.SubTotal}");
            }

            // Sử dụng QRCoder để tạo mã QR dưới dạng SVG
            using var qrGenerator = new QRCodeGenerator();
            var qrCodeData = qrGenerator.CreateQrCode(qrCodeContent.ToString(), QRCodeGenerator.ECCLevel.Q);
            using var qrCodeSvg = new SvgQRCode(qrCodeData);

            // Xuất mã QR thành SVG string
            var svgQrCode = qrCodeSvg.GetGraphic(5); // 5 là kích thước pixel của mỗi ô vuông

            // Trả SVG về client
            return Content(svgQrCode, "image/svg+xml");
        }
    }
}
