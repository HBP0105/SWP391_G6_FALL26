USE HeadphoneSalesDB;
GO

-- 1. Lấy tự động CustomerID và ProductID thực tế đang tồn tại trong Database
DECLARE @CustID INT, @CustName NVARCHAR(100), @CustPhone VARCHAR(20);
SELECT TOP 1 
    @CustID = CustomerID, 
    @CustName = FullName, 
    @CustPhone = Phone 
FROM Customers 
ORDER BY CustomerID;

DECLARE @ProdID INT, @Price DECIMAL(18,2);
SELECT TOP 1 
    @ProdID = ProductID, 
    @Price = Price 
FROM Products 
ORDER BY ProductID;

-- Kiểm tra dữ liệu
IF @CustID IS NULL
BEGIN
    RAISERROR(N'Bảng Customers chưa có dữ liệu! Vui lòng tạo ít nhất 1 khách hàng trước.', 16, 1);
    RETURN;
END;

IF @ProdID IS NULL
BEGIN
    RAISERROR(N'Bảng Products chưa có dữ liệu! Vui lòng tạo ít nhất 1 sản phẩm trước.', 16, 1);
    RETURN;
END;

DECLARE @O1 INT, @O2 INT, @O3 INT, @O4 INT, @O5 INT;

-- 2. TẠO 5 ĐƠN HÀNG PENDING
-- Đơn 1
INSERT INTO Orders (CustomerID, TotalAmount, ShippingName, ShippingPhone, ShippingAddress, OrderStatus, OrderDate, UpdatedAt)
VALUES (@CustID, @Price, N'Nguyễn Văn An', '0912000001', N'25 Cầu Giấy, Phường Quan Hoa, Cầu Giấy, Hà Nội', 'PENDING', DATEADD(MINUTE, -50, GETDATE()), GETDATE());
SET @O1 = SCOPE_IDENTITY();

-- Đơn 2
INSERT INTO Orders (CustomerID, TotalAmount, ShippingName, ShippingPhone, ShippingAddress, OrderStatus, OrderDate, UpdatedAt)
VALUES (@CustID, @Price, N'Trần Bình', '0912000002', N'80 Nguyễn Trãi, Thượng Đình, Thanh Xuân, Hà Nội', 'PENDING', DATEADD(MINUTE, -40, GETDATE()), GETDATE());
SET @O2 = SCOPE_IDENTITY();

-- Đơn 3
INSERT INTO Orders (CustomerID, TotalAmount, ShippingName, ShippingPhone, ShippingAddress, OrderStatus, OrderDate, UpdatedAt)
VALUES (@CustID, @Price, N'Lê Phương Chi', '0912000003', N'120 Lê Lợi, Bến Thành, Quận 1, TP. Hồ Chí Minh', 'PENDING', DATEADD(MINUTE, -30, GETDATE()), GETDATE());
SET @O3 = SCOPE_IDENTITY();

-- Đơn 4
INSERT INTO Orders (CustomerID, TotalAmount, ShippingName, ShippingPhone, ShippingAddress, OrderStatus, OrderDate, UpdatedAt)
VALUES (@CustID, @Price, N'Phạm Tiến Dũng', '0912000004', N'15 Bạch Đằng, Hải Châu 1, Hải Châu, Đà Nẵng', 'PENDING', DATEADD(MINUTE, -20, GETDATE()), GETDATE());
SET @O4 = SCOPE_IDENTITY();

-- Đơn 5
INSERT INTO Orders (CustomerID, TotalAmount, ShippingName, ShippingPhone, ShippingAddress, OrderStatus, OrderDate, UpdatedAt)
VALUES (@CustID, @Price, N'Hoàng Thu Hà', '0912000005', N'45 Lê Duẩn, Bến Nghé, Quận 1, TP. Hồ Chí Minh', 'PENDING', DATEADD(MINUTE, -10, GETDATE()), GETDATE());
SET @O5 = SCOPE_IDENTITY();

-- 3. CHI TIẾT SẢN PHẨM (OrderItems)
INSERT INTO OrderItems (OrderID, ProductID, Quantity, UnitPrice) VALUES
(@O1, @ProdID, 1, @Price),
(@O2, @ProdID, 1, @Price),
(@O3, @ProdID, 1, @Price),
(@O4, @ProdID, 1, @Price),
(@O5, @ProdID, 1, @Price);

-- 4. THÔNG TIN THANH TOÁN (Payments)
INSERT INTO Payments (OrderID, PaymentMethod, Amount, PaymentStatus) VALUES
(@O1, 'COD',           @Price, 'PENDING'),
(@O2, 'COD',           @Price, 'PENDING'),
(@O3, 'BANK_TRANSFER', @Price, 'PENDING'),
(@O4, 'COD',           @Price, 'PENDING'),
(@O5, 'VNPAY',         @Price, 'PENDING');

-- 5. THÔNG TIN VẬN CHUYỂN (Shipments)
INSERT INTO Shipments (OrderID, ShippingProvider, ShippingAddress, ShippingStatus, EstimatedDeliveryDate) VALUES
(@O1, N'Giao Hàng Nhanh (GHN)',      N'25 Cầu Giấy, Phường Quan Hoa, Cầu Giấy, Hà Nội',       'PENDING', CAST(DATEADD(DAY, 3, GETDATE()) AS DATE)),
(@O2, N'Giao Hàng Tiết Kiệm (GHTK)', N'80 Nguyễn Trãi, Thượng Đình, Thanh Xuân, Hà Nội',      'PENDING', CAST(DATEADD(DAY, 3, GETDATE()) AS DATE)),
(@O3, N'Viettel Post',               N'120 Lê Lợi, Bến Thành, Quận 1, TP. Hồ Chí Minh',        'PENDING', CAST(DATEADD(DAY, 4, GETDATE()) AS DATE)),
(@O4, N'Giao Hàng Nhanh (GHN)',      N'15 Bạch Đằng, Hải Châu 1, Hải Châu, Đà Nẵng',           'PENDING', CAST(DATEADD(DAY, 3, GETDATE()) AS DATE)),
(@O5, N'VNPost Tiết Kiệm',           N'45 Lê Duẩn, Bến Nghé, Quận 1, TP. Hồ Chí Minh',         'PENDING', CAST(DATEADD(DAY, 4, GETDATE()) AS DATE));
GO
