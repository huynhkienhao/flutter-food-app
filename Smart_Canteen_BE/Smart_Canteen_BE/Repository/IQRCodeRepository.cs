using Smart_Canteen_BE.Model;

namespace Smart_Canteen_BE.Repository
{
    public interface IQRCodeRepository
    {
        Task<QRCode> GetQRCodeByOrderIdAsync(int orderId);
        Task AddQRCodeAsync(QRCode qrCode);
        Task<QRCode> GetQRCodeByIdAsync(int qrCodeId);
    }
}
