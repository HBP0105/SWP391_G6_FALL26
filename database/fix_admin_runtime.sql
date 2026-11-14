USE HeadphoneSalesDB;
GO

IF OBJECT_ID('dbo.AIConfigurations', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.AIConfigurations (
        ConfigID INT IDENTITY(1,1) PRIMARY KEY,
        SimilarityWeight DECIMAL(3,2) NOT NULL DEFAULT 0.60,
        BehaviorWeight DECIMAL(3,2) NOT NULL DEFAULT 0.40,
        MinSimilarityThreshold DECIMAL(3,2) NOT NULL DEFAULT 0.50,
        TopKLimit INT NOT NULL DEFAULT 8,
        FallbackStrategy VARCHAR(50) NOT NULL DEFAULT 'HEURISTIC',
        AlgorithmStatus VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
        UpdatedAt DATETIME2 NOT NULL DEFAULT GETDATE(),
        UpdatedBy INT NULL,
        CONSTRAINT CK_AIConfigurations_SimilarityWeight
            CHECK (SimilarityWeight BETWEEN 0.0 AND 1.0),
        CONSTRAINT CK_AIConfigurations_BehaviorWeight
            CHECK (BehaviorWeight BETWEEN 0.0 AND 1.0),
        CONSTRAINT CK_AIConfigurations_MinThreshold
            CHECK (MinSimilarityThreshold BETWEEN 0.0 AND 1.0),
        CONSTRAINT CK_AIConfigurations_TopKLimit CHECK (TopKLimit > 0),
        CONSTRAINT FK_AIConfigurations_Staff
            FOREIGN KEY (UpdatedBy) REFERENCES dbo.Staff(StaffID) ON DELETE SET NULL
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.AIConfigurations)
BEGIN
    INSERT INTO dbo.AIConfigurations
        (SimilarityWeight, BehaviorWeight, MinSimilarityThreshold,
         TopKLimit, FallbackStrategy, AlgorithmStatus)
    VALUES (0.60, 0.40, 0.50, 8, 'HEURISTIC', 'ACTIVE');
END
GO
