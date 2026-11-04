-- =========================================================================
-- Script SQL: Tạo 5 đơn hàng trạng thái PENDING để kiểm thử hệ thống
-- Database: HeadphoneSalesDB (SQL Server)
-- =========================================================================

USE HeadphoneSalesDB;
GO

SET NOCOUNT ON;

BEGIN TRANSACTION;

BEGIN TRY
    -- 1. Khai báo biến lưu ID khách hàng và sản phẩm
    DECLARE @Cust1 INT, @Cust2 INT, @Cust3 INT, @Cust4 INT, @Cust5 INT;
    DECLARE @Prod1 INT, @Price1 DECIMAL(18,2);
    DECLARE @Prod2 INT, @Price2 DECIMAL(18,2);
    DECLARE @Prod3 INT, @Price3 DECIMAL(18,2);
    DECLARE @Prod4 INT, @Price4 DECIMAL(18,2);
    DECLARE @Prod5 INT, @Price5 DECIMAL(18,2);
    DECLARE @Prod6 INT, @Price6 DECIMAL(18,2);
    DECLARE @Prod7 INT, @Price7 DECIMAL(18,2);

    -- 2. Đảm bảo có ít nhất 1 khách hàng trong hệ thống (phòng trường hợp DB trống)
    IF NOT EXISTS (SELECT 1 FROM Customers)
    BEGIN
        INSERT INTO Customers (FullName, Email, PasswordHash, Phone, Status, CreatedAt)
        VALUES (N'Khách hàng thử nghiệm', 'test.customer@gmail.com', 'DEMO_HASH_123456', '0912000001', 'ACTIVE', GETDATE());
    END

    -- Lấy CustomerID (ưu tiên theo Email seed, nếu không có thì lấy các customer hiện có)
    SELECT TOP 1 @Cust1 = CustomerID FROM Customers WHERE Email = 'an.nguyen@gmail.com';
    IF @Cust1 IS NULL SELECT TOP 1 @Cust1 = CustomerID FROM Customers ORDER BY CustomerID ASC;

    SELECT TOP 1 @Cust2 = CustomerID FROM Customers WHERE Email = 'binh.tran@gmail.com';
    IF @Cust2 IS NULL SELECT TOP 1 @Cust2 = CustomerID FROM Customers;

    SELECT TOP 1 @Cust3 = CustomerID FROM Customers WHERE Email = 'chi.le@gmail.com';
    IF @Cust3 IS NULL SELECT TOP 1 @Cust3 = CustomerID FROM Customers;

    SELECT TOP 1 @Cust4 = CustomerID FROM Customers WHERE Email = 'dung.pham@gmail.com';
    IF @Cust4 IS NULL SELECT TOP 1 @Cust4 = CustomerID FROM Customers;

    SELECT TOP 1 @Cust5 = CustomerID FROM Customers WHERE Email = 'ha.hoang@gmail.com';
    IF @Cust5 IS NULL SELECT TOP 1 @Cust5 = CustomerID FROM Customers;

    -- 3. Lấy ProductID và Price
    SELECT TOP 1 @Prod1 = ProductID, @Price1 = Price FROM Products WHERE ProductName LIKE N'%WH-1000XM5%';
    IF @Prod1 IS NULL SELECT TOP 1 @Prod1 = ProductID, @Price1 = Price FROM Products ORDER BY ProductID ASC;

    SELECT TOP 1 @Prod2 = ProductID, @Price2 = Price FROM Products WHERE ProductName LIKE N'%Tune 720BT%';
    IF @Prod2 IS NULL SELECT TOP 1 @Prod2 = ProductID, @Price2 = Price FROM Products ORDER BY ProductID DESC;

    SELECT TOP 1 @Prod3 = ProductID, @Price3 = Price FROM Products WHERE ProductName LIKE N'%AirPods Pro%';
    IF @Prod3 IS NULL SELECT TOP 1 @Prod3 = ProductID, @Price3 = Price FROM Products;

    SELECT TOP 1 @Prod4 = ProductID, @Price4 = Price FROM Products WHERE ProductName LIKE N'%Liberty 4%';
    IF @Prod4 IS NULL SELECT TOP 1 @Prod4 = ProductID, @Price4 = Price FROM Products;

    SELECT TOP 1 @Prod5 = ProductID, @Price5 = Price FROM Products WHERE ProductName LIKE N'%Cloud III%';
    IF @Prod5 IS NULL SELECT TOP 1 @Prod5 = ProductID, @Price5 = Price FROM Products;

    SELECT TOP 1 @Prod6 = ProductID, @Price6 = Price FROM Products WHERE ProductName LIKE N'%Major V%';
    IF @Prod6 IS NULL SELECT TOP 1 @Prod6 = ProductID, @Price6 = Price FROM Products;

    SELECT TOP 1 @Prod7 = ProductID, @Price7 = Price FROM Products WHERE ProductName LIKE N'%W820NB%';
    IF @Prod7 IS NULL SELECT TOP 1 @Prod7 = ProductID, @Price7 = Price FROM Products;

    -- Giá trị mặc định nếu sản phẩm chưa có giá
    SET @Price1 = ISNULL(@Price1, 8990000);
    SET @Price2 = ISNULL(@Price2, 1590000);
    SET @Price3 = ISNULL(@Price3, 5990000);
    SET @Price4 = ISNULL(@Price4, 2190000);
    SET @Price5 = ISNULL(@Price5, 3990000);
    SET @Price6 = ISNULL(@Price6, 3890000);
    SET @Price7 = ISNULL(@Price7, 1690000);

    DECLARE @NewOrderID INT;

    -- =========================================================================
    -- ĐƠN HÀNG 1: PENDING - Phương thức COD (1 sản phẩm)
    -- =========================================================================
    INSERT INTO Orders (CustomerID, TotalAmount, ShippingName, ShippingPhone, ShippingAddress, OrderStatus, OrderDate)
    VALUES (@Cust1, @Price1, N'Nguyễn Văn An', '0912000001', N'25 Cầu Giấy, Phường Quan Hoa, Quận Cầu Giấy, Hà Nội', 'PENDING', DATEADD(MINUTE, -15, GETDATE()));
    
    SET @NewOrderID = SCOPE_IDENTITY();

    INSERT INTO OrderItems (OrderID, ProductID, Quantity, UnitPrice)
    VALUES (@NewOrderID, @Prod1, 1, @Price1);

    INSERT INTO Payments (OrderID, PaymentMethod, TransactionID, Amount, PaymentStatus, ResponseCode, PaymentDate)
    VALUES (@NewOrderID, 'COD', NULL, @Price1, 'PENDING', NULL, NULL);

    INSERT INTO Shipments (OrderID, ShippingProvider, TrackingNumber, ShippingAddress, ShippingStatus, EstimatedDeliveryDate)
    VALUES (@NewOrderID, N'Giao Hàng Nhanh (GHN)', NULL, N'25 Cầu Giấy, Phường Quan Hoa, Quận Cầu Giấy, Hà Nội', 'PENDING', CAST(DATEADD(DAY, 3, GETDATE()) AS DATE));

    -- =========================================================================
    -- ĐƠN HÀNG 2: PENDING - Phương thức VNPAY (Chưa thanh toán - số lượng 2)
    -- =========================================================================
    INSERT INTO Orders (CustomerID, TotalAmount, ShippingName, ShippingPhone, ShippingAddress, OrderStatus, OrderDate)
    VALUES (@Cust2, @Price2 * 2, N'Trần Bình Minh', '0912000002', N'80 Nguyễn Trãi, Phường Thượng Đình, Quận Thanh Xuân, Hà Nội', 'PENDING', DATEADD(MINUTE, -45, GETDATE()));
    
    SET @NewOrderID = SCOPE_IDENTITY();

    INSERT INTO OrderItems (OrderID, ProductID, Quantity, UnitPrice)
    VALUES (@NewOrderID, @Prod2, 2, @Price2);

    INSERT INTO Payments (OrderID, PaymentMethod, TransactionID, Amount, PaymentStatus, ResponseCode, PaymentDate)
    VALUES (@NewOrderID, 'VNPAY', 'VNPAY-PEND-1002', @Price2 * 2, 'PENDING', NULL, NULL);

    INSERT INTO Shipments (OrderID, ShippingProvider, TrackingNumber, ShippingAddress, ShippingStatus, EstimatedDeliveryDate)
    VALUES (@NewOrderID, N'Giao Hàng Tiết Kiệm (GHTK)', NULL, N'80 Nguyễn Trãi, Phường Thượng Đình, Quận Thanh Xuân, Hà Nội', 'PENDING', CAST(DATEADD(DAY, 3, GETDATE()) AS DATE));

    -- =========================================================================
    -- ĐƠN HÀNG 3: PENDING - Phương thức BANK_TRANSFER (Chuyển khoản - 2 món hàng)
    -- =========================================================================
    INSERT INTO Orders (CustomerID, TotalAmount, ShippingName, ShippingPhone, ShippingAddress, OrderStatus, OrderDate)
    VALUES (@Cust3, @Price3 + @Price4, N'Lê Thị Chi', '0912000003', N'120 Lê Lợi, Phường Bến Thành, Quận 1, TP. Hồ Chí Minh', 'PENDING', DATEADD(HOUR, -2, GETDATE()));
    
    SET @NewOrderID = SCOPE_IDENTITY();

    INSERT INTO OrderItems (OrderID, ProductID, Quantity, UnitPrice)
    VALUES 
        (@NewOrderID, @Prod3, 1, @Price3),
        (@NewOrderID, @Prod4, 1, @Price4);

    INSERT INTO Payments (OrderID, PaymentMethod, TransactionID, Amount, PaymentStatus, ResponseCode, PaymentDate)
    VALUES (@NewOrderID, 'BANK_TRANSFER', 'MB-TEST-998877', @Price3 + @Price4, 'PENDING', NULL, NULL);

    INSERT INTO Shipments (OrderID, ShippingProvider, TrackingNumber, ShippingAddress, ShippingStatus, EstimatedDeliveryDate)
    VALUES (@NewOrderID, N'Viettel Post', NULL, N'120 Lê Lợi, Phường Bến Thành, Quận 1, TP. Hồ Chí Minh', 'PENDING', CAST(DATEADD(DAY, 4, GETDATE()) AS DATE));

    -- =========================================================================
    -- ĐƠN HÀNG 4: PENDING - Phương thức COD (Giao tới Đà Nẵng)
    -- =========================================================================
    INSERT INTO Orders (CustomerID, TotalAmount, ShippingName, ShippingPhone, ShippingAddress, OrderStatus, OrderDate)
    VALUES (@Cust4, @Price5, N'Phạm Tiến Dũng', '0912000004', N'15 Bạch Đằng, Phường Hải Châu 1, Quận Hải Châu, TP. Đà Nẵng', 'PENDING', DATEADD(HOUR, -4, GETDATE()));
    
    SET @NewOrderID = SCOPE_IDENTITY();

    INSERT INTO OrderItems (OrderID, ProductID, Quantity, UnitPrice)
    VALUES (@NewOrderID, @Prod5, 1, @Price5);

    INSERT INTO Payments (OrderID, PaymentMethod, TransactionID, Amount, PaymentStatus, ResponseCode, PaymentDate)
    VALUES (@NewOrderID, 'COD', NULL, @Price5, 'PENDING', NULL, NULL);

    INSERT INTO Shipments (OrderID, ShippingProvider, TrackingNumber, ShippingAddress, ShippingStatus, EstimatedDeliveryDate)
    VALUES (@NewOrderID, N'Giao Hàng Nhanh (GHN)', NULL, N'15 Bạch Đằng, Phường Hải Châu 1, Quận Hải Châu, TP. Đà Nẵng', 'PENDING', CAST(DATEADD(DAY, 2, GETDATE()) AS DATE));

    -- =========================================================================
    -- ĐƠN HÀNG 5: PENDING - Phương thức VNPAY (Đã thanh toán trước - Chờ duyệt)
    -- =========================================================================
    INSERT INTO Orders (CustomerID, TotalAmount, ShippingName, ShippingPhone, ShippingAddress, OrderStatus, OrderDate)
    VALUES (@Cust5, @Price6 + @Price7, N'Hoàng Thu Hà', '0912000005', N'45 Lê Duẩn, Phường Bến Nghé, Quận 1, TP. Hồ Chí Minh', 'PENDING', DATEADD(HOUR, -6, GETDATE()));
    
    SET @NewOrderID = SCOPE_IDENTITY();

    INSERT INTO OrderItems (OrderID, ProductID, Quantity, UnitPrice)
    VALUES 
        (@NewOrderID, @Prod6, 1, @Price6),
        (@NewOrderID, @Prod7, 1, @Price7);

    INSERT INTO Payments (OrderID, PaymentMethod, TransactionID, Amount, PaymentStatus, ResponseCode, PaymentDate)
    VALUES (@NewOrderID, 'VNPAY', 'VNPAY-PAID-554433', @Price6 + @Price7, 'SUCCESS', '00', DATEADD(MINUTE, -355, GETDATE()));

    INSERT INTO Shipments (OrderID, ShippingProvider, TrackingNumber, ShippingAddress, ShippingStatus, EstimatedDeliveryDate)
    VALUES (@NewOrderID, N'Viettel Post', NULL, N'45 Lê Duẩn, Phường Bến Nghé, Quận 1, TP. Hồ Chí Minh', 'PENDING', CAST(DATEADD(DAY, 3, GETDATE()) AS DATE));

    COMMIT TRANSACTION;
    PRINT N'==> Tạo thành công 5 đơn hàng PENDING!';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
    
    PRINT N'Lỗi xảy ra: ' + ERROR_MESSAGE();
    THROW;
END CATCH;
GO

-- =========================================================================
-- Kiểm tra 5 đơn hàng PENDING mới nhất vừa tạo
-- =========================================================================
SELECT TOP 5
    o.OrderID,
    o.ShippingName,
    o.ShippingPhone,
    o.TotalAmount,
    o.OrderStatus,
    o.OrderDate,
    p.PaymentMethod,
    p.PaymentStatus,
    (SELECT STRING_AGG(prod.ProductName + ' (x' + CAST(oi.Quantity AS VARCHAR) + ')', ', ')
     FROM OrderItems oi 
     JOIN Products prod ON oi.ProductID = prod.ProductID
     WHERE oi.OrderID = o.OrderID) AS Products
FROM Orders o
LEFT JOIN Payments p ON o.OrderID = p.OrderID
WHERE o.OrderStatus = 'PENDING'
ORDER BY o.OrderID DESC;
GO
