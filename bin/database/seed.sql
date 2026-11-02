-- Sample data
INSERT INTO Roles (RoleName, Description) VALUES
('CUSTOMER', N'Customer account'),
('MANAGER', N'Manages products, inventory and orders'),
('ADMIN', N'Manages users, roles and system');
GO

INSERT INTO Categories (CategoryName, Description) VALUES
(N'Wireless Headphones', N'Wireless over-ear headphones'),
(N'Wired Headphones', N'Wired headphones'),
(N'Gaming Headphones', N'Headphones for gaming'),
(N'Earbuds', N'True wireless earbuds'),
(N'Noise Cancelling', N'Headphones with active noise cancellation');
GO

INSERT INTO Brands (BrandName, Description) VALUES
(N'Sony', N'Sony headphones'),
(N'Bose', N'Bose headphones'),
(N'JBL', N'JBL headphones'),
(N'Apple', N'Apple audio products'),
(N'Sennheiser', N'Sennheiser headphones'),
(N'Audio-Technica', N'Audio-Technica headphones');
GO

INSERT INTO Users (RoleID, FullName, Email, PasswordHash, Phone) VALUES
(1, N'Nguyen Van A', 'customer@gmail.com', 'HASHED_PASSWORD', '0901234567'),
(2, N'Manager', 'manager@gmail.com', 'HASHED_PASSWORD', '0901234568'),
(3, N'Administrator', 'admin@gmail.com', 'HASHED_PASSWORD', '0901234569');
GO

INSERT INTO Addresses
(UserID, ReceiverName, ReceiverPhone, AddressLine, Ward, District, Province, IsDefault)
VALUES
(1, N'Nguyen Van A', '0901234567', N'123 Nguyen Trai',
 N'Thanh Xuan Trung', N'Thanh Xuan', N'Ha Noi', 1);
GO

INSERT INTO Products
(CategoryID, BrandID, ProductName, Description, Price, StockQuantity,
 ConnectionType, DriverSize, NoiseCancelling, BatteryLife, Microphone,
 WaterResistance, Weight)
VALUES
(1,1,N'Sony WH-1000XM5',N'Premium wireless noise cancelling headphones',8490000,50,'WIRELESS',30,1,30,1,NULL,250),
(1,1,N'Sony WH-1000XM4',N'Wireless noise cancelling headphones',6990000,30,'WIRELESS',40,1,30,1,NULL,254),
(1,2,N'Bose QuietComfort Ultra',N'Premium noise cancelling headphones',9990000,20,'WIRELESS',35,1,24,1,NULL,253),
(3,3,N'JBL Quantum 910',N'Wireless gaming headset',6990000,15,'WIRELESS',50,1,39,1,NULL,420),
(4,4,N'AirPods Pro 2',N'True wireless earbuds',5990000,40,'BLUETOOTH',11,1,6,1,'IPX4',52),
(1,5,N'Sennheiser Momentum 4',N'Wireless headphones with long battery life',7990000,25,'WIRELESS',42,1,60,1,NULL,293);
GO

INSERT INTO ProductImages (ProductID, ImageURL, PublicID, IsPrimary) VALUES
(1,'https://res.cloudinary.com/demo/image/upload/sony-xm5.jpg','sony-xm5',1),
(2,'https://res.cloudinary.com/demo/image/upload/sony-xm4.jpg','sony-xm4',1),
(3,'https://res.cloudinary.com/demo/image/upload/bose-qc-ultra.jpg','bose-qc-ultra',1);
GO

INSERT INTO Vouchers
(VoucherCode, Description, DiscountType, DiscountValue, MinOrderAmount,
 MaxDiscount, StartDate, EndDate, UsageLimit, CreatedBy)
VALUES
('WELCOME10',N'10% discount for new customers','PERCENT',10,
 1000000,500000,'2026-01-01','2027-01-01',1000,2);
GO

INSERT INTO UserBehaviors
(UserID, ProductID, BehaviorType, SearchKeyword, SessionID)
VALUES
(1,1,'VIEW',NULL,'SESSION001'),
(1,2,'VIEW',NULL,'SESSION001'),
(1,3,'VIEW',NULL,'SESSION001'),
(1,1,'FAVORITE',NULL,'SESSION001'),
(1,1,'CART',NULL,'SESSION001'),
(1,NULL,'SEARCH',N'Sony wireless','SESSION001'),
(1,1,'PURCHASE',NULL,'SESSION001');
GO

INSERT INTO AIRecommendations
(UserID, SessionID, ProductID, RecommendationType, SimilarityScore,
 BehaviorScore, FinalScore, Reason)
VALUES
(1, 'SESSION001', 2, 'SIMILAR', 0.94000, 0.90000, 0.93000,
 N'Similar to headphones frequently viewed and favorited'),
(1, 'SESSION001', 3, 'PERSONALIZED', 0.88000, 0.85000, 0.86500,
 N'Recommended based on wireless and noise cancelling preferences'),
(1, 'SESSION001', 6, 'PERSONALIZED', 0.87000, 0.82000, 0.84500,
 N'Recommended based on similar wireless headphone preferences'),
(NULL, 'SESSION002', 1, 'BEST_SELLER', 0.95000, 0.80000, 0.90000,
 N'Cold start recommendation: Top selling wireless headphones for guest user');
GO

SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;
GO