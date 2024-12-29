using Microsoft.EntityFrameworkCore;
using Smart_Canteen_BE.Model;

namespace Smart_Canteen_BE.Repository
{
    public class QRCodeRepository : IQRCodeRepository
    {
        private readonly ApplicationDbContext _context;

        public QRCodeRepository(ApplicationDbContext context)
        {
            _context = context;
        }

        public async Task<QRCode> GetQRCodeByOrderIdAsync(int orderId)
        {
            return await _context.QRCodes
                .Include(qr => qr.Order)
                .FirstOrDefaultAsync(qr => qr.OrderId == orderId);
        }

        public async Task AddQRCodeAsync(QRCode qrCode)
        {
            await _context.QRCodes.AddAsync(qrCode);
            await _context.SaveChangesAsync();
        }

        public async Task<QRCode> GetQRCodeDetailsByOrderIdAsync(int orderId)
        {
            return await _context.QRCodes
                .Include(qr => qr.Order)
                .ThenInclude(o => o.OrderDetails)
                .ThenInclude(od => od.Product)
                .FirstOrDefaultAsync(qr => qr.OrderId == orderId);
        }
        public async Task<QRCode> GetQRCodeByIdAsync(int qrCodeId)
        {
            return await _context.QRCodes
                .Include(qr => qr.Order)
                .FirstOrDefaultAsync(qr => qr.QRCodeId == qrCodeId);
        }
    }
}
