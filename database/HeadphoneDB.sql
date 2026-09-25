IF DB_ID('HeadphoneSalesDB') IS NULL
BEGIN
    CREATE DATABASE HeadphoneSalesDB;
END
GO

USE HeadphoneSalesDB;
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


INSERT INTO Roles (RoleName, Description)
VALUES
('ADMIN', 'System administrator'),
('MANAGER', 'Store manager');
GO



