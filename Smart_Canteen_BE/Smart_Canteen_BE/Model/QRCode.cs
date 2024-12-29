namespace Smart_Canteen_BE.Model
{
    public class QRCode
    {
        public int QRCodeId { get; set; }
        public int OrderId { get; set; }
        public Order Order { get; set; }
        public string QRCodeData { get; set; }
    }
}
