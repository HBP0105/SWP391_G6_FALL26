IF DB_ID('HeadphoneSalesDB') IS NULL
BEGIN
    CREATE DATABASE HeadphoneSalesDB;
END
GO

USE HeadphoneSalesDB;
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

-- Drop tables if they already exist to ensure a clean re-run
IF OBJECT_ID('dbo.AuditLogs', 'U') IS NOT NULL DROP TABLE dbo.AuditLogs;
IF OBJECT_ID('dbo.Notifications', 'U') IS NOT NULL DROP TABLE dbo.Notifications;
IF OBJECT_ID('dbo.AIRecommendations', 'U') IS NOT NULL DROP TABLE dbo.AIRecommendations;
IF OBJECT_ID('dbo.UserBehaviors', 'U') IS NOT NULL DROP TABLE dbo.UserBehaviors;
IF OBJECT_ID('dbo.Favorites', 'U') IS NOT NULL DROP TABLE dbo.Favorites;
IF OBJECT_ID('dbo.ReviewImages', 'U') IS NOT NULL DROP TABLE dbo.ReviewImages;
IF OBJECT_ID('dbo.Reviews', 'U') IS NOT NULL DROP TABLE dbo.Reviews;
IF OBJECT_ID('dbo.OrderVouchers', 'U') IS NOT NULL DROP TABLE dbo.OrderVouchers;
IF OBJECT_ID('dbo.Vouchers', 'U') IS NOT NULL DROP TABLE dbo.Vouchers;
IF OBJECT_ID('dbo.Shipments', 'U') IS NOT NULL DROP TABLE dbo.Shipments;
IF OBJECT_ID('dbo.Payments', 'U') IS NOT NULL DROP TABLE dbo.Payments;
IF OBJECT_ID('dbo.OrderItems', 'U') IS NOT NULL DROP TABLE dbo.OrderItems;
IF OBJECT_ID('dbo.Orders', 'U') IS NOT NULL DROP TABLE dbo.Orders;
IF OBJECT_ID('dbo.CartItems', 'U') IS NOT NULL DROP TABLE dbo.CartItems;
IF OBJECT_ID('dbo.Carts', 'U') IS NOT NULL DROP TABLE dbo.Carts;
IF OBJECT_ID('dbo.InventoryTransactions', 'U') IS NOT NULL DROP TABLE dbo.InventoryTransactions;
IF OBJECT_ID('dbo.ProductImages', 'U') IS NOT NULL DROP TABLE dbo.ProductImages;
IF OBJECT_ID('dbo.Products', 'U') IS NOT NULL DROP TABLE dbo.Products;
IF OBJECT_ID('dbo.Brands', 'U') IS NOT NULL DROP TABLE dbo.Brands;
IF OBJECT_ID('dbo.Categories', 'U') IS NOT NULL DROP TABLE dbo.Categories;
IF OBJECT_ID('dbo.Addresses', 'U') IS NOT NULL DROP TABLE dbo.Addresses;
IF OBJECT_ID('dbo.Staff', 'U') IS NOT NULL DROP TABLE dbo.Staff;
IF OBJECT_ID('dbo.Customers', 'U') IS NOT NULL DROP TABLE dbo.Customers;
IF OBJECT_ID('dbo.Roles', 'U') IS NOT NULL DROP TABLE dbo.Roles;
GO


CREATE TABLE Roles (
    RoleID INT IDENTITY(1,1) PRIMARY KEY,
    RoleName VARCHAR(20) NOT NULL UNIQUE,
    Description NVARCHAR(255)
);
GO




CREATE TABLE Customers (
    CustomerID INT IDENTITY(1,1) PRIMARY KEY,
    FullName NVARCHAR(100) NOT NULL,
    Email VARCHAR(150) NOT NULL UNIQUE,
    PasswordHash VARCHAR(255) NOT NULL,
    Phone VARCHAR(20),
    Status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    CreatedAt DATETIME2 NOT NULL DEFAULT GETDATE(),
    UpdatedAt DATETIME2,

    CONSTRAINT CK_Customers_Status
        CHECK (Status IN ('ACTIVE', 'INACTIVE', 'BANNED'))
);
GO



CREATE TABLE Staff (
    StaffID INT IDENTITY(1,1) PRIMARY KEY,
    RoleID INT NOT NULL,
    FullName NVARCHAR(100) NOT NULL,
    Email VARCHAR(150) NOT NULL UNIQUE,
    PasswordHash VARCHAR(255) NOT NULL,
    Phone VARCHAR(20),
    Status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    CreatedAt DATETIME2 NOT NULL DEFAULT GETDATE(),
    UpdatedAt DATETIME2,

    CONSTRAINT FK_Staff_Roles
        FOREIGN KEY (RoleID)
        REFERENCES Roles(RoleID),

    CONSTRAINT CK_Staff_Status
        CHECK (Status IN ('ACTIVE', 'INACTIVE', 'BANNED'))
);
GO



CREATE TABLE Addresses (
    AddressID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT NOT NULL,
    ReceiverName NVARCHAR(100) NOT NULL,
    ReceiverPhone VARCHAR(20) NOT NULL,
    AddressLine NVARCHAR(255) NOT NULL,
    Ward NVARCHAR(100),
    District NVARCHAR(100),
    Province NVARCHAR(100),
    IsDefault BIT NOT NULL DEFAULT 0,
    CreatedAt DATETIME2 NOT NULL DEFAULT GETDATE(),
    UpdatedAt DATETIME2,

    CONSTRAINT FK_Addresses_Customers
        FOREIGN KEY (CustomerID)
        REFERENCES Customers(CustomerID)
        ON DELETE CASCADE
);
GO

CREATE UNIQUE INDEX UX_Addresses_Default
ON Addresses(CustomerID)
WHERE IsDefault = 1;
GO




CREATE TABLE Categories (
    CategoryID INT IDENTITY(1,1) PRIMARY KEY,
    CategoryName NVARCHAR(100) NOT NULL UNIQUE,
    Description NVARCHAR(500),
    Status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    CreatedAt DATETIME2 NOT NULL DEFAULT GETDATE(),
    UpdatedAt DATETIME2,

    CONSTRAINT CK_Categories_Status
        CHECK (Status IN ('ACTIVE', 'INACTIVE'))
);
GO



CREATE TABLE Brands (
    BrandID INT IDENTITY(1,1) PRIMARY KEY,
    BrandName NVARCHAR(100) NOT NULL UNIQUE,
    Description NVARCHAR(500),
    Status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    CreatedAt DATETIME2 NOT NULL DEFAULT GETDATE(),
    UpdatedAt DATETIME2,

    CONSTRAINT CK_Brands_Status
        CHECK (Status IN ('ACTIVE', 'INACTIVE'))
);
GO


CREATE TABLE Products (
    ProductID INT IDENTITY(1,1) PRIMARY KEY,
    CategoryID INT NOT NULL,
    BrandID INT NOT NULL,
    ProductName NVARCHAR(200) NOT NULL,
    Description NVARCHAR(MAX),
    Price DECIMAL(18,2) NOT NULL,
    StockQuantity INT NOT NULL DEFAULT 0,

    ConnectionType VARCHAR(30),
    DriverSize DECIMAL(5,2),
    NoiseCancelling BIT NOT NULL DEFAULT 0,
    BatteryLife INT,
    Microphone BIT NOT NULL DEFAULT 0,
    WaterResistance VARCHAR(20),
    Weight DECIMAL(7,2),

    Status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    CreatedAt DATETIME2 NOT NULL DEFAULT GETDATE(),
    UpdatedAt DATETIME2,

    CONSTRAINT FK_Products_Categories
        FOREIGN KEY (CategoryID)
        REFERENCES Categories(CategoryID),

    CONSTRAINT FK_Products_Brands
        FOREIGN KEY (BrandID)
        REFERENCES Brands(BrandID),

    CONSTRAINT CK_Products_Price
        CHECK (Price >= 0),

    CONSTRAINT CK_Products_Stock
        CHECK (StockQuantity >= 0),

    CONSTRAINT CK_Products_ConnectionType
        CHECK (
            ConnectionType IS NULL
            OR ConnectionType IN ('WIRED', 'WIRELESS', 'BLUETOOTH')
        ),

    CONSTRAINT CK_Products_DriverSize
        CHECK (DriverSize IS NULL OR DriverSize > 0),

    CONSTRAINT CK_Products_BatteryLife
        CHECK (BatteryLife IS NULL OR BatteryLife >= 0),

    CONSTRAINT CK_Products_Weight
        CHECK (Weight IS NULL OR Weight > 0),

    CONSTRAINT CK_Products_Status
        CHECK (Status IN ('ACTIVE', 'INACTIVE', 'OUT_OF_STOCK'))
);
GO




CREATE TABLE ProductImages (
    ImageID INT IDENTITY(1,1) PRIMARY KEY,
    ProductID INT NOT NULL,
    ImageURL VARCHAR(500) NOT NULL,
    PublicID VARCHAR(255),
    IsPrimary BIT NOT NULL DEFAULT 0,
    CreatedAt DATETIME2 NOT NULL DEFAULT GETDATE(),

    CONSTRAINT FK_ProductImages_Products
        FOREIGN KEY (ProductID)
        REFERENCES Products(ProductID)
        ON DELETE CASCADE
);
GO



CREATE TABLE InventoryTransactions (
    TransactionID BIGINT IDENTITY(1,1) PRIMARY KEY,
    ProductID INT NOT NULL,
    TransactionType VARCHAR(20) NOT NULL,
    Quantity INT NOT NULL,
    PreviousQuantity INT NOT NULL,
    NewQuantity INT NOT NULL,
    Reason NVARCHAR(500),
    CreatedBy INT,
    CreatedAt DATETIME2 NOT NULL DEFAULT GETDATE(),

    CONSTRAINT FK_InventoryTransactions_Products
        FOREIGN KEY (ProductID)
        REFERENCES Products(ProductID),

    CONSTRAINT FK_InventoryTransactions_Staff
        FOREIGN KEY (CreatedBy)
        REFERENCES Staff(StaffID),

    CONSTRAINT CK_InventoryTransactions_Type
        CHECK (
            TransactionType IN
            ('IMPORT', 'SALE', 'RETURN', 'ADJUSTMENT')
        ),

    CONSTRAINT CK_InventoryTransactions_Quantity
        CHECK (Quantity > 0),

    CONSTRAINT CK_InventoryTransactions_Previous
        CHECK (PreviousQuantity >= 0),

    CONSTRAINT CK_InventoryTransactions_New
        CHECK (NewQuantity >= 0)
);
GO




CREATE TABLE Carts (
    CartID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT NOT NULL UNIQUE,
    CreatedAt DATETIME2 NOT NULL DEFAULT GETDATE(),
    UpdatedAt DATETIME2,

    CONSTRAINT FK_Carts_Customers
        FOREIGN KEY (CustomerID)
        REFERENCES Customers(CustomerID)
        ON DELETE CASCADE
);
GO



CREATE TABLE CartItems (
    CartItemID INT IDENTITY(1,1) PRIMARY KEY,
    CartID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT NOT NULL,
    AddedAt DATETIME2 NOT NULL DEFAULT GETDATE(),

    CONSTRAINT FK_CartItems_Carts
        FOREIGN KEY (CartID)
        REFERENCES Carts(CartID)
        ON DELETE CASCADE,

    CONSTRAINT FK_CartItems_Products
        FOREIGN KEY (ProductID)
        REFERENCES Products(ProductID),

    CONSTRAINT CK_CartItems_Quantity
        CHECK (Quantity > 0),

    CONSTRAINT UQ_CartItems_Cart_Product
        UNIQUE (CartID, ProductID)
);
GO




CREATE TABLE Orders (
    OrderID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT NOT NULL,

    TotalAmount DECIMAL(18,2) NOT NULL DEFAULT 0,

    ShippingName NVARCHAR(100) NOT NULL,
    ShippingPhone VARCHAR(20) NOT NULL,
    ShippingAddress NVARCHAR(500) NOT NULL,

    OrderStatus VARCHAR(30) NOT NULL DEFAULT 'PENDING',
    OrderDate DATETIME2 NOT NULL DEFAULT GETDATE(),
    UpdatedAt DATETIME2,

    CONSTRAINT FK_Orders_Customers
        FOREIGN KEY (CustomerID)
        REFERENCES Customers(CustomerID),

    CONSTRAINT CK_Orders_TotalAmount
        CHECK (TotalAmount >= 0),

    CONSTRAINT CK_Orders_Status
        CHECK (
            OrderStatus IN
            ('PENDING',
             'CONFIRMED',
             'SHIPPING',
             'DELIVERED',
             'CANCELLED')
        )
);
GO



CREATE TABLE OrderItems (
    OrderItemID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(18,2) NOT NULL,

    Subtotal AS (Quantity * UnitPrice) PERSISTED,

    CONSTRAINT FK_OrderItems_Orders
        FOREIGN KEY (OrderID)
        REFERENCES Orders(OrderID)
        ON DELETE CASCADE,

    CONSTRAINT FK_OrderItems_Products
        FOREIGN KEY (ProductID)
        REFERENCES Products(ProductID),

    CONSTRAINT CK_OrderItems_Quantity
        CHECK (Quantity > 0),

    CONSTRAINT CK_OrderItems_UnitPrice
        CHECK (UnitPrice >= 0)
);
GO


CREATE TABLE Payments (
    PaymentID BIGINT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT NOT NULL UNIQUE,
    PaymentMethod VARCHAR(30) NOT NULL,
    TransactionID VARCHAR(100),
    Amount DECIMAL(18,2) NOT NULL,
    PaymentStatus VARCHAR(30) NOT NULL DEFAULT 'PENDING',
    ResponseCode VARCHAR(20),
    PaymentDate DATETIME2,

    CONSTRAINT FK_Payments_Orders
        FOREIGN KEY (OrderID)
        REFERENCES Orders(OrderID),

    CONSTRAINT CK_Payments_Method
        CHECK (
            PaymentMethod IN
            ('COD', 'VNPAY', 'BANK_TRANSFER')
        ),

    CONSTRAINT CK_Payments_Amount
        CHECK (Amount >= 0),

    CONSTRAINT CK_Payments_Status
        CHECK (
            PaymentStatus IN
            ('PENDING', 'SUCCESS', 'FAILED', 'CANCELLED')
        )
);
GO




CREATE TABLE Shipments (
    ShipmentID BIGINT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT NOT NULL UNIQUE,
    ShippingProvider NVARCHAR(100),
    TrackingNumber VARCHAR(100),
    ShippingAddress NVARCHAR(500),
    ShippingStatus VARCHAR(30) NOT NULL DEFAULT 'PENDING',
    EstimatedDeliveryDate DATE,
    ShippedAt DATETIME2,
    DeliveredAt DATETIME2,

    CONSTRAINT FK_Shipments_Orders
        FOREIGN KEY (OrderID)
        REFERENCES Orders(OrderID),

    CONSTRAINT CK_Shipments_Status
        CHECK (
            ShippingStatus IN
            ('PENDING',
             'PROCESSING',
             'SHIPPING',
             'DELIVERED',
             'FAILED')
        )
);
GO




CREATE TABLE Vouchers (
    VoucherID INT IDENTITY(1,1) PRIMARY KEY,
    VoucherCode VARCHAR(50) NOT NULL UNIQUE,
    Description NVARCHAR(500),

    DiscountType VARCHAR(20) NOT NULL,
    DiscountValue DECIMAL(18,2) NOT NULL,
    MinOrderAmount DECIMAL(18,2) NOT NULL DEFAULT 0,
    MaxDiscount DECIMAL(18,2),

    StartDate DATETIME2 NOT NULL,
    EndDate DATETIME2 NOT NULL,

    UsageLimit INT,
    UsedCount INT NOT NULL DEFAULT 0,

    Status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',

    CreatedBy INT,
    CreatedAt DATETIME2 NOT NULL DEFAULT GETDATE(),

    CONSTRAINT FK_Vouchers_Staff
        FOREIGN KEY (CreatedBy)
        REFERENCES Staff(StaffID),

    CONSTRAINT CK_Vouchers_DiscountType
        CHECK (DiscountType IN ('PERCENT', 'FIXED')),

    CONSTRAINT CK_Vouchers_DiscountValue
        CHECK (DiscountValue >= 0),

    CONSTRAINT CK_Vouchers_MinOrder
        CHECK (MinOrderAmount >= 0),

    CONSTRAINT CK_Vouchers_MaxDiscount
        CHECK (MaxDiscount IS NULL OR MaxDiscount >= 0),

    CONSTRAINT CK_Vouchers_UsageLimit
        CHECK (UsageLimit IS NULL OR UsageLimit > 0),

    CONSTRAINT CK_Vouchers_UsedCount
        CHECK (UsedCount >= 0),

    CONSTRAINT CK_Vouchers_Date
        CHECK (EndDate > StartDate),

    CONSTRAINT CK_Vouchers_Status
        CHECK (Status IN ('ACTIVE', 'INACTIVE', 'EXPIRED'))
);
GO



CREATE TABLE OrderVouchers (
    OrderVoucherID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT NOT NULL,
    VoucherID INT NOT NULL,
    DiscountAmount DECIMAL(18,2) NOT NULL,

    CONSTRAINT FK_OrderVouchers_Orders
        FOREIGN KEY (OrderID)
        REFERENCES Orders(OrderID)
        ON DELETE CASCADE,

    CONSTRAINT FK_OrderVouchers_Vouchers
        FOREIGN KEY (VoucherID)
        REFERENCES Vouchers(VoucherID),

    CONSTRAINT CK_OrderVouchers_Discount
        CHECK (DiscountAmount >= 0),

    CONSTRAINT UQ_OrderVouchers_Order
        UNIQUE (OrderID)
);
GO


CREATE TABLE Reviews (
    ReviewID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT NOT NULL,
    ProductID INT NOT NULL,

    Rating INT NOT NULL,
    Comment NVARCHAR(1000),

    Status VARCHAR(20) NOT NULL DEFAULT 'VISIBLE',
    CreatedAt DATETIME2 NOT NULL DEFAULT GETDATE(),
    UpdatedAt DATETIME2,

    CONSTRAINT FK_Reviews_Customers
        FOREIGN KEY (CustomerID)
        REFERENCES Customers(CustomerID),

    CONSTRAINT FK_Reviews_Products
        FOREIGN KEY (ProductID)
        REFERENCES Products(ProductID),

    CONSTRAINT CK_Reviews_Rating
        CHECK (Rating BETWEEN 1 AND 5),

    CONSTRAINT CK_Reviews_Status
        CHECK (Status IN ('VISIBLE', 'HIDDEN')),

    CONSTRAINT UQ_Reviews_Customer_Product
        UNIQUE (CustomerID, ProductID)
);
GO

CREATE TABLE ReviewImages (
    ImageID INT IDENTITY(1,1) PRIMARY KEY,
    ReviewID INT NOT NULL,
    ImageURL VARCHAR(500) NOT NULL,
    PublicID VARCHAR(255),
    IsPrimary BIT NOT NULL DEFAULT 0,
    CreatedAt DATETIME2 NOT NULL DEFAULT GETDATE(),

    CONSTRAINT FK_ReviewImages_Reviews
        FOREIGN KEY (ReviewID)
        REFERENCES Reviews(ReviewID)
        ON DELETE CASCADE
);
GO




CREATE TABLE Favorites (
    FavoriteID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT NOT NULL,
    ProductID INT NOT NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT GETDATE(),

    CONSTRAINT FK_Favorites_Customers
        FOREIGN KEY (CustomerID)
        REFERENCES Customers(CustomerID)
        ON DELETE CASCADE,

    CONSTRAINT FK_Favorites_Products
        FOREIGN KEY (ProductID)
        REFERENCES Products(ProductID),

    CONSTRAINT UQ_Favorites_Customer_Product
        UNIQUE (CustomerID, ProductID)
);
GO



CREATE TABLE UserBehaviors (
    BehaviorID BIGINT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT,
    ProductID INT,

    BehaviorType VARCHAR(30) NOT NULL,
    SearchKeyword NVARCHAR(255),
    SessionID VARCHAR(100),

    CreatedAt DATETIME2 NOT NULL DEFAULT GETDATE(),

    CONSTRAINT FK_UserBehaviors_Customers
        FOREIGN KEY (CustomerID)
        REFERENCES Customers(CustomerID)
        ON DELETE SET NULL,

    CONSTRAINT FK_UserBehaviors_Products
        FOREIGN KEY (ProductID)
        REFERENCES Products(ProductID),

    CONSTRAINT CK_UserBehaviors_Type
        CHECK (
            BehaviorType IN
            ('VIEW',
             'SEARCH',
             'FAVORITE',
             'CART',
             'PURCHASE')
        )
);
GO



CREATE TABLE AIRecommendations (
    RecommendationID BIGINT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT NULL,
    SessionID VARCHAR(100) NULL,
    ProductID INT NOT NULL,

    RecommendationType VARCHAR(30) NOT NULL,

    SimilarityScore DECIMAL(6,5) NOT NULL,
    BehaviorScore DECIMAL(6,5) NOT NULL,
    FinalScore DECIMAL(6,5) NOT NULL,

    Reason NVARCHAR(500),

    IsClicked BIT NOT NULL DEFAULT 0,
    IsPurchased BIT NOT NULL DEFAULT 0,

    CreatedAt DATETIME2 NOT NULL DEFAULT GETDATE(),

    CONSTRAINT FK_AIRecommendations_Customers
        FOREIGN KEY (CustomerID)
        REFERENCES Customers(CustomerID)
        ON DELETE SET NULL,

    CONSTRAINT FK_AIRecommendations_Products
        FOREIGN KEY (ProductID)
        REFERENCES Products(ProductID),

    CONSTRAINT CK_AIRecommendations_Type
        CHECK (
            RecommendationType IN
            ('SIMILAR',
             'PERSONALIZED',
             'TRENDING',
             'BEST_SELLER',
             'COLD_START')
        ),

    CONSTRAINT CK_AIRecommendations_Similarity
        CHECK (SimilarityScore BETWEEN 0 AND 1),

    CONSTRAINT CK_AIRecommendations_Behavior
        CHECK (BehaviorScore BETWEEN 0 AND 1),

    CONSTRAINT CK_AIRecommendations_Final
        CHECK (FinalScore BETWEEN 0 AND 1)
);
GO




CREATE TABLE Notifications (
    NotificationID BIGINT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT NOT NULL,
    OrderID INT,

    NotificationType VARCHAR(30) NOT NULL,
    RecipientEmail VARCHAR(150) NOT NULL,
    Subject NVARCHAR(255),
    Message NVARCHAR(MAX),

    Status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    SentAt DATETIME2,
    CreatedAt DATETIME2 NOT NULL DEFAULT GETDATE(),

    CONSTRAINT FK_Notifications_Customers
        FOREIGN KEY (CustomerID)
        REFERENCES Customers(CustomerID)
        ON DELETE CASCADE,

    CONSTRAINT FK_Notifications_Orders
        FOREIGN KEY (OrderID)
        REFERENCES Orders(OrderID)
        ON DELETE SET NULL,

    CONSTRAINT CK_Notifications_Type
        CHECK (
            NotificationType IN
            ('ORDER', 'PAYMENT', 'DELIVERY')
        ),

    CONSTRAINT CK_Notifications_Status
        CHECK (
            Status IN ('PENDING', 'SENT', 'FAILED')
        )
);
GO



CREATE TABLE AuditLogs (
    AuditLogID BIGINT IDENTITY(1,1) PRIMARY KEY,
    StaffID INT,
    Action VARCHAR(50) NOT NULL,
    EntityName VARCHAR(100),
    EntityID VARCHAR(100),
    OldData NVARCHAR(MAX),
    NewData NVARCHAR(MAX),
    CreatedAt DATETIME2 NOT NULL DEFAULT GETDATE(),

    CONSTRAINT FK_AuditLogs_Staff
        FOREIGN KEY (StaffID)
        REFERENCES Staff(StaffID)
        ON DELETE SET NULL
);
GO



CREATE INDEX IX_UserBehaviors_CustomerID
ON UserBehaviors(CustomerID);
GO

CREATE INDEX IX_UserBehaviors_ProductID
ON UserBehaviors(ProductID);
GO

CREATE INDEX IX_UserBehaviors_BehaviorType
ON UserBehaviors(BehaviorType);
GO

CREATE INDEX IX_UserBehaviors_CreatedAt
ON UserBehaviors(CreatedAt);
GO


CREATE INDEX IX_AIRecommendations_CustomerID
ON AIRecommendations(CustomerID);
GO

CREATE INDEX IX_AIRecommendations_SessionID
ON AIRecommendations(SessionID);
GO

CREATE INDEX IX_AIRecommendations_ProductID
ON AIRecommendations(ProductID);
GO

CREATE INDEX IX_AIRecommendations_FinalScore
ON AIRecommendations(FinalScore DESC);
GO


CREATE INDEX IX_Products_CategoryID
ON Products(CategoryID);
GO

CREATE INDEX IX_Products_BrandID
ON Products(BrandID);
GO

CREATE INDEX IX_Orders_CustomerID
ON Orders(CustomerID);
GO


-- =========================================================
-- SEED DATA FOR AI INTEGRATION & TESTING
-- =========================================================

INSERT INTO Roles (RoleName, Description)
VALUES
('ADMIN', 'System administrator'),
('MANAGER', 'Store manager');
GO

INSERT INTO Categories (CategoryName, Description, Status)
VALUES
(N'Headphone', N'Headphones including over-ear and on-ear products.', 'ACTIVE'),
(N'Earbud', N'Wireless and true wireless earbuds designed for portable listening.', 'ACTIVE');
GO

INSERT INTO Brands (BrandName, Description, Status)
VALUES
(N'Sony', N'Japanese electronics brand known for headphones, audio equipment, and noise cancelling technology.', 'ACTIVE'),
(N'Apple', N'Technology company offering AirPods and other wireless audio products.', 'ACTIVE'),
(N'Bose', N'Audio brand specializing in premium headphones and noise cancelling technology.', 'ACTIVE'),
(N'JBL', N'Audio brand offering headphones, earbuds, speakers, and other consumer audio products.', 'ACTIVE'),
(N'Audio-Technica', N'Japanese audio manufacturer known for professional and consumer headphones.', 'ACTIVE'),
(N'Sennheiser', N'German audio company specializing in professional and consumer audio products.', 'ACTIVE'),
(N'Razer', N'Gaming brand producing headsets and other gaming peripherals.', 'ACTIVE'),
(N'HyperX', N'Gaming brand known for gaming headsets and other gaming accessories.', 'ACTIVE'),
(N'Anker Soundcore', N'Audio brand offering wireless headphones, earbuds, and portable audio products.', 'ACTIVE'),
(N'Marshall', N'Audio brand known for headphones, speakers, and products with a distinctive design.', 'ACTIVE');
GO

-- =========================================================
-- PRODUCTS (50 items, all stock > 5, fully populated specs)
-- =========================================================
INSERT INTO Products (
    ProductName, CategoryID, BrandID, Description, Price, StockQuantity,
    ConnectionType, DriverSize, NoiseCancelling, BatteryLife,
    Microphone, WaterResistance, Weight, Status
)
VALUES
(N'Sony WH-1000XM5', 1, 1, N'Industry-leading noise canceling with two processors and 8 microphones. Exceptional sound quality and ultra-comfortable lightweight design.', 8990000, 45, 'BLUETOOTH', 30.0, 1, 30, 1, 'None', 250.0, 'ACTIVE'),
(N'Sony WH-1000XM4', 1, 1, N'Premium wireless noise-canceling headphones with Dual Noise Sensor technology and touch sensor controls.', 6990000, 35, 'BLUETOOTH', 40.0, 1, 30, 1, 'None', 254.0, 'ACTIVE'),
(N'Sony WH-CH720N', 1, 1, N'Sony''s lightest wireless noise-canceling headband, featuring the Integrated Processor V1 for rich sound.', 2790000, 50, 'BLUETOOTH', 30.0, 1, 35, 1, 'None', 192.0, 'ACTIVE'),
(N'Sony MDR-7506', 1, 1, N'Legendary professional studio monitor headphones providing pristine audio fidelity for recording and broadcast.', 2490000, 30, 'WIRED', 40.0, 0, 0, 0, 'None', 230.0, 'ACTIVE'),
(N'Apple AirPods Max', 1, 2, N'High-fidelity audio with Active Noise Cancellation, Transparency mode, and computational audio with Apple H1 headphone chip.', 13990000, 25, 'BLUETOOTH', 40.0, 1, 20, 1, 'None', 384.8, 'ACTIVE'),
(N'Bose QuietComfort 45', 1, 3, N'The iconic quiet comfort headphones with world-class noise cancellation, proprietary acoustic technology, and all-day comfort.', 7990000, 40, 'BLUETOOTH', 40.0, 1, 24, 1, 'None', 240.0, 'ACTIVE'),
(N'Bose QuietComfort Ultra Headphones', 1, 3, N'Breakthrough spatialized audio for more immersive listening, world-class ANC, and CustomTune technology.', 10490000, 20, 'BLUETOOTH', 40.0, 1, 24, 1, 'None', 253.0, 'ACTIVE'),
(N'Bose 700', 1, 3, N'Critically acclaimed for its modern sleek design, 11 levels of noise cancellation, and unrivaled voice pickup.', 8490000, 25, 'BLUETOOTH', 40.0, 1, 20, 1, 'None', 249.0, 'ACTIVE'),
(N'JBL Tune 770NC', 1, 4, N'Adaptive Noise Cancelling wireless headphones with JBL Pure Bass Sound, lightweight design, and up to 70 hours battery.', 3290000, 60, 'BLUETOOTH', 40.0, 1, 70, 1, 'None', 232.0, 'ACTIVE'),
(N'JBL Live 670NC', 1, 4, N'Wireless on-ear headphones with True Adaptive Noise Cancelling, Smart Ambient, and Personi-Fi 2.0 sound personalization.', 3790000, 40, 'BLUETOOTH', 40.0, 1, 65, 1, 'None', 219.0, 'ACTIVE'),
(N'JBL Quantum 810', 1, 4, N'Wireless over-ear performance gaming headset with dual surround sound, active noise cancelling, and 2.4GHz wireless.', 4990000, 30, 'WIRELESS', 50.0, 1, 43, 1, 'None', 418.0, 'ACTIVE'),
(N'Audio-Technica ATH-M50x', 1, 5, N'Critically acclaimed sonic performance praised by top audio engineers and pro audio reviewers worldwide.', 3990000, 50, 'WIRED', 45.0, 0, 0, 0, 'None', 285.0, 'ACTIVE'),
(N'Audio-Technica ATH-M50xBT2', 1, 5, N'Wireless over-ear headphones delivering the legendary M50x studio sound with Bluetooth 5.0 and 50 hours of battery.', 5290000, 35, 'BLUETOOTH', 45.0, 0, 50, 1, 'None', 307.0, 'ACTIVE'),
(N'Audio-Technica ATH-M40x', 1, 5, N'Professional monitor headphones tuned flat for incredibly accurate audio monitoring across an extended frequency range.', 2790000, 40, 'WIRED', 40.0, 0, 0, 0, 'None', 240.0, 'ACTIVE'),
(N'Sennheiser HD 560S', 1, 6, N'Open-back reference headphones designed for detailed analytical listening with linear acoustic tuning.', 4490000, 35, 'WIRED', 38.0, 0, 0, 0, 'None', 240.0, 'ACTIVE'),
(N'Sennheiser Momentum 4 Wireless', 1, 6, N'Audiophile-inspired 42mm transducer system delivering brilliant dynamics and unmatched 60-hour battery life.', 8490000, 30, 'BLUETOOTH', 42.0, 1, 60, 1, 'None', 293.0, 'ACTIVE'),
(N'Sennheiser HD 660S2', 1, 6, N'High-end open-back dynamic headphones providing deep sub-bass and intimate emotional vocal clarity.', 13990000, 15, 'WIRED', 38.0, 0, 0, 0, 'None', 260.0, 'ACTIVE'),
(N'Razer BlackShark V2 Pro', 1, 7, N'Wireless esports gaming headset featuring TriForce Titanium 50mm drivers and HyperClear super wideband mic.', 4490000, 40, 'WIRELESS', 50.0, 0, 70, 1, 'None', 320.0, 'ACTIVE'),
(N'Razer Kraken V3 HyperSense', 1, 7, N'PC gaming headset powered by intelligent haptic technology for tactile sensory immersion in gameplay.', 3290000, 35, 'WIRED', 50.0, 0, 0, 1, 'None', 344.0, 'ACTIVE'),
(N'Razer Barracuda X', 1, 7, N'4-in-1 multi-platform wireless gaming headset designed for PC, PlayStation, Nintendo Switch, and Android.', 2390000, 50, 'WIRELESS', 40.0, 0, 50, 1, 'None', 250.0, 'ACTIVE'),
(N'HyperX Cloud II', 1, 8, N'Iconic comfortable gaming headset with memory foam ear cushions, 53mm drivers, and virtual 7.1 surround sound.', 2090000, 60, 'WIRED', 53.0, 0, 0, 1, 'None', 320.0, 'ACTIVE'),
(N'HyperX Cloud III Wireless', 1, 8, N'Evolution of gaming comfort with up to 120 hours of battery life and angled 53mm dynamic drivers.', 3990000, 40, 'WIRELESS', 53.0, 0, 120, 1, 'None', 330.0, 'ACTIVE'),
(N'HyperX Cloud Alpha Wireless', 1, 8, N'World''s first gaming headset with up to 300 hours of battery life and dual chamber audio driver architecture.', 4890000, 25, 'WIRELESS', 50.0, 0, 300, 1, 'None', 335.0, 'ACTIVE'),
(N'Marshall Major V', 1, 10, N'Wireless on-ear headphones with 100+ hours of Bluetooth playtime, rugged foldable design, and customizable M-button.', 4290000, 45, 'BLUETOOTH', 40.0, 0, 100, 1, 'None', 186.0, 'ACTIVE'),
(N'Marshall Monitor II A.N.C.', 1, 10, N'Advanced active noise cancelling headphones with rich custom-tuned 40mm dynamic drivers and vintage Marshall styling.', 7990000, 25, 'BLUETOOTH', 40.0, 1, 30, 1, 'None', 320.0, 'ACTIVE'),
(N'Sony WF-1000XM5', 2, 1, N'The best noise-canceling truly wireless earbuds with high-resolution wireless audio and bone conduction sensors.', 6990000, 45, 'BLUETOOTH', 8.4, 1, 24, 1, 'IPX4', 5.9, 'ACTIVE'),
(N'Sony WF-C700N', 2, 1, N'Truly wireless noise canceling earbuds with ergonomic pocket-sized design, Multipoint connection, and IPX4 rating.', 2490000, 55, 'BLUETOOTH', 5.0, 1, 15, 1, 'IPX4', 4.6, 'ACTIVE'),
(N'Sony LinkBuds S', 2, 1, N'Never off. Automatic ambient sound switching, high-res audio wireless, and ultra-lightweight comfortable fit.', 3990000, 35, 'BLUETOOTH', 5.0, 1, 20, 1, 'IPX4', 4.8, 'ACTIVE'),
(N'Apple AirPods Pro 2', 2, 2, N'Up to 2x more Active Noise Cancellation, Adaptive Audio, USB-C MagSafe Case, and personalized spatial audio.', 5490000, 70, 'BLUETOOTH', 11.0, 1, 30, 1, 'IP54', 5.3, 'ACTIVE'),
(N'Apple AirPods 3', 2, 2, N'Spatial audio with dynamic head tracking, contoured fit, force sensor controls, and sweat/water resistance.', 4190000, 50, 'BLUETOOTH', 11.0, 0, 30, 1, 'IPX4', 4.28, 'ACTIVE'),
(N'Apple AirPods 4', 2, 2, N'The next generation open-ear design featuring Active Noise Cancellation and the powerful Apple H2 chip.', 4790000, 40, 'BLUETOOTH', 11.0, 1, 24, 1, 'IP54', 4.3, 'ACTIVE'),
(N'Bose QuietComfort Ultra Earbuds', 2, 3, N'World-class noise cancellation combined with Bose Immersive Audio and CustomTune technology.', 7490000, 35, 'BLUETOOTH', 9.3, 1, 24, 1, 'IPX4', 6.24, 'ACTIVE'),
(N'Bose QuietComfort Earbuds II', 2, 3, N'Engineered to fit you uniquely, offering pioneering noise reduction and lifelike, well-balanced sound.', 5990000, 30, 'BLUETOOTH', 9.3, 1, 24, 1, 'IPX4', 6.2, 'ACTIVE'),
(N'JBL Tune Buds', 2, 4, N'True wireless earbuds featuring 10mm drivers with JBL Pure Bass Sound and Active Noise Cancelling.', 1990000, 65, 'BLUETOOTH', 10.0, 1, 48, 1, 'IP54', 5.1, 'ACTIVE'),
(N'JBL Live Beam 3', 2, 4, N'High-res audio earbuds with smart touchscreen charging case, True Adaptive ANC, and 6 beamforming mics.', 3990000, 30, 'BLUETOOTH', 10.0, 1, 48, 1, 'IP55', 5.0, 'ACTIVE'),
(N'JBL Wave Beam', 2, 4, N'Budget-friendly true wireless earbuds with JBL Deep Bass Sound, ergonomic closed stick design, and 32h battery.', 1290000, 70, 'BLUETOOTH', 8.0, 0, 32, 1, 'IP54', 4.4, 'ACTIVE'),
(N'Audio-Technica ATH-TWX9', 2, 5, N'Flagship true wireless earbuds with digital hybrid noise-cancelling and a deep UV sterilization system in the case.', 7290000, 20, 'BLUETOOTH', 5.8, 1, 18, 1, 'IPX4', 5.4, 'ACTIVE'),
(N'Audio-Technica ATH-SQ1TW2', 2, 5, N'Distinctive square-shaped true wireless earbuds offering clear sound, low-latency mode, and multiple trendy colors.', 1890000, 45, 'BLUETOOTH', 5.8, 0, 20, 1, 'IPX5', 4.0, 'ACTIVE'),
(N'Sennheiser Momentum True Wireless 4', 2, 6, N'Audiophile TrueResponse transducer system, adaptive ANC, Snapdragon Sound, and lossless audio support.', 7990000, 30, 'BLUETOOTH', 7.0, 1, 30, 1, 'IP54', 6.2, 'ACTIVE'),
(N'Sennheiser CX Plus SE', 2, 6, N'Active Noise Cancellation true wireless earbuds with custom bass boost, IPX4 splash resistance, and ergonomic fit.', 3190000, 40, 'BLUETOOTH', 7.0, 1, 24, 1, 'IPX4', 6.0, 'ACTIVE'),
(N'Razer Hammerhead True Wireless Pro', 2, 7, N'THX Certified advanced hybrid active noise cancellation gaming earbuds with 60ms low latency mode.', 4490000, 25, 'BLUETOOTH', 10.0, 1, 20, 1, 'IPX4', 5.0, 'ACTIVE'),
(N'Razer Hammerhead Hyperspeed', 2, 7, N'Gaming earbuds with 2.4GHz wireless dongle and Bluetooth 5.2 for ultra-fast, seamless audio on consoles and PC.', 3590000, 35, 'WIRELESS', 10.0, 1, 30, 1, 'IPX4', 5.3, 'ACTIVE'),
(N'HyperX Cirro Buds Pro', 2, 8, N'True wireless earbuds featuring hybrid active noise cancellation, 90ms game mode, and up to 35 hours battery.', 2190000, 40, 'BLUETOOTH', 8.0, 1, 35, 1, 'IPX4', 5.2, 'ACTIVE'),
(N'Anker Soundcore Liberty 4', 2, 9, N'ACAA 3.0 coaxial acoustic architecture, premium sound with heart rate sensor, and spatial 360 audio.', 2990000, 50, 'BLUETOOTH', 9.2, 1, 28, 1, 'IPX4', 5.8, 'ACTIVE'),
(N'Anker Soundcore Liberty 4 NC', 2, 9, N'Reduces noise by up to 98.5% with high sensitivity in-ear sensor, 11mm custom driver, and Hi-Res wireless audio.', 2190000, 65, 'BLUETOOTH', 11.0, 1, 50, 1, 'IPX4', 5.0, 'ACTIVE'),
(N'Anker Soundcore Space A40', 2, 9, N'Ultra-compact earbuds with adaptive noise cancelling, LDAC high-res mode, and marathon 50-hour playback.', 1790000, 60, 'BLUETOOTH', 10.0, 1, 50, 1, 'IPX4', 4.9, 'ACTIVE'),
(N'Anker Soundcore Life P3', 2, 9, N'Customized noise cancelling with Transport, Outdoor, and Indoor modes, plus thumping BassUp technology.', 1590000, 70, 'BLUETOOTH', 11.0, 1, 35, 1, 'IPX5', 5.0, 'ACTIVE'),
(N'Marshall Motif II A.N.C.', 2, 10, N'Huge sound in a tiny package. 30 hours of playtime with active noise cancellation and iconic Marshall styling.', 5190000, 35, 'BLUETOOTH', 6.0, 1, 30, 1, 'IPX5', 4.31, 'ACTIVE'),
(N'Marshall Minor IV', 2, 10, N'True wireless open-ear earbuds delivering Marshall signature sound, 30+ hours of playtime, and Bluetooth LE Audio.', 3490000, 45, 'BLUETOOTH', 12.0, 0, 30, 1, 'IPX4', 7.39, 'ACTIVE'),
(N'Sony WF-1000XM4', 2, 1, N'Integrated Processor V1 noise cancelling, LDAC audio, speak-to-chat, and beamforming microphones with sensor.', 4990000, 30, 'BLUETOOTH', 6.0, 1, 24, 1, 'IPX4', 7.3, 'ACTIVE');
GO

-- =========================================================
-- PRODUCT IMAGES (Primary image for each of the 50 products)
-- =========================================================
INSERT INTO ProductImages (ProductID, ImageURL, PublicID, IsPrimary)
SELECT p.ProductID,
       'assets/img/product0' + CAST(((p.ProductID - 1) % 9 + 1) AS VARCHAR(10)) + '.png',
       'local_assets/product0' + CAST(((p.ProductID - 1) % 9 + 1) AS VARCHAR(10)),
       1
FROM Products p;
GO

-- =========================================================
-- CUSTOMERS (10 customers, Password: '123456')
-- =========================================================
INSERT INTO Customers (FullName, Email, PasswordHash, Phone, Status)
VALUES
(N'Nguyen Van An',   'an.nguyen@gmail.com',   '123456', '0901000001', 'ACTIVE'),
(N'Tran Thi Binh',   'binh.tran@gmail.com',   '123456', '0901000002', 'ACTIVE'),
(N'Le Hoang Cuong',  'cuong.le@gmail.com',    '123456', '0901000003', 'ACTIVE'),
(N'Pham Minh Duc',   'duc.pham@gmail.com',    '123456', '0901000004', 'ACTIVE'),
(N'Vo Thi Ha',       'ha.vo@gmail.com',       '123456', '0901000005', 'ACTIVE'),
(N'Dang Huu Long',   'long.dang@gmail.com',   '123456', '0901000006', 'ACTIVE'),
(N'Hoang Mai Lan',   'lan.hoang@gmail.com',   '123456', '0901000007', 'ACTIVE'),
(N'Vu Tien Nam',     'nam.vu@gmail.com',      '123456', '0901000008', 'ACTIVE'),
(N'Ngo Thu Trang',   'trang.ngo@gmail.com',   '123456', '0901000009', 'ACTIVE'),
(N'Doan Quoc Tuan',  'tuan.doan@gmail.com',   '123456', '0901000010', 'ACTIVE');
GO

-- =========================================================
-- ADDRESSES (Default address for each customer)
-- =========================================================
INSERT INTO Addresses (CustomerID, ReceiverName, ReceiverPhone, AddressLine, Ward, District, Province, IsDefault)
VALUES
(1,  N'Nguyen Van An',  '0901000001', N'123 Nguyen Trai',        N'Phuong Ben Thanh',  N'Quan 1',        N'TP Ho Chi Minh', 1),
(2,  N'Tran Thi Binh',  '0901000002', N'456 Le Duan',            N'Phuong Thach Thang', N'Quan Hai Chau', N'Da Nang',       1),
(3,  N'Le Hoang Cuong', '0901000003', N'789 Hoang Hoa Tham',     N'Phuong Lieu Giai',  N'Quan Ba Dinh',  N'Ha Noi',          1),
(4,  N'Pham Minh Duc',  '0901000004', N'101 Tran Hung Dao',      N'Phuong 5',          N'Quan 5',        N'TP Ho Chi Minh', 1),
(5,  N'Vo Thi Ha',      '0901000005', N'202 Nguyen Van Cu',      N'Phuong An Khanh',   N'Quan Ninh Kieu', N'Can Tho',       1),
(6,  N'Dang Huu Long',  '0901000006', N'303 Quang Trung',        N'Phuong 10',         N'Quan Go Vap',   N'TP Ho Chi Minh', 1),
(7,  N'Hoang Mai Lan',  '0901000007', N'404 Kim Ma',             N'Phuong Ngoc Khanh', N'Quan Ba Dinh',  N'Ha Noi',         1),
(8,  N'Vu Tien Nam',    '0901000008', N'505 Vo Thi Sau',         N'Phuong Vo Thi Sau', N'Quan 3',        N'TP Ho Chi Minh', 1),
(9,  N'Ngo Thu Trang',  '0901000009', N'606 Phan Chau Trinh',    N'Phuong Phuoc Ninh', N'Quan Hai Chau', N'Da Nang',       1),
(10, N'Doan Quoc Tuan', '0901000010', N'707 Cach Mang Thang 8', N'Phuong 15',         N'Quan 10',       N'TP Ho Chi Minh', 1);
GO

-- =========================================================
-- CARTS & CART ITEMS (Active cart for each customer)
-- =========================================================
INSERT INTO Carts (CustomerID, CreatedAt)
SELECT CustomerID, DATEADD(DAY, -CustomerID * 3, GETDATE())
FROM Customers;
GO

INSERT INTO CartItems (CartID, ProductID, Quantity, AddedAt)
VALUES
(1,  5,  1, DATEADD(DAY, -2, GETDATE())),
(1,  18, 1, DATEADD(DAY, -1, GETDATE())),
(2,  7,  1, DATEADD(DAY, -3, GETDATE())),
(3,  1,  1, DATEADD(DAY, -2, GETDATE())),
(4,  26, 1, DATEADD(DAY, -4, GETDATE())),
(5,  12, 1, DATEADD(DAY, -2, GETDATE())),
(6,  16, 1, DATEADD(DAY, -5, GETDATE())),
(7,  2,  1, DATEADD(DAY, -1, GETDATE())),
(8,  29, 1, DATEADD(DAY, -3, GETDATE())),
(9,  15, 1, DATEADD(DAY, -2, GETDATE())),
(10, 44, 1, DATEADD(DAY, -1, GETDATE()));
GO

-- =========================================================
-- ORDERS, ORDER ITEMS, PAYMENTS, SHIPMENTS
-- 10 customers, each purchased 8-10 distinct products
-- All Orders DELIVERED, all Payments SUCCESS, all Shipments DELIVERED
-- =========================================================

-- Order 1 (Customer 1, 60 days ago)
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;

INSERT INTO Orders (CustomerID, TotalAmount, ShippingName, ShippingPhone, ShippingAddress, OrderStatus, OrderDate)
SELECT 1,
       (1 * (SELECT Price FROM Products WHERE ProductID = 1) + 1 * (SELECT Price FROM Products WHERE ProductID = 4) + 1 * (SELECT Price FROM Products WHERE ProductID = 7)),
       a.ReceiverName,
       a.ReceiverPhone,
       a.AddressLine + N', ' + a.Ward + N', ' + a.District + N', ' + a.Province,
       'DELIVERED',
       DATEADD(DAY, -60, GETDATE())
FROM Addresses a
WHERE a.CustomerID = 1 AND a.IsDefault = 1;

INSERT INTO OrderItems (OrderID, ProductID, Quantity, UnitPrice)
VALUES
(1, 1, 1, (SELECT Price FROM Products WHERE ProductID = 1)),
(1, 4, 1, (SELECT Price FROM Products WHERE ProductID = 4)),
(1, 7, 1, (SELECT Price FROM Products WHERE ProductID = 7));

INSERT INTO Payments (OrderID, PaymentMethod, TransactionID, Amount, PaymentStatus, ResponseCode, PaymentDate)
SELECT 1, 'BANK_TRANSFER', 'TXN_ORD1', TotalAmount, 'SUCCESS', '00', OrderDate
FROM Orders WHERE OrderID = 1;

INSERT INTO Shipments (OrderID, ShippingProvider, TrackingNumber, ShippingAddress, ShippingStatus, EstimatedDeliveryDate, ShippedAt, DeliveredAt)
SELECT 1, N'Viettel Post', 'TRK100001', ShippingAddress, 'DELIVERED',
       CAST(DATEADD(DAY, -(60 - 3), GETDATE()) AS DATE),
       DATEADD(HOUR, 4, OrderDate),
       DATEADD(DAY, 2, OrderDate)
FROM Orders WHERE OrderID = 1;
GO

-- Order 2 (Customer 1, 35 days ago)
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;

INSERT INTO Orders (CustomerID, TotalAmount, ShippingName, ShippingPhone, ShippingAddress, OrderStatus, OrderDate)
SELECT 1,
       (1 * (SELECT Price FROM Products WHERE ProductID = 12) + 1 * (SELECT Price FROM Products WHERE ProductID = 15) + 1 * (SELECT Price FROM Products WHERE ProductID = 26)),
       a.ReceiverName,
       a.ReceiverPhone,
       a.AddressLine + N', ' + a.Ward + N', ' + a.District + N', ' + a.Province,
       'DELIVERED',
       DATEADD(DAY, -35, GETDATE())
FROM Addresses a
WHERE a.CustomerID = 1 AND a.IsDefault = 1;

INSERT INTO OrderItems (OrderID, ProductID, Quantity, UnitPrice)
VALUES
(2, 12, 1, (SELECT Price FROM Products WHERE ProductID = 12)),
(2, 15, 1, (SELECT Price FROM Products WHERE ProductID = 15)),
(2, 26, 1, (SELECT Price FROM Products WHERE ProductID = 26));

INSERT INTO Payments (OrderID, PaymentMethod, TransactionID, Amount, PaymentStatus, ResponseCode, PaymentDate)
SELECT 2, 'COD', 'TXN_ORD2', TotalAmount, 'SUCCESS', '00', OrderDate
FROM Orders WHERE OrderID = 2;

INSERT INTO Shipments (OrderID, ShippingProvider, TrackingNumber, ShippingAddress, ShippingStatus, EstimatedDeliveryDate, ShippedAt, DeliveredAt)
SELECT 2, N'Shopee Xpress', 'TRK100002', ShippingAddress, 'DELIVERED',
       CAST(DATEADD(DAY, -(35 - 3), GETDATE()) AS DATE),
       DATEADD(HOUR, 4, OrderDate),
       DATEADD(DAY, 2, OrderDate)
FROM Orders WHERE OrderID = 2;
GO

-- Order 3 (Customer 1, 10 days ago)
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;

INSERT INTO Orders (CustomerID, TotalAmount, ShippingName, ShippingPhone, ShippingAddress, OrderStatus, OrderDate)
SELECT 1,
       (1 * (SELECT Price FROM Products WHERE ProductID = 29) + 1 * (SELECT Price FROM Products WHERE ProductID = 34) + 1 * (SELECT Price FROM Products WHERE ProductID = 44)),
       a.ReceiverName,
       a.ReceiverPhone,
       a.AddressLine + N', ' + a.Ward + N', ' + a.District + N', ' + a.Province,
       'DELIVERED',
       DATEADD(DAY, -10, GETDATE())
FROM Addresses a
WHERE a.CustomerID = 1 AND a.IsDefault = 1;

INSERT INTO OrderItems (OrderID, ProductID, Quantity, UnitPrice)
VALUES
(3, 29, 1, (SELECT Price FROM Products WHERE ProductID = 29)),
(3, 34, 1, (SELECT Price FROM Products WHERE ProductID = 34)),
(3, 44, 1, (SELECT Price FROM Products WHERE ProductID = 44));

INSERT INTO Payments (OrderID, PaymentMethod, TransactionID, Amount, PaymentStatus, ResponseCode, PaymentDate)
SELECT 3, 'VNPAY', 'TXN_ORD3', TotalAmount, 'SUCCESS', '00', OrderDate
FROM Orders WHERE OrderID = 3;

INSERT INTO Shipments (OrderID, ShippingProvider, TrackingNumber, ShippingAddress, ShippingStatus, EstimatedDeliveryDate, ShippedAt, DeliveredAt)
SELECT 3, N'Giao Hang Nhanh', 'TRK100003', ShippingAddress, 'DELIVERED',
       CAST(DATEADD(DAY, -(10 - 3), GETDATE()) AS DATE),
       DATEADD(HOUR, 4, OrderDate),
       DATEADD(DAY, 2, OrderDate)
FROM Orders WHERE OrderID = 3;
GO

-- Order 4 (Customer 2, 65 days ago)
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;

INSERT INTO Orders (CustomerID, TotalAmount, ShippingName, ShippingPhone, ShippingAddress, OrderStatus, OrderDate)
SELECT 2,
       (1 * (SELECT Price FROM Products WHERE ProductID = 1) + 1 * (SELECT Price FROM Products WHERE ProductID = 3) + 1 * (SELECT Price FROM Products WHERE ProductID = 9)),
       a.ReceiverName,
       a.ReceiverPhone,
       a.AddressLine + N', ' + a.Ward + N', ' + a.District + N', ' + a.Province,
       'DELIVERED',
       DATEADD(DAY, -65, GETDATE())
FROM Addresses a
WHERE a.CustomerID = 2 AND a.IsDefault = 1;

INSERT INTO OrderItems (OrderID, ProductID, Quantity, UnitPrice)
VALUES
(4, 1, 1, (SELECT Price FROM Products WHERE ProductID = 1)),
(4, 3, 1, (SELECT Price FROM Products WHERE ProductID = 3)),
(4, 9, 1, (SELECT Price FROM Products WHERE ProductID = 9));

INSERT INTO Payments (OrderID, PaymentMethod, TransactionID, Amount, PaymentStatus, ResponseCode, PaymentDate)
SELECT 4, 'BANK_TRANSFER', 'TXN_ORD4', TotalAmount, 'SUCCESS', '00', OrderDate
FROM Orders WHERE OrderID = 4;

INSERT INTO Shipments (OrderID, ShippingProvider, TrackingNumber, ShippingAddress, ShippingStatus, EstimatedDeliveryDate, ShippedAt, DeliveredAt)
SELECT 4, N'Viettel Post', 'TRK100004', ShippingAddress, 'DELIVERED',
       CAST(DATEADD(DAY, -(65 - 3), GETDATE()) AS DATE),
       DATEADD(HOUR, 4, OrderDate),
       DATEADD(DAY, 2, OrderDate)
FROM Orders WHERE OrderID = 4;
GO

-- Order 5 (Customer 2, 40 days ago)
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;

INSERT INTO Orders (CustomerID, TotalAmount, ShippingName, ShippingPhone, ShippingAddress, OrderStatus, OrderDate)
SELECT 2,
       (1 * (SELECT Price FROM Products WHERE ProductID = 12) + 1 * (SELECT Price FROM Products WHERE ProductID = 16) + 1 * (SELECT Price FROM Products WHERE ProductID = 21)),
       a.ReceiverName,
       a.ReceiverPhone,
       a.AddressLine + N', ' + a.Ward + N', ' + a.District + N', ' + a.Province,
       'DELIVERED',
       DATEADD(DAY, -40, GETDATE())
FROM Addresses a
WHERE a.CustomerID = 2 AND a.IsDefault = 1;

INSERT INTO OrderItems (OrderID, ProductID, Quantity, UnitPrice)
VALUES
(5, 12, 1, (SELECT Price FROM Products WHERE ProductID = 12)),
(5, 16, 1, (SELECT Price FROM Products WHERE ProductID = 16)),
(5, 21, 1, (SELECT Price FROM Products WHERE ProductID = 21));

INSERT INTO Payments (OrderID, PaymentMethod, TransactionID, Amount, PaymentStatus, ResponseCode, PaymentDate)
SELECT 5, 'COD', 'TXN_ORD5', TotalAmount, 'SUCCESS', '00', OrderDate
FROM Orders WHERE OrderID = 5;

INSERT INTO Shipments (OrderID, ShippingProvider, TrackingNumber, ShippingAddress, ShippingStatus, EstimatedDeliveryDate, ShippedAt, DeliveredAt)
SELECT 5, N'Shopee Xpress', 'TRK100005', ShippingAddress, 'DELIVERED',
       CAST(DATEADD(DAY, -(40 - 3), GETDATE()) AS DATE),
       DATEADD(HOUR, 4, OrderDate),
       DATEADD(DAY, 2, OrderDate)
FROM Orders WHERE OrderID = 5;
GO

-- Order 6 (Customer 2, 12 days ago)
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;

INSERT INTO Orders (CustomerID, TotalAmount, ShippingName, ShippingPhone, ShippingAddress, OrderStatus, OrderDate)
SELECT 2,
       (1 * (SELECT Price FROM Products WHERE ProductID = 27) + 1 * (SELECT Price FROM Products WHERE ProductID = 29) + 1 * (SELECT Price FROM Products WHERE ProductID = 35)),
       a.ReceiverName,
       a.ReceiverPhone,
       a.AddressLine + N', ' + a.Ward + N', ' + a.District + N', ' + a.Province,
       'DELIVERED',
       DATEADD(DAY, -12, GETDATE())
FROM Addresses a
WHERE a.CustomerID = 2 AND a.IsDefault = 1;

INSERT INTO OrderItems (OrderID, ProductID, Quantity, UnitPrice)
VALUES
(6, 27, 1, (SELECT Price FROM Products WHERE ProductID = 27)),
(6, 29, 1, (SELECT Price FROM Products WHERE ProductID = 29)),
(6, 35, 1, (SELECT Price FROM Products WHERE ProductID = 35));

INSERT INTO Payments (OrderID, PaymentMethod, TransactionID, Amount, PaymentStatus, ResponseCode, PaymentDate)
SELECT 6, 'VNPAY', 'TXN_ORD6', TotalAmount, 'SUCCESS', '00', OrderDate
FROM Orders WHERE OrderID = 6;

INSERT INTO Shipments (OrderID, ShippingProvider, TrackingNumber, ShippingAddress, ShippingStatus, EstimatedDeliveryDate, ShippedAt, DeliveredAt)
SELECT 6, N'Giao Hang Nhanh', 'TRK100006', ShippingAddress, 'DELIVERED',
       CAST(DATEADD(DAY, -(12 - 3), GETDATE()) AS DATE),
       DATEADD(HOUR, 4, OrderDate),
       DATEADD(DAY, 2, OrderDate)
FROM Orders WHERE OrderID = 6;
GO

-- Order 7 (Customer 3, 70 days ago)
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;

INSERT INTO Orders (CustomerID, TotalAmount, ShippingName, ShippingPhone, ShippingAddress, OrderStatus, OrderDate)
SELECT 3,
       (1 * (SELECT Price FROM Products WHERE ProductID = 2) + 1 * (SELECT Price FROM Products WHERE ProductID = 6) + 1 * (SELECT Price FROM Products WHERE ProductID = 12)),
       a.ReceiverName,
       a.ReceiverPhone,
       a.AddressLine + N', ' + a.Ward + N', ' + a.District + N', ' + a.Province,
       'DELIVERED',
       DATEADD(DAY, -70, GETDATE())
FROM Addresses a
WHERE a.CustomerID = 3 AND a.IsDefault = 1;

INSERT INTO OrderItems (OrderID, ProductID, Quantity, UnitPrice)
VALUES
(7, 2, 1, (SELECT Price FROM Products WHERE ProductID = 2)),
(7, 6, 1, (SELECT Price FROM Products WHERE ProductID = 6)),
(7, 12, 1, (SELECT Price FROM Products WHERE ProductID = 12));

INSERT INTO Payments (OrderID, PaymentMethod, TransactionID, Amount, PaymentStatus, ResponseCode, PaymentDate)
SELECT 7, 'BANK_TRANSFER', 'TXN_ORD7', TotalAmount, 'SUCCESS', '00', OrderDate
FROM Orders WHERE OrderID = 7;

INSERT INTO Shipments (OrderID, ShippingProvider, TrackingNumber, ShippingAddress, ShippingStatus, EstimatedDeliveryDate, ShippedAt, DeliveredAt)
SELECT 7, N'Viettel Post', 'TRK100007', ShippingAddress, 'DELIVERED',
       CAST(DATEADD(DAY, -(70 - 3), GETDATE()) AS DATE),
       DATEADD(HOUR, 4, OrderDate),
       DATEADD(DAY, 2, OrderDate)
FROM Orders WHERE OrderID = 7;
GO

-- Order 8 (Customer 3, 45 days ago)
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;

INSERT INTO Orders (CustomerID, TotalAmount, ShippingName, ShippingPhone, ShippingAddress, OrderStatus, OrderDate)
SELECT 3,
       (1 * (SELECT Price FROM Products WHERE ProductID = 18) + 1 * (SELECT Price FROM Products WHERE ProductID = 24) + 1 * (SELECT Price FROM Products WHERE ProductID = 28)),
       a.ReceiverName,
       a.ReceiverPhone,
       a.AddressLine + N', ' + a.Ward + N', ' + a.District + N', ' + a.Province,
       'DELIVERED',
       DATEADD(DAY, -45, GETDATE())
FROM Addresses a
WHERE a.CustomerID = 3 AND a.IsDefault = 1;

INSERT INTO OrderItems (OrderID, ProductID, Quantity, UnitPrice)
VALUES
(8, 18, 1, (SELECT Price FROM Products WHERE ProductID = 18)),
(8, 24, 1, (SELECT Price FROM Products WHERE ProductID = 24)),
(8, 28, 1, (SELECT Price FROM Products WHERE ProductID = 28));

INSERT INTO Payments (OrderID, PaymentMethod, TransactionID, Amount, PaymentStatus, ResponseCode, PaymentDate)
SELECT 8, 'COD', 'TXN_ORD8', TotalAmount, 'SUCCESS', '00', OrderDate
FROM Orders WHERE OrderID = 8;

INSERT INTO Shipments (OrderID, ShippingProvider, TrackingNumber, ShippingAddress, ShippingStatus, EstimatedDeliveryDate, ShippedAt, DeliveredAt)
SELECT 8, N'Shopee Xpress', 'TRK100008', ShippingAddress, 'DELIVERED',
       CAST(DATEADD(DAY, -(45 - 3), GETDATE()) AS DATE),
       DATEADD(HOUR, 4, OrderDate),
       DATEADD(DAY, 2, OrderDate)
FROM Orders WHERE OrderID = 8;
GO

-- Order 9 (Customer 3, 15 days ago)
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;

INSERT INTO Orders (CustomerID, TotalAmount, ShippingName, ShippingPhone, ShippingAddress, OrderStatus, OrderDate)
SELECT 3,
       (1 * (SELECT Price FROM Products WHERE ProductID = 30) + 1 * (SELECT Price FROM Products WHERE ProductID = 39) + 1 * (SELECT Price FROM Products WHERE ProductID = 44) + 1 * (SELECT Price FROM Products WHERE ProductID = 48)),
       a.ReceiverName,
       a.ReceiverPhone,
       a.AddressLine + N', ' + a.Ward + N', ' + a.District + N', ' + a.Province,
       'DELIVERED',
       DATEADD(DAY, -15, GETDATE())
FROM Addresses a
WHERE a.CustomerID = 3 AND a.IsDefault = 1;

INSERT INTO OrderItems (OrderID, ProductID, Quantity, UnitPrice)
VALUES
(9, 30, 1, (SELECT Price FROM Products WHERE ProductID = 30)),
(9, 39, 1, (SELECT Price FROM Products WHERE ProductID = 39)),
(9, 44, 1, (SELECT Price FROM Products WHERE ProductID = 44)),
(9, 48, 1, (SELECT Price FROM Products WHERE ProductID = 48));

INSERT INTO Payments (OrderID, PaymentMethod, TransactionID, Amount, PaymentStatus, ResponseCode, PaymentDate)
SELECT 9, 'VNPAY', 'TXN_ORD9', TotalAmount, 'SUCCESS', '00', OrderDate
FROM Orders WHERE OrderID = 9;

INSERT INTO Shipments (OrderID, ShippingProvider, TrackingNumber, ShippingAddress, ShippingStatus, EstimatedDeliveryDate, ShippedAt, DeliveredAt)
SELECT 9, N'Giao Hang Nhanh', 'TRK100009', ShippingAddress, 'DELIVERED',
       CAST(DATEADD(DAY, -(15 - 3), GETDATE()) AS DATE),
       DATEADD(HOUR, 4, OrderDate),
       DATEADD(DAY, 2, OrderDate)
FROM Orders WHERE OrderID = 9;
GO

-- Order 10 (Customer 4, 75 days ago)
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;

INSERT INTO Orders (CustomerID, TotalAmount, ShippingName, ShippingPhone, ShippingAddress, OrderStatus, OrderDate)
SELECT 4,
       (1 * (SELECT Price FROM Products WHERE ProductID = 1) + 1 * (SELECT Price FROM Products WHERE ProductID = 2) + 1 * (SELECT Price FROM Products WHERE ProductID = 6)),
       a.ReceiverName,
       a.ReceiverPhone,
       a.AddressLine + N', ' + a.Ward + N', ' + a.District + N', ' + a.Province,
       'DELIVERED',
       DATEADD(DAY, -75, GETDATE())
FROM Addresses a
WHERE a.CustomerID = 4 AND a.IsDefault = 1;

INSERT INTO OrderItems (OrderID, ProductID, Quantity, UnitPrice)
VALUES
(10, 1, 1, (SELECT Price FROM Products WHERE ProductID = 1)),
(10, 2, 1, (SELECT Price FROM Products WHERE ProductID = 2)),
(10, 6, 1, (SELECT Price FROM Products WHERE ProductID = 6));

INSERT INTO Payments (OrderID, PaymentMethod, TransactionID, Amount, PaymentStatus, ResponseCode, PaymentDate)
SELECT 10, 'BANK_TRANSFER', 'TXN_ORD10', TotalAmount, 'SUCCESS', '00', OrderDate
FROM Orders WHERE OrderID = 10;

INSERT INTO Shipments (OrderID, ShippingProvider, TrackingNumber, ShippingAddress, ShippingStatus, EstimatedDeliveryDate, ShippedAt, DeliveredAt)
SELECT 10, N'Viettel Post', 'TRK100010', ShippingAddress, 'DELIVERED',
       CAST(DATEADD(DAY, -(75 - 3), GETDATE()) AS DATE),
       DATEADD(HOUR, 4, OrderDate),
       DATEADD(DAY, 2, OrderDate)
FROM Orders WHERE OrderID = 10;
GO

-- Order 11 (Customer 4, 42 days ago)
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;

INSERT INTO Orders (CustomerID, TotalAmount, ShippingName, ShippingPhone, ShippingAddress, OrderStatus, OrderDate)
SELECT 4,
       (1 * (SELECT Price FROM Products WHERE ProductID = 9) + 1 * (SELECT Price FROM Products WHERE ProductID = 14)),
       a.ReceiverName,
       a.ReceiverPhone,
       a.AddressLine + N', ' + a.Ward + N', ' + a.District + N', ' + a.Province,
       'DELIVERED',
       DATEADD(DAY, -42, GETDATE())
FROM Addresses a
WHERE a.CustomerID = 4 AND a.IsDefault = 1;

INSERT INTO OrderItems (OrderID, ProductID, Quantity, UnitPrice)
VALUES
(11, 9, 1, (SELECT Price FROM Products WHERE ProductID = 9)),
(11, 14, 1, (SELECT Price FROM Products WHERE ProductID = 14));

INSERT INTO Payments (OrderID, PaymentMethod, TransactionID, Amount, PaymentStatus, ResponseCode, PaymentDate)
SELECT 11, 'COD', 'TXN_ORD11', TotalAmount, 'SUCCESS', '00', OrderDate
FROM Orders WHERE OrderID = 11;

INSERT INTO Shipments (OrderID, ShippingProvider, TrackingNumber, ShippingAddress, ShippingStatus, EstimatedDeliveryDate, ShippedAt, DeliveredAt)
SELECT 11, N'Shopee Xpress', 'TRK100011', ShippingAddress, 'DELIVERED',
       CAST(DATEADD(DAY, -(42 - 3), GETDATE()) AS DATE),
       DATEADD(HOUR, 4, OrderDate),
       DATEADD(DAY, 2, OrderDate)
FROM Orders WHERE OrderID = 11;
GO

-- Order 12 (Customer 4, 14 days ago)
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;

INSERT INTO Orders (CustomerID, TotalAmount, ShippingName, ShippingPhone, ShippingAddress, OrderStatus, OrderDate)
SELECT 4,
       (1 * (SELECT Price FROM Products WHERE ProductID = 22) + 1 * (SELECT Price FROM Products WHERE ProductID = 31) + 1 * (SELECT Price FROM Products WHERE ProductID = 40)),
       a.ReceiverName,
       a.ReceiverPhone,
       a.AddressLine + N', ' + a.Ward + N', ' + a.District + N', ' + a.Province,
       'DELIVERED',
       DATEADD(DAY, -14, GETDATE())
FROM Addresses a
WHERE a.CustomerID = 4 AND a.IsDefault = 1;

INSERT INTO OrderItems (OrderID, ProductID, Quantity, UnitPrice)
VALUES
(12, 22, 1, (SELECT Price FROM Products WHERE ProductID = 22)),
(12, 31, 1, (SELECT Price FROM Products WHERE ProductID = 31)),
(12, 40, 1, (SELECT Price FROM Products WHERE ProductID = 40));

INSERT INTO Payments (OrderID, PaymentMethod, TransactionID, Amount, PaymentStatus, ResponseCode, PaymentDate)
SELECT 12, 'VNPAY', 'TXN_ORD12', TotalAmount, 'SUCCESS', '00', OrderDate
FROM Orders WHERE OrderID = 12;

INSERT INTO Shipments (OrderID, ShippingProvider, TrackingNumber, ShippingAddress, ShippingStatus, EstimatedDeliveryDate, ShippedAt, DeliveredAt)
SELECT 12, N'Giao Hang Nhanh', 'TRK100012', ShippingAddress, 'DELIVERED',
       CAST(DATEADD(DAY, -(14 - 3), GETDATE()) AS DATE),
       DATEADD(HOUR, 4, OrderDate),
       DATEADD(DAY, 2, OrderDate)
FROM Orders WHERE OrderID = 12;
GO

-- Order 13 (Customer 5, 80 days ago)
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;

INSERT INTO Orders (CustomerID, TotalAmount, ShippingName, ShippingPhone, ShippingAddress, OrderStatus, OrderDate)
SELECT 5,
       (1 * (SELECT Price FROM Products WHERE ProductID = 3) + 1 * (SELECT Price FROM Products WHERE ProductID = 5) + 1 * (SELECT Price FROM Products WHERE ProductID = 10)),
       a.ReceiverName,
       a.ReceiverPhone,
       a.AddressLine + N', ' + a.Ward + N', ' + a.District + N', ' + a.Province,
       'DELIVERED',
       DATEADD(DAY, -80, GETDATE())
FROM Addresses a
WHERE a.CustomerID = 5 AND a.IsDefault = 1;

INSERT INTO OrderItems (OrderID, ProductID, Quantity, UnitPrice)
VALUES
(13, 3, 1, (SELECT Price FROM Products WHERE ProductID = 3)),
(13, 5, 1, (SELECT Price FROM Products WHERE ProductID = 5)),
(13, 10, 1, (SELECT Price FROM Products WHERE ProductID = 10));

INSERT INTO Payments (OrderID, PaymentMethod, TransactionID, Amount, PaymentStatus, ResponseCode, PaymentDate)
SELECT 13, 'BANK_TRANSFER', 'TXN_ORD13', TotalAmount, 'SUCCESS', '00', OrderDate
FROM Orders WHERE OrderID = 13;

INSERT INTO Shipments (OrderID, ShippingProvider, TrackingNumber, ShippingAddress, ShippingStatus, EstimatedDeliveryDate, ShippedAt, DeliveredAt)
SELECT 13, N'Viettel Post', 'TRK100013', ShippingAddress, 'DELIVERED',
       CAST(DATEADD(DAY, -(80 - 3), GETDATE()) AS DATE),
       DATEADD(HOUR, 4, OrderDate),
       DATEADD(DAY, 2, OrderDate)
FROM Orders WHERE OrderID = 13;
GO

-- Order 14 (Customer 5, 50 days ago)
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;

INSERT INTO Orders (CustomerID, TotalAmount, ShippingName, ShippingPhone, ShippingAddress, OrderStatus, OrderDate)
SELECT 5,
       (1 * (SELECT Price FROM Products WHERE ProductID = 15) + 1 * (SELECT Price FROM Products WHERE ProductID = 23) + 1 * (SELECT Price FROM Products WHERE ProductID = 32)),
       a.ReceiverName,
       a.ReceiverPhone,
       a.AddressLine + N', ' + a.Ward + N', ' + a.District + N', ' + a.Province,
       'DELIVERED',
       DATEADD(DAY, -50, GETDATE())
FROM Addresses a
WHERE a.CustomerID = 5 AND a.IsDefault = 1;

INSERT INTO OrderItems (OrderID, ProductID, Quantity, UnitPrice)
VALUES
(14, 15, 1, (SELECT Price FROM Products WHERE ProductID = 15)),
(14, 23, 1, (SELECT Price FROM Products WHERE ProductID = 23)),
(14, 32, 1, (SELECT Price FROM Products WHERE ProductID = 32));

INSERT INTO Payments (OrderID, PaymentMethod, TransactionID, Amount, PaymentStatus, ResponseCode, PaymentDate)
SELECT 14, 'COD', 'TXN_ORD14', TotalAmount, 'SUCCESS', '00', OrderDate
FROM Orders WHERE OrderID = 14;

INSERT INTO Shipments (OrderID, ShippingProvider, TrackingNumber, ShippingAddress, ShippingStatus, EstimatedDeliveryDate, ShippedAt, DeliveredAt)
SELECT 14, N'Shopee Xpress', 'TRK100014', ShippingAddress, 'DELIVERED',
       CAST(DATEADD(DAY, -(50 - 3), GETDATE()) AS DATE),
       DATEADD(HOUR, 4, OrderDate),
       DATEADD(DAY, 2, OrderDate)
FROM Orders WHERE OrderID = 14;
GO

-- Order 15 (Customer 5, 18 days ago)
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;

INSERT INTO Orders (CustomerID, TotalAmount, ShippingName, ShippingPhone, ShippingAddress, OrderStatus, OrderDate)
SELECT 5,
       (1 * (SELECT Price FROM Products WHERE ProductID = 36) + 1 * (SELECT Price FROM Products WHERE ProductID = 41) + 1 * (SELECT Price FROM Products WHERE ProductID = 47)),
       a.ReceiverName,
       a.ReceiverPhone,
       a.AddressLine + N', ' + a.Ward + N', ' + a.District + N', ' + a.Province,
       'DELIVERED',
       DATEADD(DAY, -18, GETDATE())
FROM Addresses a
WHERE a.CustomerID = 5 AND a.IsDefault = 1;

INSERT INTO OrderItems (OrderID, ProductID, Quantity, UnitPrice)
VALUES
(15, 36, 1, (SELECT Price FROM Products WHERE ProductID = 36)),
(15, 41, 1, (SELECT Price FROM Products WHERE ProductID = 41)),
(15, 47, 1, (SELECT Price FROM Products WHERE ProductID = 47));

INSERT INTO Payments (OrderID, PaymentMethod, TransactionID, Amount, PaymentStatus, ResponseCode, PaymentDate)
SELECT 15, 'VNPAY', 'TXN_ORD15', TotalAmount, 'SUCCESS', '00', OrderDate
FROM Orders WHERE OrderID = 15;

INSERT INTO Shipments (OrderID, ShippingProvider, TrackingNumber, ShippingAddress, ShippingStatus, EstimatedDeliveryDate, ShippedAt, DeliveredAt)
SELECT 15, N'Giao Hang Nhanh', 'TRK100015', ShippingAddress, 'DELIVERED',
       CAST(DATEADD(DAY, -(18 - 3), GETDATE()) AS DATE),
       DATEADD(HOUR, 4, OrderDate),
       DATEADD(DAY, 2, OrderDate)
FROM Orders WHERE OrderID = 15;
GO

-- Order 16 (Customer 6, 85 days ago)
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;

INSERT INTO Orders (CustomerID, TotalAmount, ShippingName, ShippingPhone, ShippingAddress, OrderStatus, OrderDate)
SELECT 6,
       (1 * (SELECT Price FROM Products WHERE ProductID = 4) + 1 * (SELECT Price FROM Products WHERE ProductID = 8) + 1 * (SELECT Price FROM Products WHERE ProductID = 11)),
       a.ReceiverName,
       a.ReceiverPhone,
       a.AddressLine + N', ' + a.Ward + N', ' + a.District + N', ' + a.Province,
       'DELIVERED',
       DATEADD(DAY, -85, GETDATE())
FROM Addresses a
WHERE a.CustomerID = 6 AND a.IsDefault = 1;

INSERT INTO OrderItems (OrderID, ProductID, Quantity, UnitPrice)
VALUES
(16, 4, 1, (SELECT Price FROM Products WHERE ProductID = 4)),
(16, 8, 1, (SELECT Price FROM Products WHERE ProductID = 8)),
(16, 11, 1, (SELECT Price FROM Products WHERE ProductID = 11));

INSERT INTO Payments (OrderID, PaymentMethod, TransactionID, Amount, PaymentStatus, ResponseCode, PaymentDate)
SELECT 16, 'BANK_TRANSFER', 'TXN_ORD16', TotalAmount, 'SUCCESS', '00', OrderDate
FROM Orders WHERE OrderID = 16;

INSERT INTO Shipments (OrderID, ShippingProvider, TrackingNumber, ShippingAddress, ShippingStatus, EstimatedDeliveryDate, ShippedAt, DeliveredAt)
SELECT 16, N'Viettel Post', 'TRK100016', ShippingAddress, 'DELIVERED',
       CAST(DATEADD(DAY, -(85 - 3), GETDATE()) AS DATE),
       DATEADD(HOUR, 4, OrderDate),
       DATEADD(DAY, 2, OrderDate)
FROM Orders WHERE OrderID = 16;
GO

-- Order 17 (Customer 6, 52 days ago)
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;

INSERT INTO Orders (CustomerID, TotalAmount, ShippingName, ShippingPhone, ShippingAddress, OrderStatus, OrderDate)
SELECT 6,
       (1 * (SELECT Price FROM Products WHERE ProductID = 17) + 1 * (SELECT Price FROM Products WHERE ProductID = 25)),
       a.ReceiverName,
       a.ReceiverPhone,
       a.AddressLine + N', ' + a.Ward + N', ' + a.District + N', ' + a.Province,
       'DELIVERED',
       DATEADD(DAY, -52, GETDATE())
FROM Addresses a
WHERE a.CustomerID = 6 AND a.IsDefault = 1;

INSERT INTO OrderItems (OrderID, ProductID, Quantity, UnitPrice)
VALUES
(17, 17, 1, (SELECT Price FROM Products WHERE ProductID = 17)),
(17, 25, 1, (SELECT Price FROM Products WHERE ProductID = 25));

INSERT INTO Payments (OrderID, PaymentMethod, TransactionID, Amount, PaymentStatus, ResponseCode, PaymentDate)
SELECT 17, 'COD', 'TXN_ORD17', TotalAmount, 'SUCCESS', '00', OrderDate
FROM Orders WHERE OrderID = 17;

INSERT INTO Shipments (OrderID, ShippingProvider, TrackingNumber, ShippingAddress, ShippingStatus, EstimatedDeliveryDate, ShippedAt, DeliveredAt)
SELECT 17, N'Shopee Xpress', 'TRK100017', ShippingAddress, 'DELIVERED',
       CAST(DATEADD(DAY, -(52 - 3), GETDATE()) AS DATE),
       DATEADD(HOUR, 4, OrderDate),
       DATEADD(DAY, 2, OrderDate)
FROM Orders WHERE OrderID = 17;
GO

-- Order 18 (Customer 6, 20 days ago)
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;

INSERT INTO Orders (CustomerID, TotalAmount, ShippingName, ShippingPhone, ShippingAddress, OrderStatus, OrderDate)
SELECT 6,
       (1 * (SELECT Price FROM Products WHERE ProductID = 33) + 1 * (SELECT Price FROM Products WHERE ProductID = 42) + 1 * (SELECT Price FROM Products WHERE ProductID = 49)),
       a.ReceiverName,
       a.ReceiverPhone,
       a.AddressLine + N', ' + a.Ward + N', ' + a.District + N', ' + a.Province,
       'DELIVERED',
       DATEADD(DAY, -20, GETDATE())
FROM Addresses a
WHERE a.CustomerID = 6 AND a.IsDefault = 1;

INSERT INTO OrderItems (OrderID, ProductID, Quantity, UnitPrice)
VALUES
(18, 33, 1, (SELECT Price FROM Products WHERE ProductID = 33)),
(18, 42, 1, (SELECT Price FROM Products WHERE ProductID = 42)),
(18, 49, 1, (SELECT Price FROM Products WHERE ProductID = 49));

INSERT INTO Payments (OrderID, PaymentMethod, TransactionID, Amount, PaymentStatus, ResponseCode, PaymentDate)
SELECT 18, 'VNPAY', 'TXN_ORD18', TotalAmount, 'SUCCESS', '00', OrderDate
FROM Orders WHERE OrderID = 18;

INSERT INTO Shipments (OrderID, ShippingProvider, TrackingNumber, ShippingAddress, ShippingStatus, EstimatedDeliveryDate, ShippedAt, DeliveredAt)
SELECT 18, N'Giao Hang Nhanh', 'TRK100018', ShippingAddress, 'DELIVERED',
       CAST(DATEADD(DAY, -(20 - 3), GETDATE()) AS DATE),
       DATEADD(HOUR, 4, OrderDate),
       DATEADD(DAY, 2, OrderDate)
FROM Orders WHERE OrderID = 18;
GO

-- Order 19 (Customer 7, 68 days ago)
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;

INSERT INTO Orders (CustomerID, TotalAmount, ShippingName, ShippingPhone, ShippingAddress, OrderStatus, OrderDate)
SELECT 7,
       (1 * (SELECT Price FROM Products WHERE ProductID = 5) + 1 * (SELECT Price FROM Products WHERE ProductID = 7) + 1 * (SELECT Price FROM Products WHERE ProductID = 13)),
       a.ReceiverName,
       a.ReceiverPhone,
       a.AddressLine + N', ' + a.Ward + N', ' + a.District + N', ' + a.Province,
       'DELIVERED',
       DATEADD(DAY, -68, GETDATE())
FROM Addresses a
WHERE a.CustomerID = 7 AND a.IsDefault = 1;

INSERT INTO OrderItems (OrderID, ProductID, Quantity, UnitPrice)
VALUES
(19, 5, 1, (SELECT Price FROM Products WHERE ProductID = 5)),
(19, 7, 1, (SELECT Price FROM Products WHERE ProductID = 7)),
(19, 13, 1, (SELECT Price FROM Products WHERE ProductID = 13));

INSERT INTO Payments (OrderID, PaymentMethod, TransactionID, Amount, PaymentStatus, ResponseCode, PaymentDate)
SELECT 19, 'BANK_TRANSFER', 'TXN_ORD19', TotalAmount, 'SUCCESS', '00', OrderDate
FROM Orders WHERE OrderID = 19;

INSERT INTO Shipments (OrderID, ShippingProvider, TrackingNumber, ShippingAddress, ShippingStatus, EstimatedDeliveryDate, ShippedAt, DeliveredAt)
SELECT 19, N'Viettel Post', 'TRK100019', ShippingAddress, 'DELIVERED',
       CAST(DATEADD(DAY, -(68 - 3), GETDATE()) AS DATE),
       DATEADD(HOUR, 4, OrderDate),
       DATEADD(DAY, 2, OrderDate)
FROM Orders WHERE OrderID = 19;
GO

-- Order 20 (Customer 7, 38 days ago)
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;

INSERT INTO Orders (CustomerID, TotalAmount, ShippingName, ShippingPhone, ShippingAddress, OrderStatus, OrderDate)
SELECT 7,
       (1 * (SELECT Price FROM Products WHERE ProductID = 19) + 1 * (SELECT Price FROM Products WHERE ProductID = 26) + 1 * (SELECT Price FROM Products WHERE ProductID = 34)),
       a.ReceiverName,
       a.ReceiverPhone,
       a.AddressLine + N', ' + a.Ward + N', ' + a.District + N', ' + a.Province,
       'DELIVERED',
       DATEADD(DAY, -38, GETDATE())
FROM Addresses a
WHERE a.CustomerID = 7 AND a.IsDefault = 1;

INSERT INTO OrderItems (OrderID, ProductID, Quantity, UnitPrice)
VALUES
(20, 19, 1, (SELECT Price FROM Products WHERE ProductID = 19)),
(20, 26, 1, (SELECT Price FROM Products WHERE ProductID = 26)),
(20, 34, 1, (SELECT Price FROM Products WHERE ProductID = 34));

INSERT INTO Payments (OrderID, PaymentMethod, TransactionID, Amount, PaymentStatus, ResponseCode, PaymentDate)
SELECT 20, 'COD', 'TXN_ORD20', TotalAmount, 'SUCCESS', '00', OrderDate
FROM Orders WHERE OrderID = 20;

INSERT INTO Shipments (OrderID, ShippingProvider, TrackingNumber, ShippingAddress, ShippingStatus, EstimatedDeliveryDate, ShippedAt, DeliveredAt)
SELECT 20, N'Shopee Xpress', 'TRK100020', ShippingAddress, 'DELIVERED',
       CAST(DATEADD(DAY, -(38 - 3), GETDATE()) AS DATE),
       DATEADD(HOUR, 4, OrderDate),
       DATEADD(DAY, 2, OrderDate)
FROM Orders WHERE OrderID = 20;
GO

-- Order 21 (Customer 7, 16 days ago)
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;

INSERT INTO Orders (CustomerID, TotalAmount, ShippingName, ShippingPhone, ShippingAddress, OrderStatus, OrderDate)
SELECT 7,
       (1 * (SELECT Price FROM Products WHERE ProductID = 37) + 1 * (SELECT Price FROM Products WHERE ProductID = 43) + 1 * (SELECT Price FROM Products WHERE ProductID = 50)),
       a.ReceiverName,
       a.ReceiverPhone,
       a.AddressLine + N', ' + a.Ward + N', ' + a.District + N', ' + a.Province,
       'DELIVERED',
       DATEADD(DAY, -16, GETDATE())
FROM Addresses a
WHERE a.CustomerID = 7 AND a.IsDefault = 1;

INSERT INTO OrderItems (OrderID, ProductID, Quantity, UnitPrice)
VALUES
(21, 37, 1, (SELECT Price FROM Products WHERE ProductID = 37)),
(21, 43, 1, (SELECT Price FROM Products WHERE ProductID = 43)),
(21, 50, 1, (SELECT Price FROM Products WHERE ProductID = 50));

INSERT INTO Payments (OrderID, PaymentMethod, TransactionID, Amount, PaymentStatus, ResponseCode, PaymentDate)
SELECT 21, 'VNPAY', 'TXN_ORD21', TotalAmount, 'SUCCESS', '00', OrderDate
FROM Orders WHERE OrderID = 21;

INSERT INTO Shipments (OrderID, ShippingProvider, TrackingNumber, ShippingAddress, ShippingStatus, EstimatedDeliveryDate, ShippedAt, DeliveredAt)
SELECT 21, N'Giao Hang Nhanh', 'TRK100021', ShippingAddress, 'DELIVERED',
       CAST(DATEADD(DAY, -(16 - 3), GETDATE()) AS DATE),
       DATEADD(HOUR, 4, OrderDate),
       DATEADD(DAY, 2, OrderDate)
FROM Orders WHERE OrderID = 21;
GO

-- Order 22 (Customer 8, 72 days ago)
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;

INSERT INTO Orders (CustomerID, TotalAmount, ShippingName, ShippingPhone, ShippingAddress, OrderStatus, OrderDate)
SELECT 8,
       (1 * (SELECT Price FROM Products WHERE ProductID = 2) + 1 * (SELECT Price FROM Products WHERE ProductID = 6) + 1 * (SELECT Price FROM Products WHERE ProductID = 10)),
       a.ReceiverName,
       a.ReceiverPhone,
       a.AddressLine + N', ' + a.Ward + N', ' + a.District + N', ' + a.Province,
       'DELIVERED',
       DATEADD(DAY, -72, GETDATE())
FROM Addresses a
WHERE a.CustomerID = 8 AND a.IsDefault = 1;

INSERT INTO OrderItems (OrderID, ProductID, Quantity, UnitPrice)
VALUES
(22, 2, 1, (SELECT Price FROM Products WHERE ProductID = 2)),
(22, 6, 1, (SELECT Price FROM Products WHERE ProductID = 6)),
(22, 10, 1, (SELECT Price FROM Products WHERE ProductID = 10));

INSERT INTO Payments (OrderID, PaymentMethod, TransactionID, Amount, PaymentStatus, ResponseCode, PaymentDate)
SELECT 22, 'BANK_TRANSFER', 'TXN_ORD22', TotalAmount, 'SUCCESS', '00', OrderDate
FROM Orders WHERE OrderID = 22;

INSERT INTO Shipments (OrderID, ShippingProvider, TrackingNumber, ShippingAddress, ShippingStatus, EstimatedDeliveryDate, ShippedAt, DeliveredAt)
SELECT 22, N'Viettel Post', 'TRK100022', ShippingAddress, 'DELIVERED',
       CAST(DATEADD(DAY, -(72 - 3), GETDATE()) AS DATE),
       DATEADD(HOUR, 4, OrderDate),
       DATEADD(DAY, 2, OrderDate)
FROM Orders WHERE OrderID = 22;
GO

-- Order 23 (Customer 8, 44 days ago)
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;

INSERT INTO Orders (CustomerID, TotalAmount, ShippingName, ShippingPhone, ShippingAddress, OrderStatus, OrderDate)
SELECT 8,
       (1 * (SELECT Price FROM Products WHERE ProductID = 16) + 1 * (SELECT Price FROM Products WHERE ProductID = 20) + 1 * (SELECT Price FROM Products WHERE ProductID = 28)),
       a.ReceiverName,
       a.ReceiverPhone,
       a.AddressLine + N', ' + a.Ward + N', ' + a.District + N', ' + a.Province,
       'DELIVERED',
       DATEADD(DAY, -44, GETDATE())
FROM Addresses a
WHERE a.CustomerID = 8 AND a.IsDefault = 1;

INSERT INTO OrderItems (OrderID, ProductID, Quantity, UnitPrice)
VALUES
(23, 16, 1, (SELECT Price FROM Products WHERE ProductID = 16)),
(23, 20, 1, (SELECT Price FROM Products WHERE ProductID = 20)),
(23, 28, 1, (SELECT Price FROM Products WHERE ProductID = 28));

INSERT INTO Payments (OrderID, PaymentMethod, TransactionID, Amount, PaymentStatus, ResponseCode, PaymentDate)
SELECT 23, 'COD', 'TXN_ORD23', TotalAmount, 'SUCCESS', '00', OrderDate
FROM Orders WHERE OrderID = 23;

INSERT INTO Shipments (OrderID, ShippingProvider, TrackingNumber, ShippingAddress, ShippingStatus, EstimatedDeliveryDate, ShippedAt, DeliveredAt)
SELECT 23, N'Shopee Xpress', 'TRK100023', ShippingAddress, 'DELIVERED',
       CAST(DATEADD(DAY, -(44 - 3), GETDATE()) AS DATE),
       DATEADD(HOUR, 4, OrderDate),
       DATEADD(DAY, 2, OrderDate)
FROM Orders WHERE OrderID = 23;
GO

-- Order 24 (Customer 8, 11 days ago)
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;

INSERT INTO Orders (CustomerID, TotalAmount, ShippingName, ShippingPhone, ShippingAddress, OrderStatus, OrderDate)
SELECT 8,
       (1 * (SELECT Price FROM Products WHERE ProductID = 32) + 1 * (SELECT Price FROM Products WHERE ProductID = 38) + 1 * (SELECT Price FROM Products WHERE ProductID = 45) + 1 * (SELECT Price FROM Products WHERE ProductID = 48)),
       a.ReceiverName,
       a.ReceiverPhone,
       a.AddressLine + N', ' + a.Ward + N', ' + a.District + N', ' + a.Province,
       'DELIVERED',
       DATEADD(DAY, -11, GETDATE())
FROM Addresses a
WHERE a.CustomerID = 8 AND a.IsDefault = 1;

INSERT INTO OrderItems (OrderID, ProductID, Quantity, UnitPrice)
VALUES
(24, 32, 1, (SELECT Price FROM Products WHERE ProductID = 32)),
(24, 38, 1, (SELECT Price FROM Products WHERE ProductID = 38)),
(24, 45, 1, (SELECT Price FROM Products WHERE ProductID = 45)),
(24, 48, 1, (SELECT Price FROM Products WHERE ProductID = 48));

INSERT INTO Payments (OrderID, PaymentMethod, TransactionID, Amount, PaymentStatus, ResponseCode, PaymentDate)
SELECT 24, 'VNPAY', 'TXN_ORD24', TotalAmount, 'SUCCESS', '00', OrderDate
FROM Orders WHERE OrderID = 24;

INSERT INTO Shipments (OrderID, ShippingProvider, TrackingNumber, ShippingAddress, ShippingStatus, EstimatedDeliveryDate, ShippedAt, DeliveredAt)
SELECT 24, N'Giao Hang Nhanh', 'TRK100024', ShippingAddress, 'DELIVERED',
       CAST(DATEADD(DAY, -(11 - 3), GETDATE()) AS DATE),
       DATEADD(HOUR, 4, OrderDate),
       DATEADD(DAY, 2, OrderDate)
FROM Orders WHERE OrderID = 24;
GO

-- Order 25 (Customer 9, 78 days ago)
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;

INSERT INTO Orders (CustomerID, TotalAmount, ShippingName, ShippingPhone, ShippingAddress, OrderStatus, OrderDate)
SELECT 9,
       (1 * (SELECT Price FROM Products WHERE ProductID = 3) + 1 * (SELECT Price FROM Products WHERE ProductID = 8) + 1 * (SELECT Price FROM Products WHERE ProductID = 13)),
       a.ReceiverName,
       a.ReceiverPhone,
       a.AddressLine + N', ' + a.Ward + N', ' + a.District + N', ' + a.Province,
       'DELIVERED',
       DATEADD(DAY, -78, GETDATE())
FROM Addresses a
WHERE a.CustomerID = 9 AND a.IsDefault = 1;

INSERT INTO OrderItems (OrderID, ProductID, Quantity, UnitPrice)
VALUES
(25, 3, 1, (SELECT Price FROM Products WHERE ProductID = 3)),
(25, 8, 1, (SELECT Price FROM Products WHERE ProductID = 8)),
(25, 13, 1, (SELECT Price FROM Products WHERE ProductID = 13));

INSERT INTO Payments (OrderID, PaymentMethod, TransactionID, Amount, PaymentStatus, ResponseCode, PaymentDate)
SELECT 25, 'BANK_TRANSFER', 'TXN_ORD25', TotalAmount, 'SUCCESS', '00', OrderDate
FROM Orders WHERE OrderID = 25;

INSERT INTO Shipments (OrderID, ShippingProvider, TrackingNumber, ShippingAddress, ShippingStatus, EstimatedDeliveryDate, ShippedAt, DeliveredAt)
SELECT 25, N'Viettel Post', 'TRK100025', ShippingAddress, 'DELIVERED',
       CAST(DATEADD(DAY, -(78 - 3), GETDATE()) AS DATE),
       DATEADD(HOUR, 4, OrderDate),
       DATEADD(DAY, 2, OrderDate)
FROM Orders WHERE OrderID = 25;
GO

-- Order 26 (Customer 9, 48 days ago)
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;

INSERT INTO Orders (CustomerID, TotalAmount, ShippingName, ShippingPhone, ShippingAddress, OrderStatus, OrderDate)
SELECT 9,
       (1 * (SELECT Price FROM Products WHERE ProductID = 18) + 1 * (SELECT Price FROM Products WHERE ProductID = 21)),
       a.ReceiverName,
       a.ReceiverPhone,
       a.AddressLine + N', ' + a.Ward + N', ' + a.District + N', ' + a.Province,
       'DELIVERED',
       DATEADD(DAY, -48, GETDATE())
FROM Addresses a
WHERE a.CustomerID = 9 AND a.IsDefault = 1;

INSERT INTO OrderItems (OrderID, ProductID, Quantity, UnitPrice)
VALUES
(26, 18, 1, (SELECT Price FROM Products WHERE ProductID = 18)),
(26, 21, 1, (SELECT Price FROM Products WHERE ProductID = 21));

INSERT INTO Payments (OrderID, PaymentMethod, TransactionID, Amount, PaymentStatus, ResponseCode, PaymentDate)
SELECT 26, 'COD', 'TXN_ORD26', TotalAmount, 'SUCCESS', '00', OrderDate
FROM Orders WHERE OrderID = 26;

INSERT INTO Shipments (OrderID, ShippingProvider, TrackingNumber, ShippingAddress, ShippingStatus, EstimatedDeliveryDate, ShippedAt, DeliveredAt)
SELECT 26, N'Shopee Xpress', 'TRK100026', ShippingAddress, 'DELIVERED',
       CAST(DATEADD(DAY, -(48 - 3), GETDATE()) AS DATE),
       DATEADD(HOUR, 4, OrderDate),
       DATEADD(DAY, 2, OrderDate)
FROM Orders WHERE OrderID = 26;
GO

-- Order 27 (Customer 9, 13 days ago)
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;

INSERT INTO Orders (CustomerID, TotalAmount, ShippingName, ShippingPhone, ShippingAddress, OrderStatus, OrderDate)
SELECT 9,
       (1 * (SELECT Price FROM Products WHERE ProductID = 27) + 1 * (SELECT Price FROM Products WHERE ProductID = 35) + 1 * (SELECT Price FROM Products WHERE ProductID = 46)),
       a.ReceiverName,
       a.ReceiverPhone,
       a.AddressLine + N', ' + a.Ward + N', ' + a.District + N', ' + a.Province,
       'DELIVERED',
       DATEADD(DAY, -13, GETDATE())
FROM Addresses a
WHERE a.CustomerID = 9 AND a.IsDefault = 1;

INSERT INTO OrderItems (OrderID, ProductID, Quantity, UnitPrice)
VALUES
(27, 27, 1, (SELECT Price FROM Products WHERE ProductID = 27)),
(27, 35, 1, (SELECT Price FROM Products WHERE ProductID = 35)),
(27, 46, 1, (SELECT Price FROM Products WHERE ProductID = 46));

INSERT INTO Payments (OrderID, PaymentMethod, TransactionID, Amount, PaymentStatus, ResponseCode, PaymentDate)
SELECT 27, 'VNPAY', 'TXN_ORD27', TotalAmount, 'SUCCESS', '00', OrderDate
FROM Orders WHERE OrderID = 27;

INSERT INTO Shipments (OrderID, ShippingProvider, TrackingNumber, ShippingAddress, ShippingStatus, EstimatedDeliveryDate, ShippedAt, DeliveredAt)
SELECT 27, N'Giao Hang Nhanh', 'TRK100027', ShippingAddress, 'DELIVERED',
       CAST(DATEADD(DAY, -(13 - 3), GETDATE()) AS DATE),
       DATEADD(HOUR, 4, OrderDate),
       DATEADD(DAY, 2, OrderDate)
FROM Orders WHERE OrderID = 27;
GO

-- Order 28 (Customer 10, 66 days ago)
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;

INSERT INTO Orders (CustomerID, TotalAmount, ShippingName, ShippingPhone, ShippingAddress, OrderStatus, OrderDate)
SELECT 10,
       (1 * (SELECT Price FROM Products WHERE ProductID = 1) + 1 * (SELECT Price FROM Products WHERE ProductID = 9) + 1 * (SELECT Price FROM Products WHERE ProductID = 14)),
       a.ReceiverName,
       a.ReceiverPhone,
       a.AddressLine + N', ' + a.Ward + N', ' + a.District + N', ' + a.Province,
       'DELIVERED',
       DATEADD(DAY, -66, GETDATE())
FROM Addresses a
WHERE a.CustomerID = 10 AND a.IsDefault = 1;

INSERT INTO OrderItems (OrderID, ProductID, Quantity, UnitPrice)
VALUES
(28, 1, 1, (SELECT Price FROM Products WHERE ProductID = 1)),
(28, 9, 1, (SELECT Price FROM Products WHERE ProductID = 9)),
(28, 14, 1, (SELECT Price FROM Products WHERE ProductID = 14));

INSERT INTO Payments (OrderID, PaymentMethod, TransactionID, Amount, PaymentStatus, ResponseCode, PaymentDate)
SELECT 28, 'BANK_TRANSFER', 'TXN_ORD28', TotalAmount, 'SUCCESS', '00', OrderDate
FROM Orders WHERE OrderID = 28;

INSERT INTO Shipments (OrderID, ShippingProvider, TrackingNumber, ShippingAddress, ShippingStatus, EstimatedDeliveryDate, ShippedAt, DeliveredAt)
SELECT 28, N'Viettel Post', 'TRK100028', ShippingAddress, 'DELIVERED',
       CAST(DATEADD(DAY, -(66 - 3), GETDATE()) AS DATE),
       DATEADD(HOUR, 4, OrderDate),
       DATEADD(DAY, 2, OrderDate)
FROM Orders WHERE OrderID = 28;
GO

-- Order 29 (Customer 10, 36 days ago)
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;

INSERT INTO Orders (CustomerID, TotalAmount, ShippingName, ShippingPhone, ShippingAddress, OrderStatus, OrderDate)
SELECT 10,
       (1 * (SELECT Price FROM Products WHERE ProductID = 20) + 1 * (SELECT Price FROM Products WHERE ProductID = 25) + 1 * (SELECT Price FROM Products WHERE ProductID = 30)),
       a.ReceiverName,
       a.ReceiverPhone,
       a.AddressLine + N', ' + a.Ward + N', ' + a.District + N', ' + a.Province,
       'DELIVERED',
       DATEADD(DAY, -36, GETDATE())
FROM Addresses a
WHERE a.CustomerID = 10 AND a.IsDefault = 1;

INSERT INTO OrderItems (OrderID, ProductID, Quantity, UnitPrice)
VALUES
(29, 20, 1, (SELECT Price FROM Products WHERE ProductID = 20)),
(29, 25, 1, (SELECT Price FROM Products WHERE ProductID = 25)),
(29, 30, 1, (SELECT Price FROM Products WHERE ProductID = 30));

INSERT INTO Payments (OrderID, PaymentMethod, TransactionID, Amount, PaymentStatus, ResponseCode, PaymentDate)
SELECT 29, 'COD', 'TXN_ORD29', TotalAmount, 'SUCCESS', '00', OrderDate
FROM Orders WHERE OrderID = 29;

INSERT INTO Shipments (OrderID, ShippingProvider, TrackingNumber, ShippingAddress, ShippingStatus, EstimatedDeliveryDate, ShippedAt, DeliveredAt)
SELECT 29, N'Shopee Xpress', 'TRK100029', ShippingAddress, 'DELIVERED',
       CAST(DATEADD(DAY, -(36 - 3), GETDATE()) AS DATE),
       DATEADD(HOUR, 4, OrderDate),
       DATEADD(DAY, 2, OrderDate)
FROM Orders WHERE OrderID = 29;
GO

-- Order 30 (Customer 10, 9 days ago)
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;

INSERT INTO Orders (CustomerID, TotalAmount, ShippingName, ShippingPhone, ShippingAddress, OrderStatus, OrderDate)
SELECT 10,
       (1 * (SELECT Price FROM Products WHERE ProductID = 36) + 1 * (SELECT Price FROM Products WHERE ProductID = 41) + 1 * (SELECT Price FROM Products WHERE ProductID = 47)),
       a.ReceiverName,
       a.ReceiverPhone,
       a.AddressLine + N', ' + a.Ward + N', ' + a.District + N', ' + a.Province,
       'DELIVERED',
       DATEADD(DAY, -9, GETDATE())
FROM Addresses a
WHERE a.CustomerID = 10 AND a.IsDefault = 1;

INSERT INTO OrderItems (OrderID, ProductID, Quantity, UnitPrice)
VALUES
(30, 36, 1, (SELECT Price FROM Products WHERE ProductID = 36)),
(30, 41, 1, (SELECT Price FROM Products WHERE ProductID = 41)),
(30, 47, 1, (SELECT Price FROM Products WHERE ProductID = 47));

INSERT INTO Payments (OrderID, PaymentMethod, TransactionID, Amount, PaymentStatus, ResponseCode, PaymentDate)
SELECT 30, 'VNPAY', 'TXN_ORD30', TotalAmount, 'SUCCESS', '00', OrderDate
FROM Orders WHERE OrderID = 30;

INSERT INTO Shipments (OrderID, ShippingProvider, TrackingNumber, ShippingAddress, ShippingStatus, EstimatedDeliveryDate, ShippedAt, DeliveredAt)
SELECT 30, N'Giao Hang Nhanh', 'TRK100030', ShippingAddress, 'DELIVERED',
       CAST(DATEADD(DAY, -(9 - 3), GETDATE()) AS DATE),
       DATEADD(HOUR, 4, OrderDate),
       DATEADD(DAY, 2, OrderDate)
FROM Orders WHERE OrderID = 30;
GO

-- =========================================================
-- REVIEWS (Strictly from customers who purchased the products)
-- =========================================================
INSERT INTO Reviews (CustomerID, ProductID, Rating, Comment, Status, CreatedAt)
VALUES
(1, 1, 5, N'Wearing Comfort: Soft ear cushions, lightweight headband, comfortable for 8+ hour flights.\nMicrophone Quality: Superb noise filtering during conference calls.\nSound Quality: Crisp highs, detailed mids, and powerful deep bass.\nBest noise cancelling headphones I have ever owned. Absolutely worth every penny for frequent travelers.', 'VISIBLE', DATEADD(DAY, -55, GETDATE())),
(2, 1, 5, N'Wearing Comfort: Extremely comfortable and does not squeeze my glasses.\nMicrophone Quality: Crystal clear voice pickup in noisy cafes.\nSound Quality: Balanced studio-like signature with punchy low end.\nBattery life is mindblowing, lasting nearly a full week of daily commute!', 'VISIBLE', DATEADD(DAY, -38, GETDATE())),
(4, 1, 4, N'Wearing Comfort: Very plush pads and lightweight design.\nMicrophone Quality: Good clarity for voice calls and meetings.\nSound Quality: Detailed treble and wide soundstage.\nOutstanding ANC performance, though the carrying case is slightly bulky.', 'VISIBLE', DATEADD(DAY, -30, GETDATE())),
(10, 1, 5, N'Wearing Comfort: Premium feel, no pressure points on crown.\nMicrophone Quality: Multi-mic array works like magic for remote work.\nSound Quality: Immersive sound with deep punchy bass.\nSony continues to lead the ANC market. Highly recommended!', 'VISIBLE', DATEADD(DAY, -25, GETDATE())),
(3, 2, 5, N'Wearing Comfort: Classic foldable design, folds into a compact case.\nMicrophone Quality: Clear voice during calls.\nSound Quality: Warm and pleasant sound with punchy sub-bass.\nStill one of the best value ANC over-ear headphones on the market.', 'VISIBLE', DATEADD(DAY, -62, GETDATE())),
(4, 2, 4, N'Wearing Comfort: Very comfortable for extended listening sessions.\nMicrophone Quality: Decent mic for daily calls.\nSound Quality: Strong bass response, excellent for hip-hop and pop.\nANC is solid and physical buttons are easy to operate.', 'VISIBLE', DATEADD(DAY, -40, GETDATE())),
(8, 2, 5, N'Wearing Comfort: Plush headband and ear cups fit snugly.\nMicrophone Quality: Clear voice capture without distortion.\nSound Quality: Rich acoustics with LDAC codec support.\nLove the multi-point connection between laptop and phone.', 'VISIBLE', DATEADD(DAY, -35, GETDATE())),
(2, 3, 4, N'Wearing Comfort: Featherlight design, can wear all day without fatigue.\nMicrophone Quality: Acceptable for regular calls.\nSound Quality: Clear sound with decent punch.\nGreat budget ANC headphones from Sony. Battery lasts forever.', 'VISIBLE', DATEADD(DAY, -33, GETDATE())),
(5, 3, 5, N'Wearing Comfort: Ultra-light, soft ear cushions.\nMicrophone Quality: Clear for Zoom meetings.\nSound Quality: Well-rounded audio with V1 processor tuning.\nBest lightweight headset for students and home office work.', 'VISIBLE', DATEADD(DAY, -45, GETDATE())),
(9, 3, 4, N'Wearing Comfort: Light on head, no clamping fatigue.\nMicrophone Quality: Reliable mic performance.\nSound Quality: Clean vocals and good treble response.\nSolid build quality for the price bracket.', 'VISIBLE', DATEADD(DAY, -28, GETDATE())),
(1, 4, 5, N'Wearing Comfort: Traditional studio fit, durable coiled cable.\nMicrophone Quality: Pro studio design without built-in mic.\nSound Quality: Exceptionally flat and transparent studio reference sound.\nA true industry workhorse for audio editing and mixing.', 'VISIBLE', DATEADD(DAY, -50, GETDATE())),
(6, 4, 5, N'Wearing Comfort: Classic studio headband, replaceable ear pads.\nMicrophone Quality: Pure audiophile monitoring headset.\nSound Quality: Precise instrument separation and accurate mids.\nEvery music producer should have one of these.', 'VISIBLE', DATEADD(DAY, -48, GETDATE())),
(5, 5, 5, N'Wearing Comfort: Breathable knit mesh canopy and memory foam cups.\nMicrophone Quality: Studio-grade beamforming microphones.\nSound Quality: Incomparable sound fidelity and spatial audio.\nThe build quality and digital crown control feel ultra-luxurious.', 'VISIBLE', DATEADD(DAY, -42, GETDATE())),
(7, 5, 4, N'Wearing Comfort: Super comfortable though on the heavier side.\nMicrophone Quality: Best transparency mode and call quality in class.\nSound Quality: Mesmerizing spatial audio with head tracking.\nPerfect companion for Apple ecosystem users.', 'VISIBLE', DATEADD(DAY, -32, GETDATE())),
(3, 6, 5, N'Wearing Comfort: Benchmark comfort, practically disappears on your head.\nMicrophone Quality: Clear and natural sounding mic.\nSound Quality: Balanced acoustic signature with smooth highs.\nBose reigns supreme when it comes to long flight comfort.', 'VISIBLE', DATEADD(DAY, -40, GETDATE())),
(4, 6, 4, N'Wearing Comfort: Extremely soft synthetic leather cushions.\nMicrophone Quality: Clear voice in quiet and moderate environments.\nSound Quality: Warm and non-fatiguing sound.\nQuiet mode blocks out office air conditioning effortlessly.', 'VISIBLE', DATEADD(DAY, -35, GETDATE())),
(8, 6, 5, N'Wearing Comfort: Super light clamping pressure.\nMicrophone Quality: Great for daily conference calls.\nSound Quality: Crisp and articulate soundstage.\nNever travel without them.', 'VISIBLE', DATEADD(DAY, -22, GETDATE())),
(1, 7, 5, N'Wearing Comfort: Luxurious padding, feels like clouds on ears.\nMicrophone Quality: Excellent voice pick-up with noise rejection.\nSound Quality: Immersive Audio mode brings movies and live concerts to life.\nThe spatial audio upgrade is truly a game changer.', 'VISIBLE', DATEADD(DAY, -30, GETDATE())),
(7, 7, 5, N'Wearing Comfort: Premium materials and perfect headband contour.\nMicrophone Quality: Highly articulate call quality.\nSound Quality: Deep subterranean bass with sparkling highs.\nBose flagship delivers on every promise.', 'VISIBLE', DATEADD(DAY, -20, GETDATE())),
(2, 9, 4, N'Wearing Comfort: Soft ear pads with foldable arms.\nMicrophone Quality: Good microphone for daily calls.\nSound Quality: Signature JBL Pure Bass with punchy dynamic energy.\nUp to 70 hours of battery means I rarely plug it in.', 'VISIBLE', DATEADD(DAY, -35, GETDATE())),
(4, 9, 4, N'Wearing Comfort: Snug fit, lightweight construction.\nMicrophone Quality: Clear voice transmission.\nSound Quality: Thumping bass response that energetic music lovers want.\nIncredible value for money.', 'VISIBLE', DATEADD(DAY, -25, GETDATE())),
(10, 9, 4, N'Wearing Comfort: Comfortable on ears, easy to adjust.\nMicrophone Quality: Works reliably for phone calls.\nSound Quality: Energetic V-shaped profile.\nAdaptive ANC works very well in street noise.', 'VISIBLE', DATEADD(DAY, -18, GETDATE())),
(1, 12, 5, N'Wearing Comfort: Robust headband and swiveling earcups for 1-ear monitoring.\nMicrophone Quality: Pure studio wired monitor without built-in mic.\nSound Quality: Legendary clarity, tight bass, and honest midrange.\nA must-have standard for audio recording and critical listening.', 'VISIBLE', DATEADD(DAY, -32, GETDATE())),
(2, 12, 5, N'Wearing Comfort: Tight initial clamp that relaxes comfortably over time.\nMicrophone Quality: Wired pro monitoring headphone.\nSound Quality: Crystal clear definition in every instrument track.\nBuilt like a tank and easily lasts for many years.', 'VISIBLE', DATEADD(DAY, -26, GETDATE())),
(3, 12, 5, N'Wearing Comfort: Comfortable pads with detachable cable system.\nMicrophone Quality: Pro studio gear.\nSound Quality: Unforgiving detail revelation, perfect for mastering.\nUnbeatable audio fidelity in this price range.', 'VISIBLE', DATEADD(DAY, -20, GETDATE())),
(1, 15, 5, N'Wearing Comfort: Velour ear pads are heavenly for hours of wear.\nMicrophone Quality: Audiophile open-back wired cans.\nSound Quality: Incredibly wide soundstage, surgical imaging and natural timbre.\nClassical and acoustic music sound breathtaking on these.', 'VISIBLE', DATEADD(DAY, -28, GETDATE())),
(5, 15, 5, N'Wearing Comfort: Breathable open-back design keeps ears cool.\nMicrophone Quality: Audiophile studio design.\nSound Quality: Flat, linear bass extension and crystal clear vocals.\nOne of the best open-back headphones under $200.', 'VISIBLE', DATEADD(DAY, -19, GETDATE())),
(2, 16, 5, N'Wearing Comfort: Luxurious padding, sits gently around ears.\nMicrophone Quality: 4-mic digital beamforming array captures clear speech.\nSound Quality: Audiophile-grade dynamic drivers, warm rich bass and airy highs.\n60 hours battery life with ANC on is unmatched by any competitor.', 'VISIBLE', DATEADD(DAY, -24, GETDATE())),
(8, 16, 5, N'Wearing Comfort: Super soft headband and earcups.\nMicrophone Quality: Crystal clear call performance indoors and out.\nSound Quality: Deep, impactful bass and silky smooth vocals.\nThe companion app sound personalization is phenomenal.', 'VISIBLE', DATEADD(DAY, -14, GETDATE())),
(1, 26, 5, N'Wearing Comfort: Much smaller and more ergonomic than WF-1000XM4.\nMicrophone Quality: Bone conduction sensor isolates voice in noisy crowds.\nSound Quality: Dynamic Driver X delivers rich vocals and deep sub-bass.\nThe pinnacle of true wireless noise cancellation.', 'VISIBLE', DATEADD(DAY, -22, GETDATE())),
(7, 26, 5, N'Wearing Comfort: Foam ear tips seal completely without ear fatigue.\nMicrophone Quality: Excellent wind noise reduction during phone calls.\nSound Quality: Hi-Res wireless audio with LDAC sounds pristine.\nSony perfected their flagship earbuds with the XM5.', 'VISIBLE', DATEADD(DAY, -15, GETDATE())),
(1, 29, 5, N'Wearing Comfort: Vent system equalizes pressure, extremely comfortable.\nMicrophone Quality: Industry benchmark for voice calls and Siri commands.\nSound Quality: Powerful adaptive EQ and mind-blowing spatial audio.\nAdaptive Audio seamlessly blends ANC with transparency.', 'VISIBLE', DATEADD(DAY, -18, GETDATE())),
(2, 29, 5, N'Wearing Comfort: Tiny, lightweight and stays firmly in ear.\nMicrophone Quality: Best transparency mode hands down.\nSound Quality: Clean, rich sound with noticeable bass improvement over gen 1.\nUSB-C case makes charging so convenient.', 'VISIBLE', DATEADD(DAY, -11, GETDATE())),
(1, 44, 5, N'Wearing Comfort: Cloud-like silicone tips, great fit for jogging.\nMicrophone Quality: 6-mic array filters background noise effectively.\nSound Quality: ACAA 3.0 dual dynamic drivers deliver sparkling clarity.\nBuilt-in heart rate tracking in soundcore app is a neat bonus!', 'VISIBLE', DATEADD(DAY, -12, GETDATE())),
(3, 44, 5, N'Wearing Comfort: Ergonomic stem design sits comfortably for hours.\nMicrophone Quality: Clean and loud audio during phone calls.\nSound Quality: Dual driver separation rivals earbuds twice the price.\nAnker packed flagship features at an unbeatable price point.', 'VISIBLE', DATEADD(DAY, -8, GETDATE()));
GO

-- =========================================================
-- REVIEW IMAGES (Sample verified photo attachments)
-- =========================================================
INSERT INTO ReviewImages (ReviewID, ImageURL, PublicID, IsPrimary, CreatedAt)
SELECT r.ReviewID,
       'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=600&auto=format&fit=crop&q=80',
       'review_photos/sample_hp_01',
       1,
       r.CreatedAt
FROM Reviews r
WHERE r.ProductID = 1 AND r.CustomerID = 1;

INSERT INTO ReviewImages (ReviewID, ImageURL, PublicID, IsPrimary, CreatedAt)
SELECT r.ReviewID,
       'https://images.unsplash.com/photo-1583394838336-acd977736f90?w=600&auto=format&fit=crop&q=80',
       'review_photos/sample_hp_02',
       1,
       r.CreatedAt
FROM Reviews r
WHERE r.ProductID = 12 AND r.CustomerID = 2;
GO

-- =========================================================
-- FAVORITES / WISHLIST (3-4 wishlist products per customer)
-- =========================================================
INSERT INTO Favorites (CustomerID, ProductID, CreatedAt)
VALUES
(1,  5,  DATEADD(DAY, -15, GETDATE())),
(1,  8,  DATEADD(DAY, -12, GETDATE())),
(1,  16, DATEADD(DAY, -10, GETDATE())),

(2,  5,  DATEADD(DAY, -20, GETDATE())),
(2,  7,  DATEADD(DAY, -18, GETDATE())),
(2,  26, DATEADD(DAY, -5,  GETDATE())),

(3,  1,  DATEADD(DAY, -25, GETDATE())),
(3,  5,  DATEADD(DAY, -22, GETDATE())),
(3,  16, DATEADD(DAY, -14, GETDATE())),

(4,  7,  DATEADD(DAY, -30, GETDATE())),
(4,  16, DATEADD(DAY, -28, GETDATE())),
(4,  26, DATEADD(DAY, -15, GETDATE())),

(5,  1,  DATEADD(DAY, -16, GETDATE())),
(5,  6,  DATEADD(DAY, -14, GETDATE())),
(5,  29, DATEADD(DAY, -8,  GETDATE())),

(6,  1,  DATEADD(DAY, -35, GETDATE())),
(6,  7,  DATEADD(DAY, -25, GETDATE())),
(6,  16, DATEADD(DAY, -18, GETDATE())),

(7,  1,  DATEADD(DAY, -28, GETDATE())),
(7,  6,  DATEADD(DAY, -21, GETDATE())),
(7,  28, DATEADD(DAY, -12, GETDATE())),

(8,  1,  DATEADD(DAY, -32, GETDATE())),
(8,  5,  DATEADD(DAY, -24, GETDATE())),
(8,  26, DATEADD(DAY, -16, GETDATE())),

(9,  1,  DATEADD(DAY, -22, GETDATE())),
(9,  6,  DATEADD(DAY, -19, GETDATE())),
(9,  29, DATEADD(DAY, -10, GETDATE())),

(10, 5,  DATEADD(DAY, -26, GETDATE())),
(10, 7,  DATEADD(DAY, -18, GETDATE())),
(10, 26, DATEADD(DAY, -7,  GETDATE()));
GO

-- =========================================================
-- USER BEHAVIORS (Browsing & purchasing logs for AI models)
-- =========================================================
INSERT INTO UserBehaviors (CustomerID, ProductID, BehaviorType, SearchKeyword, CreatedAt)
SELECT o.CustomerID, oi.ProductID, 'PURCHASE', NULL, o.OrderDate
FROM OrderItems oi
JOIN Orders o ON oi.OrderID = o.OrderID;

INSERT INTO UserBehaviors (CustomerID, ProductID, BehaviorType, SearchKeyword, CreatedAt)
SELECT f.CustomerID, f.ProductID, 'FAVORITE', NULL, f.CreatedAt
FROM Favorites f;

INSERT INTO UserBehaviors (CustomerID, ProductID, BehaviorType, SearchKeyword, CreatedAt)
SELECT ci.CartID, ci.ProductID, 'CART', NULL, ci.AddedAt
FROM CartItems ci;

INSERT INTO UserBehaviors (CustomerID, ProductID, BehaviorType, SearchKeyword, CreatedAt)
VALUES
(1, 1, 'VIEW', N'Sony WH-1000XM5', DATEADD(DAY, -62, GETDATE())),
(1, 4, 'VIEW', N'Studio headphones', DATEADD(DAY, -61, GETDATE())),
(2, 1, 'VIEW', N'Noise cancelling headphones', DATEADD(DAY, -66, GETDATE())),
(3, 2, 'VIEW', N'Sony headphones', DATEADD(DAY, -71, GETDATE())),
(4, 1, 'VIEW', N'Sony XM5', DATEADD(DAY, -76, GETDATE())),
(5, 5, 'VIEW', N'AirPods Max', DATEADD(DAY, -81, GETDATE()));
GO
