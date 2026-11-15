USE HeadphoneSalesDB;
GO

IF COL_LENGTH('dbo.Orders', 'CancelReason') IS NULL
BEGIN
    ALTER TABLE dbo.Orders
    ADD CancelReason NVARCHAR(500) NULL;
END
GO

IF COL_LENGTH('dbo.Products', 'ImageURL') IS NULL
BEGIN
    ALTER TABLE dbo.Products
    ADD ImageURL VARCHAR(500) NULL;
END
GO

IF COL_LENGTH('dbo.Products', 'Weight') IS NULL
BEGIN
    ALTER TABLE dbo.Products
    ADD Weight DECIMAL(7,2) NULL;
END
GO

IF COL_LENGTH('dbo.Products', 'EmbeddingVector') IS NULL
BEGIN
    ALTER TABLE dbo.Products
    ADD EmbeddingVector NVARCHAR(MAX) NULL;
END
GO

IF OBJECT_ID('dbo.ProductImages', 'U') IS NOT NULL
BEGIN
    UPDATE p
    SET p.ImageURL = pi.ImageURL
    FROM dbo.Products p
    JOIN dbo.ProductImages pi ON p.ProductID = pi.ProductID
    WHERE p.ImageURL IS NULL;
END
GO

SELECT 'Products' AS TableName, COUNT(*) AS [RowCount] FROM dbo.Products
UNION ALL
SELECT 'Vouchers', COUNT(*) FROM dbo.Vouchers
UNION ALL
SELECT 'Orders', COUNT(*) FROM dbo.Orders;
GO
