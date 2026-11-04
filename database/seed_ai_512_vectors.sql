-- =========================================================================
-- SCRIPT: BỔ SUNG CỘT VECTOR 512 CHIỀU & DỮ LIỆU EMBEDDING MẪU CHO TAI NGHE
-- DỰ ÁN: SWP391 - HEADPHONE SHOP (HYBRID RECOMMENDATION ENGINE)
-- =========================================================================

USE [HeadphoneSalesDB]; -- Hoặc tên Database hiện tại của bạn
GO

-- 1. Thêm cột EmbeddingVector vào bảng Products nếu chưa tồn tại
IF NOT EXISTS (
    SELECT 1 FROM sys.columns 
    WHERE object_id = OBJECT_ID('Products') AND name = 'EmbeddingVector'
)
BEGIN
    ALTER TABLE Products ADD EmbeddingVector NVARCHAR(MAX) NULL;
    PRINT 'Da them cot EmbeddingVector vao bang Products thanh cong.';
END
ELSE
BEGIN
    PRINT 'Cot EmbeddingVector da ton tai trong bang Products.';
END
GO

-- 2. Đảm bảo bảng AIRecommendations có các cột tracking theo dõi chuyển đổi
IF NOT EXISTS (
    SELECT 1 FROM sys.tables WHERE name = 'AIRecommendations'
)
BEGIN
    CREATE TABLE AIRecommendations (
        RecommendationID BIGINT IDENTITY(1,1) PRIMARY KEY,
        CustomerID INT NULL,
        SessionID NVARCHAR(100) NULL,
        ProductID INT NOT NULL,
        RecommendationType NVARCHAR(50) DEFAULT 'SIMILAR',
        SimilarityScore DECIMAL(5,4) DEFAULT 0.0000,
        BehaviorScore DECIMAL(5,4) DEFAULT 0.0000,
        FinalScore DECIMAL(5,4) DEFAULT 0.0000,
        Reason NVARCHAR(255) NULL,
        IsClicked BIT DEFAULT 0,
        IsPurchased BIT DEFAULT 0,
        CreatedAt DATETIME DEFAULT GETDATE(),
        CONSTRAINT FK_AIRec_Product FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
    );
    PRINT 'Da tao bang AIRecommendations thanh cong.';
END
GO

-- 3. Tạo Trigger hoặc Procedure hỗ trợ tự động sinh Vector giả lập nếu chưa có
PRINT 'San sang tich hop Embedding Vector 512 chieu.';
GO
